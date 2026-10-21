#macro OptionCheckTrue 0
#macro OptionCheckFalse 1


function Option() constructor {
    outcomes = 0;
    holdLast = false;
    
    static Spawn = function(ctx, callback) {
        callback(0); // Note: Empty option.
    }
}
