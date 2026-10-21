function Selectable(_text, _index) constructor {
    content = _text.original;
    text = _text;
    index = _index;
    
    static GrowText = function() {
        text.Set($"{ChScale(1.1)}{content}");
    }
    
    static ResetText = function() {
        text.Set(content);
    }
    
    static Step = function() {
        text.Step();
    }
    
    static Draw = function(x, y, c=c_white) {
        text.Draw(x, y, c);
    }
}




function Selector(width=512, _ypos=room_height/2, _xpos = room_width/2) constructor {
    options = []
    hovered = -1;
    box = new Box(width, room_height)
    margin = 16
    hpad = 32
    vpad = 8
    uid = GetUniqueId()
    onSelected = undefined;
    returns = undefined;
    hasCancel = false;
    
    state_appear = 0;
    state_active = 1;
    state_selected = 2;
    state = new State(state_appear);
    
    sfx = new SfxPlayer()
    ypos = _ypos
    xpos = _xpos
    cmds = Cmds()
    font = f_test
    
    prim = new UiPrimitives()
    
    static Cleanup = function() {
        sfx.Cleanup()
    }
    
    static Refresh = function(_options, _onSelected) {
        box.h = room_height;
        var h = -margin;
        
        options = []
        onSelected = _onSelected
        
        for (var i = 0; i < array_length(_options); i++) {
            var text = new Text(_options[i], FontLookup(font))
            text.WithAlign(fa_center).WithFit(box.Pad(hpad, 0))
            array_push(options, {
                    s: new Selectable(text, i), 
                    b: new PositionedBox(xpos, 0, box.w, text.Dimensions().h + 2 * vpad)
                }
            )
            h += text.Dimensions().h + margin;
            h += margin;
        }
        box.h = h;
        
        var yp = ypos - (box.h)/2;
        for (var i = 0; i < array_length(options); i++) {
            options[i].b.SetY(yp);
            yp += options[i].b.h + margin;
        }
        
        
        if hovered >= array_length(_options) {
            hovered = -1
        }
        
        state.Set(state_active)
    }
    
    static Activate = function(_options, _onSelected, _hasCancel=false, _returns=undefined) {
        Refresh(_options, _onSelected)
        
        hovered = -1;
        returns = _returns;
        hasCancel = _hasCancel;
        
        state.Set(state_appear)
    }
    
    // State things
    
    static _UpdateAppear = function() {
        for (var i = 0; i < array_length(options); i++) {
            options[i].s.Step()
        }
        if state.mono > 15 {
            state.Set(state_active);
        }
    }
    
    static _Hover = function(i) {
        if hovered != -1 {
            options[hovered].s.ResetText();
        }
        var opt = options[i]
        opt.s.GrowText();
        hovered = i;
    } 
    
    static _UpdateActive = function() {

        for (var i = 0; i < array_length(options); i++) {
            var opt = options[i]
            opt.s.Step();
            if (Mouse().Changed() && opt.b.Inside(MouseX, MouseY) && i != hovered) {
                _Hover(i);
            }
        }
        
        if cmds.Check(CMD_UP) {
            var i = hovered < 0 ? 0: hovered;
            i = (i + array_length(options)-1) % array_length(options);
            _Hover(i);
        }
        if cmds.Check(CMD_DOWN) {
            var i = hovered < 0 ? -1: hovered;
            i = (i + 1) % array_length(options);
            _Hover(i);
        }
            
        
        if CommandsContinueCheck() && hovered >= 0 {
            state.Set(state_selected)
            //var s = sndSelectorSelect;
            //if hasCancel && (hovered == (array_length(options) - 1)) {
                //s = sndSelectorCancel
            //}
            //sfx.play(s);
        }
    }
    
    static _UpdateSelected = function() {
        if state.mono > 60 {
            PopControlStack()
            if is_undefined(returns) {
                onSelected(hovered)    
            } else {
                onSelected(returns[hovered])
            }
        }
    }
    
    
    static Update = function() {
        if !IsActiveControl(uid) {
            return
        }
        state.Update()
        switch (state.Get()) {
            case state_appear:
                _UpdateAppear();
                return;
            case state_active:
                _UpdateActive()
                return;
            case state_selected:
                _UpdateSelected()
                return;
        }
    }
    
    static Draw = function() {
        if !IsActiveControl(uid) {
            return
        }
        switch (state.Get()) {
            case state_appear:
                _DrawAppear();
                return;
            case state_active:
                _DrawActive()
                return;
            case state_selected:
                _DrawSelected()
                return;
        }
    }
    
    static _DrawAppear = function() {
        _Draw()
    }
    
    static _DrawActive = function() {
        _Draw()
    }
    
    static _DrawSelected = function() {
        for (var i = 0; i < array_length(options); i++) {
            var opt = options[i]
            
            if i == hovered {
                if floor(state.mono/12) % 2 == 1 {
                    _DrawOptHovered(opt)
                } else {
                    _DrawOptSelected(opt)
                }
            } else {
                _DrawOptIdle(opt)
            }
        }
    }
    
    static _Draw = function() {
        for (var i = 0; i < array_length(options); i++) {
            var opt = options[i];
            
            if i == hovered {
                _DrawOptHovered(opt)
            } else {
                _DrawOptIdle(opt)
            }
        }
    }
    
    static _DrawOptHovered = function(opt) {
        var b = opt.b;
        var m = margin/4;
        prim.RectangleFill(b.x0-m, b.y0-m, b.x1+m, b.y1+m, prim.fill.base)
        opt.s.Draw(b.x0 + hpad, b.y0 + vpad, C_WHITE);
        prim.RectangleBorder(b.x0-m, b.y0-m, b.x1+m, b.y1+m, 2, prim.border.base);
        m = m+1;
        prim.RectangleCorners(b.x0-m, b.y0-m, b.x1+m, b.y1+m, 4, 16, prim.border.base);
    }
    
    static _DrawOptSelected = function(opt) {
        var b = opt.b;
        var m = margin/4;
        prim.RectangleFill(b.x0-m, b.y0-m, b.x1+m, b.y1+m, prim.fill.light)
        opt.s.Draw(b.x0 + hpad, b.y0 + vpad, C_WHITE);
        prim.RectangleBorder(b.x0-m, b.y0-m, b.x1+m, b.y1+m, 2, prim.border.light);
        m = m+1;
        prim.RectangleCorners(b.x0-m, b.y0-m, b.x1+m, b.y1+m, 4, 16, prim.border.base);
    }
    
    static _DrawOptIdle = function(opt) {
        var b = opt.b;
        prim.RectangleFill(b.x0, b.y0, b.x1, b.y1, prim.fill.dark, 7/8)
        opt.s.Draw(b.x0 + hpad, b.y0 + vpad, C_LTGRAY);
        prim.RectangleBorder(b.x0, b.y0, b.x1, b.y1, 1, prim.border.dark);
        var m = 1;
        prim.RectangleCorners(b.x0-m, b.y0-m, b.x1+m, b.y1+m, 3, 16, prim.border.base);
    }
}

