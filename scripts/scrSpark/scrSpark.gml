/// Spark Particles
/// @arg system - the particle system to attach the sparks to
/// @arg color - the color of the spark particles.
function SparkParticles(_system, _scale=1, color=c_white) constructor{
	
    system = _system;
	spark = part_type_create();
	part_type_sprite(spark, spr_spark, false, true, true)
	part_type_size(spark, 3/32, 3/32, 1/16, 0);
	part_type_scale(spark, _scale, _scale);
	part_type_speed(spark, 0, 0, 0, 0);
	part_type_direction(spark, 80, 100, 0, 0);
	part_type_gravity(spark, 0, 270);
	part_type_orientation(spark, 0, 360, 1, 0, false);
	part_type_colour3(spark, color, color, color);
	part_type_alpha3(spark, 1, 1, 0);
	part_type_blend(spark, false);
	part_type_life(spark, 12, 12);

	emitter = part_emitter_create(system);
	part_emitter_region(system, emitter, 0, 0, 0, 0, ps_shape_rectangle, ps_distr_linear);
    
    static Cleanup = function() {
        part_type_destroy(spark);
        part_emitter_destroy(system, emitter);
    }
    
    static Emit = function(_x, _y) {
        var _info = part_system_get_info(system)
	
    	_x = _x-_info.xorigin
    	_y = _y-_info.yorigin
    	
    	part_emitter_region(system, emitter, _x, _x, _y, _y, ps_shape_rectangle, ps_distr_linear);
    	
    	part_emitter_burst(system, emitter, spark, 1);
    } 
}
