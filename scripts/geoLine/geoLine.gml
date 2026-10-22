function PointsLine(p0, p1) {
    return new Line(p0.x, p0.y, p1.x, p1.y)
}


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
    
    static Center = function(){
        return p0.Add(p1).Multiply(0.5)
    }
    
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
    
    static ClosestPointLine = function(o) {
        if !Intersect(o) {
            var candidate = ClosestPoint(o.p0)
            var cd = candidate.Subtract(o.p0).Distance2()
            
            var c = ClosestPoint(o.p1)
            var d = c.Subtract(o.p1).Distance2()
            if d < cd { 
                candidate = c
                cd = d 
            }
            
            d = p0.Subtract(o.ClosestPoint(p0)).Distance2()
            if d < cd { 
                candidate = p0.Multiply(1)
                cd = d 
            }
            
            d = p1.Subtract(o.ClosestPoint(p1)).Distance2()
            if d < cd { 
                candidate = p1.Multiply(1)
                cd = d 
            }
            
            return candidate
        }
        
        // Follows https://www.cuemath.com/geometry/intersection-of-two-lines/
        var a = p1.y - p0.y;
       	var b = p0.x - p1.x;
       	var c = p0.y * (-b) - a * p0.x;
        
        var oa = o.p1.y - o.p0.y;
       	var ob = o.p0.x - o.p1.x;
       	var oc = o.p0.y * (-ob) - oa * o.p0.x;
        
		var _x = (b * oc - ob * c)/(a * ob - oa * b);
		var _y = (c * oa - oc * a)/(a * ob - oa * b);

		return new Vec2(_x, _y)
    }
    
    static ClosestPointPolygon = function(o) {
        if !Intersect(o) {
            var candidate = p0
            var d2 = p0.Subtract(o.ClosestPoint(p0)).Distance2()
            for (var i = 0; i<array_length(o.lines); i++) {
                var p = ClosestPointLine(o.lines[i])
                var pd2 = p.Subtract(o.ClosestPoint(p)).Distance2()
                if pd2 < d2 {
                    candidate = p
                    d2 = pd2
                }
            }
            return candidate
        }
        
        var sum = new Vec2(0,0)
        var n = 0
        for (var i = 0; i<array_length(o.lines); i++) {
            var l = o.lines[i]
            if l.Intersect(self) {
                sum = sum.Add(ClosestPointLine(l))
                n+=1
            }
        }
        if n > 0 {
            return sum.Multiply(1/n)
        }

		return p0.Add(p1).Multiply(0.5) // Failsafe - shouldn't get here.
    }
    
    static ClosestPointCircle = function(o) {
        return ClosestPoint(o.center)
    }
    
    
    static ClosestPointShape = function(o) {
        if !is_struct(o) || is_undefined(o.Shape) {
            return undefined;
        }
        if o.Shape == "Line" {
            return ClosestPointLine(o)
        }
        if o.Shape == "Polygon" {
            return ClosestPointPolygon(o)
        }
        if o.Shape == "Circle" {
            return ClosestPointCircle(o)
        }
        return false
    }
    
    static ClosestPointInfinite = function(p) {
        var uab = delta.Unit();
        var d = p.Subtract(p0).Dot(uab);
        
        // Closest point assuming our line is infinite
        return p0.Add(uab.Multiply(d));
    }

    static ClosestPoint = function(p) {
        return ClosestPointInfinite(p).Clamp(p0, p1)
    }
    
     static ClosestEdgePoint = function(p) {
        return ClosestPoint(p)
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
            { name: "reverse", l0: new Line(1, 0, -1, 0), l1: new Vec2(0, 1), expect: new Vec2(0, 0) },
            { name: "gets clamped", l0: new Line(-1, 0, 1, 0), l1: new Vec2(-3, 1), expect: new Vec2(-1, 0) },
            { name: "angled", l0: new Line(-1, -1, 2, 2), l1: new Vec2(-3, 3), expect: new Vec2(0, 0) },
        ]
        
        array_foreach(testCases, function(tc){
            assert_that(tc.l0.ClosestPoint(tc.l1).IsEqual(tc.expect), $"{tc.name}: {tc.l0.ClosestPoint(tc.l1).Str()} != {tc.expect.Str()}")
        })
    }
    
    static should_find_closest_point_shape = function() {
        testCases = [
            { name: "line", l0: new Line(-1, 0, 1, 0), o: new Line(0.5, 1, 0.5, 2), expect: new Vec2(0.5, 0) },
            { name: "line intersect", l0: new Line(-1, 0, 1, 0), o: new Line(0, 1, 0, -1), expect: new Vec2(0, 0) },
            { name: "line near endpoint", l0: new Line(0, 0, 10, 0), o: new Line(9, 1, 20, -0.5), expect: new Vec2(10, 0) },
            { name: "line angled", l0: new Line(0, 0, 4, 4), o: new Line(4, 0, 3, 1), expect: new Vec2(2, 2) },
            { name: "line angled clamped", l0: new Line(0, 0, 4, 4), o: new Line(6, 5, 7, 5), expect: new Vec2(4, 4) },
            { name: "line angled reversed", l0: new Line(4, 4, 0, 0), o: new Line(6, 5, 7, 5), expect: new Vec2(4, 4) },
            { name: "polygon", l0: new Line(-1, 0, 1, 0), o: new Polygon([[0.5, 1], [1, 2], [-1, 2]]), expect: new Vec2(0.5, 0) },
            { name: "polygon intersect", l0: new Line(-1, 1, 3, 1), o: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), expect: new Vec2(1, 1) },
            { name: "polygon partial", l0: new Line(1, 1, 3, 1), o: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), expect: new Vec2(2, 1) },
            { name: "polygon inside", l0: new Line(0.5, 0.5, 1.5, 1.5), o: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), expect: new Vec2(1.0, 1.0) },
            { name: "circle", l0: new Line(-1, 0, 1, 0), o: new Circle(new Vec2(0.5, 5), 1), expect: new Vec2(0.5, 0) },
            { name: "circle intersect", l0: new Line(-3, 1, 3, 1), o: new Circle(new Vec2(0, 0), 2), expect: new Vec2(0, 1) },
            { name: "circle inside", l0: new Line(-1, 0.5, 1, 0.5), o: new Circle(new Vec2(0, 0), 2), expect: new Vec2(0, 0.5) },
            { name: "line offset", l0: new Line(10, 5, 14, 5), o: new Line(12, 7, 12, 9), expect: new Vec2(12, 5) },
            { name: "polygon offset", l0: new Line(10, 5, 14, 5), o: new Polygon([[12, 7], [13, 9], [11, 9]]), expect: new Vec2(12, 5) },
            { name: "circle offset", l0: new Line(10, 5, 14, 5), o: new Circle(new Vec2(13, 8), 1), expect: new Vec2(13, 5) },
        ]
        
        array_foreach(testCases, function(tc){
            assert_that(tc.l0.ClosestPointShape(tc.o).IsEqual(tc.expect), $"{tc.name}: {tc.l0.ClosestPointShape(tc.o).Str()} != {tc.expect.Str()}")
        })
    }
}
