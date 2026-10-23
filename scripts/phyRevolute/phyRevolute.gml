
#macro REVOLUTE_BREAK_DISTANCE (64/2)

function PhyRevolute(obj0, obj1, pos) : PhyJoin(pos) constructor {
    type = JOIN_TYPE_REV
    
    static _init_ = function(obj0, obj1, pos) {
       	join = physics_joint_revolute_create(obj0, obj1, pos.x, pos.y, 0, 0, false, 0, 0, false, false)
        Register([obj0, obj1]) 
    }
    _init_(obj0, obj1, pos)
    
    
    static CalculateStrain = function() {
        return GetJoinDistance()/REVOLUTE_BREAK_DISTANCE;
    }
    
    static OnBreak = function() {
        //var _line = GetJoinLine()
    	//joint_break_emit_line(global.p.weld, _line)
    }
}










