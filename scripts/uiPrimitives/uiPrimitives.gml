// Uses https://lospec.com/palette-list/spoozy Spoozy

#macro CUiBorder c_ltgray
#macro CUiDarkBorder c_gray
#macro CUiLightBorder c_white
#macro CUiDarkBack #160c09
#macro CUiBack #261305
#macro CUiLightBack  #653611

function DefaultUiBorder() {
    return new UiColors(
        CUiBorder,
        CUiDarkBorder,
        CUiLightBorder
    )
}

function DefaultUiFill() {
    return new UiColors(
        CUiBack,
        CUiDarkBack,
        CUiLightBack
    )
}

function UiColors(_base, _dark, _light) constructor {
    base = _base
    dark = _dark
    light = _light
}

function UiPrimitives(_border=DefaultUiBorder(), _fill=DefaultUiFill()) constructor {
    border = _border
    fill = _fill
    
    static RoundedRectangle = function(x0, y0, x1, y1, w=1, cFill=fill.light, cBorder=border.base) {
        draw_set_alpha(1)
        draw_set_color(cBorder);
        draw_roundrect(x0-w/2, y0-w/2, x1+w/2, y1+w/2, false);
        draw_set_color(cFill);
        draw_roundrect(x0+w/2, y0+w/2, x1-w/2, y1-w/2, false);
    }
    
    static RectangleBorder = function(x0, y0, x1, y1, w=1, color=border.dark, alpha=1){
        draw_primitive_begin(pr_trianglestrip);
        
        draw_vertex_colour(x0, y0, color, alpha);
        draw_vertex_colour(x0 + w, y0 + w, color, alpha);
        draw_vertex_colour(x1, y0, color, alpha);
        draw_vertex_colour(x1 - w, y0 + w, color, alpha);
        draw_vertex_colour(x1, y1, color, alpha);
        draw_vertex_colour(x1 - w, y1 - w, color, alpha);
        draw_vertex_colour(x0, y1, color, alpha);
        draw_vertex_colour(x0 + w, y1 - w, color, alpha);
        draw_vertex_colour(x0, y0, color, alpha);
        draw_vertex_colour(x0 + w, y0 + w, color, alpha);
        
        draw_primitive_end();
    }
    
    static RectangleCorners = function(_x0, _y0, _x1, _y1, _w=2, _len=16, _color=border.base, _alpha=1){
        Corner(_x0, _y0, 1, 1, _w, _len, _color, _alpha);
        Corner(_x1, _y0, -1, 1, _w, _len, _color, _alpha);
        Corner(_x0, _y1, 1, -1, _w, _len, _color, _alpha);
        Corner(_x1, _y1, -1, -1, _w, _len, _color, _alpha);
    }  
    
    static RectangleFill = function(_x0, _y0, _x1, _y1, _color=fill.base, _alpha=1) {
        draw_set_alpha(_alpha);
        draw_set_color(_color);
        draw_rectangle(_x0, _y0, _x1, _y1, false);
        draw_set_alpha(1);
    }
    
    static Corner = function(_x, _y, _sx, _sy, _w=2, _len=8, _color=border.base, _alpha=1){
        draw_primitive_begin(pr_trianglestrip);
        
        draw_vertex_colour(_x + _sx*_len, _y, _color, _alpha);
        draw_vertex_colour(_x + _sx*_len, _y + _sy*_w, _color, _alpha);
        draw_vertex_colour(_x, _y, _color, _alpha);
        draw_vertex_colour(_x + _sx*_w, _y + _sy*_w, _color, _alpha);
        draw_vertex_colour(_x, _y + _sy*_len, _color, _alpha);
        draw_vertex_colour(_x + _sx*_w, _y + _sy*_len, _color, _alpha);
        
        draw_primitive_end();
    }
    
    static Diamond = function(c, r, w=2, cBorder=CUiBorder, cfill=CUiDarkBack, alpha=1){
       DrawPolygonFill(c, 4, r, 0, cfill, alpha)
       DrawPolygonOutline(c, 4, r, w, 0, cBorder, 1)
    }
}

