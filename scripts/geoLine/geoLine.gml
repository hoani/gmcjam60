 /// Create a geometry line
/// @arg {Real} x0 - start x
/// @arg {Real} y0 - start y
/// @arg {Real} x1 - end x
/// @arg {Real} y1 - end y
function Line(_x0, _y0, _x1, _y1) constructor {
    p0 = new Vec2(_x0, _y0)
    p1 = new Vec2(_x1, _y1)

    delta = p1.Subtract(p0);
    
    static Shape = "Line"
    
    
    static Direction = function(){
        return delta.Direction()
    }
    
    static Distance2 = function() {
        return delta.Distance2()
    } 
    
    static Distance = function() {
        return delta.Distance()
    } 
    
    static Intersect = function(o) {
        if !is_struct(o) || is_undefined(o.Shape) {
            return false;
        }
        if o.Shape == "Line" {
            return Clockwise(p0, p1, o.p0) != Clockwise(p0, p1, o.p1) && Clockwise(o.p0, o.p1, p0) != Clockwise(o.p0, o.p1, p1)
        }
        if o.Shape == "Polygon" {
            return o.Intersect(self)
        }
        if o.Shape == "Circle" {
            return o.Intersect(self)
        }
        return false
    }
    

    static ClosestPoint = function(p) {
        var uab = delta.Unit();
        var d = p.Subtract(p0).Dot(uab);
        
        // Closest point assuming our line is infinite
        var pinf = p0.Add(uab.Multiply(d));
        
        return pinf.Clamp(p0, p1)
    }
    
    static Str = function() {
        return $"({p0.x}, {p0.y}, {p1.x}, {p1.y})"
    }
    
    
} 


// Determines if three points are arranged in a clockwise manner.
// Note: the original algorithm calls this counterclockwise, but gamemaker has y pointing down.
//       it actually makes no difference to the algorithm
function Clockwise(a, b, c) {
    return (c.y - a.y)*(b.x - a.x) > (b.y - a.y)*(c.x - a.x)
}



function LineTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    
    static test_subject="Line Tests"
    
    static should_segment = function() {

        for (var i = 5; i < 10; i++) {
            var v = DirectionToVec2(i*75);
            var l = new Line(5, 5, 5 + v.x*i, 5 + v.y*i);
            assert_that((l.Distance() - i) < 1/64, $"distance of {l.Str()} does not match {i}");
            assert_that((l.Distance2() - i*i) < 1/64, $"distance of {l.Str()} does not match {i}");
        }
        
        for (var i = 0; i<360; i++) {
            var dir = i;
            var v = DirectionToVec2(i);
            var l = new Line(100, 120, 100 + v.x*5, 120 + v.y*5)
            assert_that(angle_difference(l.Direction(), dir) < 1/64, $"direction of {l.Str()}) does not match {dir}");
        }
    }
    
    static should_intersect_lines = function() {
        testCases = [
            { name: "basic", l0: new Line(-1, 0, 1, 0), l1: new Line(0, 1, 0, -1), expect: true },
            { name: "angle", l0: new Line(-1, -1, 1, 1), l1: new Line(-1, 0, 1, 0), expect: true },
            { name: "parallel", l0: new Line(1, 1, 1, 3), l1: new Line(0, 1, 0, 3), expect: false },
            { name: "not touching", l0: new Line(-1, 0, 1, 0), l1: new Line(0, 1, 0, 3), expect: false },
        ]
        
        array_foreach(testCases, function(tc){
            assert_that(tc.l0.Intersect(tc.l1) == tc.expect, tc.name)
        })
    }
    
    static should_find_closest_point = function() {
        testCases = [
            { name: "basic", l0: new Line(-1, 0, 1, 0), l1: new Vec2(0, 1), expect: new Vec2(0, 0) },
            { name: "gets clamped", l0: new Line(-1, 0, 1, 0), l1: new Vec2(-3, 1), expect: new Vec2(-1, 0) },
            { name: "angled", l0: new Line(-1, -1, 2, 2), l1: new Vec2(-3, 3), expect: new Vec2(0, 0) },
        ]
        
        array_foreach(testCases, function(tc){
            assert_that(tc.l0.ClosestPoint(tc.l1).IsEqual(tc.expect), $"{tc.name}: {tc.l0.ClosestPoint(tc.l1).Str()} != {tc.expect.Str()}")
        })
    }
}
