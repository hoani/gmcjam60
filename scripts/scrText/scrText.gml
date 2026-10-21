function DrawTextOutlined(text, x, y, ctext=C_WHITE, coutline=C_BLACK){
    draw_set_color(coutline)
    draw_text(x-1, y, text)
    draw_text(x+1, y, text)
    draw_text(x, y-1, text)
    draw_text(x, y+1, text)
    
    draw_set_color(ctext)
    draw_text(x, y, text)
}

function TextAlign(halign, valign) {
    draw_set_halign(halign)
    draw_set_valign(valign)
}

function ResetTextAlign() {
    TextAlign(fa_left, fa_top) 
}