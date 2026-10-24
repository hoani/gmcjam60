

function ActiveController() constructor {
    uid = GetUniqueId()
    
    static Update = function() {
        if !IsActiveControl(uid) {
            return
        }
        _Update()
    }
    
    static _Update = function() {}
}


/// Provides a stack to allow objects to determine if they are active.
/// Generally used for coordinating layered UI elements.
function ControlStackClass() constructor {
    stack = [];
    locked = false;
    pending = [];
    
    /// Push an array of ids onto the stack, these become the active ids
    /// @arg array _ids the new active ids.
    static Push = function(_ids=[], pushOnLock=true) {
        if !is_array(_ids) {
            _ids = [_ids]
        }
        if array_length(_ids) == 0 {
            return;
        }
        if locked && pushOnLock == false {
            return;
        }
        if locked {
            pending = array_concat(pending, _ids);
        } else {
            array_push(stack, _ids);
        }
        DebugMessage($"PUSH: level {array_length(stack)}, stack {stack}, locked {locked}")
    }
    
    static Locked = function() {
        return locked
    }
    
    static Lock = function() {
        if locked {
            DebugError("Attempted to lock a locked control stack", true)
            return;
        }
        locked = true;
        DebugMessage("Control stack locked")
    }
    
    static Unlock = function() {
        locked = false;
        DebugMessage("Control stack unlocked")
        Push(pending)
        pending = []
    }
    
    /// Pop the active items off the stack.
    static Pop = function() {
        array_pop(stack);
        DebugMessage($" POP: level {array_length(stack)}, stack {stack}")
    }
    
    /// Remove all items from control stack
    static Clear = function() {
        stack = []
        pending = []
        locked = false;
        DebugMessage($" CLEAR: level {array_length(stack)}, stack {stack}")
    }

    /// Determine if id is currently in the stack    
    static InStack = function(_id) {
        for (var i = 0; i<array_length(stack); i++) {
            if array_contains(stack[i], _id) {
                return true;
            }
        }
        return false;
    }
    
    /// Whether an instance is currently active
    /// @arg {Object.Instance} id to check
    static IsActive = function(_id) {
        var _items = array_last(stack);
        for (var i = 0; i<array_length(_items); i++) {
            if _items[i] == _id {
                return true
            }
        }
        return false;
    }
}

// Static helpers for global access.

function PushControlStack(_ids=[], pushOnLock=true) {
    ControlStack().Push(_ids, pushOnLock);
}

function PopControlStack() {
    ControlStack().Pop();
}

function LockControlStack() {
    ControlStack().Lock();
}

function UnlockControlStack() {
    ControlStack().Unlock();
}

function ControlStackLocked() {
    return ControlStack().Locked();
}

function ClearControlStack() {
    ControlStack().Clear();
}

function IsActiveControl(who) {
    return ControlStack().IsActive(who);
}

function InControlStack(who) {
    return ControlStack().InStack(who);
}


function ControlStackTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    static test_subject="Control Stack Tests"
    
    static should_manage_stack = function() {
        s = new ControlStackClass()
        s.Push([1, 2, 3]);
        assert_is_true(s.IsActive(1));
        assert_is_false(s.IsActive(4));
        
        s.Push([4, 5]);
        assert_is_true(s.IsActive(4));
        assert_is_false(s.IsActive(1));
        
        s.Push([2, 3]);
        assert_is_true(s.IsActive(2));
        assert_is_false(s.IsActive(1));
        
        assert_is_true(s.InStack(1));
        assert_is_true(s.InStack(4));
        
        s.Pop();
        s.Pop();
        assert_is_true(s.IsActive(1));
        
        assert_is_false(s.InStack(4));
    }
    
    static should_handle_locks = function() {
        s = new ControlStackClass()
        s.Push([1, 2, 3]);
        assert_is_true(s.IsActive(1));
        assert_is_false(s.IsActive(4));
        
        s.Lock()
        s.Push([4, 5]);
        assert_is_true(s.IsActive(1));
        assert_is_false(s.IsActive(4));
        
        s.Unlock()
        assert_is_true(s.IsActive(4));
        assert_is_false(s.IsActive(1));
    }
}

