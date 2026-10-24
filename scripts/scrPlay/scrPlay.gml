
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
    
    restart = Button(new Vec2(room_width/2, room_height/2), sprStart, function() {
        PopControlStack() // Pop button
        PopControlStack() // Pop self
        Reset()
        onRestart()
    }).HCenter().VCenter()
    
    
    static Reset = function() {
        state = new State(StateIdle)
        remaining = 0
    }
    
    static OnBreak = function() {
        remaining--;
        if remaining <= 0 {
            DebugMessage("You win")
            state.Set(StateWin)
            PushControlStack(restart.uid)
        }
    }
    
    static OnOutOfBounds = function() {
        DebugMessage("You lose")
        PushControlStack(restart.uid)
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
        
        restart.Update()
        
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
                break
        }
    }
    
    static Draw = function() {
        if !InControlStack(uid) {
            return
        }
        restart.Draw()
    }

}