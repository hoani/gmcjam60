var m = main.Fraction() * magnitude
var f = flare.Fraction() * magnitude

var mc = merge_colour(c_aqua, c_white, main.Fraction())
var fc = merge_colour(c_lime, c_white, flare.Fraction())

draw_primitive_begin(pr_trianglelist);



draw_vertex_colour(x + orth.x*m, y+ orth.y*m, mc, 0.5);
draw_vertex_colour(x - orth.x*m, y+ orth.y*m, mc, 0.5);
draw_vertex_colour(x + unit.x * 30*m, y + unit.y * 30*m, mc, 0.25*main.Fraction() );


if flare.Active() {
    draw_vertex_colour(x + orth.x*f, y+ orth.y*f, fc, 0.5);
    draw_vertex_colour(x - orth.x*f, y+ orth.y*f, fc, 0.5);
    draw_vertex_colour(x + a.x * 20*f, y + a.y * 30*f, c_white, 0.25*flare.Fraction());
    
    draw_vertex_colour(x + orth.x*f, y+ orth.y*f, fc, 0.5);
    draw_vertex_colour(x - orth.x*f, y+ orth.y*f, fc, 0.5);
    draw_vertex_colour(x + b.x * 20*f, y + b.y * 30*f, c_white, 0.25*flare.Fraction());
}


draw_primitive_end();