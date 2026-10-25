

/// Callback mechanism for calling and consuming callbacks.
function Callback() constructor{
    callback = undefined
    repeats = 0
    
    /// Set the next callback.
    /// @arg _callback
    /// @arg _repeats - additional calls to `Call` will trigger the callback
    static Set = function(_callback, _repeats=0) {
        callback = _callback
        repeats=_repeats
    }
    
    static HasPending = function() {
        return !is_undefined(callback)
    }
    
    /// Call and consume the callback. Does nothing if undefined
    static Call = function() {
        if (is_undefined(callback)) {
            return;
        }
        var tempCallback = callback;
        if repeats > 0 {
            repeats--
        } else {
            callback = undefined;
        }
        
        var args = array_create(argument_count);
        for (var i = 0; i < argument_count; i++) {
            args[i] = argument[i];
        }
        method_call(tempCallback, args);
    }
}

// Allows us to set up a callback where we can arrange the calling, and follow a typical spawn/callback sequence.
function CompoundCallback() constructor {
    callbacks = []
    
    /// Set the next callback.
    /// @arg _callback
    static Push = function(_callback) {
        array_push(callbacks, _callback)
    }
    
    static Clear = function() {
        callbacks = []
    }
    
    static HasPending = function() {
        return array_length(callbacks) != 0
    }
    
    /// Call and consume the callback. Does nothing if empty
    static Call = function() {
        var _list = callbacks
        callbacks = []
        
        var args = array_create(argument_count);
        for (var i = 0; i < argument_count; i++) {
            args[i] = argument[i];
        }
        for (var i = 0; i<array_length(_list); i++) {
            method_call(_list[i], args);
        }
    }
}

function CallbackTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    
    static test_subject="Callback Tests"
    
    static should_trigger_correctly = function() {
        
        cb = new Callback()
        
        var data = {
            cb: cb,
            val: 0,
            m: function() {
                val+=1;
                cb.Set(n)
            },
            n: function() {
                val+=2;
            },
        }
        
        cb.Call();
        assert_equal(0, data.val);
        
        cb.Set(data.n)
        cb.Call();
        assert_equal(2, data.val);
        cb.Call();
        assert_equal(2, data.val);
        
        cb.Set(data.m)
        cb.Call();
        assert_equal(3, data.val);
        cb.Call();
        assert_equal(5, data.val);
        cb.Call();
        assert_equal(5, data.val);
    }
    
    static should_trigger_with_args = function() {
        
        cb = new Callback()
        
        var data = {
            cb: cb,
            val: 0,
            m: function(a, b, c) {
                val+=a + b + c;
            },
        }
        
        cb.Set(data.m)
        cb.Call(1, 2, 3);
        assert_equal(6, data.val);
    }
    
    static should_multiple_triggers = function() {
        
        cb = new Callback()
        
        var data = {
            cb: cb,
            val: 0,
            m: function(a, b, c) {
                val+=a + b + c;
            },
        }
        
        cb.Set(data.m, 2)
        cb.Call(1, 2, 3);
        cb.Call(1, 2, 3);
        cb.Call(1, 2, 3);
        assert_equal(12, data.val);
    }
}