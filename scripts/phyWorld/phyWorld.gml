


function PhysicsWorld(_gravity = 9.8, _maxYSpd = 8, _pixelsPerMeter = 128) constructor {
    gravity = _gravity
    pixelsPerMeter = _pixelsPerMeter;
    
    static _init_ = function() {
        NewWorld()
    }
    
    _init_();
    
    static NewWorld = function() {
        physics_world_create(1/pixelsPerMeter);
        physics_world_gravity(0, gravity);
        physics_world_update_iterations(20);
        physics_world_update_speed(60);
        
        camera_setup = false
        
        paused = true
        physics_pause_enable(paused)
    }
    
    
    static Start = function() {
        paused = false
        physics_pause_enable(paused)
    }
    
    static ResetWorld = function() {
        DestroyWorld()
        NewWorld()
    }
    
    static DestroyWorld = function() {
       	instance_destroy(objPhyJoin)
       	instance_destroy(objPhyMaterial)
    }
}