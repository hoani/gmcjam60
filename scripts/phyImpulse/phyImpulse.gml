function PhyImpulse(_inst) constructor {
    others = []
    instance = _inst
    
    
    static Register = function(_inst) {
        if _inst.body.dynamic == noone {
            return
        }
        if other.placement.index == MATERIAL_BLACKHOLE {
            return
        }
        if !array_contains(others, _inst) {
            array_push(others, _inst)
        }
    }
    
    
    static GetOthers = function() {
        var who = others
        others = []
        return who
    }
    
    static Impulse = function() {
        var impulse = _BodyImpulse(instance)
        
        
        for (var i = 0; i<array_length(others); i++) {
            if !_AngleCheck(others[i]) {
                continue
            }
            var candidate = _BodyImpulse(others[i]);
            if candidate.Distance2() > impulse.Distance2() {
                impulse = candidate
            }
        }
        
        others = []
        return impulse
    }
    
    static _AngleCheck = function(b) {
        if !instance_exists(b) || b.body.dynamic == noone {
            return false
        }
        
        // Here we check that the hitters change in momentum is _away_ from our body
        // so it is likely the change in impulse is due to our body
        var spd = new Vec2(b.phy_speed_x, b.phy_speed_y)
        var dv = spd.Subtract(b.body.dynamic.prev.spd)
        var dpos = new Vec2(instance.phy_position_x - b.phy_position_x, instance.phy_position_y - b.phy_position_y)
        return dv.Dot(dpos) < 0;
    }
    
    static _BodyImpulse = function(b) {
        if !instance_exists(b) || b.body.dynamic == noone {
            return new Vec2()
        }
        var prev = b.body.dynamic.prev;
        var dvx = b.phy_speed_x - prev.spd.x;
        var dvy = b.phy_speed_y - prev.spd.y;
        return (new Vec2(dvx, dvy))
            .Multiply(b.phy_mass)
            .Multiply(1-0.75*b.restitution); // Assume bouncier objects spread impact
    }

}