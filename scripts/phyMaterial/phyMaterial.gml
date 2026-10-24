function MaterialBodyDynamic(_draw) : MaterialBody(_draw) constructor {
    dynamic = new BodyDynamic()
    
    static PreUpdate = function(ctx) {
        dynamic.PreUpdate(ctx)
    }
}


function MaterialBody(_draw) : Joinable() constructor {
    draw = _draw
    joins = []
    dynamic = noone;
    
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
    draw = MaterialDraw()
    static Placement = function() {
        DebugError("material has no placement property")
        return new Placement();
    }
    
    static Draw = function(_x, _y) {
        shader_set(shSketch);
        shader_set_uniform_f(shader_get_uniform(shSketch, "u_frame"), Mono());
        
        // Have to trick the shader into thinking a texture is present... needed because of primitives.
        var tex = sprite_get_texture(sprPhyBase, 0); 
        texture_set_stage(shader_get_sampler_index(shSketch, "gm_BaseTexture"), tex);
        
        draw.Placement(_DrawContext(_x, _y))
        shader_reset()
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
    }
    
    static Confirm = function(x, y) {
        Drag(x, y)
        array_push(points, new Vec2(x, y))
        return _Confirm(x, y)
    }
    
    static _Confirm = function(x, y) {
        return false
    }
    
    static Draw = function() {
        draw.Placement(self)
        DrawJoins()
    }
    
    static _Shape = function() {
        return noone
    }
    
    static _Type = function() {
        return JOIN_TYPE_WELD
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
    
    static DrawJoins = function() {
        for (var i = 0; i< array_length(joinCandidates); i++) {
            var j = joinCandidates[i]
            draw_set_colour(c_lime)
            draw_circle(j.pos.x, j.pos.y, 5, true)
            draw_set_colour(c_white)
        }
    }
    
    static Encode = function() {
        return EncodePlacement(index, points)
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
    
    static Play = function(ctx) {
        Build(ctx)
    }
}





