// Files. A game's files live in buckets, and a bucket is a tree of folders. 
// Like your own little file system.

// Files do not pass through the Scoreboat API directly. 
// Asking for a file upload or download will make the API hand out a temporary link where you send or fetch your files.

/// @ignore
function __sb_bucket_endpoint(_bucket_id, _name){
	return "bkt/" + __sb_url_encode(_bucket_id) + "/" + _name;
}

/// Counts downloads, so that two in flight never share a temporary file.
global.__SbDownloads = 0;

/// @function sb_file_list(bucket_id, [path], [options], [on_success], [on_fail])
/// @description Lists what is in a folder. path is "/" unless given.
///   on_success(listing) is called with { path, folders, folder_count, files,
///   file_count, offset, limit }. Each of folders is { path, name, creator,
///   created } and each of files is { id, path, name, size, content_type,
///   sha256, creator, created, updated }. creator is the id of the player who
///   made it, as in sb_player().id, or not set.
///   Folders and files have separate rules: when the caller may see one and
///   not the other, the one they may not see is not set, rather than empty.
///   options is a struct, every member optional:
///     limit, offset   Pagination. limit is 50 unless given and at most 200.
///   on_fail(error) is called with { stage, http_status, message }.
///   Returns a request handle, like sb_buckets.
function sb_file_list(_bucket_id, _path = "/", _options = undefined, _on_success = undefined, _on_fail = undefined){
	var _params = { path: _path };
	if(is_struct(_options)){
		if(!is_undefined(_options[$ "limit"])) _params.limit = _options.limit;
		if(!is_undefined(_options[$ "offset"])) _params.offset = _options.offset;
	}
	var _endpoint = __sb_bucket_endpoint(_bucket_id, "ls/") + __sb_query(_params);
	return __sb_api("GET", _endpoint, undefined, undefined, _on_success, _on_fail);
}

/// @function sb_file_info(bucket_id, path, [on_success], [on_fail])
/// @description Gets what is known about one file, without downloading it.
///   on_success(file) is called with { id, path, name, size, content_type,
///   sha256, creator, created, updated }.
///   on_fail(error) is called with { stage, http_status, message }.
///   Returns a request handle, like sb_buckets.
function sb_file_info(_bucket_id, _path, _on_success = undefined, _on_fail = undefined){
	var _endpoint = __sb_bucket_endpoint(_bucket_id, "file/") + __sb_query({ path: _path });
	return __sb_api("GET", _endpoint, undefined, undefined, _on_success, _on_fail);
}

/// @function sb_file_delete(bucket_id, path, [on_success], [on_fail])
/// @description Deletes a file. on_success(result) is called with { deleted },
///   the path that was removed.
///   on_fail(error) is called with { stage, http_status, message }.
///   Returns a request handle, like sb_buckets.
function sb_file_delete(_bucket_id, _path, _on_success = undefined, _on_fail = undefined){
	var _endpoint = __sb_bucket_endpoint(_bucket_id, "file/") + __sb_query({ path: _path });
	return __sb_api("DELETE", _endpoint, undefined, undefined, _on_success, _on_fail);
}

/// @function sb_folder_create(bucket_id, path, [on_success], [on_fail])
/// @description Makes a folder. The folder it goes in has to exist already.
///   A folder made by a signed-in player is theirs: where the rules say "the
///   creator", they mean that player.
///   on_success(folder) is called with { path, name, creator, created }.
///   on_fail(error) is called with { stage, http_status, message }; a folder
///   that is already there fails with http_status 409.
///   Returns a request handle, like sb_buckets.
function sb_folder_create(_bucket_id, _path, _on_success = undefined, _on_fail = undefined){
	return __sb_api("POST", __sb_bucket_endpoint(_bucket_id, "dir/"), { path: _path }, undefined, _on_success, _on_fail);
}

/// @function sb_file_upload(bucket_id, path, buffer, [options], [on_success], [on_fail])
/// @description Uploads the contents of a buffer as a file, replacing the file
///   at path if there is one. The buffer is copied before this returns, so it
///   can be deleted or reused straight away.
///   What is sent is everything written to the buffer so far, that is, up to
///   where buffer_tell(buffer) is; or the whole buffer when nothing has been
///   written since it was made or loaded.
///   on_success(file) is called with { id, path, name, size, content_type,
///   sha256, creator, created, updated }.
///   options is a struct, every member optional:
///     size           How many bytes of the buffer to send, from its start.
///     content_type   A media type to record with the file, such as
///                    "application/json". "application/octet-stream" unless given.
///   on_fail(error) is called with { stage, http_status, message }. A file
///   larger than the bucket accepts fails with http_status 413, and one there
///   is no room left for with 507.
///   Returns a request handle, like sb_buckets.
function sb_file_upload(_bucket_id, _path, _buffer, _options = undefined, _on_success = undefined, _on_fail = undefined){
	var _request = new __SbRequest();
	_request.success(_on_success).fail(_on_fail);

	var _size = buffer_tell(_buffer);
	if(_size <= 0) _size = buffer_get_size(_buffer);
	var _body = { path: _path };
	if(is_struct(_options)){
		if(!is_undefined(_options[$ "size"])) _size = _options.size;
		if(!is_undefined(_options[$ "content_type"])) _body.content_type = _options.content_type;
	}
	if(_size <= 0 || _size > buffer_get_size(_buffer)){
		_request.__reject({ stage: "upload", http_status: -1, message: "There is nothing in the buffer to upload" });
		return _request;
	}
	// An int64, so json_stringify writes 11 rather than 11.0.
	_size = int64(_size);
	_body.size = _size;

	// The link accepts exactly the promised number of bytes, so they are
	// copied into a buffer of exactly that size, with its position at the end.
	var _bytes = buffer_create(_size, buffer_fixed, 1);
	buffer_copy(_buffer, 0, _size, _bytes, 0);
	buffer_seek(_bytes, buffer_seek_start, _size);

	// The session is held on to in case sb_session_use() is called before the
	// upload has finished.
	var _upload = { request: _request, session: __sb_session(), bucket_id: _bucket_id, bytes: _bytes, upload_id: "" };

	_upload.finish = method(_upload, function(_file){
		buffer_delete(bytes);
		request.__resolve(_file);
	});
	_upload.give_up = method(_upload, function(_error){
		buffer_delete(bytes);
		request.__reject(_error);
	});
	_upload.on_sent = method(_upload, function(_status, _data){
		if(_status < 200 || _status >= 300){
			return give_up({ stage: "upload", http_status: _status, message: __sb_error_message(_status, _data) });
		}
		var _endpoint = __sb_bucket_endpoint(bucket_id, "upload/" + __sb_url_encode(upload_id) + "/complete/");
		__sb_api("POST", _endpoint, undefined, undefined, finish, give_up, session);
	});
	_upload.on_started = method(_upload, function(_target){
		upload_id = _target.upload_id;
		// To the file store, not to the API: the session's token stays here.
		global.__SbTransport.send_raw(_target.url, _target.method, _target.headers, bytes, on_sent);
	});

	__sb_api("POST", __sb_bucket_endpoint(_bucket_id, "upload/"), _body, undefined, _upload.on_started, _upload.give_up, _upload.session);
	return _request;
}

/// @function sb_file_upload_string(bucket_id, path, text, [options], [on_success], [on_fail])
/// @description Uploads a string as a file. 
/// For instance json_stringify() data structures
function sb_file_upload_string(_bucket_id, _path, _text, _options = undefined, _on_success = undefined, _on_fail = undefined){
	var _length = string_byte_length(_text);
	if(_length <= 0){
		var _request = new __SbRequest();
		_request.success(_on_success).fail(_on_fail);
		_request.__reject({ stage: "upload", http_status: -1, message: "There is nothing in the string to upload" });
		return _request;
	}
	var _buffer = buffer_create(_length, buffer_fixed, 1);
	buffer_write(_buffer, buffer_text, _text);
	var _handle = sb_file_upload(_bucket_id, _path, _buffer, _options, _on_success, _on_fail);
	buffer_delete(_buffer);
	return _handle;
}

/// @function sb_file_download(bucket_id, path, [on_success], [on_fail])
/// @description Downloads a file into a new buffer. on_success(result) is
///   called with { buffer, file }: buffer holds the file's bytes, positioned
///   at the start, and is the caller's to buffer_delete() when done with it.
///   file is { id, path, name, size, content_type, sha256, creator, created,
///   updated }.
///   on_fail(error) is called with { stage, http_status, message }. A bucket
///   that has handed out its month's downloads fails with http_status 429.
///   Returns a request handle, like sb_buckets.
function sb_file_download(_bucket_id, _path, _on_success = undefined, _on_fail = undefined){
	var _request = new __SbRequest();
	_request.success(_on_success).fail(_on_fail);

	global.__SbDownloads += 1;
	var _download = {
		request: _request,
		file: undefined,
		target: "scoreboat_download_" + string(global.__SbDownloads) + ".tmp",
	};

	_download.on_fetched = method(_download, function(_status, _data){
		if(_status != 200 || !file_exists(target)){
			if(file_exists(target)) file_delete(target);
			return request.__reject({ stage: "download", http_status: _status, message: __sb_error_message(_status, undefined) });
		}
		var _buffer = buffer_load(target);
		file_delete(target);
		request.__resolve({ buffer: _buffer, file: file });
	});
	_download.on_linked = method(_download, function(_link){
		var _url = _link.url;
		struct_remove(_link, "url");
		struct_remove(_link, "expires_in");
		file = _link;
		// From the file store, not from the API: the link is all it needs.
		global.__SbTransport.fetch_file(_url, target, on_fetched);
	});
	_download.on_failed = method(_download, function(_error){ request.__reject(_error); });

	var _endpoint = __sb_bucket_endpoint(_bucket_id, "download/") + __sb_query({ path: _path });
	__sb_api("GET", _endpoint, undefined, undefined, _download.on_linked, _download.on_failed);
	return _request;
}

/// @function sb_file_download_string(bucket_id, path, [on_success], [on_fail])
/// @description Downloads a file as a string. on_success(result) is called
///   with { text, file }. Otherwise the same as sb_file_download, with no
///   buffer to clean up.
function sb_file_download_string(_bucket_id, _path, _on_success = undefined, _on_fail = undefined){
	var _request = new __SbRequest();
	_request.success(_on_success).fail(_on_fail);

	var _pending = { request: _request };
	_pending.on_done = method(_pending, function(_result){
		var _text = (buffer_get_size(_result.buffer) > 0) ? buffer_read(_result.buffer, buffer_text) : "";
		buffer_delete(_result.buffer);
		request.__resolve({ text: _text, file: _result.file });
	});
	_pending.on_failed = method(_pending, function(_error){ request.__reject(_error); });

	sb_file_download(_bucket_id, _path, _pending.on_done, _pending.on_failed);
	return _request;
}
