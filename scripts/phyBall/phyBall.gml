#macro BALL_BASE_RADIUS 32


function BallBody(_c, _radius = BALL_BASE_RADIUS, _draw) : MaterialBodyDynamic(_draw) constructor {
    shape = new Circle(_c, _radius)
    joinDelegate = new BallJoiner(shape)
    
    static _Update = function(ctx) {
        shape.center.x = ctx.x
        shape.center.y = ctx.y
    }
}

function BallJoiner(_circle) : EdgeWeldJoiner(_circle) constructor { }

function MaterialBall() : Material() constructor {
    draw = new BallDraw()
    static Placement = function() {
        return new BallPlacement(draw)
    }
    
    static _DrawContext = function(_x, _y) {
        return {
            c: new Vec2(_x, _y),
            r: BALL_BASE_RADIUS,
        }
    }
}


function BallDraw() : MaterialDraw() constructor {
    
    static Placement = function(ctx) {
        with (ctx) {
            DrawPlus(c, 8, 2)
            DrawCircleOutline(c, r, 2)
        }
    }
}




function BallPlacement(_draw) : MaterialPlacement(_draw) constructor {
    index = MATERIAL_BALL
    PlaceInner = 0
    PlaceOuter = 1
    PlaceDrag = 2
    
    c = new Vec2()
    o = new Vec2()
    r = BALL_BASE_RADIUS
    
    s = new State(PlaceInner)
    
    static Drag = function(x, y) {
        UpdateJoins()
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
        return new Circle(c, r)
    }
    
    static _Place = function() {
       	return CircleFixture(r).
            Density(0.5).
            Restitution(0.5).
            Friction(1).
            LinearDamping(0.125).
            Bullet().
            JoinCandidates(joinCandidates).
            Apply(c.x, c.y, new BallBody(c, r, draw))
    }
}

