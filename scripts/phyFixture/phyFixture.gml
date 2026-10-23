#macro PhyCollisionMain 1
#macro PhyCollisionNone 0

function CircleFixture(radius) {
    return (new PhyFixture()).Circle(radius)
}

function PolygonFixture(c, polygon) {
    return (new PhyFixture()).Polygon(c, polygon)
}


function PhyFixture() constructor {
    f = physics_fixture_create();
    physics_fixture_set_density(f, 0.25);
    physics_fixture_set_restitution(f, 0.5);
    physics_fixture_set_collision_group(f, PhyCollisionMain);
    bullet = false
    isStatic = false
    rotation = 0
    joinCandidates = []
    
    
    static Apply = function(_x, _y, body) {
        var inst = InstanceCreate(_x, _y, objPhyMaterial, {body: body})
        physics_fixture_bind(f, inst);
       	physics_fixture_delete(f);

        inst.phy_bullet = bullet
        inst.phy_fixed_rotation = isStatic
        inst.phy_rotation = -rotation
        
        for (var i = 0; i < array_length(joinCandidates); i++) {
            var j = joinCandidates[i];
            if !j.success {
                continue
            }
            switch j.which {
                case JOIN_TYPE_WELD:
                    new PhyWeld(inst, j.who, j.pos) // Note: self registering
                    break;
            }
        }
        
        return inst
    }
    
    static Circle = function(radius) {
        physics_fixture_set_circle_shape(f, radius);
        return self
    }
    
    static Polygon = function(c, polygon) {
        physics_fixture_set_polygon_shape(f);
        for (var i = 0; i < array_length(polygon.points); i++) {
            var p = polygon.points[i].Subtract(c)
            physics_fixture_add_point(f, p.x, p.y)
        }
        return self
    }
    
    static Bullet = function() {
        bullet = true
        return self
    }
    
    static Static = function() {
        isStatic = true
        return Density(0)
    }
    
    static Density = function(val) {
        physics_fixture_set_density(f, val);
        return self
    }
    
    static Restitution = function(val) {
        physics_fixture_set_restitution(f, val);
        return self
    }
    
    static Friction = function(val) {
        physics_fixture_set_friction(f, val);
        return self
    }
    
    static LinearDamping = function(val) {
        physics_fixture_set_linear_damping(f, val);
        return self
    }
    
    static CollisionMain = function() {
        physics_fixture_set_collision_group(f, PhyCollisionMain);
        return self
    }
    
    static CollisionNone = function() {
        physics_fixture_set_collision_group(f, PhyCollisionNone);
        return self
    }
    
    static Rotation = function(val) {
        rotation = val
        return self
    }
    
    static JoinCandidates = function(val) {
        joinCandidates = val
        return self
    }
    
    
}