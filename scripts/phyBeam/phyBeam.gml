#macro BEAM_BASE_XOFFSET 32

function BeamBody(_line, draw) : LineBodyDynamic(_line, draw) constructor {
    joinDelegate = new BeamJoiner(_line)
    
    
    static _CanPlace = function(o) {
        if o.IsJoinCandidate(self) {
            return true
        }
        return method(self, static_get(MaterialBody)._CanPlace)(o)
    }
}



function MaterialBeam() : Material("Beam") constructor {
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
    static Placement = function(ctx, color=c_white) {
        DrawCircleOutline(ctx.a, 3, 2, color)
        DrawCircleOutline(ctx.b, 3, 2, color)
        DrawLine(ctx.a, ctx.b, 2, color)
        
        if struct_exists(ctx, "s") && ctx.s.Get() == ctx.PlaceDrag {
            draw_sprite(sprTransform, 1, MouseX, MouseY)
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
    PlaceDone = 3
    
    a = new Vec2()
    b = new Vec2()
    d = BEAM_BASE_XOFFSET
    
    s = new State(PlaceA)
    
    static _Drag = function(x, y) {
        UpdateJoins()
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
    
    static _Confirm = function(x, y) {
        switch s.Get() {
            case PlaceA:
                s.Set(PlaceB)
                return noone
            case PlaceB:
                s.Set(PlaceDone)
                return Place()
        }
    }
    
    static _Shape = function() {
        return PointsLine(a, b)
    }
    
    static _Mask = function() {
        var base = _Shape()
        var d = base.Distance()
        var factor = (d - 1)/d
        return base.Multiply(factor)
    }
    
    
    static _CheckCanPlace = function() {
        canPlace = true
        with(objPhyMaterial) {
            var placeable = body.CanPlace(other) || other.IsJoinCandidate(body)
            other.canPlace &= placeable
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
            JoinCandidates(joinCandidates).
            Apply(c.x, c.y, new BeamBody(line, draw))
    }
}

