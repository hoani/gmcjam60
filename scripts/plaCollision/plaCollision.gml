function CollisionCoords(_x, _y, dx0, dy0, dx1, dy1) {
    return { p0: CollisionPoint(_x, _y, dx0, dy0), p1: CollisionPoint(_x, _y, dx1, dy1) }
}

function CollisionPoint(_x, _y, dx0, dy0) {
    return { x: _x + dx0, y: _y + dy0 }
}

function CheckCollisionRectangle(r, obj, excludes=[], current=noone) {
    var list = ds_list_create();
    var num = collision_rectangle_list(r.p0.x, r.p0.y, r.p1.x, r.p1.y, obj, true, true, list, false);
    var result = noone;
    for (var i = 0; i < num; i++){
        var candidate = ds_list_find_value(list, i);
        if !array_contains(excludes, candidate) {
            result = candidate;
            if candidate == current || current == noone {
                break;
            }
        }
    }
    ds_list_destroy(list);
    return result;
}


function CheckCollisionLine(l, obj, excludes=[], current=noone) {
    var list = ds_list_create();
    var num = collision_line_list(l.p0.x, l.p0.y, l.p1.x, l.p1.y, obj, true, true, list, false);
    var result = noone;
    for (var i = 0; i < num; i++){
        var candidate = ds_list_find_value(list, i);
        if !array_contains(excludes, candidate) {
            result = candidate;
            if candidate == current || current == noone {
                break;
            }
        }
    }
    ds_list_destroy(list);
    return result;
}

function CheckCollisionPoint(p, obj, excludes=[], current=noone) {
    var list = ds_list_create();
    var num = collision_point_list(p.x, p.y, obj, true, true, list, false);
    var result = noone;
    for (var i = 0; i < num; i++){
        var candidate = ds_list_find_value(list, i);
        if !array_contains(excludes, candidate) {
            result = candidate;
            if candidate == current || current == noone {
                break;
            }
        }
    }
    ds_list_destroy(list);
    return result;
}