// Datastores. Small JSON records under a key. The owner can expose fields for others to incr/set.

/// @ignore
function __sb_record_endpoint(_datastore_id, _key = undefined){
	var _endpoint = "ds/" + __sb_url_encode(_datastore_id) + "/records/";
	if(!is_undefined(_key)) _endpoint += __sb_url_encode(_key) + "/";
	return _endpoint;
}

/// @function sb_datastores([on_success], [on_fail])
/// @description Lists the game's datastores. on_success(result) gets { datastores: [{ id, name }] }.
function sb_datastores(_on_success = undefined, _on_fail = undefined){
	var _endpoint = "gm/" + __sb_url_encode(__sb_session().gid) + "/datastores/";
	return __sb_api("GET", _endpoint, undefined, undefined, _on_success, _on_fail);
}

/// @function sb_datastore_details(datastore_id, [on_success], [on_fail])
/// @description Gets a datastore's rules and limits.
function sb_datastore_details(_datastore_id, _on_success = undefined, _on_fail = undefined){
	return __sb_api("GET", "ds/" + __sb_url_encode(_datastore_id) + "/", undefined, undefined, _on_success, _on_fail);
}

/// @function sb_datastore_records(datastore_id, [options], [on_success], [on_fail])
/// @description Lists records. options: { order, owner, prefix, limit, offset }.
///   order is "key", "created", "updated" or a data field, "-" in front to reverse ("-plays").
///   owner is a player id or "me". on_success(page) gets { records, count, offset, limit }.
function sb_datastore_records(_datastore_id, _options = undefined, _on_success = undefined, _on_fail = undefined){
	return __sb_api("GET", __sb_record_endpoint(_datastore_id) + __sb_query(_options), undefined, undefined, _on_success, _on_fail);
}

/// @function sb_datastore_get(datastore_id, key, [on_success], [on_fail])
/// @description Gets one record: { key, owner, data, exposed, created, updated }.
function sb_datastore_get(_datastore_id, _key, _on_success = undefined, _on_fail = undefined){
	return __sb_api("GET", __sb_record_endpoint(_datastore_id, _key), undefined, undefined, _on_success, _on_fail);
}

/// @function sb_datastore_create(datastore_id, key, data, [exposed], [on_success], [on_fail])
/// @description Makes a record owned by the signed-in player. data is a struct.
///   exposed e.g. { plays: { op: "incr" }, wins: { op: "incr", once_per_player: true } }.
function sb_datastore_create(_datastore_id, _key, _data, _exposed = undefined, _on_success = undefined, _on_fail = undefined){
	var _body = { key: _key, data: _data };
	if(is_struct(_exposed)) _body.exposed = _exposed;
	return __sb_api("POST", __sb_record_endpoint(_datastore_id), _body, undefined, _on_success, _on_fail);
}

/// @function sb_datastore_update(datastore_id, key, changes, [on_success], [on_fail])
/// @description Changes a record. changes: { set, unset, incr, exposed }, all optional.
///   Non-owners can only set/incr exposed fields. on_success(record) also gets skipped,
///   the once_per_player fields that were already counted for this player.
function sb_datastore_update(_datastore_id, _key, _changes, _on_success = undefined, _on_fail = undefined){
	return __sb_api("PATCH", __sb_record_endpoint(_datastore_id, _key), _changes, undefined, _on_success, _on_fail);
}

/// @function sb_datastore_incr(datastore_id, key, field, [amount], [on_success], [on_fail])
/// @description Adds amount (default 1) to a field. Needs a signed-in player on others' records.
function sb_datastore_incr(_datastore_id, _key, _field, _amount = 1, _on_success = undefined, _on_fail = undefined){
	var _incr = {};
	_incr[$ _field] = _amount;
	return sb_datastore_update(_datastore_id, _key, { incr: _incr }, _on_success, _on_fail);
}

/// @function sb_datastore_delete(datastore_id, key, [on_success], [on_fail])
/// @description Deletes a record. Owner only.
function sb_datastore_delete(_datastore_id, _key, _on_success = undefined, _on_fail = undefined){
	return __sb_api("DELETE", __sb_record_endpoint(_datastore_id, _key), undefined, undefined, _on_success, _on_fail);
}
