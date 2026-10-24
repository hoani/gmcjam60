/// Create a geometry polygon
/// @arg {array} points - can be array of arrays, ie/ [[x0, y0], [x1, y1]...] or of Vec2s [p0, p1, ... etc]
function Polygon(_points) constructor {
    points = []
    lines = []
    
    static Shape = "Polygon"

    for (var i = 0; i < array_length(_points); i++) {
        var point = _points[i];
        if is_array(point) {
            array_push(points, new Vec2(point[0], point[1]));
        } else {
            array_push(points, point)
        }
    }
    
    if array_length(points) > 2 {
        if !Clockwise(points[0], points[1], points[2]) {
            points = array_reverse(points)
        }
    }
    
    for (var i = 0; i < array_length(points); i++) {
        var p0 = points[i]
        var p1 = points[(i + 1) % array_length(points)]
        array_push(lines, new Line(p0.x, p0.y, p1.x, p1.y))
    }

    static Contains = function(p) {
        for (var i = 0; i < array_length(lines); i++) {
            if lines[i].ClosestPoint(p).IsEqual(p) {
                return true // On an edge
            }
        }
        
        var intersects = 0;
        var linf = new Line(p.x, p.y, p.x + 1000000, p.y)
        for (var i = 0; i < array_length(lines); i++) {
            if (linf.Intersect(lines[i])) {
                intersects++
            }
        }
        return (intersects % 2) != 0 // Odd intersects = point inside
    }
    
    static OutsideOf = function(b) {
        for (var i = 0; i< array_length(points); i++) {
            if b.PointInside(points[i]) {
                return false
            }
        }
        
        for (var i = 0; i < array_length(b.lines); i++) {
            if _LineIntersect(b.lines[i]) {
                return false
            }
        }
        return true
    }
    
    
    static _LineIntersect = function(o) {
        for (var i = 0; i < array_length(lines); i++) {
            if (o.Intersect(lines[i])) {
                return true
            }
        }
        return Contains(o.p0) || Contains(o.p1)
    }
    
    static Intersect = function(o) {
        if !is_struct(o) || is_undefined(o.Shape) {
            return false;
        }
        if o.Shape == "Line" {
            return _LineIntersect(o)
        }
        if o.Shape == "Polygon" {
            for (var i = 0; i < array_length(lines); i++) {
                if (o._LineIntersect(lines[i])) {
                    return true
                }
            }
            for (var i = 0; i < array_length(o.points); i++) {
                if (Contains(o.points[i])) {
                    return true
                }
            }
            return false
        }
        if o.Shape == "Circle" {
            return o.Intersect(self)
        }
        return false
    }
    
    static ClosestPointLine = function(o) {
        var p = o.ClosestPointPolygon(self)
        return ClosestPoint(p)
    }
    
    static ClosestPointPolygon = function(o) {
        if !Intersect(o) {
            var candidate = points[0]
            var d2 = candidate.Subtract(o.ClosestPoint(candidate)).Distance2()
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

		return points[0].Multiply(1) // Failsafe - shouldn't get here.
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
    
    
    static ClosestPoint = function(p) {
        if Contains(p) {
            return p
        }
        
        return ClosestEdgePoint(p)
    }
    
    static ClosestEdgePoint = function(p) {
        var candidate = points[0];
        var cd2 = candidate.Subtract(p).Distance2()
        for (var i = 0; i<array_length(lines); i++) {
            var pline = lines[i].ClosestPoint(p)
            var ld2 = pline.Subtract(p).Distance2()
            if (ld2 < cd2) {
                candidate = pline
                cd2 = ld2
            }
        }
        
        return candidate
    }
    
    static Str = function() {
        var str = "["
        for (var i = 0; i<array_length(points); i++) {
            str += points[i].Str() + " "
        }
        
        return str + "]"
    }
} 





function PolygonTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    
    static test_subject="Polygon Tests"
    

    
    static should_determine_point_in_polygon = function() {
        testCases = [
            { name: "inside", poly: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), p: new Vec2(1, 1), expect: true },
            { name: "outside", poly: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), p: new Vec2(-0.5, 1), expect: false },
            { name: "inside triangle", poly: new Polygon([[0, 0], [0, 2], [2, 2]]), p: new Vec2(1, 1.5), expect: true },
            { name: "outside triangle", poly: new Polygon([[0, 0], [0, 2], [2, 2]]), p: new Vec2(1, 0.5), expect: false },
            { name: "on triangle", poly: new Polygon([[0, 0], [0, 2], [2, 2]]), p: new Vec2(1, 1), expect: true },
        ]
        
        array_foreach(testCases, function(tc){
            assert_that(tc.poly.Contains(tc.p) == tc.expect, tc.name)
        })
    }
    
    static should_intersect = function() {
        testCases = [
            { name: "line through triangle", poly: new Polygon([[0, 0], [0, 2], [2, 2]]), o: new Line(-2, 1, 2, 1), expect: true },
            { name: "line outside triangle", poly: new Polygon([[0, 0], [0, 2], [2, 2]]), o: new Line(-2, 1, -1, 1), expect: false },
            { name: "line encapsulated", poly: new Polygon([[0, 0], [0, 2], [2, 2]]), o: new Line(0.5, 1, 1, 1.5), expect: true },
            { name: "polygon overlap", poly: new Polygon([[0, 0], [0, 2], [2, 2]]), o: new Polygon([[1, 0], [1, 2], [3, 2]]), expect: true },
            { name: "polygon not overlap", poly: new Polygon([[0, 0], [0, 2], [2, 2]]), o: new Polygon([[-1.5, 1.5], [-1.5, 3.5], [0.5, 3.5]]), expect: false },
            { name: "polygon encapsulated", poly: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), o: new Polygon([[0.5, 0.5], [1, 1], [1, 0.5]]), expect: true },
        ]
        
        array_foreach(testCases, function(tc){
            assert_that(tc.poly.Intersect(tc.o) == tc.expect, tc.name)
            assert_that(tc.o.Intersect(tc.poly) == tc.expect, tc.name)
        })
    }
    
    static should_closest_point = function() {
        testCases = [
            { name: "inside", poly: new Polygon([[0, 0], [0, 2], [2, 2]]), p: new Vec2(0.5, 1), expect: new Vec2(0.5, 1) },
            { name: "outside", poly: new Polygon([[0, 0], [0, 2], [2, 2]]), p: new Vec2(2, 0), expect: new Vec2(1, 1) },
        ]
        
        array_foreach(testCases, function(tc){
            assert_that(tc.poly.ClosestPoint(tc.p).IsEqual(tc.expect), $"{tc.name}, expected {tc.expect.Str()}, got {tc.poly.ClosestPoint(tc.p).Str()}")
        })
    }
    
    
    static should_make_polygons_clockwise = function() {
        testCases = [
            { name: "ccw", poly: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]) },
            { name: "cw", poly: new Polygon([[0, 0], [0, 2], [-2, 2], [-2, 0]]) },
        ]
        
        array_foreach(testCases, function(tc){
            assert_is_true(Clockwise(tc.poly.points[0], tc.poly.points[1], tc.poly.points[2]), $"{tc.name}, {tc.poly.Str()} is counter clockwise")
        })
    }
    
    
    static should_find_closest_point_shape = function() {
        
        testCases = [
            { name: "line", poly: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), o: new Line(1, -1, 1, -2), expect: new Vec2(1, 0) },
            { name: "line intersect", poly: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), o: new Line(1, -1, 1, 10), expect: new Vec2(1, 1) },
            { name: "line partial", poly: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), o: new Line(1, 1, 1, -1), expect: new Vec2(1, 0) },
            { name: "line inside", poly: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), o: new Line(0.5, 0.5, 1.5, 1.5), expect: new Vec2(1.0, 1.0) },
            { name: "polygon", poly: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), o: new Polygon([[0.5, -1], [1, -2], [-1, -2]]), expect: new Vec2(0.5, 0) },
            { name: "polygon intersect", poly: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), o: new Polygon([[1, -1], [1, 3], [3, 3], [3, -1]]), expect: new Vec2(1, 1) },
            { name: "polygon inside", poly: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), o: new Polygon([[0.5, 0.5], [0.5, 1.5], [1.5, 1.5], [1.5, 0.5]]), expect: new Vec2(1, 1) },
            { name: "circle", poly: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), o: new Circle(new Vec2(0.5, 5), 1), expect: new Vec2(0.5, 2) },
            { name: "circle intersect", poly: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), o: new Circle(new Vec2(1, 3), 1.5), expect: new Vec2(1, 2) },
            { name: "circle inside", poly: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), o: new Circle(new Vec2(1, 1), 0.5), expect: new Vec2(1, 1) },
            { name: "line offset", poly: new Polygon([[10, 5], [10, 7], [12, 7], [12, 5]]), o: new Line(13, 6, 14, 6), expect: new Vec2(12, 6) },
            { name: "polygon offset", poly: new Polygon([[10, 5], [10, 7], [12, 7], [12, 5]]), o: new Polygon([[13, 6], [15, 5], [15, 7]]), expect: new Vec2(12, 6) },
            { name: "circle offset", poly: new Polygon([[10, 5], [10, 7], [12, 7], [12, 5]]), o: new Circle(new Vec2(11, 10), 1), expect: new Vec2(11, 7) },
        ]
        
        array_foreach(testCases, function(tc){
            assert_that(tc.poly.ClosestPointShape(tc.o).IsEqual(tc.expect), $"{tc.name}: {tc.poly.ClosestPointShape(tc.o).Str()} != {tc.expect.Str()}")
        })
    }
}
