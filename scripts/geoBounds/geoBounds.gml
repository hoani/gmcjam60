function Bounds(_x0, _y0, _x1, _y1) constructor {
    p0 = new Vec2(_x0, _y0)
    p1 = new Vec2(_x1, _y1)
    
    lines = [
        new Line(p0.x, p0.y, p0.x, p1.y),
        new Line(p0.x, p0.y, p1.x, p0.y),
        new Line(p1.x, p0.y, p1.x, p1.y),
        new Line(p0.x, p1.y, p1.x, p1.y),
    ]
    
    static Outside = function(shape) {
        return shape.OutsideOf(self)
    }
    
    static PointInside = function(p) {
        return (p.x >= p0.x) && (p.x <= p1.x)
            && (p.y >= p0.y) && (p.y <= p1.y)
    }
}



function BoundsTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    
    static test_subject="Bounds Tests"
    
    
    static should_determine_circle_outside = function() {
        testCases = [
            { name: "circle inside", b: new Bounds(0, 0, 10, 10), o: new Circle(new Vec2(5, 5), 1), expect: false },
            { name: "circle overlapping edge", b: new Bounds(0, 0, 10, 10), o: new Circle(new Vec2(11, 5), 2), expect: false },
            { name: "circle outside", b: new Bounds(0, 0, 10, 10), o: new Circle(new Vec2(15, 5), 2), expect: true },
            { name: "circle near corner", b: new Bounds(0, 0, 10, 10), o: new Circle(new Vec2(11, 11), 1.2), expect: true },
            { name: "circle encapsulates bounds", b: new Bounds(0, 0, 10, 10), o: new Circle(new Vec2(5, 5), 20), expect: false },
        ]
        
        array_foreach(testCases, function(tc){
            assert_that(tc.b.Outside(tc.o) == tc.expect, tc.name)
        })
    }
    
    static should_determine_line_outside = function() {
        testCases = [
            { name: "line inside", b: new Bounds(0, 0, 10, 10), o: new Line(2, 2, 8, 8), expect: false },
            { name: "line crossing edge", b: new Bounds(0, 0, 10, 10), o: new Line(5, 5, 15, 5), expect: false },
            { name: "line through bounds", b: new Bounds(0, 0, 10, 10), o: new Line(-5, 5, 15, 5), expect: false },
            { name: "line outside", b: new Bounds(0, 0, 10, 10), o: new Line(12, 0, 12, 10), expect: true },
            { name: "line past corner", b: new Bounds(0, 0, 10, 10), o: new Line(9, 12, 12, 9), expect: true },
        ]
        
        array_foreach(testCases, function(tc){
            assert_that(tc.b.Outside(tc.o) == tc.expect, tc.name)
        })
    }
    
    static should_determine_polygon_outside = function() {
        testCases = [
            { name: "polygon inside", b: new Bounds(0, 0, 10, 10), o: new Polygon([[2, 2], [2, 4], [4, 4], [4, 2]]), expect: false },
            { name: "polygon overlapping", b: new Bounds(0, 0, 10, 10), o: new Polygon([[8, 8], [8, 12], [12, 12], [12, 8]]), expect: false },
            { name: "polygon outside", b: new Bounds(0, 0, 10, 10), o: new Polygon([[12, 12], [12, 14], [14, 14], [14, 12]]), expect: true },
            { name: "polygon near corner", b: new Bounds(0, 0, 10, 10), o: new Polygon([[11, 9.5], [9.5, 11], [12, 12]]), expect: true },
            { name: "polygon encapsulates bounds", b: new Bounds(0, 0, 10, 10), o: new Polygon([[-5, -5], [-5, 15], [15, 15], [15, -5]]), expect: false },
        ]
        
        array_foreach(testCases, function(tc){
            assert_that(tc.b.Outside(tc.o) == tc.expect, tc.name)
        })
    }
}