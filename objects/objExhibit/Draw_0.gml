draw_set_font(fntZoo)
draw_set_halign(fa_center)
draw_set_valign(fa_top)
draw_set_color(c_white)
draw_text(room_width/2, 16, name)


array_foreach(labels, function(label){
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_text(label.xpos, label.ypos, label.name)
})