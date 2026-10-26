

function Help(_pos, _sprite, _helpSprite) {
    return new HelpClass(_pos, _sprite, _helpSprite)
}

function HelpClass(_pos, _sprite, _helpSprite) : ActiveController() constructor {
    
    sprite = _sprite
    helpSprite = _helpSprite
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
        }
        
        var h = b.Inside(MouseX, MouseY)
        if hovered != h {
            hovered = h
            if hovered {
                PushControlStack(uid)
                cooldown.Trigger()
            } else {
                PopControlStack()
                cooldown.Trigger()
            }
        }
    }
    
    
    static Draw = function() {
        if !InControlStack(uid) {
            return
        }
        
        if cooldown.Active() || hovered {
            var alpha = hovered ? 1 - cooldown.Fraction() : cooldown.Fraction()
            draw_set_alpha(alpha*0.25)
            draw_set_color(c_black)
            draw_rectangle(0, 0, room_width, room_height, false)
            draw_set_alpha(1)
            draw_set_colour(c_white)
        }
        
        var frame = MonoSlowed(hovered ? 4 : 8);
        var amount = hovered ? 0.5 : 1.25;
        var alpha = hovered ? 1 : 0.75;
        
        shader_set(shWobble);
        shader_set_uniform_f(shader_get_uniform(shWobble, "u_frame"), frame);
        shader_set_uniform_f(shader_get_uniform(shWobble, "u_amount"), amount);
        
        draw_sprite_ext(sprite, 0, b.x0, b.y0, 1, 1, 0, c_white, alpha)
        
        if cooldown.Active() || hovered {
            
            alpha = hovered ? 1 - cooldown.Fraction() : cooldown.Fraction()
            draw_sprite_ext(helpSprite, 0, room_width/2, room_height/2, 1, 1, 0, c_white, alpha)
            
        }
        
        shader_reset()
    }

}