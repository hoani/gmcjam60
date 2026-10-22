function MaterialBody(_draw, _joinable=noone) : Joinable(_joinable) constructor {
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


