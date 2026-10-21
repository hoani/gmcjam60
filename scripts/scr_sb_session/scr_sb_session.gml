/// @function sb_session_create()
/// @description Makes a new, uninitialized Scoreboat session.
/// Use when you need to authenticate multiple API keys at once
/// Does not enable the created session. Pass it to sb_session_use first
function sb_session_create(){
	return new __SbClass();
}

/// @function sb_session_use([session])
/// @description Makes every sb_* call from now on act on this session. 
///   To return to the default session, pass in nothing. Requests already sent keep the
///   session they were made with. Returns the session that was current, so a
///   caller can put it back:
///       var new_session = sb_session_create()
///       var _previous = sb_session_use(new_session);
///       sb_init(...);
///       sb_session_use(_previous);
function sb_session_use(_session = undefined){
	var _previous = global.__SbCurrent;
	if(is_undefined(_session)) _session = global.__SbInst;
	else if(!is_instanceof(_session, __SbClass)) throw "Scoreboat: sb_session_use expects a session from sb_session_create()";
	global.__SbCurrent = _session;
	return _previous;
}

/// @function sb_session_current()
/// @description The session every sb_* call acts on right now: the default one,
///   or whichever was last passed to sb_session_use.
function sb_session_current(){
	return global.__SbCurrent;
}
