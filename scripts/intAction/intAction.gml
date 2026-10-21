function ActionBase() constructor {
    isLast = false;
    
    static Spawn = function(ctx, callback, isLast=false) {
        callback(); // Note: Empty action.
    }
    
    static SetLast = function() {
        isLast = true;
    }
    
    static Done = function() {
        
    }
}

