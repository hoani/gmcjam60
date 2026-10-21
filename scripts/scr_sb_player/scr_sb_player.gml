// Players: the people playing the game, as Scoreboat knows them.

/// @ignore
function __sb_player_endpoint(_session, _name){
	return "gm/" + __sb_url_encode(_session.gid) + "/player/" + _name + "/";
}

/// What was saved for this game under _key, or "" when nothing was.
/// @ignore
function __sb_player_saved(_session, _key){
	ini_open(_sb_player_store);
	var _value = ini_read_string(_session.gid, _key, "");
	ini_close();
	return _value;
}

/// Saves _value for this game under _key. An empty string removes it.
/// @ignore
function __sb_player_save(_session, _key, _value){
	ini_open(_sb_player_store);
	if(_value == "") ini_key_delete(_session.gid, _key);
	else ini_write_string(_session.gid, _key, _value);
	ini_close();
}

/// Sends a call that answers with a signed-in player, and makes that player
/// the session's. The callbacks get the player.
/// @ignore
function __sb_player_sign_in(_session, _name, _body, _on_success, _on_fail){
	var _accept = method({ session: _session }, function(_data){
		session.accept_player(_data);
		return _data.player;
	});
	var _request = new __SbRequest();
	_request.success(_on_success).fail(_on_fail);
	(new __SbApiCall(_request, _session, "POST", __sb_player_endpoint(_session, _name), _body, _accept)).start();
	return _request;
}

/// Sends a call about the signed-in player that answers with that player.
/// @ignore
function __sb_player_update(_method, _name, _body, _on_success, _on_fail){
	var _session = __sb_session();
	var _accept = method({ session: _session }, function(_player){
		if(!is_undefined(session.player) && session.player.id == _player.id) session.player = _player;
		return _player;
	});
	return __sb_api(_method, __sb_player_endpoint(_session, _name), _body, _accept, _on_success, _on_fail);
}

/// @function sb_player()
/// @description The signed-in player, or undefined when nobody is:
///   { id, display_name, username, email, email_verified, guest, created }.
///   id is public: it is what score tables show and what sb_leaderboard_scores
///   takes for its player and around options.
function sb_player(){
	return __sb_session().player;
}

/// @function sb_player_signed_in()
/// @description True while a player is signed in on the current session.
function sb_player_signed_in(){
	return !is_undefined(__sb_session().player);
}

/// @function sb_player_guest([on_success], [on_fail])
/// @description Signs this device in as a guest: a player with no account,
///   known only by a secret Scoreboat hands out the first time and the library
///   saves to disk. The same device is the same guest every time after that.
///   on_success(player) is called with the player, as sb_player() returns it.
///   on_fail(error) is called with { stage, http_status, message }.
///   Returns a request handle: .success(fn) and .fail(fn) can be chained on it.
///   Fails straight away if the session has not finished sb_init.
///   A saved secret that is refused is kept. If the guest has since become an
///   account or been removed, call sb_player_guest_forget() to start afresh.
function sb_player_guest(_on_success = undefined, _on_fail = undefined){
	var _session = __sb_session();
	var _body = {};
	var _secret = __sb_player_saved(_session, "guest_secret");
	if(_secret != "") _body.secret = _secret;
	return __sb_player_sign_in(_session, "guest", _body, _on_success, _on_fail);
}

/// @function sb_player_guest_forget()
/// @description Throws away this device's saved guest secret, so that the next
///   sb_player_guest() makes a new guest. The old guest and their scores stay
///   on the server, but nothing can sign in as them again.
function sb_player_guest_forget(){
	__sb_player_save(__sb_session(), "guest_secret", "");
}

/// @function sb_player_register(username, password, [options], [on_success], [on_fail])
/// @description Makes an account and signs in to it. Called while signed in as
///   a guest it turns that guest into the account, keeping their scores and
///   everything else they have. The guest secret stops working once it does.
///   options is a struct, every member optional:
///     email          Lets the player reset a forgotten password.
///     display_name   The name shown to other players. The username if left out.
function sb_player_register(_username, _password, _options = undefined, _on_success = undefined, _on_fail = undefined){
	var _session = __sb_session();
	var _body = { username: _username, password: _password };
	if(is_struct(_options)){
		if(!is_undefined(_options[$ "email"])) _body.email = _options.email;
		if(!is_undefined(_options[$ "display_name"])) _body.display_name = _options.display_name;
	}
	// A guest who registers becomes the account, and their secret is spent.
	var _was_guest = !is_undefined(_session.player) && _session.player.guest;
	var _forget_guest = method({ session: _session, was_guest: _was_guest }, function(_player){
		if(was_guest) __sb_player_save(session, "guest_secret", "");
	});
	return __sb_player_sign_in(_session, "register", _body, _forget_guest, undefined).success(_on_success).fail(_on_fail);
}

/// @function sb_player_login(login, password, [on_success], [on_fail])
/// @description Signs in to an account. login is its username or its email.
///   on_success(player), on_fail(error) and the return value are as for
///   sb_player_guest. Wrong details fail with HTTP 403, and too many wrong
///   tries in a row with HTTP 429 for a while.
function sb_player_login(_login, _password, _on_success = undefined, _on_fail = undefined){
	return __sb_player_sign_in(__sb_session(), "login", { login: _login, password: _password }, _on_success, _on_fail);
}

/// @function sb_player_login_ticket(ticket, [on_success], [on_fail])
/// @description Signs in with a ticket from the game's own server, for games
///   that authenticate their players themselves. The server gets the ticket
///   from Scoreboat with a key the game does not ship with; it works once and
///   only for a couple of minutes.
///   on_success(player), on_fail(error) and the return value are as for
///   sb_player_guest.
function sb_player_login_ticket(_ticket, _on_success = undefined, _on_fail = undefined){
	return __sb_player_sign_in(__sb_session(), "login", { ticket: _ticket }, _on_success, _on_fail);
}

/// @function sb_player_resume([on_success], [on_fail])
/// @description Signs back in as whoever was signed in when the game last ran,
///   without asking them for anything. Call it once sb_init has succeeded.
///   Fails straight away with HTTP -1 when nobody was, and with HTTP 403 when
///   their sign-in has since ended. Either way, ask them to sign in again.
///   on_success(player), on_fail(error) and the return value are as for
///   sb_player_guest.
function sb_player_resume(_on_success = undefined, _on_fail = undefined){
	var _session = __sb_session();
	var _refresh_token = __sb_player_saved(_session, "refresh_token");
	if(_refresh_token == ""){
		var _request = new __SbRequest();
		_request.fail(_on_fail);
		_request.__reject({ stage: "request", http_status: -1, message: "No saved sign-in" });
		return _request;
	}
	// A refresh answers without the refresh token it was given, so the session
	// is told about it here.
	var _remember = method({ session: _session, refresh_token: _refresh_token }, function(_player){
		session.player_refresh_token = refresh_token;
	});
	var _forget = method({ session: _session }, function(_error){
		if(_error.http_status == 403) __sb_player_save(session, "refresh_token", "");
	});
	return __sb_player_sign_in(_session, "refresh", { refresh_token: _refresh_token }, _remember, _forget)
		.success(_on_success).fail(_on_fail);
}

/// @function sb_player_logout([on_success], [on_fail])
/// @description Signs the player out. The library forgets them at once, so
///   sb_player() is undefined as soon as this returns, whatever the server
///   goes on to say. A guest can come back with sb_player_guest().
///   on_success(result) is called with { signed_out }. on_fail(error) and the
///   return value are as for sb_player_guest.
function sb_player_logout(_on_success = undefined, _on_fail = undefined){
	var _session = __sb_session();
	if(is_undefined(_session.player)){
		var _request = new __SbRequest();
		_request.success(_on_success);
		_request.__resolve({ signed_out: true });
		return _request;
	}
	// Sent with the player's token, which is then dropped.
	var _request = __sb_api("POST", __sb_player_endpoint(_session, "logout"), {}, undefined, _on_success, _on_fail);
	_session.clear_player();
	return _request;
}

/// @function sb_player_rename(display_name, [on_success], [on_fail])
/// @description Changes the name the signed-in player is shown under. Entries
///   already on a leaderboard keep the name they were set with.
///   on_success(player), on_fail(error) and the return value are as for
///   sb_player_guest.
function sb_player_rename(_display_name, _on_success = undefined, _on_fail = undefined){
	return __sb_player_update("PATCH", "me", { display_name: _display_name }, _on_success, _on_fail);
}

/// @function sb_player_password_forgot(login, [on_success], [on_fail])
/// @description Mails a reset code to the account login names, if there is one
///   and it has an email address. on_success(result) is called with { sent }
///   either way, so that nothing is given away about which accounts exist.
///   on_fail(error) and the return value are as for sb_player_guest.
function sb_player_password_forgot(_login, _on_success = undefined, _on_fail = undefined){
	return __sb_api("POST", __sb_player_endpoint(__sb_session(), "password/forgot"), { login: _login }, undefined, _on_success, _on_fail);
}

/// @function sb_player_password_reset(login, code, password, [on_success], [on_fail])
/// @description Sets a new password with the code that was mailed. The player
///   is signed out everywhere and has to sign in with it.
///   on_success(result) is called with { reset }. on_fail(error) and the return
///   value are as for sb_player_guest.
function sb_player_password_reset(_login, _code, _password, _on_success = undefined, _on_fail = undefined){
	var _body = { login: _login, code: _code, password: _password };
	return __sb_api("POST", __sb_player_endpoint(__sb_session(), "password/reset"), _body, undefined, _on_success, _on_fail);
}

/// @function sb_player_email_verify([code], [on_success], [on_fail])
/// @description Confirms the signed-in player's email address. With no code it
///   mails them one, and on_success(result) is called with { sent }. With the
///   code they typed in, on_success(player) is called with the player, whose
///   email_verified is now true.
///   on_fail(error) and the return value are as for sb_player_guest.
function sb_player_email_verify(_code = undefined, _on_success = undefined, _on_fail = undefined){
	if(is_undefined(_code)){
		return __sb_api("POST", __sb_player_endpoint(__sb_session(), "email/verify"), {}, undefined, _on_success, _on_fail);
	}
	return __sb_player_update("POST", "email/verify", { code: _code }, _on_success, _on_fail);
}
