
function Commands(_list) constructor {
    
    checks = {};
    state = {};
    input_devices = {};
    
    _command_list = _list;
    
    for (var i = 0; i<array_length(_command_list); i++) {
        struct_set(checks, _command_list[i], []);
        struct_set(state, _command_list[i], new CommandState());
    }
    
    static Update = function() {
        for (var i = 0; i<array_length(_command_list); i++) {
             _InputUpdate(_command_list[i]);
        }
    }
    
    // Register a command
    // @arg {string} _cmd
    // @arg {Callback} _check
    static Register = function(_cmd, _check) {
    	var _arr = struct_get(checks, _cmd);
    	
    	array_push(_arr, _check);
    	struct_set(checks, _cmd, _arr);
    }
    
    static Check = function(_cmd) {
    	return struct_get(state, _cmd).check;
    }
    
    static Pressed = function(_cmd) {
    	return struct_get(state, _cmd).pressed;
    }
    
    static Released = function(_cmd) {
    	return struct_get(state, _cmd).released;
    }
    
    static _InputUpdate = function(cmd) {
        var cmd_state = struct_get(state, cmd)
        var _last = cmd_state.check;
        var _check = false;
        var _checks = struct_get(checks, cmd);
        for (var _i=0; _i<array_length(_checks); _i++) {
            _check |= _checks[_i].Call();
        }
        
        var _pressed = _check && (_last != _check);	
        var _released = !_check && (_last != _check);
        struct_set(state, cmd, new CommandState(_pressed, _check, _released))
    }
    
    static HasInputDevice = function(key) {
        return struct_exists(input_devices, key) 
    }
    
    static GetInputDevice = function(key) {
        return struct_get(input_devices, key) 
    }
    
    static RegisterInputDevice = function(key, value=0) {
        if HasInputDevice(key) {
            return false;
        }
        struct_set(input_devices, key, value)
        return true;
    }
}

function CommandState(_pressed=false, _check=false, _released=false) constructor {
    pressed = _pressed;
    check = _check;
    released = _released;
}


