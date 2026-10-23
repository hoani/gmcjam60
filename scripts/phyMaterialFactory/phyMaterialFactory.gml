
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
        for (var i = 0; i<array_length(data.points); i++) {
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


