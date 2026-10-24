/// Create a geometry circle
function Circle(_center, _radius) constructor {
    center = _center
    radius = _radius
    
    static Shape = "Circle"


    static Contains = function(p) {
        return p.Subtract(center).Distance2() <= radius*radius;
    }
    
    static Intersect = function(o) {
        if !is_struct(o) || is_undefined(o.Shape) {
            return false;
        }
        if o.Shape == "Line" {
            return Contains(o.ClosestPoint(center))
        }
        if o.Shape == "Polygon" {
            for (var i = 0; i < array_length(o.lines); i++) {
                if Intersect(o.lines[i]) {
                    return true;
                }
            }
            return o.Contains(center)
        }
        if o.Shape == "Circle" {
            return center.Subtract(o.center).Distance() <= (radius + o.radius)
        }
    }
    
    static OutsideOf = function(b) {
        // Find closest point to center
        var _v = new Vec2(
            clamp(center.x, b.p0.x, b.p1.x),
            clamp(center.y, b.p0.y, b.p1.y)
        )
        var _dp = _v.Subtract(center)
        return _dp.Distance2() > (radius * radius);
    }
    
    static ClosestPointLine = function(o) {
        var p = o.ClosestPointCircle(self)
        return ClosestPoint(p)
    }
    
    static ClosestPointPolygon = function(o) {
        var p = o.ClosestPointCircle(self)
        return ClosestPoint(p)
    }
    
    static ClosestPointCircle = function(o) {
        if Intersect(o) {
            var dv = o.center.Subtract(center)
            var t = (dv.Distance() + radius - o.radius) / 2
            return ClosestPoint(center.Add(dv.Unit().Multiply(t)))
        }
        
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
        if (Contains(p)) {
            return p
        }
        
        return ClosestEdgePoint(p)
    }
    
    static ClosestEdgePoint = function(p) {
        if (p.IsEqual(center)) {
            return p.Add(new Vec2(0, -radius))
        }
        
        return center.Add(p.Subtract(center).Unit().Multiply(radius))
    }
    
    
    static Str = function() {
        return $"({center.Str()}, r {radius})"
    }
} 



function CircleTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    
    static test_subject="Circle Tests"
    

    
    static should_determine_point_inside = function() {
        testCases = [
            { name: "inside", circle: new Circle(new Vec2(0, 0), 5), p: new Vec2(1, 1), expect: true },
        ]
        
        array_foreach(testCases, function(tc){
            assert_that(tc.circle.Contains(tc.p) == tc.expect, tc.name)
        })
    }
    
    static should_intersect = function() {
        testCases = [
            { name: "line inside", circle: new Circle(new Vec2(0, 0), 5), o: new Line(-2, 1, 2, 1), expect: true },
            { name: "line outside", circle: new Circle(new Vec2(0, 0), 0.5), o: new Line(-2, 1, -1, 1), expect: false },
            { name: "line overlap", circle: new Circle(new Vec2(0, 0), 5), o: new Line(-8, 1, 8, 1), expect: true },
            
            { name: "polygon inside", circle: new Circle(new Vec2(0, 0), 5), o: new Polygon([[0, 0], [0, 2], [2, 2]]), expect: true },
            { name: "polygon circle inside", circle: new Circle(new Vec2(1, 1), 0.5), o: new Polygon([[0, 0], [0, 2], [2, 2], [2, 0]]), expect: true },
            { name: "polygon outside", circle: new Circle(new Vec2(-6, 0), 5), o: new Polygon([[0, 0], [0, 2], [2, 2]]), expect: false },
            { name: "polygon overlap", circle: new Circle(new Vec2(-1, 0), 2), o: new Polygon([[0, 0], [0, 2], [2, 2]]), expect: true },
            
            { name: "circle inside", circle: new Circle(new Vec2(0, 0), 5), o: new Circle(new Vec2(1, 0), 1), expect: true },
            { name: "circle outside", circle: new Circle(new Vec2(-3, 0), 5), o: new Circle(new Vec2(8, 0), 5), expect: false },
            { name: "circle overlap", circle: new Circle(new Vec2(-1, 0), 2), o: new Circle(new Vec2(4, 0), 5), expect: true },
        ]
        
        array_foreach(testCases, function(tc){
            assert_that(tc.circle.Intersect(tc.o) == tc.expect, tc.name)
            assert_that(tc.o.Intersect(tc.circle) == tc.expect, tc.name)
        })
    }
    
    static should_closest_point = function() {
        testCases = [
            { name: "inside", circle: new Circle(new Vec2(0, 0), 5), p: new Vec2(2, 0), expect: new Vec2(2, 0) },
            { name: "outside", circle: new Circle(new Vec2(0, 0), 5), p: new Vec2(0, 100), expect: new Vec2(0, 5) },
        ]
        
        array_foreach(testCases, function(tc){
            assert_that(tc.circle.ClosestPoint(tc.p).IsEqual(tc.expect), $"{tc.name}, expected {tc.expect.Str()}, got {tc.circle.ClosestPoint(tc.p)}")
        })
    }
    
    
    static should_find_closest_point_shape = function() {
        testCases = [
            { name: "line", c: new Circle(new Vec2(0, 0), 2), o: new Line(3, -1, 3, 1), expect: new Vec2(2, 0) },
            { name: "line intersect", c: new Circle(new Vec2(0, 0), 2), o: new Line(-3, 1, 3, 1), expect: new Vec2(0, 1) },
            { name: "line inside", c: new Circle(new Vec2(0, 0), 2), o: new Line(-1, 0.5, 1, 0.5), expect: new Vec2(0, 0.5) },
            { name: "polygon", c: new Circle(new Vec2(0, 0), 2), o: new Polygon([[3, -1], [3, 1], [5, 0]]), expect: new Vec2(2, 0) },
            { name: "polygon intersect", c: new Circle(new Vec2(0, 0), 2), o: new Polygon([[1, -3], [1, 3], [5, 3], [5, -3]]), expect: new Vec2(1, 0) },
            { name: "circle", c: new Circle(new Vec2(0, 0), 2), o: new Circle(new Vec2(0, 5), 1), expect: new Vec2(0, 2) },
            { name: "circle intersect", c: new Circle(new Vec2(0, 0), 2), o: new Circle(new Vec2(3, 0), 2), expect: new Vec2(1.5, 0) },
            { name: "line offset", c: new Circle(new Vec2(10, 5), 2), o: new Line(13, 4, 13, 6), expect: new Vec2(12, 5) },
            { name: "polygon offset", c: new Circle(new Vec2(10, 5), 2), o: new Polygon([[10, 8], [12, 8], [11, 10]]), expect: new Vec2(10, 7) },
            { name: "circle offset", c: new Circle(new Vec2(10, 5), 2), o: new Circle(new Vec2(5, 5), 1), expect: new Vec2(8, 5) },
        ]
        
        array_foreach(testCases, function(tc){
            assert_that(tc.c.ClosestPointShape(tc.o).IsEqual(tc.expect), $"{tc.name}: {tc.c.ClosestPointShape(tc.o).Str()} != {tc.expect.Str()}")
        })
    }
}
