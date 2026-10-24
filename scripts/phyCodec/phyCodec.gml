function EncodePlacement(index, points){
    var _points = []
    for (var i = 0; i<array_length(points); i++) {
        array_push(_points, points[i].x, points[i].y)
    }
    var spec = { index: index, points: _points };
    return spec
}

function DecodePlacement(data) {
    var points = []
    for (var i = 0; i<array_length(data.points); i+=2) {
        array_push(points, new Vec2(data.points[i], data.points[i + 1]))
    }
    return {index: data.index, points, points}
}


function MaterialCodecTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    
    static test_subject="Material Codec Tests"

    
    static should_codec = function() {
        
        testCases = [
            { name: "simple", index: 0, points: [new Vec2(1, 2), new Vec2(100, 200)] },
            { name: "no points", index: 2, points: [] },
            { name: "many points", index: 2, points: [new Vec2(1, 2), new Vec2(100, 200), new Vec2(1, 2), new Vec2(100, 200), new Vec2(3, 4), new Vec2(100, 200)] },
        ]
        
        array_foreach(testCases, function(tc){
            var enc = EncodePlacement(tc.index, tc.points)
            var result = DecodePlacement(enc)
            
            assert_equal(array_length(tc.points), array_length(result.points))
            for (var i = 0; i < array_length(tc.points); i++) {
                assert_is_true(tc.points[i].IsEqual(result.points[i]))
            }
            assert_equal(tc.index, result.index)
        })
    }
}