/// Create a vec2 point
/// @arg {Real} _x - initial x
/// @arg {Real} _y - initial y
function Vec2(_x = 0.0, _y = 0.0) constructor{
    x = _x;
    y = _y;
    
    
    static Direction = function(){
        return point_direction(0, 0, x, y)
    }
    
    static Distance2 = function() {
        return x*x + y*y
    } 
    
    static Distance = function() {
        return point_distance(0, 0, x, y)
    } 
    
    static Add = function(o) {
        return new Vec2(x + o.x, y + o.y)
    }
    
    static Subtract = function(o) {
        return new Vec2(x - o.x, y - o.y)
    }
    
    static Unit = function(){
        var _d = Distance()
        if (_d == 0) {
            return new Vec2(0, 0);
        }
        return new Vec2(x/_d, y/_d)
    }
    
    static IsZero = function() {
        return x == 0 && y == 0
    }
    
    static IsEqual = function(o) {
        return x == o.x && y == o.y
    }
    
    static Dot = function(o) {
        return x*o.x + y*o.y
    }
    
    static Multiply = function(n) {
        return new Vec2(x * n, y *n)
    }
    
    static Accelerate = function(accel, limit=undefined) {
        x += accel.x;
        y += accel.y;
        
        if !is_undefined(limit) {
            var dist = Distance()
            if dist > limit {
                var limited = Unit().Multiply(limit)
                x = limited.x;
                y = limited.y;
            }
        }
    }
    
    static Decelerate = function(amount) {
        if IsZero() {
            return
        }
        var d = Distance()
        if d <= amount {
            x = 0
            y = 0
            return
        }
        var u = Unit();
        
        x -= amount * u.x;
        y -= amount * u.y;
    }
    
    static SetDirection = function(dir) {
        var d = Distance()
        x = d * dcos(dir)
        y = d * -dsin(dir)
        return self
    }
    
    static Rotate = function(angle) {
        var d = Distance()
        angle += Direction()
        x = d * dcos(angle)
        y = d * -dsin(angle)
        return self
    }
    
    static SetDistance = function(dist) {
        var d = Distance()
        if d == 0 {
            x = dist
            y = 0
            return self
        }
        x = dist * x / d
        y = dist * y / d
        return self
    }
    
    // Clamps assuming this point is on an infinite line including the segment p0, p1
    static Clamp = function(p0, p1) {
        if p0.x == p1.x {
            return new Vec2(x, clamp(y, min(p0.y, p1.y), max(p0.y, p1.y)))
        }
        if (p0.y == p1.y) {
            return new Vec2(clamp(x, min(p0.x, p1.x), max(p0.x, p1.x)), y)
        }
        if p0.x > p1.x {
            var px = p1
            p1 = p0
            p0 = px
        }
        var _x = clamp(x, p0.x, p1.x);
        if (_x == p0.x) {
            return new Vec2(p0.x, p0.y)
        }
        if (_x == p1.x) {
            return new Vec2(p1.x, p1.y)
        }
        
        return new Vec2(x, y)
    }
    
    static Str = function() {
        return $"({x}, {y})"
    }
} 

function DirectionToVec2(dir) {
    var v = new Vec2(1, 0);
    v.SetDirection(dir)
    return v
}


function Vec2Tests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    
    static test_subject="Vec2 Tests"
    
    static should_convert_direction = function() {
        // Basic checks
        assert_equal(DirectionToVec2(0.0).x, 1.0); 
        assert_equal(DirectionToVec2(0.0).y, 0.0);
        
        assert_equal(DirectionToVec2(90.0).x, 0.0); 
        assert_equal(DirectionToVec2(90.0).y, -1.0);
        
        // Convert to and from
        for (var i = 0; i<360; i++) {
            var dir = i;
            var v = DirectionToVec2(i);
            assert_that(abs(angle_difference(v.Direction(), dir)) < 1/64, $"direction of ({v.x}, {v.y}) does not match {dir}");
        }
    }
}
