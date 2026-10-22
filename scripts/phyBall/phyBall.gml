function BallBody(_c, _radius = 32, _draw) : MaterialBody(_draw) constructor {
    dynamic = new BodyDynamic()
    circle = new Circle(_c, _radius)
    
    static PreUpdate = function(ctx) {
        dynamic.PreUpdate(ctx)
    }
    
    static Update = function(ctx) {
        circle.center.x = ctx.x
        circle.center.y = ctx.y
    }
}



function MaterialBall() constructor {
    draw = new BallDraw()
    static Placement = function() {
        return new BallPlacement(draw)
    }
}


function BallDraw() : MaterialDraw() constructor {
    static Placement = function(ctx) {
        with (ctx) {
            draw_line(c.x, c.y-8, c.x, c.y+8)
            draw_line(c.x-8, c.y, c.x+8, c.y)
            draw_circle(c.x, c.y, r, true)
        }
    }
    
    static Build = function(ctx) {
        var _c = c_white;
        draw_circle_color(ctx.x, ctx.y, ctx.body.circle.radius, _c, _c, true)
    }
}


function BallPlacement(_draw) : MaterialPlacement(_draw) constructor {
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
                
                if r < 16 {
                    r = 16
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
            Apply(c.x, c.y, new BallBody(c, r, draw))
    }
}

