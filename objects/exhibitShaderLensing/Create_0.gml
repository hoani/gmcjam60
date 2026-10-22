event_inherited();

enable = true

name = "lensing"

application_surface_draw_enable(false);

u_holes   = shader_get_uniform(shLensing, "u_holes");
u_resolution = shader_get_uniform(shLensing, "u_resolution");
index = 0

hole_data = array_create(8 * 3, 0);
