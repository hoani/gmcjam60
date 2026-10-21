 function PlatFloor(_x, _y, xscale, yscale, spr, angle, _centered=false) constructor {
    centered = _centered
    w = sprite_get_width(spr)*xscale;
    h = sprite_get_height(spr)*yscale;
    
    vcosc = dcos(angle);
    vsinc = dsin(angle);
    
    wc = w;
    hc = h;
    
    slope = angle;
    
    if slope > 90 {
        slope -= 360;
    }
    
    while slope < 0 {
        slope += 90
        var wp = w;
        var hp = h;
        w = hp;
        h = wp;
    }
    
    vcos = dcos(slope);
    vsin = dsin(slope);
    
    static _init = function(_x, _y) {
        UpdatePosition(_x, _y);
    }
    
    c = new Vec2()
    p0 = new Vec2()
    p1 = new Vec2()
    p2 = new Vec2()
    p3 = new Vec2()
    
    _init(_x, _y);
    
    
    static UpdatePosition = function(_x, _y) {
        if centered {
            c.x = _x
            c.y = _y
        } else {
            c.x = _x + (vcosc*wc + vsinc*hc)/2;
            c.y = _y + (-vsinc*wc + vcosc*hc)/2;
        }
        
        p0.x = c.x - (vcos*w + vsin*h)/2;
        p0.y = c.y - (-vsin*w + vcos*h)/2;
        
        p1.x = c.x + (vcos*w - vsin*h)/2;
        p1.y = c.y - (vsin*w + vcos*h)/2;
        
        p2.x = c.x + (vcos*w + vsin*h)/2;
        p2.y = c.y + (-vsin*w + vcos*h)/2;
        
        p3.x = c.x + (-vcos*w + vsin*h)/2;
        p3.y = c.y - (-vsin*w - vcos*h)/2;
    }
    
    static FloorAngle = function(_x, _y, _w, _gdir=-90) {
        var _slope = slope;
        var _v0 = _x;
        var _v1 = p1.x;
        var _delta = _v0 - _v1
        if 2.0 * abs(_delta) <= _w {
            return 0; // at peak, don't go up/down slope.
        }
        if _delta > 0 {
            return _slope - 90;
        } else {
            return _slope;
        }
    }
    
    static DebugDraw = function() {
        if !Debug() {
            return;
        } 
        
        draw_set_color(c_aqua);
        draw_line(p0.x, p0.y, p1.x, p1.y);
        
        draw_set_color(c_yellow);
        draw_line(p2.x, p2.y, p1.x, p1.y);
        
        draw_set_color(c_red);
        draw_line(p0.x, p0.y, p3.x, p3.y);
        
        draw_set_color(c_fuchsia);
        draw_line(p2.x, p2.y, p3.x, p3.y);
        
        draw_set_color(c_white);
    }
}



function PlatFloorTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    
    static test_subject="Platform Floor Tests"
    
    static should_bounds_no_centering = function() {
        f = new PlatFloor(32, 64, 2, 1, sprPlaBlock, 0, false)
        assert_equal(32, f.p0.x)
        assert_equal(64, f.p0.y)
        
        assert_equal(64, f.p1.x)
        assert_equal(64, f.p1.y)
        
        assert_equal(64, f.p2.x)
        assert_equal(80, f.p2.y)
        
        assert_equal(32, f.p3.x)
        assert_equal(80, f.p3.y)
    }
    
    static should_bounds_centered = function() {
        f = new PlatFloor(32 + 16, 64 + 8, 2, 1, sprPlaBlock, 0, true)
        assert_equal(32, f.p0.x)
        assert_equal(64, f.p0.y)
        
        assert_equal(64, f.p1.x)
        assert_equal(64, f.p1.y)
        
        assert_equal(64, f.p2.x)
        assert_equal(80, f.p2.y)
        
        assert_equal(32, f.p3.x)
        assert_equal(80, f.p3.y)
    }
}

