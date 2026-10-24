
function PhysicsWorld() {
    if !variable_global_exists("physicsWorld") {
        global.physicsWorld = new _PhysicsWorld();
    }
    return global.physicsWorld
}

function _PhysicsWorld(_gravity = 9.8, _maxYSpd = 8, _pixelsPerMeter = 128) constructor {
    gravity = _gravity
    pixelsPerMeter = _pixelsPerMeter;
    physicsRoom = room
    
    static _init_ = function() {
        NewWorld()
    }
    
    _init_();
    
    static NewWorld = function() {
        physics_world_create(1/pixelsPerMeter);
        physics_world_gravity(0, gravity);
        physics_world_update_iterations(20);
        physics_world_update_speed(60);
        
        started = false
        physics_pause_enable(!started)
    }
    
    
    static Started = function() {
        return started
    }
    
    
    static Start = function() {
        started = true
        physics_pause_enable(!started)
    }
    
    static Reset = function() {
        Destroy()
        NewWorld()
    }
    
    static Destroy = function() {
       	instance_destroy(objPhyJoin)
       	instance_destroy(objPhyMaterial)
    }
}