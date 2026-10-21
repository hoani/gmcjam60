event_inherited();

ZooTextBox = function(label, text, font, x, y, w, h, appear=new TextAppear(), disappear=new TextAppear()){
    NewLabel(label, x, y-18)
    var r = {
        text: new Text(text, FontLookup(font), appear, disappear),
        xpos: x,
        ypos: y,
        box: new Box(w, h),
        hovered: false,
        font: font,
        surf: undefined,
        redraw: false,
        align: fa_left,
        
        
        new_surface: function() {
            if surface_exists(surf) {
                return false;
            }
            surf = surface_create(box.w, box.h)
            return true
        },
        
        step: function() {
            text.Step()
            var hovered_prev = hovered
            hovered = box.Inside(mouse_x - xpos, mouse_y - ypos)
            if hovered_prev != hovered {
                redraw = true;
            }
            redraw |= text.RequiresUpdate();
            
            if hovered && mouse_check_button_released(mb_left) {
                if !text.IsDead() {
                    text.End()
                } else {
                    text.Restart()
                }
            }
        },
        
        draw: function() {
            if new_surface() || redraw {
                surface_set_target(surf)
                draw_set_color(c_dkgrey)
                draw_rectangle(0, 0, 0 + box.w, 0 + box.h, false)
                draw_set_valign(fa_top)
                
                if hovered {
                    draw_set_font(font)
                    draw_set_halign(align)
                    var xoff = 0;
                    if align == fa_middle {
                        xoff = box.w/2
                    } else if align == fa_right {
                        xoff = box.w
                    }
                    draw_set_alpha(0.25)
                    draw_set_color(c_red)
                    draw_text(xoff, 0, Runes(text.str))
                    draw_set_alpha(1)
                }
                
                text.Draw(0, 0)
                
                surface_reset_target()
                redraw = false;
            }
            draw_surface(surf, xpos, ypos)
        }
    };
    
    r.text.Fit(r.box)
    r.box.h = r.text.Dimensions().h
   
    
    return r;
};
