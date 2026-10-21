function PlatJump() constructor {
    buffering = new Cooldown(10)
    coyote = new Cooldown(10)
    wall_factor = 0.75 // Wall lateral speed (compared to vertical)
    wall_coyote = new Cooldown(8)
    roof_clip = 2 // vertical clip when moving horizontally through the air.
    
    height = {
        min: 8,
        max: 64,    
        double: 22,
        hang: 18,
    }
    
    speed = {
        hang: 0,
        start: 0,
        double: 0,
        drop_factor: 0,
    }
    
    
    static _init_ = function() {
        RefreshSpeeds()
    }
    
    _init_();
    
    static RefreshSpeeds = function() {
        var g = PlaGravity()
        speed.hang = sqrt(2.0*g*height.hang)
        speed.start = sqrt(2.0*g*height.max)
        speed.double = sqrt(2.0*g*height.double)
        speed.drop_factor = height.max/height.min
    }
    
    
    static Update = function() {
        buffering.Update()
        coyote.Update()
        wall_coyote.Update()
    }
    
    
    static Triggered = function() {
        buffering.Cancel()
        coyote.Cancel()  
        wall_coyote.Cancel()
    }
}