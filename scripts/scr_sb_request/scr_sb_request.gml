/// What every sb_* call that talks to the server returns. Attach callbacks with
/// .success(fn) and .fail(fn), or poll .done / .succeeded / .result / .error.
/// An undefined callback is ignored, so optional callback parameters can be
/// forwarded straight in.
/// Guaranteed to call either success or fail, and only once. 
// Internal. Do not use directly. 
/// @ignore
function __SbRequest() constructor {
	done = false;
	succeeded = false;
	result = undefined;
	error = undefined;
	__on_success = [];
	__on_fail = [];

	success = function(_callback = undefined){
		if(is_undefined(_callback)) return self;
		if(!done) array_push(__on_success, _callback);
		else if(succeeded) _callback(result);
		return self;
	}

	fail = function(_callback = undefined){
		if(is_undefined(_callback)) return self;
		if(!done) array_push(__on_fail, _callback);
		else if(!succeeded) _callback(error);
		return self;
	}

	__resolve = function(_result){
		if(done) return;
		done = true;
		succeeded = true;
		result = _result;
		var _callbacks = __on_success;
		__on_success = [];
		__on_fail = [];
		for(var _i = 0; _i < array_length(_callbacks); _i++){
			_callbacks[_i](result);
		}
	}

	__reject = function(_error){
		if(done) return;
		done = true;
		succeeded = false;
		error = _error;
		var _callbacks = __on_fail;
		__on_success = [];
		__on_fail = [];
		for(var _i = 0; _i < array_length(_callbacks); _i++){
			_callbacks[_i](error);
		}
	}
}

/// The message for a response that was not the one hoped for.
/// @ignore
function __sb_error_message(_status, _data){
	if(is_struct(_data) && struct_exists(_data, "error")) return string(_data.error);
	if(_status < 0) return "Network error";
	return "Unexpected response (HTTP " + string(_status) + ")";
}

/// One call to the API made with a session's token.
/// internal class. Do not use directly.
/// Holds on to the session it was made with, so sb_session_use() while the
/// call is in flight does not change whose token it carries.
/// A 401 means the token is no good: the session is refreshed and the call
/// sent once more before giving up.
/// _transform(data), when given, reshapes the response before it is handed to
/// the success callbacks.
/// @ignore
function __SbApiCall(_request, _session, _method, _endpoint, _body = undefined, _transform = undefined) constructor {
	request = _request;
	session = _session;
	http_method = _method;
	endpoint = _endpoint;
	body = _body;
	transform = _transform;
	token = undefined;
	retried = false;

	start = function(){
		if(session.state != SB_STATE.READY){
			return request.__reject({ stage: "request", http_status: -1, message: "Scoreboat is not initialized" });
		}
		token = session.bearer();
		global.__SbTransport.send(endpoint, session.api_headers(), body, on_response, http_method);
	}

	on_response = function(_status, _data){
		if(_status == 401 && !retried && session.state == SB_STATE.READY){
			retried = true;
			// The session may already hold a newer token than the one this was sent with.
			if(session.bearer() != token) return start();
			session.refresh().success(on_refreshed).fail(on_refresh_failed);
			return;
		}

		if(_status < 200 || _status >= 300 || !is_struct(_data)){
			return request.__reject({ stage: "request", http_status: _status, message: __sb_error_message(_status, _data) });
		}
		request.__resolve(is_undefined(transform) ? _data : transform(_data));
	}

	on_refreshed = function(_info){
		start();
	}

	on_refresh_failed = function(_error){
		request.__reject(_error);
	}
}

/// Starts an API call and returns its request handle. It is made on the
/// current session unless another is given.
/// @ignore
function __sb_api(_method, _endpoint, _body, _transform, _on_success, _on_fail, _session = undefined){
	var _request = new __SbRequest();
	_request.success(_on_success).fail(_on_fail);
	if(is_undefined(_session)) _session = __sb_session();
	(new __SbApiCall(_request, _session, _method, _endpoint, _body, _transform)).start();
	return _request;
}
