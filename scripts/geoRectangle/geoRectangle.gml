

function Rectangle(c, w, h, angle) {
    
    var dx = dcos(angle)
    var dy = -dsin(angle)
    
    var w2 = dx * w/2 + dy * h/2
    var h2 = dx * h/2 + dy * w/2
    
    return new Polygon([
        c.Add(new Vec2(-w2, -h2)),
        c.Add(new Vec2(w2, -h2)),
        c.Add(new Vec2(w2, h2)),
        c.Add(new Vec2(-w2, h2)),
    ]) 
} 





function RectangleTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    
    static test_subject="Rectangle Tests"
    

    
    static should_make_polygon = function() {
        testCases = [
            { name: "simple", rec: Rectangle(new Vec2(1, 1), 4, 2, 0), expect: new Polygon([[-1, 0], [3, 0], [3, 2], [-1, 2]]) },
            { name: "rotated", rec: Rectangle(new Vec2(1, 1), 4, 2, 90), expect: new Polygon([[2, 3], [0, 3], [0, -1], [2, -1]]) },
        ]
        
        array_foreach(testCases, function(tc){
            // Just do some rounding to remove annoying esp errors
            array_foreach(tc.rec.points, function(p) {
                p.x = round(p.x)
                p.y = round(p.y)
            })
            assert_equal(tc.rec.Str(), tc.expect.Str(), $"{tc.name} {tc.rec.Str()} != {tc.expect.Str()}")
        })
    }
    
}
