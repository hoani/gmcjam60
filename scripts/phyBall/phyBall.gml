function PhyBodyBall(_c, _radius = 32) constructor {
    dynamic = new BodyDynamic()
    circle = new Circle(_c, _radius)
    
    static PreUpdate = function(ctx) {
        dynamic.PreUpdate(ctx)
    }
    
    static Update = function(ctx) {
        circle.center.x = ctx.x
        circle.center.y = ctx.y
    }
    
    static Draw = function(ctx) {
        var _c = c_white;
        draw_circle_color(ctx.x, ctx.y, circle.radius, _c, _c, true)		
    }
    
}



function MaterialBall() constructor {
    
    static Placement = function() {
        return new BallPlacement()
    }
}


function BallPlacement() constructor {
    PlaceInner = 0
    PlaceOuter = 1
    PlaceDrag = 2
    
    c = new Vec2()
    o = new Vec2()
    r = 32
    
    s = new State(PlaceInner)
    
    static Drag = function(x, y) {
        switch s.Get() {
            case PlaceInner:
                c = new Vec2(x, y)
                break;
            case PlaceOuter:
                o = c.Subtract(new Vec2(x, y))
                r = o.Distance()
                
                if r < 32 {
                    r = 32
                }
                break;
            case PlaceDrag:
                c = (new Vec2(x, y)).Add(o)
        }
    }
    
    static Confirm = function(x, y) {
        Drag(x, y)
        switch s.Get() {
            case PlaceInner:
                s.Set(PlaceOuter)
                return noone
            case PlaceOuter:
                s.Set(PlaceDrag)
                return noone
            case PlaceDrag:
                return _Place()
        }
    }
    
    static _Place = function() {
       	return CircleFixture(r).
            Density(0.5).
            Restitution(0.5).
            Friction(1).
            LinearDamping(0.125).
            Bullet().
            Apply(c.x, c.y, new PhyBodyBall(c, r))
    }
    
    static Draw = function() {
        
        draw_circle(c.x, c.y, r, true)
    }
}

