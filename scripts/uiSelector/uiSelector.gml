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
    
    hoverSfx = sndHover
    pressSfx = sndButton
    
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
        
        var yp = ypos - (box.h)/2 + margin;
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
        if hovered != i {
            CreateSfx(hoverSfx)
        }
        var opt = options[i]
        opt.s.GrowText();
        hovered = i;
    } 
    
    static Unhover = function() {
        hovered = -1;
    }
    
    static _UpdateActive = function() {

        var noHover = Mouse().Changed()
        for (var i = 0; i < array_length(options); i++) {
            var opt = options[i]
            opt.s.Step();
            if (Mouse().Changed() && opt.b.Inside(MouseX, MouseY)) {
                if i != hovered {
                    _Hover(i);
                }
                noHover = false
            }
        }
        if noHover {
            hovered = -1
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
            CreateSfx(pressSfx)
            //var s = sndSelectorSelect;
            //if hasCancel && (hovered == (array_length(options) - 1)) {
                //s = sndSelectorCancel
            //}
            //sfx.play(s);
        }
    }
    
    static _UpdateSelected = function() {
        if state.mono > 30 {
            if is_undefined(returns) {
                onSelected(hovered)    
            } else {
                onSelected(returns[hovered])
            }
            state.Set(state_active)
        }
    }
    
    
    static Update = function() {
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
                _DrawOptHovered(opt)
                _DrawOptSelected(opt)
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
        var frame = MonoSlowed(4);
        var amount = 0.5;
        var alpha = 1
        
        shader_set(shWobble);
        shader_set_uniform_f(shader_get_uniform(shWobble, "u_frame"), frame);
        shader_set_uniform_f(shader_get_uniform(shWobble, "u_amount"), amount);
        
        var b = opt.b;
        var m = margin/4;
        opt.s.Draw(b.x0 + hpad, b.y0 + vpad, C_WHITE);
        prim.RectangleBorder(b.x0-m, b.y0-m, b.x1+m, b.y1+m, 4, prim.border.light, alpha);
        m = m+1;
        prim.RectangleCorners(b.x0-m, b.y0-m, b.x1+m, b.y1+m, 8, 16, prim.border.light, alpha);
        
        shader_reset()
        
        
    }
    
    static _DrawOptSelected = function(opt) {
        var frame = MonoSlowed(4);
        var amount = 0.5;
        
        
        
        var fract = state.mono/30
        var alpha = 1 - fract
        
        shader_set(shWobble);
        shader_set_uniform_f(shader_get_uniform(shWobble, "u_frame"), frame);
        shader_set_uniform_f(shader_get_uniform(shWobble, "u_amount"), amount);
        
        var b = opt.b;
        var m = (fract*2 + 1/4)*margin;
        opt.s.Draw(b.x0 + hpad, b.y0 + vpad, C_WHITE);
        prim.RectangleBorder(b.x0-m, b.y0-m, b.x1+m, b.y1+m, 4, prim.border.light, alpha);
        m = m+1;
        prim.RectangleCorners(b.x0-m, b.y0-m, b.x1+m, b.y1+m, 8, 16, prim.border.light, alpha);
        
        
        shader_reset()
        
        
    }
    
    static _DrawOptIdle = function(opt) {
        var frame = MonoSlowed(8);
        var amount = 1.25;
        var alpha = 0.75
        
        shader_set(shWobble);
        shader_set_uniform_f(shader_get_uniform(shWobble, "u_frame"), frame);
        shader_set_uniform_f(shader_get_uniform(shWobble, "u_amount"), amount);
        
        var b = opt.b;
        opt.s.Draw(b.x0 + hpad, b.y0 + vpad, C_LTGRAY);
        prim.RectangleBorder(b.x0, b.y0, b.x1, b.y1, 2, prim.border.light, alpha);
        var m = 1;
        prim.RectangleCorners(b.x0-m, b.y0-m, b.x1+m, b.y1+m, 4, 16, prim.border.base, alpha);
        
        shader_reset()
    }
}

