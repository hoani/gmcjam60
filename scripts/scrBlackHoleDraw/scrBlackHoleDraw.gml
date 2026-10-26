function BlackHoleShader() constructor {
    data = array_create(8 * 3, 0);

    u_holes   = shader_get_uniform(shLensing, "u_holes");
    u_resolution = shader_get_uniform(shLensing, "u_resolution");
    u_count = shader_get_uniform(shLensing, "u_count");
    count = 0
    
    static Update = function() {
        count = 0
        
        if !PhysicsWorld().Started() {
            application_surface_draw_enable(true);
            return
        }
        
        
        with (objPhyBlackHole) {
            other.data[other.count*3] = x
            other.data[other.count*3 + 1] = y
            other.data[other.count*3 + 2] = 8
            other.count++
        }
        application_surface_draw_enable(count == 0);
    }
    
    
    static PostDraw = function() {
        if application_surface_is_draw_enabled() {
            return
        }
        shader_set(shLensing);
        gpu_set_texrepeat(true);
        shader_set_uniform_f_array(u_holes, data);
        shader_set_uniform_i(u_count, count);
        shader_set_uniform_f(u_resolution, surface_get_width(application_surface), surface_get_height(application_surface));
        
        draw_surface(application_surface, 0, 0)
        gpu_set_texrepeat(false);
        
        shader_reset();
    }
    
}