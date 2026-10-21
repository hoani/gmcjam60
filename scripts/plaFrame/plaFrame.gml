function PlatFrame() constructor {
    hang = noone
    hang_exclude = noone;
    ground = {
        inst: noone,
        slope: 0,
        scos: 1,
        ssin: 0,
    }
    roof = noone
    wall = {
        left: noone,
        right: noone,
        pressing: false,
    }
    grav = noone
    excludes = []
    
    
    static UpdateExcludes = function(c) {
        var list = ds_list_create();
        var num = collision_rectangle_list(c.p0.x, c.p0.y, c.p1.x, c.p1.y, objPlaFloor, true, true, list, false);
        excludes = [];
        for (var i = 0; i < num; i++) {
            var item = ds_list_find_value(list, i);
            array_push(excludes, ds_list_find_value(list, i));
        }
        ds_list_destroy(list);
        if !array_contains(excludes, hang_exclude) {
            hang_exclude = noone
        }
    }
    
    static SetFloor = function(inst, x, y, width) {
        ground.inst = inst;
        if instance_exists(inst) {
            ground.slope = inst.FloorAngle(x, y, width);
        } else {
            ground.slope = 0;
        }
        ground.scos = dcos(ground.slope);
        ground.ssin = dsin(ground.slope);
    }
    
    static UpdateHang = function() {
        if hang != noone {
            if hang != wall.left && hang != wall.right && !array_contains(excludes, hang) {
                hang = noone;
            }
        }
    }
    
    static FloorIsSteppable = function() {
        if (ground.inst == noone) {
            return true
        }
    
        return (abs(ground.slope) <= 30.0);
    }
}