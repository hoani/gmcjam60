/// Unix time stamp.
/// Required as the GML timestamp is from 1899, not 1970
/// @ignore
function __sb_unix_now(){
	var _previous = date_get_timezone();
	date_set_timezone(timezone_utc);
	var _now = floor((date_current_datetime() - 25569) * 86400);
	date_set_timezone(_previous);
	return int64(_now);
}

/// Scoreboat authentication handshake state. 
/// internal class. Do not use directly.
/// Holds on to the session it was started for, so sb_session_use() while the
/// handshake is in flight cannot send the token to the wrong session.
/// With _is_refresh the session is already ready and keeps its current token
/// until the new one arrives, and a failure is retried later instead of
/// resetting the session.
/// @ignore
function __SbAuthFlow(_request, _session, _is_refresh = false) constructor {
	request = _request;
	session = _session;
	is_refresh = _is_refresh;
	stage = "challenge";
	info = undefined;
	player_refresh_token = undefined;

	start = function(){
		session.flow = self;
		global.__SbTransport.send("auth/jwt/challenge/", session.auth_headers(), undefined, on_challenge);
	}

	/// True once the session was reset or started over while this was in flight.
	is_stale = function(){
		return session.flow != self;
	}

	supersede = function(){
		request.__reject({ stage: stage, http_status: -1, message: "Superseded by a newer sb_init" });
	}

	on_challenge = function(_status, _data){
		if(is_stale()) return supersede();
		if(_status != 201 || !is_struct(_data)) return reject(_status, _data);
		if(_data[$ "algorithm"] != "hmac-sha256"){
			return reject(_status, { error: "Unsupported key algorithm: " + string(_data[$ "algorithm"]) });
		}

		var _unix_ts = __sb_unix_now();
		// No permissions named, so the token gets everything the key holds.
		// Be *very* careful here to avoid overreach, but given I am expecting most people to just use the game_client service key role I think this ought to be fine[?]
		var _message = __sb_build_message(_data.request_id, _data.nonce, _unix_ts, undefined);
		var _body = {
			request_id: _data.request_id,
			challenge: __sb_proof_hmac(session.secret, _message),
			unix_ts: _unix_ts,
		};

		stage = "redeem";
		global.__SbTransport.send("auth/jwt/redeem/", session.auth_headers(), _body, on_redeem);
	}

	on_redeem = function(_status, _data){
		if(is_stale()) return supersede();
		if(_status != 200 || !is_struct(_data) || !is_string(_data[$ "token"])) return reject(_status, _data);

		session.accept_token(_data);
		session.flow = undefined;
		info = {
			expires_at: _data[$ "expires_at"],
			permissions: _data[$ "permissions"],
			declined: _data[$ "declined"],
		};
		if(is_undefined(session.player_refresh_token)) return request.__resolve(info);

		// The player's token was made from the key's old one, so it is renewed
		// along with it before anybody waiting on this refresh carries on.
		stage = "player";
		player_refresh_token = session.player_refresh_token;
		global.__SbTransport.send(__sb_player_endpoint(session, "refresh"), session.key_headers(),
			{ refresh_token: player_refresh_token }, on_player);
	}

	on_player = function(_status, _data){
		// Signed out, or signed in as somebody else, while this was in flight.
		if(session.player_refresh_token == player_refresh_token){
			if(_status == 200 && is_struct(_data) && is_string(_data[$ "token"])) session.accept_player(_data);
			// Refused: the sign-in has ended on the server. A network error
			// instead leaves the player as they are, to be renewed next time.
			else if(_status == 401 || _status == 403) session.clear_player();
		}
		request.__resolve(info);
	}

	/* An initial handshake goes back to the uninitialized state first, so a fail
		callback that looks at sb_ready() or calls sb_init() again sees a clean
		library. A refresh keeps the credentials and tries again with a growing
		wait: the token is good until it expires, and a 4xx cannot be told apart
		from a transient one (a stale challenge and a revoked key are both 403).
	*/
	reject = function(_status, _data){
		var _message = __sb_error_message(_status, _data);

		if(is_refresh){
			session.flow = undefined;
			session.refresh_request = undefined;
			session.refresh_failures++;
			session.refresh_at = __sb_unix_now() + min(_sb_refresh_max_backoff, 30 * power(2, session.refresh_failures - 1));
		} else {
			session.reset();
		}
		request.__reject({ stage: stage, http_status: _status, message: _message });
	}
}
