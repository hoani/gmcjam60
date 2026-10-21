/// A number the way the server wants it. string() alone rounds to two decimal
/// places, and the server refuses more than six.
/// @ignore
function __sb_decimal_string(_value){
	if(is_real(_value) && frac(_value) != 0) return string_format(_value, 0, 6);
	return string(_value);
}

/// Turns a struct into "?a=1&b=2". Undefined values are left out.
/// @ignore
function __sb_query(_params){
	if(!is_struct(_params)) return "";
	var _query = "";
	var _names = struct_get_names(_params);
	for(var _i = 0; _i < array_length(_names); _i++){
		var _value = _params[$ _names[_i]];
		if(is_undefined(_value)) continue;
		_query += (_query == "") ? "?" : "&";
		_query += __sb_url_encode(_names[_i]) + "=" + __sb_url_encode(__sb_decimal_string(_value));
	}
	return _query;
}

/// The server sends scores as decimal strings. Games want numbers.
/// @ignore
function __sb_score_result(_score){
	if(is_string(_score[$ "score"])) _score.score = real(_score.score);
	if(is_string(_score[$ "secondary_score"])) _score.secondary_score = real(_score.secondary_score);
	return _score;
}

/// @ignore
function __sb_scores_result(_page){
	var _scores = _page[$ "scores"];
	if(is_array(_scores)){
		for(var _i = 0; _i < array_length(_scores); _i++){
			__sb_score_result(_scores[_i]);
		}
	}
	return _page;
}

/// A leaderboard's score bounds come as decimal strings too.
/// @ignore
function __sb_leaderboard_result(_leaderboard){
	if(is_string(_leaderboard[$ "min_score"])) _leaderboard.min_score = real(_leaderboard.min_score);
	if(is_string(_leaderboard[$ "max_score"])) _leaderboard.max_score = real(_leaderboard.max_score);
	return _leaderboard;
}

/// @function sb_leaderboard_details(leaderboard_id, [on_success], [on_fail])
/// @description Gets a leaderboard's settings. on_success(leaderboard) is called
///   with { id, name, description, game, ordering, secondary_ordering, unique,
///   min_score, max_score, entries }. min_score and max_score are the lowest and
///   highest score the leaderboard accepts, or not set when it has no such
///   bound: a submit outside them fails. on_fail(error) is called with { stage, http_status, message }.
///   Returns a request handle: .success(fn) and .fail(fn) can be chained on it.
///   Fails straight away if the session has not finished sb_init.
function sb_leaderboard_details(_leaderboard_id, _on_success = undefined, _on_fail = undefined){
	var _endpoint = "lb/" + __sb_url_encode(_leaderboard_id) + "/";
	return __sb_api("GET", _endpoint, undefined, __sb_leaderboard_result, _on_success, _on_fail);
}

/// @function sb_leaderboard_scores(leaderboard_id, [options], [on_success], [on_fail])
/// @description Reads the score table. on_success(page) is called with
///   { leaderboard, count, offset, limit, next_offset, scores }, where each of
///   scores is { id, rank, player, player_name, score, secondary_score, added,
///   updated, extra_data }. player is the id of the player whose entry it is,
///   as in sb_player().id. next_offset is the offset of the next page, or not set on
///   the last one.
///   options is a struct, every member optional:
///     limit, offset, page   Pagination. limit is 50 unless given and at most
///                           200. page starts at 1 and overrides offset.
///     order                 "best" (default), "worst", "newest" or "oldest".
///     since, until          ISO date or datetime strings. Only scores set
///                           inside them count, and rank is counted among those.
///     player_name, min_score, max_score
///                           Narrow which entries come back. Their rank is still
///                           their place on the whole table.
///     player                A player's id. Only that player's entries.
///     around                A player's id. Returns the limit entries centred
///                           on that player's best one, and adds player_rank
///                           and player_score (that entry's id) to the page.
///   Entries of banned and deleted players are left out, and not ranked against.
///   on_fail(error) is called with { stage, http_status, message }.
///   Returns a request handle, like sb_leaderboard_details.
function sb_leaderboard_scores(_leaderboard_id, _options = undefined, _on_success = undefined, _on_fail = undefined){
	var _endpoint = "lb/" + __sb_url_encode(_leaderboard_id) + "/score/" + __sb_query(_options);
	return __sb_api("GET", _endpoint, undefined, __sb_scores_result, _on_success, _on_fail);
}

/// @function sb_leaderboard_submit(leaderboard_id, player_name, score, [options], [on_success], [on_fail])
/// @description Submits a score for the signed-in player. When nobody is
///   signed in, the device is signed in as a guest first (see sb_player_guest),
///   so a game with no accounts needs nothing but this call.
///   player_name is the name shown beside the entry. Pass "" to use the
///   player's display name.
///   on_success(entry) is called with the player's best entry on the board,
///   which need not be the one just sent:
///   { id, rank, player, player_name, score, secondary_score, added, updated,
///   extra_data, improved, submitted }. improved is whether this submission is
///   now their best. submitted is the id of the entry this call created, or
///   not set when it updated or lost to an existing one.
///   options is a struct, every member optional:
///     secondary_score   Breaks ties on score.
///     extra_data        Anything json_stringify can handle. Stored with the
///                       entry. At most 1 MB.
///   on_fail(error) is called with { stage, http_status, message }.
///   Returns a request handle, like sb_leaderboard_details.
function sb_leaderboard_submit(_leaderboard_id, _player_name, _score, _options = undefined, _on_success = undefined, _on_fail = undefined){
	// Scores go out as strings so that none of their decimals are lost on the way.
	var _body = { score: __sb_decimal_string(_score) };
	if(is_string(_player_name) && _player_name != "") _body.player_name = _player_name;
	if(is_struct(_options)){
		if(!is_undefined(_options[$ "secondary_score"])) _body.secondary_score = __sb_decimal_string(_options.secondary_score);
		if(!is_undefined(_options[$ "extra_data"])) _body.extra_data = _options.extra_data;
	}

	var _endpoint = "lb/" + __sb_url_encode(_leaderboard_id) + "/score/";
	var _session = __sb_session();
	if(!is_undefined(_session.player) || _session.state != SB_STATE.READY){
		return __sb_api("POST", _endpoint, _body, __sb_score_result, _on_success, _on_fail);
	}

	// Nobody is signed in, so become a guest and then submit. The session is
	// held on to in case sb_session_use() is called in between.
	var _request = new __SbRequest();
	_request.success(_on_success).fail(_on_fail);
	var _pending = { request: _request, session: _session, endpoint: _endpoint, body: _body };
	var _submit = method(_pending, function(_player){
		__sb_api("POST", endpoint, body, __sb_score_result, on_done, on_failed, session);
	});
	_pending.on_done = method(_pending, function(_entry){ request.__resolve(_entry); });
	_pending.on_failed = method(_pending, function(_error){ request.__reject(_error); });

	var _body_guest = {};
	var _secret = __sb_player_saved(_session, "guest_secret");
	if(_secret != "") _body_guest.secret = _secret;
	__sb_player_sign_in(_session, "guest", _body_guest, _submit, _pending.on_failed);
	return _request;
}

/// @function sb_leaderboard_score_get(score_id, [on_success], [on_fail])
/// @description Gets a single score by its id. on_success(score) is called with
///   { id, player, player_name, score, secondary_score, added, updated,
///   extra_data }. There is no rank here: use sb_leaderboard_scores for that.
///   on_fail(error) is called with { stage, http_status, message }.
///   Returns a request handle, like sb_leaderboard_details.
function sb_leaderboard_score_get(_score_id, _on_success = undefined, _on_fail = undefined){
	var _endpoint = "score/" + __sb_url_encode(_score_id) + "/";
	return __sb_api("GET", _endpoint, undefined, __sb_score_result, _on_success, _on_fail);
}
