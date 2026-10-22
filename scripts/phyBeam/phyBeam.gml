function BeamBody(_line, draw) : MaterialBody(draw) constructor {
    line = _line
}



function MaterialBeam() constructor {
    draw = new BeamDraw()
    static Placement = function() {
        return new BeamPlacement(draw)
    }
}


function BeamDraw() : MaterialDraw() constructor {
    static Placement = function(ctx) {
        with (ctx) {
            draw_circle(a.x, a.y, 3, true)
            draw_circle(b.x, b.y, 3, true)
            draw_line(a.x, a.y, b.x, b.y)
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
    
    static CanJoin = function(o) {
        o.GetJoinShape(self, line)
        return false
    }
    
    static GetJoinShape = function(o, shape) {
        switch(shape.Shape) {
            case "Line":
                
        }
        if delegate != noone {
            return delegate.GetJoinShape(o, shape)
        }
        return new JoinCandidate(JOIN_TYPE_WELD, false, new Vec2(0, 0))
    }
}



function BeamPlacement(_draw) : MaterialPlacement(_draw) constructor {
    PlaceA = 0
    PlaceB = 1
    PlaceDrag = 2
    
    a = new Vec2()
    b = new Vec2()
    d = 32
    
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
                break;
        }
    }
    
    static Confirm = function(x, y) {
        Drag(x, y)
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
            Apply(c.x, c.y, new BeamBody(line, draw))
    }
}

