function EventsRegistry(_events=[], _flags=[]) constructor{
    e = {};
    flag = {};
    
    
    static RegisterEvent = function(_events) {
        _Register(_events, e, "event")
    }
    
    static RegisterFlag = function(_flags) {
        _Register(_flags, flag, "flag")
    }
    
    static ClearAllFlags = function() {
        var names = struct_get_names(flag)
        for (var i = 0; i< array_length(names); i++) {
            var name = names[i]
            struct_set(flag, name, 0);
        }
    }
    
    RegisterEvent(_events);
    RegisterFlag(_flags);
    
    static GetEvent = function(name) {
        return _Get(name, e, "event")
    }
    
    static EventIncr = function(name) {
        _Modify(name, e, 1, "event")
    }
    
    static GetFlag = function(name) {
        return _Get(name, flag, "flag")
    }
    
    static FlagIncr = function(name) {
        _Modify(name, flag, 1, "flag")
    }
    
    static FlagDecr = function(name) {
        _Modify(name, flag, -1, "flag")
    }
    
    static IsEqual = function(o) {
        return _IsEqual(e, o.e) && _IsEqual(flag, o.flag);
    }
    
    static Debug = function() {
        var str = "Events: [";
        var names = struct_get_names(e);
        for (var i = 0; i< array_length(names); i++) {
            var name = names[i]
            var count = GetEvent(name);
            str += $"{name}:{count} "
        }
        str+="]\nEvents: ["
        names = struct_get_names(flag);
        for (var i = 0; i< array_length(names); i++) {
            var name = names[i]
            var count = GetFlag(name);
            str += $"{name}:{count} "
        }
        str+="]"
        return str;
    }
    
    static Encode = function() {
        var toEncode = {
            e: e,
            flag: flag,
        };
        
        return json_stringify(toEncode);
    } 
    
    static Decode = function(json) {
        var decoded = json_parse(json);
        _DecodeTo(decoded.e, e, "event");        
        _DecodeTo(decoded.flag, flag, "flag");
    }
    
    // Private Methods
    
    static _Register = function(_input, _target, _type) {
        if is_string(_input) {
            _input = [_input]
        }
        if !is_array(_input) {
            DebugError($"{_type} {_input} has invalid type", true);
            return;
        }
        
        for (var i = 0; i < array_length(_input); i++) {
            var name = _input[i];
            if struct_exists(_target, name) {
                DebugError($"{_type} {name} already registered", true);
            } else {
                struct_set(_target, name, 0);
            }
        }
    }
    
    static _Modify = function(_name, _target, _amt, _type) {
        if !struct_exists(_target, _name) {
            DebugError($"{_type} {_name} doesn't exist, unable to modify by {_amt}", true);
            return;
        }
        struct_set(_target, _name, max(0, struct_get(_target, _name) + _amt));
    }
    
    static _Get = function(_name, _target, _type) {
        if !struct_exists(_target, _name) {
            DebugError($"{_type} {_name} doesn't exist, unable to get", true);
            return;
        }
        return struct_get(_target, _name);
    }
    
    static _IsEqual = function(mine, o) {
        if struct_names_count(mine) != struct_names_count(o) {
            return false;
        }
        
        var names = struct_get_names(mine);
        for (var i = 0; i < array_length(names); i++) {
            var name = names[i];
            if !struct_exists(o, name) {
                return false;
            }
            if struct_get(mine, name) != struct_get(o, name) {
                return false;
            }
        }
        return true;
    }
    
    static _DecodeTo = function(_source, _target, _type) {
        var names = struct_get_names(_source)
        for (var i = 0; i < array_length(names); i++) {
            var name = names[i];
            if !struct_exists(_target, name) {
                DebugError($"attempted to decode unregisterd {_type} {name}", true);
            } else {
                struct_set(_target, name, struct_get(_source, name));
            }
        }
    }
    
    
}


function EventsRegistryTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    static test_subject="Events Registry"
    
    static should_do_modifiers = function() {
        var r = new EventsRegistry(["intro", "ending"], ["upgrade.mining", "boneking.released"])
        
        r.FlagIncr("upgrade.mining");
        r.FlagIncr("upgrade.mining");
        assert_equal(r.GetFlag("upgrade.mining"), 2)
        r.FlagDecr("upgrade.mining");
        assert_equal(r.GetFlag("upgrade.mining"), 1)
        
        r.EventIncr("ending");
        assert_equal(r.GetEvent("ending"), 1)
    }
    
    static should_encode_decode_unmodified = function() {
        var original = new EventsRegistry(["intro", "ending"], ["upgrade.mining", "boneking.released"])
        var decoded = new EventsRegistry(["intro", "ending"], ["upgrade.mining", "boneking.released"])
        decoded.Decode(original.Encode());
        assert_is_true(original.IsEqual(decoded));
    }
    
    static should_encode_decode_modified = function() {
        var original = new EventsRegistry(["intro", "ending"], ["upgrade.mining", "boneking.released"])
        var modified = new EventsRegistry(["intro", "ending"], ["upgrade.mining", "boneking.released"])
        
        modified.FlagIncr("upgrade.mining");
        
        assert_is_false(original.IsEqual(modified));
        
        var decoded = new EventsRegistry(["intro", "ending"], ["upgrade.mining", "boneking.released"])
        decoded.Decode(modified.Encode());
        assert_is_true(modified.IsEqual(decoded));
    }
    
    static should_clear_all_flags = function() {
        var r = new EventsRegistry(["intro", "ending"], ["upgrade.mining", "boneking.released"])
        
        r.FlagIncr("upgrade.mining");
        r.FlagIncr("boneking.released");
        r.FlagIncr("boneking.released");
        assert_equal(r.GetFlag("upgrade.mining"), 1)
        assert_equal(r.GetFlag("boneking.released"), 2)
        r.ClearAllFlags()
        
        assert_equal(r.GetFlag("upgrade.mining"), 0)
        assert_equal(r.GetFlag("boneking.released"), 0)
    }
}