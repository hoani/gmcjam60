function Cooldown(_amount) constructor {
    amount = floor(max(1, _amount));
    value = 0; 
    
    static Trigger = function(fract=1) {
        value = amount*fract;
    } 
    
    static Active = function() {
        return value > 0;
    }
    
    static Fraction = function() {
        return value/amount;
    }
    
    static Update = function() {
        if value > 0 {
            value--;
        }
    }
    
    static Cancel = function() {
        value = 0;
    }
}