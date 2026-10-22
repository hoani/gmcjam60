function PhyBodyBlock(_p) constructor {
    p = _p
    static PreUpdate = function(ctx) {
    }
    
    static Update = function(ctx) {
    }
    
    static Draw = function(ctx) {
        with(ctx) {
            physics_draw_debug()
        }
    }
    
}



function MaterialBlock() constructor {
    static LineEndTrim = 1;
    
    static Place = function(_x0, _y0, _x1, _y1) {
        var _fix = physics_fixture_create();
       	var _x = (_x0 + _x1)/2;
       	var _y = (_y0 + _y1)/2;
       	var _dir = point_direction(_x0, _y0, _x1, _y1) 
       	var _length = point_distance(_x0, _y0, _x1, _y1)       	
        var _width = 32
       	
       	var _l2 = (_length/2) - LineEndTrim;
        var _w2 = 16;
        
        var c = new Vec2((_x0 + _x1)/2, (_y0 + _y1)/2)
        
        var p = Rectangle(c, _length, _width, _dir);
        
        return PolygonFixture(c, p).
            Static().
            Restitution(0.25).
            Apply(_x, _y, new PhyBodyBlock(p))
       
       	//physics_fixture_set_polygon_shape(_fix);
       	//physics_fixture_add_point(_fix, -_l2, -_w2)
       	//physics_fixture_add_point(_fix, _l2, -_w2)
       	//physics_fixture_add_point(_fix, _l2, _w2)
       	//physics_fixture_add_point(_fix, -_l2, _w2)
       
       	//physics_fixture_set_density(_fix, 0);
       	//physics_fixture_set_restitution(_fix, 0.25);
        //physics_fixture_set_collision_group(_fix, PhyCollisionMain);
       	//
       	//
       	//var _inst = InstanceCreate(_x, _y, objPhyMaterial, {body: new PhyBodyBlock(_length, _w2*2)})
       	//physics_fixture_bind(_fix, _inst);
       	//physics_fixture_delete(_fix);
       	////_inst.phy_rotation = -_dir
       	//_inst.phy_fixed_rotation = true;
       	//
       	//_inst.phy_bullet = false;
        //
        //return _inst
    }
}