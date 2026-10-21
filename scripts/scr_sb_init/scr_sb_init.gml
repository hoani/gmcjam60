/// @function sb_init(game_id, key_prefix, secret, [on_success], [on_fail])
/// @description Authenticates against Scoreboat and gets the library ready.
///   on_success(info) is called with { expires_at, permissions, declined } once
///   sb_ready() is true. on_fail(error) is called with { stage, http_status,
///   message } after the library has gone back to the uninitialized state.
///   Returns a request handle: .success(fn) and .fail(fn) can be chained on it.
///   Calling it while an attempt is already running joins that attempt.
function sb_init(_game_id, _key_prefix, _secret, _on_success = undefined, _on_fail = undefined){
	var _sb = __sb_session();

	if(_sb.state == SB_STATE.AUTHENTICATING){
		return _sb.auth_request.success(_on_success).fail(_on_fail);
	}

	_sb.reset();
	_sb.gid = _game_id;
	_sb.key_prefix = _key_prefix;
	_sb.secret = _secret;
	_sb.state = SB_STATE.AUTHENTICATING;

	var _request = new __SbRequest();
	_request.success(_on_success).fail(_on_fail);
	_sb.auth_request = _request;

	var _flow = new __SbAuthFlow(_request, _sb);
	_flow.start();
	return _request;
}

/// @function sb_ready()
/// @description True when the current session holds a token that has not
///   expired. Tokens are refreshed automatically shortly before they do.
function sb_ready(){
	var _sb = __sb_session();
	return _sb.state == SB_STATE.READY && __sb_unix_now() < _sb.jwt_expires_at;
}

/// @function sb_refresh([on_success], [on_fail])
/// @description Gets a new token now instead of waiting for the automatic
///   refresh. Joins a refresh that is already running. Fails straight away if
///   the session has not finished sb_init. The old token stays in use until the
///   new one arrives, and a failed refresh leaves the session as it was.
function sb_refresh(_on_success = undefined, _on_fail = undefined){
	var _sb = __sb_session();
	if(_sb.state != SB_STATE.READY){
		var _request = new __SbRequest();
		_request.fail(_on_fail);
		_request.__reject({ stage: "refresh", http_status: -1, message: "Scoreboat is not initialized" });
		return _request;
	}
	return _sb.refresh().success(_on_success).fail(_on_fail);
}
