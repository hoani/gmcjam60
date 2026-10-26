#macro C_DELETE C_RED 
#macro C_JOIN c_orange
#macro C_PLACING C_YELLOW
#macro C_PLACABLE C_GREEN

function LineBodyDynamic(_l, _draw) : MaterialBodyDynamic(_draw) constructor {
    center = _l.p0.Add(_l.p1).Multiply(0.5)
    original = _l
    shape = PointsLine(_l.p0, _l.p1)
    
    static _Update = function(ctx) {
        var local = [original.p0, original.p1]
        var _out = _RepositionLocalPoints(ctx, center, local)
        shape = PointsLine(_out[0], _out[1])
    }
}

function PolygonBodyDynamic(_c, _p, _draw) : MaterialBodyDynamic(_draw) constructor {
    center = _c
    original = _p
    shape = new Polygon(_p.points)
    
    static _Update = function(ctx) {
        shape = new Polygon(_RepositionLocalPoints(ctx, center, original.points))
    }
}

function MaterialBodyDynamic(_draw) : MaterialBody(_draw) constructor {
    dynamic = new BodyDynamic()
    static bounds = PhysicsWorld().bounds
    
    
    static PreUpdate = function(ctx) {
        dynamic.PreUpdate(ctx)
    }
    
    
    static Update = function(ctx) {
        _Update(ctx)
        
        if bounds.Outside(shape) {
            ctx.OnOutOfBounds()
        }
    }
    
    static _Update = function(ctx) {
    }
    
    static _RepositionLocalPoints = function(ctx, _center, local) {
        var _out = array_create(array_length(local))
        var _c = dcos(ctx.phy_rotation)
        var _s = dsin(ctx.phy_rotation)
        for (var i = 0; i < array_length(local); i++) {
            var _d = local[i].Subtract(_center)
            _out[i] = new Vec2(
                ctx.phy_position_x + _d.x * _c - _d.y *_s, 
                ctx.phy_position_y + _d.x * _s + _d.y *_c
            )
        }
        return _out
    }
}


function MaterialBody(_draw) : Joinable() constructor {
    draw = _draw
    joins = []
    dynamic = noone;
    deleteCandidate = false
    deletable = false
    shape = noone
    
    static PreUpdate = function(ctx) {
    }
    
    static Update = function(ctx) {
    }
    
    static Draw = function(ctx) {
        draw.Play(ctx)
    }
    
    static SetDeletable = function() {
        deletable = true
    }
    
    static RegisterDeleteCandidate = function(o) {
        if shape == noone || deletable == false {
            return
        }
        deleteCandidate = shape.Intersect(o)
    }
    
    static Cleanup = function() {
        for (var _i = 0; _i < array_length(joins); _i++) {
            if instance_exists(joins[_i]) {
                instance_destroy(joins[_i])
            }
        }
    }
    
    // Whether a candidate shape can place here
    static CanPlace = function(o) {
        return _CanPlace(o)
    }
    
    static _CanPlace = function(o) {
        return Overlaps(o._Mask()) == false
    }
    
    static Overlaps = function(o) {
        if shape == noone {
            return true
        }
        return shape.Intersect(o)
    }
}




function Material(_name) constructor {
    name = _name
    draw = MaterialDraw()
    static Placement = function() {
        DebugError("material has no placement property")
        return new Placement();
    }
    
    static Draw = function(_x, _y) {
        draw.Placement(_DrawContext(_x, _y))
    }
    
    static _DrawContext = function() {
        return {}
    }
}


function MaterialPlacement(_draw)  constructor {
    draw = _draw
    points = []
    joinCandidates = []
    index = MATERIAL_UNKNOWN
    canPlace = false
    
    static Valid = function() {
        return false;
    }
    
    static Reset = function() {
        points = []
        joinCandidates = []
        _Reset()
    }
    
    static _Reset = function() {
    }
    
    
    static Drag = function(x, y) {
        _Drag(x, y)
        
        _CheckCanPlace()
    }
    
    static _Drag = function(x, y) {
    }
    
    static Confirm = function(x, y) {
        Drag(x, y)
        array_push(points, new Vec2(x, y))
        return _Confirm(x, y)
    }
    
    static _Confirm = function(x, y) {
        return false
    }
    
    static Draw = function(color=c_white) {
        draw.Placement(self, color)
        DrawJoins()
    }
    
    static _Shape = function() {
        return noone
    }
    
    static _Mask = function() {
        return _Shape()
    }
    
    static _Type = function() {
        return JOIN_TYPE_WELD
    }
    
    // This is the default, some shapes have other requirements
    static _CheckCanPlace = function() {
        canPlace = true
        with(objPhyMaterial) {
            other.canPlace &= body.CanPlace(other)
        }
    }
    
    static UpdateJoins = function() {
        joinCandidates = []
        if _Shape() == noone {
            return
        }
        
        with(objPhyMaterial) {
            var j = body.GetJoin(other._Type(), other._Shape())
            if j.success {
                array_push(other.joinCandidates, j.With(self))
            }
        }
    }
    
    static IsJoinCandidate = function(body, _which=JOIN_TYPE_WELD) {
        for (var i = 0; i<array_length(joinCandidates); i++) {
            var c = joinCandidates[i]
            if c.who.body == body && c.which == _which {
                return true
            }
        }
        return false
    }
    
    static DrawJoins = function() {
        for (var i = 0; i< array_length(joinCandidates); i++) {
            var j = joinCandidates[i]
            DrawCircleOutline(j.pos, 5, 2, C_JOIN)
        }
    }
    
    static Encode = function() {
        return EncodePlacement(index, points)
    }
    
    static CanPlace = function() {
        return canPlace
    }
    
    static Place = function() {
        if !canPlace {
            return noone
        }
        var inst = _Place() 
        inst.placement = self // Registers self so we can delete it from assembly if needed
        return inst
    }
}



function MaterialDraw() constructor {
    
    static Placement = function(ctx, color=c_white) {
    }
    
    static Play = function(ctx) {
        with (ctx) {
            physics_draw_debug()
        }
    }
}





