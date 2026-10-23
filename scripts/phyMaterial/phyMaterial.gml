function MaterialBody(_draw) : Joinable() constructor {
    draw = _draw
    joins = []
    
    static PreUpdate = function(ctx) {
    }
    
    static Update = function(ctx) {
    }
    
    static Draw = function(ctx) {
        draw.Build(ctx)
    }
    
    static Cleanup = function() {
        static _JoinableCleanup = function() {
            for (var _i = 0; _i < array_length(joins); _i++) {
            	if instance_exists(joins[_i]) {
            		instance_destroy(joins[_i])
            	}
            }
        }
    }
}



function Material() constructor {
    static Placement = function() {
        DebugError("material has no placement property")
        return new Placement();
    }
    
    static Join = function(inst0, inst1, pos0, type0, pos1, type1) {
        return false;
    }
    
    static DrawSketch = function() {
        DebugError("material has no drawsketch property")
    }
    
    static DrawSketchJoins = function() {
        DebugError("material has no drawsketchjoin property")
    }
    
    static Draw = function(joinable, pos, detector) {
                DebugError("material has no draw property")
    }
}


function MaterialPlacement(_draw)  constructor {
    draw = _draw
    joinCandidates = []
    
    static Valid = function() {
        return false;
    }
    
    static Reset = function() {
    }
    
    static Drag = function(x, y) {
    }
    
    static Confirm = function(x, y) {
        return false
    }
    
    static Draw = function() {
        draw.Placement(self)
        DrawJoins()
    }
    
    static _Shape = function() {
        return noone
    }
    
    static UpdateJoins = function() {
        joinCandidates = []
        if _Shape() == noone {
            return
        }
        with(objPhyMaterial) {
            var j = body.GetJoin(other._Shape())
            if j.success {
                array_push(other.joinCandidates, j.With(self))
            }
            
        }
    }
    
    static DrawJoins = function() {
        for (var i = 0; i< array_length(joinCandidates); i++) {
            var j = joinCandidates[i]
            draw_set_colour(c_lime)
            draw_circle(j.pos.x, j.pos.y, 5, true)
            draw_set_colour(c_white)
        }
    }
}



function MaterialDraw() constructor {
    static Placement = function(ctx) {
    }
    
    static Build = function(ctx) {
        with (ctx) {
            physics_draw_debug()
        }
    }
    
    static BuildJoins = function(ctx) {
        with (ctx) {
            physics_draw_debug()
        }
    }
    
    static Play = function(ctx) {
        Build(ctx)
    }
    
    static PlayJoins = function(ctx) {
        BuildJoins(ctx)
    }
}


