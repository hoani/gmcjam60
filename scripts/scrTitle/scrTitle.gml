function Title(_onTrigger) : ActiveController() constructor {
    surface = surface_create(room_width, room_height)
    pending = true
    cooldown = new Cooldown(60)
    callback = new Callback()
    callback.Set(_onTrigger)
    
    
    
    
    credits = new Credits()

    
    static _Update = function() {
        
        if cooldown.Active() {
            cooldown.Update()
            if !cooldown.Active() {
                PopControlStack()
                callback.Call()
            }
            return
        }
        
        
        if !cooldown.Active() && mouse_check_button_released(mb_left) && Mono() > 10 {
            cooldown.Trigger()
            PushControlStack(uid)
        }
        
        credits.Update()
        pending = true
    }
    
    
    static Draw = function() {
        if !InControlStack(uid) {
            return
        }
        
        var surf = RefreshSurface(surface, room_width, room_height)
        pending |= surf != surface
        surface = surf
        
        if pending {
            pending = false
            surface_set_target(surface)
            draw_clear_alpha(c_white, 0)
            draw_sprite(sprTitle, 0, 0, 0)
            credits.Draw()
            surface_reset_target()
        }
        
        shader_set(shWobble);
        shader_set_uniform_f(shader_get_uniform(shWobble, "u_frame"), MonoSlowed(8));
        shader_set_uniform_f(shader_get_uniform(shWobble, "u_amount"), 0.75);
        
        if cooldown.Active() {
            var s = 2 - cooldown.Fraction()
            var xoff = (1-s)*room_width/2
            var yoff = (1-s)*room_height/2
            draw_surface_ext(surface, xoff, yoff, s, s, 0, c_white, cooldown.Fraction())
        } else {
            draw_surface(surface, 0, 0)
        }
        
        
        shader_reset()
        
    }

}