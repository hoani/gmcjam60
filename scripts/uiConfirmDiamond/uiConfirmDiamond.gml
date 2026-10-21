

function ConfirmDiamond(textbox, border) constructor {
    pos = new Vec2(textbox.pos.x, textbox.pos.y)
    pos.x += textbox.diamondPos.x
    pos.y += textbox.diamondPos.y
    
    cooldown = new Cooldown(30) // Note cooldown only delays showing the diamond, not the user input.
    callback = new Callback()
    bcolor = border
    
    uid = GetUniqueId()
    
    
    static Show = function(_callback) {
        PushControlStack(uid)
        callback.Set(_callback)
        cooldown.Trigger()
    }
    
    static Step = function() {
        cooldown.Update()
        if !IsActiveControl(uid) {
            return
        }
        
        if CommandsContinueCheck() {
            PopControlStack()
            callback.Call()
        }
    }
        
    
    static Draw = function() {
        if !IsActiveControl(uid) {
            return
        }
        
        if cooldown.Active() {
            return;
        }
        
        UiDrawDiamond(pos, 20, 2, bcolor.light, bcolor.button)
    }
}

