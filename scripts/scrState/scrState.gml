
/// Create a simple state machine.
/// @arg _initial - the initial state
function State(_initial) constructor{
    current = _initial;
    step = 0; // step is how many in-game frames we have been in the current state. This is affected by the gamespeed.
    mono = 0; // mono is the number of true frames we have been in the current state. This monotonically increases by one on each update.
    
    /// Transition the state machine to a new state. Will reset the counters if the state has changed
    /// @arg _next - the next state
    static Set = function(_next) {
        if current == _next {
            return; // State hasn't changed. Nothing to do.
        }
        current = _next;
        step = 0;
        mono = 0;
    }
    
    /// Updates the counters.
    static Update = function(speed=1) {
        step += speed
        mono++; 
    }
    
    static Mono = function() {
       return mono 
    }
    
    /// Get the current state.
    static Get = function() {
        return current;
    }
}

function StateTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    
    static test_subject="State Tests"
    
    static should_update_states = function() {

        state_idle = "IDLE";
        state_active = "ACTIVE";

        
        s = new State(state_idle);
        
        assert_equal(state_idle, s.Get());
        assert_equal(0, s.step);
        assert_equal(0, s.mono);
        
        s.Update();
        
        assert_equal(state_idle, s.Get());
        assert_equal(1, s.step);
        assert_equal(1, s.mono);
        

        s.Update(0.5);
        
        assert_equal(state_idle, s.Get());
        assert_equal(1.5, s.step);
        assert_equal(2, s.mono);
        
        s.Set(state_active)
        
        assert_equal(state_active, s.Get());
        assert_equal(0, s.step);
        assert_equal(0, s.mono);
    }
}