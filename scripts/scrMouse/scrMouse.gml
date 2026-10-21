function MouseHandler() constructor {
    last = new Pos(mouse_x, mouse_y);
    current = new Pos(mouse_x, mouse_y);
    
    static Update = function() {
        last.x = current.x;
        last.y = current.y;
        current.x = mouse_x
        current.y = mouse_y;
    }
    
    static Changed = function(amount=1) {
        return point_distance(last.x, last.y, current.x, current.y) >= amount;
    }
    
    static Get = function() {
        return current;
    }
}