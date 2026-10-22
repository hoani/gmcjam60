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


function Placement() constructor {
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
}
