

function Button(_pos, _sprite, _onPressed) {
    return new ButtonClass(_pos, _sprite, _onPressed)
}

function ButtonClass(_pos, _sprite, _onPressed) : ActiveController() constructor {
    
    sprite = _sprite
    onPressed = _onPressed
    w = sprite_get_width(_sprite)
    h = sprite_get_height(_sprite)
    c = new Vec2(_pos.x + w/2, _pos.y + h/2)
    b = new PositionedBox(c.x, c.y, w, h)
    cooldown = new Cooldown(30)
    hovered = false
    
    
    static HLeft = function() {
        b = new PositionedBox(c.x, b.y, w, h)
        return self
    }
    
    static HRight = function() {
        b = new PositionedBox(c.x - w, b.y, w, h)
        return self
    }
    
    static HCenter = function() {
        b = new PositionedBox(c.x - w/2, b.y, w, h)
        return self
    }
    
    static VTop = function() {
        b = new PositionedBox(b.x, c.y, w, h)
        return self
    }
    
    static VBottom = function() {
        b = new PositionedBox(b.x, c.y-h, w, h)
        return self
    }
    
    static VCenter = function() {
        b = new PositionedBox(b.x, c.y - h/2, w, h)
        return self
    }

    
    static _Update = function() {
        if cooldown.Active() {
            cooldown.Update()
            if !cooldown.Active() {
                PopControlStack()
                onPressed()
                hovered = false
            }
            return
        }
        
        var h = b.Inside(MouseX, MouseY)
        if hovered != h {
            hovered = h
            if hovered {
                PushControlStack(uid)
            } else {
                PopControlStack()
            }
        }
        if !hovered {
            return
        }
        
        if mouse_check_button_released(mb_left) {
            cooldown.Trigger()
        }
    }
    
    
    static Draw = function() {
        if !InControlStack(uid) {
            return
        }
        
        _Draw()
    }
    
    static _Draw = function() {
        
        var frame = MonoSlowed(hovered ? 4 : 8);
        var amount = hovered ? 0.5 : 1.25;
        var alpha = hovered ? 1 : 0.75;
        
        shader_set(shWobble);
        shader_set_uniform_f(shader_get_uniform(shWobble, "u_frame"), frame);
        shader_set_uniform_f(shader_get_uniform(shWobble, "u_amount"), amount);
        
        if cooldown.Active() {
            var s = 2 - cooldown.Fraction()
            var xoff = b.x0 + (1-s)*w/2
            var yoff = b.y0 + (1-s)*h/2
            draw_sprite_ext(sprite, 0, xoff, yoff, s, s, 0, c_white, cooldown.Fraction())
        }
        draw_sprite_ext(sprite, 0, b.x0, b.y0, 1, 1, 0, c_white, alpha)
        
        shader_reset()
        
        
        if Debug() && keyboard_check(vk_space) {
            draw_rectangle(b.x0, b.y0, b.x1, b.y1, true)
        }
    }

}