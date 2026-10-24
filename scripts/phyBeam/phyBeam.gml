#macro BEAM_BASE_XOFFSET 32

function BeamBody(_line, draw) : LineBodyDynamic(_line, draw) constructor {
    joinDelegate = new BeamJoiner(_line)
}



function MaterialBeam() : Material() constructor {
    draw = new BeamDraw()
    static Placement = function() {
        return new BeamPlacement(draw)
    }
    
    static _DrawContext = function(_x, _y) {
        return {
            a: new Vec2(_x, _y),
            b: new Vec2(_x + BEAM_BASE_XOFFSET, _y),
        }
    }
}


function BeamDraw() : MaterialDraw() constructor {
    static Placement = function(ctx) {
        with (ctx) {
            DrawCircleOutline(a, 3, 2)
            DrawCircleOutline(b, 3, 2)
            DrawLine(a, b, 2)
        }
    }
    
    static Build = function(ctx) {
        with (ctx) {
            physics_draw_debug()
        }
    }
}


function BeamJoiner(_line) : Joinable() constructor {
    line = _line
    
    static GetJoin = function(type, shape) {
        var p1 = shape.ClosestPointShape(line)
        return JoinPointLine(line, p1, type)
    }
}



function BeamPlacement(_draw) : MaterialPlacement(_draw) constructor {
    index = MATERIAL_BEAM
    PlaceA = 0
    PlaceB = 1
    PlaceDrag = 2
    
    a = new Vec2()
    b = new Vec2()
    d = BEAM_BASE_XOFFSET
    
    s = new State(PlaceA)
    
    static Drag = function(x, y) {
        var o;
        switch s.Get() {
            case PlaceA:
                a = new Vec2(x, y)
                b = new Vec2(x + d, y)
                break;
            case PlaceB:
                b = new Vec2(x, y)
                o = a.Subtract(b)
                d = o.Distance()
                
                if d < 16 {
                    d = 16
                    o.SetDistance(d)
                    b = a.Subtract(o)
                }
                break;
            case PlaceDrag:
                o = a.Subtract(b)
                b = new Vec2(x, y)
                a = b.Add(o)
                UpdateJoins()
                break;
        }
    }
    
    static _Confirm = function(x, y) {
        switch s.Get() {
            case PlaceA:
                s.Set(PlaceB)
                return noone
            case PlaceB:
                s.Set(PlaceDrag)
                return noone
            case PlaceDrag:
                return _Place()
        }
    }
    
    static _Shape = function() {
        return PointsLine(a, b)
    }
    
    static _Place = function() {
        var line = PointsLine(a, b)
        
        var c = line.Center()
        var dir = line.Direction()

       	var p = Rectangle(c, d, 4, dir);
        return PolygonFixture(c, p).
            Density(0.125).
            Friction(0.2).
            Restitution(0.75).
            Bullet().
            JoinCandidates(joinCandidates).
            Apply(c.x, c.y, new BeamBody(line, draw))
    }
}

