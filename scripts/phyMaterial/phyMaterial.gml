function Material() constructor {
    static Place = function() {
        DebugError("material has no place property")
        return noone;
    }
    
    static Join = function(inst0, inst1, pos0, type0, pos1, type1) {
        return false;
    }
    
    static CanPlace = function(joinable, pos, detector) {
        return false;
    }
    
    
    static DrawSketch = function(joinable, pos, detector) {
        DebugError("material has no drawsketch property")
    }
    
    static DrawSketchJoin = function(joinable, pos, detector) {
        DebugError("material has no drawsketchjoin property")
    }
    
    static Draw = function(joinable, pos, detector) {
                DebugError("material has no draw property")
    }
}