
cYolk = #ff9b59
cDarkYolk = #db372d
cWhite = c_white
cLight = #ffe9e8


var multiplier = 1

//part_blood
ps = part_system_create();
part_system_draw_order(ps, true);

//lines
plines = part_type_create();
part_type_shape(plines, pt_shape_line);
part_type_size(plines, 1, 1, 0, 0);
part_type_scale(plines, 0.75, 0.25);
part_type_speed(plines, 6*multiplier, 10*multiplier, 0, 0);
part_type_direction(plines, 0, 360, 0, 0);
part_type_gravity(plines, 0, 270);
part_type_orientation(plines, 0, 0, 0, 0, true);
part_type_colour2(plines, cLight, cYolk);
part_type_alpha3(plines, 1, 1, 0);
part_type_blend(plines, false);
part_type_life(plines, 4, 10);

//Spray_1
pspray = part_type_create();
part_type_sprite(pspray, sprPartSplatter, false, true, true)
part_type_size(pspray, 1, 1, 0.125, 0);
part_type_scale(pspray, 3/32, 5/32);
part_type_speed(pspray, 1, 2, 0, 0);
part_type_direction(pspray, 0, 360, 0, 0);
part_type_gravity(pspray, 0, 270);
part_type_orientation(pspray, 0, 0, 0, 0, true);
part_type_colour2(pspray, cYolk, cDarkYolk);
part_type_alpha3(pspray, 1, 1, 0);
part_type_blend(pspray, false);
part_type_life(pspray, 8, 15);




//Blood
pblood = part_type_create();
part_type_shape(pblood, pt_shape_disk);
part_type_size(pblood, 1, 1, 0, 0);
part_type_scale(pblood, 1/24, 1/24);
part_type_speed(pblood, 1*multiplier, 4*multiplier, 0, 0);
part_type_direction(pblood, 0, 360, 0, 0);
part_type_gravity(pblood, 0.1, 270);
part_type_orientation(pblood, 0, 0, 0, 0, false);
part_type_colour2(pblood, cLight, cDarkYolk);
part_type_alpha3(pblood, 1, 1, 0);
part_type_blend(pblood, false);
part_type_life(pblood, 15, 40);




pe = part_emitter_create(ps);
part_emitter_region(ps, pe, -8, 8, -8, 8, ps_shape_diamond, ps_distr_linear);

part_system_automatic_update(ps, false);
part_system_position(ps, x, y);


count = 0

emitSplat = function() {
    
    part_emitter_burst(ps, pe, plines, 5)
	part_emitter_burst(ps, pe, pspray, 2)
	part_emitter_burst(ps, pe, pblood, 10)
}


emitSplat()