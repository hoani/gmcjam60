/// Create a geometry polygon
/// @arg {array} points - can be array of arrays, ie/ [[x0, y0], [x1, y1]...] or of Vec2s [p0, p1, ... etc]
function Polygon(_points) constructor {
    points = []
    lines = []
    concave = undefined
    
    static Shape = "Polygon"

    for (var i = 0; i < array_length(_points); i++) {
        var point = _points[i];
        if is_array(point) {
            array_push(points, new Vec2(point[0], point[1]));
        } else {
            array_push(points, point)
        }
    }
    
    for (var i = 0; i < array_length(points); i++) {
        var p0 = points[i]
        var p1 = points[(i + 1) % array_length(points)]
        array_push(lines, new Line(p0.x, p0.y, p1.x, p1.y))
    }
    
    if array_length(points) > 2 {
        if !Clockwise(points[0], points[1], points[2]) {
            points = array_reverse(points)
        }
    }


    static Contains = function(p) {
        var intersects = 0;
        var linf = new Line(p.x, p.y, p.x + 1000000, p.y)
        for (var i = 0; i < array_length(lines); i++) {
            if (linf.Intersect(lines[i])) {
                intersects++
            }
        }
        return (intersects % 2) != 0 // Odd intersects = point outside
    }
    
    static Intersect = function(o) {
        if !is_struct(o) || is_undefined(o.Shape) {
            return false;
        }
        if o.Shape == "Line" {
            for (var i = 0; i < array_length(lines); i++) {
                if (o.Intersect(lines[i])) {
                    return true
                }
            }
            return Contains(o.p0) || Contains(o.p1)
        }
        if o.Shape == "Polygon" {
            for (var i = 0; i < array_length(lines); i++) {
                if (o.Intersect(lines[i])) {
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
    }
    
    static ClosestPoint = function(p) {
        if Contains(p) {
            return p
        }
        
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
            assert_that(tc.poly.ClosestPoint(tc.p).IsEqual(tc.expect), $"{tc.name}, expected {tc.expect.Str()}, got {tc.poly.ClosestPoint(tc.p)}")
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
}
