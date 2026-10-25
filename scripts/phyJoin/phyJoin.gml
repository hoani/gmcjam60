


function PhyJoin(_pos) constructor {
    inst = noone
    join = -1
    type = JOIN_TYPE_WELD
    startPos = _pos
    pos = _pos
    anchor = new Vec2()
    strain = 0
    
    static JoinStainLimit = 1
    
    
    static Cleanup = function() {
        physics_joint_delete(join)
    }
    
    static Register = function(bodies=[]) {
        var j = self;
        inst = InstanceCreate(pos.x, pos.y, objPhyJoin, { join: j })
        anchor = new Vec2(physics_joint_get_value(join, phy_joint_anchor_1_x), physics_joint_get_value(join, phy_joint_anchor_1_y))
        
        for (var i = 0; i<array_length(bodies); i++) {
            array_push(bodies[i].body.joins, inst)
        }
    }
    
    
    static EndStep = function() {
        inst.x = inst.xstart + physics_joint_get_value(join, phy_joint_anchor_1_x) -anchor.x
        inst.y = inst.ystart + physics_joint_get_value(join, phy_joint_anchor_1_y) -anchor.y
        
        pos.x = inst.x
        pos.y = inst.y
        
        inst.image_angle = physics_joint_get_value(join, phy_joint_angle)
        
        strain = CalculateStrain();
       	if (strain >= JoinStainLimit){
       		OnBreak(join)
            with (inst) {
                instance_destroy()
            }
       		return
       	}
    }
    

    static GetJoinLine = function() {
        var _x1 = physics_joint_get_value(join, phy_joint_anchor_1_x)
       	var _y1 = physics_joint_get_value(join, phy_joint_anchor_1_y)
       	var _x2 = physics_joint_get_value(join, phy_joint_anchor_2_x)
       	var _y2 = physics_joint_get_value(join, phy_joint_anchor_2_y)
       
       	return new Line(_x1, _y1, _x2, _y2)
    }
    
    static GetJoinDistance = function() {
        return GetJoinLine().Distance()
    }
    
    static CalculateStrain = function() {
        return 0;
    }
    
    static OnBreak = function() {
    }
    
    static Draw = function() {
        DrawCircleOutline(pos, 8, 2, C_JOIN)
    }
}
