function Joinable(_delegate=noone) constructor {
    joinDelegate = _delegate
    
    static GetJoin = function(type, shape) {
        if joinDelegate != noone {
            return joinDelegate.GetJoin(type, shape)
        }
        return new JoinCandidate(JOIN_TYPE_WELD, false, new Vec2(0, 0))
    }
}


function EdgeWeldJoiner(_shape) : Joinable() constructor {
    shape = _shape
    
    static GetJoin = function(_type, _other) {
        var p1 = _other.ClosestPointShape(shape)
        
        switch _type {
            case JOIN_TYPE_WELD:
                return JoinPointEdge(shape, p1)
            default:
                return JoinPointShape(shape, p1, _type)
        }
    }
}