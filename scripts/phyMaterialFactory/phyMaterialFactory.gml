
#macro MATERIAL_UNKNOWN -1
#macro MATERIAL_BEAM 0
#macro MATERIAL_BLOCK (MATERIAL_BEAM + 1)
#macro MATERIAL_BOX (MATERIAL_BLOCK + 1)
#macro MATERIAL_BALL (MATERIAL_BOX + 1)
#macro MATERIAL_WHEEL (MATERIAL_BALL + 1)
#macro MATERIAL_EGG (MATERIAL_WHEEL + 1)
#macro MATERIAL_TOTAL (MATERIAL_EGG + 1)


function MaterialFactory() constructor {
    
    materials = [
        new MaterialBeam(),
        new MaterialBlock(),
        new MaterialBox(),
        new MaterialBall(),
        new MaterialWheel(),
        new MaterialEgg(),
    ]
    
    static PlaceEncoded = function(b64enc) {
        var data = DecodePlacement(b64enc)
        
        var p = Placement(data.index)
        var inst = noone
        
        // Pretend like we are placing these by hand
        for (var i = 0; i<array_length(data.points); i++) {
            p.Drag(data.points[i].x, data.points[i].y)
            inst = p.Confirm(data.points[i].x, data.points[i].y)
        }
        return inst
    }
    
    
    static Placement = function(index) {
        if index < 0 || index >= MATERIAL_TOTAL {
            DebugError($"Invalid index {index} is not a material", true)
            index = MATERIAL_BALL;
        }
        return materials[index].Placement()
        
    }
}


function EncodedPlacementEqual(a, b) {
    return array_equals(a.points, b.points) && a.index == b.index
}

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

