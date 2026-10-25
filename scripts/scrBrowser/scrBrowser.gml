function Browser() constructor {
    navigator = Navigator(640, room_height/2);
    navigator.Activate([], FuncNone)
    
    uid = navigator.uid // This is just a passthrough
    
    
    static Refresh = function(_items, _onSelection=noone) {
        navigator.Refresh(_items, _onSelection)
    }
    
    static Update = function() {
        navigator.Update()
    }
    
    static Draw = function() {
        if !InControlStack(uid) {
            return
        }
        
        navigator.Draw()
    }
}



