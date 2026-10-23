

function Joinable(_delegate=noone) constructor {
    joinDelegate = _delegate
    
    static GetJoin = function(shape) {
        if joinDelegate != noone {
            return joinDelegate.GetJoin(shape)
        }
        return new JoinCandidate(JOIN_TYPE_WELD, false, new Vec2(0, 0))
    }
}


