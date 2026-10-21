enum SB_STATE {
	UNINITIALIZED,
	AUTHENTICATING,
	READY,
}

/// Every session, so the listener can keep all of their tokens fresh.
global.__SbSessions = [];

/// __SbClass rerpesents one authenticated identity: credentials, token and state for a single API key.
/// Most games only ever use the default session. See sb_session_create() and
/// sb_session_use() for talking to Scoreboat with more than one key at once.
/// This is an internal class and is used by the sb_* functions to keep track of state.
/// Use the public facing sb_* functions instead.
/// @ignore
function __SbClass() constructor{
	// Credentials are kept for refreshing the token later.
	gid = "";
	key_prefix = "";
	secret = "";

	JWT = undefined;
	jwt_expires_at = undefined;
	state = SB_STATE.UNINITIALIZED;
	auth_request = undefined;

	// The handshake currently running for this session, if any. A flow that is
	// no longer this one has been superseded and must not touch the session.
	flow = undefined;
	refresh_request = undefined;
	refresh_at = 0;
	refresh_failures = 0;

	// The signed-in player, if any. Their token is the key's token with the
	// player added, and is what goes out while somebody is signed in.
	player = undefined;
	player_JWT = undefined;
	player_refresh_token = undefined;

	array_push(global.__SbSessions, self);

	reset = function(){
		gid = "";
		key_prefix = "";
		secret = "";
		JWT = undefined;
		jwt_expires_at = undefined;
		state = SB_STATE.UNINITIALIZED;
		auth_request = undefined;
		flow = undefined;
		refresh_request = undefined;
		refresh_at = 0;
		refresh_failures = 0;
		player = undefined;
		player_JWT = undefined;
		player_refresh_token = undefined;
	}

	/// Takes a sign-in or player refresh response and makes it the session's
	/// player. What the player needs to come back next run is saved to disk.
	accept_player = function(_data){
		player = _data.player;
		player_JWT = _data.token;
		if(is_string(_data[$ "refresh_token"])){
			player_refresh_token = _data.refresh_token;
			__sb_player_save(self, "refresh_token", player_refresh_token);
		}
		if(is_string(_data[$ "secret"])) __sb_player_save(self, "guest_secret", _data.secret);
	}

	/// Forgets the signed-in player, and their saved sign-in with them. A
	/// guest's secret is kept: it is the only way back to that guest.
	clear_player = function(){
		player = undefined;
		player_JWT = undefined;
		player_refresh_token = undefined;
		__sb_player_save(self, "refresh_token", "");
	}

	/// Takes a redeem response and makes it the session's token.
	accept_token = function(_data){
		JWT = _data.token;
		jwt_expires_at = _data[$ "expires_at"];
		state = SB_STATE.READY;
		auth_request = undefined;
		refresh_request = undefined;
		refresh_failures = 0;
		// The floor keeps a very short token from being refreshed in a tight loop.
		refresh_at = max(jwt_expires_at - _sb_refresh_margin, __sb_unix_now() + 30);
	}

	refresh = function(){
		if(!is_undefined(refresh_request)) return refresh_request;
		var _request = new __SbRequest();
		refresh_request = _request;
		(new __SbAuthFlow(_request, self, true)).start();
		return _request;
	}

	tick = function(_now){
		if(state != SB_STATE.READY || !is_undefined(refresh_request) || _now < refresh_at) return;
		refresh();
	}

	auth_headers = function(){
		var _headers = {};
		_headers[$ "X-API-Key"] = key_prefix;
		return _headers;
	}

	/// The token to send: the player's while somebody is signed in, else the key's.
	bearer = function(){
		return is_undefined(player_JWT) ? JWT : player_JWT;
	}

	api_headers = function(){
		var _headers = {};
		_headers[$ "Authorization"] = "Bearer " + bearer();
		return _headers;
	}

	/// Headers carrying the key's own token, whoever is signed in.
	key_headers = function(){
		var _headers = {};
		_headers[$ "Authorization"] = "Bearer " + JWT;
		return _headers;
	}
}

/// HTTP plumbing
/// Internal class.
/// @ignore
function __SbTransport() constructor{
	pending = {};

	send = function(_endpoint, _headers, _body, _on_done, _method = "POST"){
		ensure_listener();

		var _map = ds_map_create();
		_map[? "Content-Type"] = "application/json";
		var _names = struct_get_names(_headers);
		for(var _i = 0; _i < array_length(_names); _i++){
			_map[? _names[_i]] = _headers[$ _names[_i]];
		}

		var _payload = is_undefined(_body) ? "" : json_stringify(_body);
		var _id = http_request(_sb_host + _endpoint, _method, _map, _payload);
		ds_map_destroy(_map);

		if(_id < 0){
			_on_done(-1, undefined);
			return;
		}
		pending[$ string(_id)] = _on_done;
	}

	/// Sends a buffer to a full URL that is not the API's, such as the link an
	/// upload is given. Nothing of the session's goes with it: only the
	/// headers passed in. _on_done(http_status, data) as for send.
	send_raw = function(_url, _method, _headers, _buffer, _on_done){
		ensure_listener();

		var _map = ds_map_create();
		var _names = struct_get_names(_headers);
		for(var _i = 0; _i < array_length(_names); _i++){
			_map[? _names[_i]] = _headers[$ _names[_i]];
		}

		var _id = http_request(_url, _method, _map, _buffer);
		ds_map_destroy(_map);

		if(_id < 0){
			_on_done(-1, undefined);
			return;
		}
		pending[$ string(_id)] = _on_done;
	}

	/// Downloads a full URL into a file, which is the one way to receive bytes
	/// that are not text. _on_done(http_status, data) as for send; the bytes
	/// are in _target when the status is 200.
	fetch_file = function(_url, _target, _on_done){
		ensure_listener();

		var _id = http_get_file(_url, _target);
		if(_id < 0){
			_on_done(-1, undefined);
			return;
		}
		pending[$ string(_id)] = _on_done;
	}

	handle_async = function(_load){
		var _key = string(_load[? "id"]);
		if(!struct_exists(pending, _key)) return;

		var _status = _load[? "status"];
		if(_status == 1) return; // still downloading

		var _on_done = pending[$ _key];
		struct_remove(pending, _key);

		var _data = undefined;
		if(_status == 0){
			try {
				_data = json_parse(_load[? "result"]);
			} catch(_e){
				_data = undefined;
			}
		}
		_on_done((_status == 0) ? _load[? "http_status"] : -1, _data);
	}

	ensure_listener = function(){
		if(!instance_exists(scoreboat_network_listener_object)){
			instance_create_depth(0, 0, 0, scoreboat_network_listener_object);
		}
	}
}

global.__SbTransport = new __SbTransport();
global.__SbInst = new __SbClass();
global.__SbCurrent = global.__SbInst;

/// @ignore
function __sb_session(){
	return global.__SbCurrent;
}

//Check for token expiry. 
global.__SbLastTick = 0;
/// @ignore
function __sb_tick(){
	if(current_time - global.__SbLastTick < 1000) return;
	global.__SbLastTick = current_time;

	var _now = __sb_unix_now();
	for(var _i = 0; _i < array_length(global.__SbSessions); _i++){
		global.__SbSessions[_i].tick(_now);
	}
}
