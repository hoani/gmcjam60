

function Joinable(_delegate=noone) constructor {
    delegate = _delegate
    
    
    static CanJoin = function(o) {
        if delegate != noone {
            return delegate.CanJoin(o)
        }
        return false
    }
    
    static GetJoinShape = function(o, shape) {
        if delegate != noone {
            return delegate.GetJoinShape(o, shape)
        }
        return new JoinCandidate(JOIN_TYPE_WELD, false, new Vec2(0, 0))
    }
}
