/// Spark Particles
/// @arg _system - the particle system to attach the sparks to
/// @arg _scale - how large to make the dust particles.
/// @arg color - the color of the spark particles.
function DustParticles(_system, _scale=1.0, color=c_white) constructor{
    system = _system;
    scale = _scale;

	cloud = part_type_create();
	part_type_sprite(cloud, spr_dust_cloud, false, true, true)
	part_type_size(cloud, 0.25*_scale, 0.75*_scale, 0.02*_scale, 0);
	part_type_scale(cloud, 1, 1);
	part_type_speed(cloud, 1*_scale, 4*_scale, 0, 0);
	part_type_direction(cloud, 45, 135, 0, 0);
	part_type_gravity(cloud, 0, 270);
	part_type_orientation(cloud, 0, 360, 0, 0, false);
	part_type_colour3(cloud, color, color, color);
	part_type_alpha3(cloud, 1, 1, 0);
	part_type_blend(cloud, false);
	part_type_life(cloud, 16, 16);

	emitter_cloud = part_emitter_create(system);
	
	base = part_type_create();
	part_type_sprite(base, spr_dust_ground, false, true, true)
	part_type_size(base, 0.5*_scale, 1.0*_scale, 0.04*_scale, 0);
	part_type_scale(base, 1, 1);
	part_type_speed(base, -2*_scale, 2*_scale, 0, 0);
	part_type_direction(base, 0, 0, 0, 0);
	part_type_gravity(base, 0, 0);
	part_type_orientation(base, 0, 0, 0, 0, false);
	part_type_colour3(base, color, color, color);
	part_type_alpha3(base, 1, 1, 0);
	part_type_blend(base, false);
	part_type_life(base, 10, 10);

	emitter_base = part_emitter_create(system);

	part_system_position(system, 0, 0);
	part_system_automatic_update(system, false)
	
    static Cleanup = function() {
    	part_type_destroy(cloud);
    	part_emitter_destroy(system, emitter_cloud);
    	part_type_destroy(base);
    	part_emitter_destroy(system, emitter_base);	
    }
    
    static Emit = function(_x, _y, _count) {
    	_count = CalculateParticleCount(_count);
    	if _count < 1 {
    		return;
    	}
    	
    	var _info = part_system_get_info(system)
    	
    	_x = _x-_info.xorigin
    	_y = _y-_info.yorigin
    	
    	var _xmin = _x-24*scale
    	var _xmax = _x+24*scale
    	
    	part_emitter_region(system, emitter_base, _xmin, _xmax, _y, _y, ps_shape_line, ps_distr_gaussian);
    	part_emitter_burst(system, emitter_base, base, _count);
    
    	var _ycloud =_y-16*scale
    	part_emitter_region(system, emitter_cloud, _xmin, _xmax, _ycloud, _ycloud, ps_shape_line, ps_distr_gaussian);
    	part_emitter_burst(system, emitter_cloud, cloud, _count);
    }
}