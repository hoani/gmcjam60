event_inherited()

var points = [];
var colors = [];
for(var i = 0; i<array_length(screens);i++) {
    var s = screens[i]
    array_push(points, s.p0.x, s.p0.y, s.p1.x, s.p1.y)
    array_push(colors, color_get_red(s.s)/255, color_get_green(s.s)/255, color_get_blue(s.s)/255)
    
    draw_rectangle_colour(s.p0.x, s.p0.y, s.p1.x, s.p1.y, s.c, s.c, s.c, s.c, false)
}


//var _amount = (count % 256) / 256
//
shader_set(shScreen);


shader_set_uniform_f_array(shader_get_uniform(shScreen, "u_points"), points);
shader_set_uniform_f_array(shader_get_uniform(shScreen, "u_color"), colors);
shader_set_uniform_i(shader_get_uniform(shScreen, "u_count"), array_length(screens));

text.Draw(pos.x, pos.y)
draw_sprite(sprScreenCharacter, floor(Game().mono/4), (pos.x + room_width/2) % room_width, (pos.y + room_height/2) % room_height)

shader_reset();






