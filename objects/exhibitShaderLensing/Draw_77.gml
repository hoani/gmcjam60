event_inherited()



if !enable {
    draw_surface(application_surface, 0, 0)
    return
}
shader_set(shLensing);
gpu_set_texrepeat(true);
shader_set_uniform_f_array(u_holes, hole_data);
shader_set_uniform_f(u_resolution, surface_get_width(application_surface), surface_get_height(application_surface));

draw_surface(application_surface, 0, 0)
gpu_set_texrepeat(false);

shader_reset();




