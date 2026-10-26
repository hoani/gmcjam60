
#macro WELD_BREAK_DISTANCE (64/4)
#macro WELD_BREAK_TORQUE (1/64)

function PhyWeld(obj0, obj1, pos) : PhyJoin(pos) constructor {
    type = JOIN_TYPE_WELD
    
    static _init_ = function(obj0, obj1, pos) {
        var _angle = obj0.phy_rotation - obj1.phy_rotation
	
       	var _m = 180/10314; // Dont know what the hell this is... but whatever.
       
       	join = physics_joint_weld_create(obj0, obj1, pos.x, pos.y, degtorad(_angle*_m), 10, 0.01, false);
       	var _ang = physics_joint_get_value(join, phy_joint_angle);
       	physics_joint_set_value(join, phy_joint_angle, degtorad(_angle));
        
        Register([obj0, obj1]) 
    }
    _init_(obj0, obj1, pos)
    
    
    static CalculateStrain = function() {
       	var _tau = physics_joint_get_value(join, phy_joint_reaction_torque)
       	
       	return (new Vec2(_tau/WELD_BREAK_TORQUE, GetJoinDistance()/WELD_BREAK_DISTANCE)).Distance();
    }
    
    static OnBreak = function() {
        var pos = GetJoinLine().Center()
        InstanceCreate(pos.x, pos.y, objJoinSplat)
    }
}










