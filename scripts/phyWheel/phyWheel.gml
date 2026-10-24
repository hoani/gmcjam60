#macro WHEEL_BASE_RADIUS 32


function WheelBody(_c, _radius = 32, _draw) : MaterialBodyDynamic(_draw) constructor {
    shape = new Circle(_c, _radius)
    joinDelegate = new WheelJoiner(shape)
    
    static _Update = function(ctx) {
        shape.center.x = ctx.x
        shape.center.y = ctx.y
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


function MaterialWheel() : Material() constructor {
    draw = new WheelDraw()
    static Placement = function() {
        return new WheelPlacement(draw)
    }
    
    static _DrawContext = function(_x, _y) {
        return {
            c: new Vec2(_x, _y),
            r: WHEEL_BASE_RADIUS,
        }
    }
}


function WheelDraw() : MaterialDraw() constructor {
    static Placement = function(ctx) {
        with (ctx) {
            DrawPlus(c, 8)
            DrawCircleOutline(c, r)
            DrawCircleOutline(c, r/2)
        }
    }
    
    static Build = function(ctx) {
        var c = ctx.body.shape.center
        var r = ctx.body.shape.radius
        DrawCircleOutline(c, r)
        DrawCircleOutline(c, r/2)
    }
}


function WheelPlacement(_draw) : MaterialPlacement(_draw) constructor {
    index = MATERIAL_WHEEL
    PlaceInner = 0
    PlaceOuter = 1
    PlaceDrag = 2
    
    c = new Vec2()
    o = new Vec2()
    r = WHEEL_BASE_RADIUS
    
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
                return Place()
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

