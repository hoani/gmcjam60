function PhyBodyBall(_radius = 32) constructor {
    dynamic = new BodyDynamic()
    
    radius = _radius
    
    static PreUpdate = function(ctx) {
        dynamic.PreUpdate(ctx)
    }
    
    static Update = function(ctx) {
    }
    
    static Draw = function(ctx) {
        var _c = c_white;
        draw_circle_color(ctx.x, ctx.y, radius, _c, _c, true)		
    }
    
}



function MaterialBall() constructor {
    static Place = function(_x0, _y0, _x1, _y1) {
        var _x = _x0;
       	var _y = _y0;
       	var _r = point_distance(_x0, _y0, _x1, _y1)
       	
       	return CircleFixture(_r).
            Density(0.5).
            Restitution(0.5).
            Friction(1).
            LinearDamping(0.125).
            Bullet().
            Apply(_x, _y, new PhyBodyBall(_r))
    }
}