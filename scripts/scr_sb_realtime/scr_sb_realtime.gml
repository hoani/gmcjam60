// Rooms. A connection to Scoreboat's socket server, where a game's clients
// join rooms and pass messages to everybody else in the same room.
//
// Connect with sb_rt_connect once sb_init has succeeded (and, if the game
// requires it, a player has signed in). Then listen with sb_rt_on and act with
// sb_rt_rooms, sb_rt_create, sb_rt_join, sb_rt_leave and sb_rt_send.
//
// Those calls do not take callbacks. The server answers each with an event,
// which sb_rt_on hears:
//   "rooms"          { rooms }, after sb_rt_rooms. Each room is
//                    { id, name, members, max_members, fixed }.
//   "joined"         { room_info, you, members, history }, after sb_rt_create
//                    or sb_rt_join. you is how the others see you; members are
//                    the others. A member is { id, player, name }; player is the
//                    id of the signed-in player, as in sb_player().id, or not set.
//                    history is the room's last messages, oldest first, each
//                    { from, data, at }: kept only by fixed rooms set to keep
//                    some, and an empty array otherwise.
//   "left"           { room_id }, after sb_rt_leave.
//   "member_joined"  { room_id, member }, when somebody else comes in.
//   "member_left"    { room_id, member }, when somebody else goes.
//   "message"        { room_id, from, data }, when somebody else sends.
//   "refused"        { action, message }, when the server will not do
//                    something: a full room, sending too fast, and so on.
//   "disconnected"   {}, when the connection is gone, for whatever reason.
//
// A client is in one room at a time. Joining another leaves the one it was in.
//
// Nothing here is called "room": that name is GameMaker's own, and setting
// it moves the game to another room. Fields say room_id and room_info instead.

/// The socket.io packets that matter here, after the engine.io "4" in front.
/// @ignore
#macro __SB_RT_CONNECT "0"
/// @ignore
#macro __SB_RT_DISCONNECT "1"
/// @ignore
#macro __SB_RT_EVENT "2"
/// @ignore
#macro __SB_RT_CONNECT_ERROR "4"

/// The one connection to the socket server.
/// Internal class. Use the sb_rt_* functions.
/// @ignore
function __SbRealtime() constructor {
	socket = -1;
	// "idle", "ticket" (asking Scoreboat for one), "opening", "connected".
	state = "idle";
	handlers = {};
	connect_request = undefined;
	current_room = undefined;

	/// Opens the socket. _url is what Scoreboat gave with the ticket, such as
	/// "ws://localhost:3000" or "wss://rooms.example.com".
	open = function(_url, _ticket){
		var _secure = string_starts_with(_url, "wss://");
		var _rest = string_delete(_url, 1, string_pos("://", _url) + 2);
		var _slash = string_pos("/", _rest);
		if(_slash > 0) _rest = string_copy(_rest, 1, _slash - 1);
		var _host = _rest;
		var _port = _secure ? 443 : 80;
		var _colon = string_pos(":", _rest);
		if(_colon > 0){
			_host = string_copy(_rest, 1, _colon - 1);
			_port = real(string_delete(_rest, 1, _colon));
		}

		global.__SbTransport.ensure_listener();
		socket = network_create_socket(_secure ? network_socket_wss : network_socket_ws);
		state = "opening";
		var _path = "/socket.io/?EIO=4&transport=websocket&ticket=" + __sb_url_encode(_ticket);
		if(network_connect_raw_async(socket, _host + _path, _port) < 0){
			fail("Could not open a connection to the socket server");
		}
	}

	/// Sends one engine.io packet.
	send_text = function(_text){
		if(socket < 0) return;
		var _size = string_byte_length(_text);
		var _buffer = buffer_create(max(_size, 1), buffer_fixed, 1);
		buffer_write(_buffer, buffer_text, _text);
		network_send_raw(socket, _buffer, _size, network_send_text);
		buffer_delete(_buffer);
	}

	emit = function(_event, _data = undefined){
		if(state != "connected") return false;
		var _packet = is_undefined(_data) ? [_event] : [_event, _data];
		send_text("4" + __SB_RT_EVENT + json_stringify(_packet));
		return true;
	}

	dispatch = function(_event, _data){
		if(_event == "joined") current_room = _data[$ "room_info"];
		else if(_event == "left") current_room = undefined;

		var _list = handlers[$ _event];
		if(!is_array(_list)) return;
		for(var _i = 0; _i < array_length(_list); _i++) _list[_i](_data);
	}

	/// Ends the connection, telling whoever was waiting for it.
	fail = function(_message){
		var _was_connected = (state == "connected");
		close_socket();
		if(!is_undefined(connect_request)){
			var _request = connect_request;
			connect_request = undefined;
			_request.__reject({ stage: "realtime", http_status: -1, message: _message });
		}
		if(_was_connected) dispatch("disconnected", {});
	}

	close_socket = function(){
		if(socket >= 0) network_destroy(socket);
		socket = -1;
		state = "idle";
		current_room = undefined;
	}

	handle_async = function(_load){
		if(socket < 0 || _load[? "id"] != socket) return;

		switch(_load[? "type"]){
			case network_type_non_blocking_connect:
				if(!_load[? "succeeded"]) fail("Could not reach the socket server");
				break;

			case network_type_disconnect:
				fail("The socket server closed the connection");
				break;

			case network_type_data:
				handle_packet(buffer_read(_load[? "buffer"], buffer_string));
				break;
		}
	}

	handle_packet = function(_text){
		var _kind = string_char_at(_text, 1);
		// Engine.io: "0" opens, "2" is the server checking we are still here.
		if(_kind == "0"){
			send_text("4" + __SB_RT_CONNECT);
			return;
		}
		if(_kind == "2"){
			send_text("3");
			return;
		}
		if(_kind != "4") return;

		// Socket.io, carried in an engine.io message.
		var _type = string_char_at(_text, 2);
		var _body = string_delete(_text, 1, 2);
		var _data = undefined;
		if(_body != ""){
			try {
				_data = json_parse(_body);
			} catch(_e){
				_data = undefined;
			}
		}

		switch(_type){
			case __SB_RT_CONNECT:
				state = "connected";
				if(!is_undefined(connect_request)){
					var _request = connect_request;
					connect_request = undefined;
					_request.__resolve({});
				}
				break;

			case __SB_RT_CONNECT_ERROR:
				// The server would not have us: a bad ticket, rooms turned off...
				var _message = (is_struct(_data) && is_string(_data[$ "message"])) ? _data.message : "Refused by the socket server";
				fail(_message);
				break;

			case __SB_RT_DISCONNECT:
				fail("The socket server ended the connection");
				break;

			case __SB_RT_EVENT:
				if(is_array(_data) && array_length(_data) > 0){
					dispatch(_data[0], array_length(_data) > 1 ? _data[1] : undefined);
				}
				break;
		}
	}
}

global.__SbRealtime = new __SbRealtime();

/// @function sb_rt_connect([on_success], [on_fail])
/// @description Connects to the game's rooms. Asks Scoreboat for a ticket with
///   the current session, so call it after sb_init, and after signing a player
///   in when the game requires one (it does unless its settings say otherwise).
///   on_success({}) is called once connected. on_fail(error) is called with
///   { stage, http_status, message }: rooms not turned on for the game fail
///   with http_status 403.
///   Returns a request handle: .success(fn) and .fail(fn) can be chained on it.
function sb_rt_connect(_on_success = undefined, _on_fail = undefined){
	var _realtime = global.__SbRealtime;
	var _request = new __SbRequest();
	_request.success(_on_success).fail(_on_fail);

	if(_realtime.state == "connected"){
		_request.__resolve({});
		return _request;
	}
	if(_realtime.state != "idle"){
		_request.__reject({ stage: "realtime", http_status: -1, message: "Already connecting" });
		return _request;
	}

	_realtime.state = "ticket";
	_realtime.connect_request = _request;
	var _on_ticket = method(_realtime, function(_answer){
		if(state != "ticket") return;
		open(_answer.url, _answer.ticket);
	});
	var _on_refused = method(_realtime, function(_error){
		if(state != "ticket") return;
		state = "idle";
		var _waiting = connect_request;
		connect_request = undefined;
		if(!is_undefined(_waiting)) _waiting.__reject(_error);
	});
	var _endpoint = "gm/" + __sb_url_encode(__sb_session().gid) + "/rt/ticket/";
	__sb_api("POST", _endpoint, {}, undefined, _on_ticket, _on_refused);
	return _request;
}

/// @function sb_rt_connected()
/// @description True while connected to the socket server.
function sb_rt_connected(){
	return global.__SbRealtime.state == "connected";
}

/// @function sb_rt_disconnect()
/// @description Leaves whatever room this client is in and closes the
///   connection. The "disconnected" handlers are called.
function sb_rt_disconnect(){
	global.__SbRealtime.fail("Disconnected");
}

/// @function sb_rt_on(event, callback)
/// @description Calls callback(data) whenever the server sends event. See the
///   top of this script for the events and what data holds for each. Several
///   callbacks may listen to the same event.
function sb_rt_on(_event, _callback){
	var _handlers = global.__SbRealtime.handlers;
	if(!is_array(_handlers[$ _event])) _handlers[$ _event] = [];
	array_push(_handlers[$ _event], _callback);
}

/// @function sb_rt_off(event)
/// @description Stops every callback listening to event.
function sb_rt_off(_event){
	struct_remove(global.__SbRealtime.handlers, _event);
}

/// @function sb_rt_room()
/// @description The room this client is in, as { id, name, members,
///   max_members, fixed } when it joined, or undefined.
function sb_rt_room(){
	return global.__SbRealtime.current_room;
}

/// @function sb_rt_rooms([search])
/// @description Asks for the listed rooms whose name contains search (all of
///   them when it is ""). The answer arrives as the "rooms" event. Returns
///   false when not connected.
function sb_rt_rooms(_search = ""){
	return global.__SbRealtime.emit("rooms", { search: _search });
}

/// @function sb_rt_create(name, [options])
/// @description Makes a room and joins it; "joined" follows. options is a
///   struct, every member optional:
///     max_members   How many may be in it. The game's limit unless given, and
///                   never more than that.
///     listed        false to keep it out of searches, so that only those told
///                   its id can join. true unless given.
///   Returns false when not connected.
function sb_rt_create(_name, _options = undefined){
	var _body = { name: _name };
	if(is_struct(_options)){
		if(!is_undefined(_options[$ "max_members"])) _body.max_members = _options.max_members;
		if(!is_undefined(_options[$ "listed"])) _body.listed = _options.listed;
	}
	return global.__SbRealtime.emit("create", _body);
}

/// @function sb_rt_join(room_id)
/// @description Joins a room by its id, leaving any other; "joined" follows,
///   or "refused" if the room is full or not there. Returns false when not
///   connected.
function sb_rt_join(_room_id){
	return global.__SbRealtime.emit("join", { room_id: _room_id });
}

/// @function sb_rt_leave()
/// @description Leaves the room this client is in; "left" follows. Returns
///   false when not connected.
function sb_rt_leave(){
	return global.__SbRealtime.emit("leave");
}

/// @function sb_rt_send(data)
/// @description Sends data to everybody else in the room; they hear it as the
///   "message" event. data is anything json_stringify can handle, up to the
///   game's message size. Returns false when not connected.
function sb_rt_send(_data){
	return global.__SbRealtime.emit("send", { data: _data });
}
