
function DummyBreakNotifier() constructor {
    static OnBreak = function() {
    }
    
    static OnOutOfBounds = function() {
    }
}


function PhyPlay(_world, _onRestart) : ActiveController() constructor {
    static StateIdle = 0
    static StatePlay = 1
    static StateWin = 2
    static StateLose = 3
    
    state = new State(StateIdle)
    remaining = 0
    world = _world
    
    onRestart = _onRestart
    
    retry = Button(new Vec2(room_width/2, room_height/2), sprRetry, function() {
        PopControlStack()
        Reset()
        onRestart()
    }).HCenter().VTop()
    
    cancel = Button(new Vec2(room_width-16, 8), sprNavigateBack, function() {
        PopControlStack()
        Reset()
        onRestart()
    }).HRight().VTop()
    
    buttons = [retry, cancel]
    
    
    static Reset = function() {
        state = new State(StateIdle)
        remaining = 0
    }
    
    static EnableButtons = function(b) {
        var stack = [self.uid]
        if is_array(b) {
            for (var i = 0; i< array_length(b); i++) {
                array_push(stack, b[i].uid)
            }
        } else {
            array_push(stack, b.uid)
        }
        PopControlStack()
        PushControlStack(stack)
    }
    
    static OnBreak = function() {
        remaining--;
        if remaining <= 0 {
            DebugMessage("You win")
            state.Set(StateWin)
            EnableButtons(retry)
        }
    }
    
    static OnOutOfBounds = function() {
        if state.Get() != StatePlay && state.Get() != StateIdle {
            return
        }
        DebugMessage("You lose")
        EnableButtons(retry)
        state.Set(StateLose)
    }
    
    static DoRegistration = function() {
         with(objPhyEgg) {
            Register(other)
        }
        state.Set(StatePlay)
    }
    
    static Update = function() {
        if !InControlStack(uid) || !world.Started() {
            return
        }
        
        state.Update()
        
        switch state.Get() {
            case StateIdle:
                remaining = instance_number(objPhyEgg)
                if remaining == 0 {
                    OnOutOfBounds()
                } else {
                    DoRegistration()
                }
                break;
            case StatePlay:
                if state.Mono() == 120 {
                    EnableButtons(cancel)
                }
                break
        }
        
        array_foreach(buttons, function(b) {
            b.Update()
        })
    }
    
    static Draw = function() {
        if !InControlStack(uid) {
            return
        }
        switch state.Get() {
            case StateWin: 
                draw_sprite(sprResult, 0, room_width/2, room_height/2)
                break;
            case StateLose:
                draw_sprite(sprResult, 1, room_width/2, room_height/2)
                break
        }
        array_foreach(buttons, function(b) {
            b.Draw()
        })
    }

}