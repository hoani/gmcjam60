function PhyBodyBox(_p) constructor {
    p = _p
    static PreUpdate = function(ctx) {
    }
    
    static Update = function(ctx) {
    }
    
    static Draw = function(ctx) {
        //draw_line(ctx.x - length/2, ctx.y - width/2, ctx.x + length/2, ctx.y - width/2)
        //draw_line(ctx.x + length/2, ctx.y - width/2, ctx.x + length/2, ctx.y + width/2)
        //draw_line(ctx.x - length/2, ctx.y + width/2, ctx.x + length/2, ctx.y + width/2)
        //draw_line(ctx.x - length/2, ctx.y + width/2, ctx.x - length/2, ctx.y - width/2)
        with(ctx) {
            physics_draw_debug()
        }
    }
    
}



function MaterialBox() constructor {
    static LineEndTrim = 1;
    
    static Place = function(_x0, _y0, _x1, _y1) {
        var _fix = physics_fixture_create();
       	var _x = (_x0 + _x1)/2;
       	var _y = (_y0 + _y1)/2;
       	var _dir = point_direction(_x0, _y0, _x1, _y1) 
       	var _length = point_distance(_x0, _y0, _x1, _y1)
        var _width = 32;
       	
       	var _l2 = (_length/2) - LineEndTrim;
        var _w2 = 16;
        
        var c = new Vec2((_x0 + _x1)/2, (_y0 + _y1)/2)
        
        var p = Rectangle(c, _length, _width, _dir);
        
        return PolygonFixture(c, p).
            Density(0.125).
            Friction(0.2).
            Restitution(0.25).
            Rotation(_dir).
            Bullet().
            Apply(_x, _y, new PhyBodyBox(p))
    }
}