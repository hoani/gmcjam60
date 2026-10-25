
cYolk = #ffe7a6
cDarkYolk = #ff9b59
cWhite = c_white
cLight = #ffe9e8


var multiplier = 1 + impulse.Distance()/10

//part_blood
ps = part_system_create();
part_system_draw_order(ps, true);

//lines
plines = part_type_create();
part_type_shape(plines, pt_shape_line);
part_type_size(plines, 1, 1, 0, 0);
part_type_scale(plines, 0.75, 0.25);
part_type_speed(plines, 6*multiplier, 10*multiplier, 0, 0);
part_type_direction(plines, 80, 100, 0, 0);
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
part_type_scale(pspray, 3/16, 5/16);
part_type_speed(pspray, 1, 2, 0, 0);
part_type_direction(pspray, 80, 100, 0, 0);
part_type_gravity(pspray, 0, 270);
part_type_orientation(pspray, 0, 0, 0, 0, true);
part_type_colour2(pspray, cYolk, cDarkYolk);
part_type_alpha3(pspray, 1, 1, 0);
part_type_blend(pspray, false);
part_type_life(pspray, 8, 15);


//Spray_1
pshell = part_type_create();
part_type_sprite(pshell, sprPartSplatter, false, true, true)
part_type_size(pshell, 1, 1, 0.125, 0);
part_type_scale(pshell, 3/16, 3/16);
part_type_speed(pshell, 2, 3, 0, 0);
part_type_direction(pshell, 0, 360, 0, 0);
part_type_gravity(pshell, 0, 270);
part_type_orientation(pshell, 0, 0, 0, 0, true);
part_type_colour2(pshell, cWhite, cLight);
part_type_alpha3(pshell, 1, 1, 0);
part_type_blend(pshell, false);
part_type_life(pshell, 8, 12);



//Blood
pblood = part_type_create();
part_type_shape(pblood, pt_shape_disk);
part_type_size(pblood, 1, 1, 0, 0);
part_type_scale(pblood, 1/16, 1/16);
part_type_speed(pblood, 1*multiplier, 4*multiplier, 0, 0);
part_type_direction(pblood, 80, 100, 0, 0);
part_type_gravity(pblood, 0.1, 270);
part_type_orientation(pblood, 0, 0, 0, 0, false);
part_type_colour2(pblood, cLight, cDarkYolk);
part_type_alpha3(pblood, 1, 1, 0);
part_type_blend(pblood, false);
part_type_life(pblood, 15, 40);



//drops
pdrops = part_type_create();
part_type_shape(pdrops, pt_shape_disk);
part_type_size(pdrops, 1, 1, 0, 0);
part_type_scale(pdrops, 1/32, 1/32);
part_type_speed(pdrops, 1*multiplier, 3*multiplier, 0, 0);
part_type_direction(pdrops, -60, 240, 0, 0);
part_type_gravity(pdrops, 0.005, 270);
part_type_orientation(pdrops, 0, 0, 0, 0, false);
part_type_colour2(pdrops, cLight, cYolk);
part_type_alpha3(pdrops, 1, 1, 0);
part_type_blend(pdrops, false);
part_type_life(pdrops, 60, 120);

pe = part_emitter_create(ps);
part_emitter_region(ps, pe, -8, 8, -8, 8, ps_shape_diamond, ps_distr_linear);

part_system_automatic_update(ps, false);
part_system_position(ps, x, y);


count = 0

emitSplat = function(spd) {
    var _dir = spd.Direction()
    var _amt = 1 + spd.Distance()/10
    part_type_direction(plines, _dir-10, _dir+10, 0, 0);
	part_type_direction(pspray, _dir-10, _dir+10, 0, 0);
	part_type_direction(pblood, _dir-10, _dir+10, 0, 0);
    
    part_emitter_burst(ps, pe, plines, 5*_amt)
	part_emitter_burst(ps, pe, pspray, 2*_amt)
	part_emitter_burst(ps, pe, pblood, 10*_amt)
    
    part_type_direction(plines, 0, 360, 0, 0);
	part_type_direction(pspray, 0, 360, 0, 0);
	part_type_direction(pblood, 0, 360, 0, 0);
    
    part_emitter_burst(ps, pe, plines, 5)
	part_emitter_burst(ps, pe, pspray, 2)
	part_emitter_burst(ps, pe, pblood, 10)
    part_emitter_burst(ps, pe, pshell, 6)
    part_emitter_burst(ps, pe, pdrops, 60)
}


emitSplat(impulse)