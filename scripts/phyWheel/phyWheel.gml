function WheelBody(_c, _radius = 32, _draw) : MaterialBodyDynamic(_draw) constructor {
    circle = new Circle(_c, _radius)
    joinDelegate = new WheelJoiner(circle)
    
    static Update = function(ctx) {
        circle.center.x = ctx.x
        circle.center.y = ctx.y
    }
}

function WheelJoiner(_circle) : Joinable() constructor {
    circle = _circle
    
    static GetJoin = function(type, shape) {
        var j = JoinPointRevolution(circle.center, shape.ClosestPoint(circle.center))
       	if j.success {
       		return j
       	}
        
        return JoinPointEdge(circle, shape.ClosestPointShape(circle), type)
    }
}


function MaterialWheel() constructor {
    draw = new WheelDraw()
    static Placement = function() {
        return new WheelPlacement(draw)
    }
}


function WheelDraw() : MaterialDraw() constructor {
    static Placement = function(ctx) {
        with (ctx) {
            draw_line(c.x, c.y-8, c.x, c.y+8)
            draw_line(c.x-8, c.y, c.x+8, c.y)
            draw_circle(c.x, c.y, r, true)
            draw_circle(c.x, c.y, r/2, true)
        }
    }
    
    static Build = function(ctx) {
        var _c = c_white;
        draw_circle_color(ctx.x, ctx.y, ctx.body.circle.radius, _c, _c, true)
        draw_circle_color(ctx.x, ctx.y, ctx.body.circle.radius/2, _c, _c, true)
    }
}


function WheelPlacement(_draw) : MaterialPlacement(_draw) constructor {
    index = MATERIAL_WHEEL
    PlaceInner = 0
    PlaceOuter = 1
    PlaceDrag = 2
    
    c = new Vec2()
    o = new Vec2()
    r = 32
    
    s = new State(PlaceInner)
    
    static Drag = function(x, y) {
        UpdateJoins()
        switch s.Get() {
            case PlaceInner:
                c = new Vec2(x, y)
                break;
            case PlaceOuter:
                o = c.Subtract(new Vec2(x, y))
                r = ClipClamp(o.Distance(), 16, 32, 64)
                break;
            case PlaceDrag:
                c = (new Vec2(x, y)).Add(o)
                break
        }
    }
    
    static _Confirm = function(x, y) {
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
    
    static _Shape = function() {
        return new Circle(c, 1)
    }
    
    static _Type = function() {
        return JOIN_TYPE_REV
    }
    
    
    static _Place = function() {
       	return CircleFixture(r).
            Density(0.5).
            Restitution(0.875).
            Friction(1).
            LinearDamping(0.125).
            Bullet().
            JoinCandidates(joinCandidates).
            Apply(c.x, c.y, new WheelBody(c, r, draw))
    }
}

