#macro JOIN_TYPE_WELD 0
#macro JOIN_TYPE_REV 1
#macro JOIN_TYPE_PRISMATIC 2

#macro BUILD_JOINT_DISTANCE 16

function JoinCandidate(_which=JOIN_TYPE_WELD, _success=false, _pos=new Vec2()) constructor {
    which = _which
    success = _success
    pos = _pos
    who = noone
    
    static With = function(_who) {
        who = _who
        return self
    }
}


function JoinablePoints(_pos, _point) {
    return _point.Subtract(pos).Distance2() < BUILD_JOINT_DISTANCE * BUILD_JOINT_DISTANCE;
}


function JoinPointRevolution(_pos, _point) {
	return new JoinCandidate(JOIN_TYPE_REV, JoinablePoints(_pos, _point), _point)
}


function JoinPointRing(_circle, _pos) {
    var _ring = new Ring(new Vec2(_inst.x, _inst.y), _circle.radius);
    var _point = _ring.ClosestPoint(_pos);
	
	return new JoinCandidate(JOIN_TYPE_WELD, JoinablePoints(_pos, _point), _point)
}


function JoinPointLine(_shape, _pos) {
	var _point = _shape.ClosestPoint(_pos);
	return new JoinCandidate(JOIN_TYPE_WELD, JoinablePoints(_pos, _point), _point)
}

function JoinPointShape(_shape, _pos) {
	var _point = _shape.ClosestEdgePoint(_pos);
	
	if JoinablePoints(_pos, _point) {
		return new JoinCandidate(JOIN_TYPE_WELD, true, _point)
	}
    
	return new JoinCandidate(JOIN_TYPE_WELD, _shape.Contains(_pos), _pos);
}


function JoinPointCircle(_circle, _pos) {
	if JoinablePoints(_circle.center, _pos) {
        return new JoinCandidate(JOIN_TYPE_WELD, true, _circle.center)
    }
    
	return JoinPointShape(_circle, _pos)
}

function JoinPointNoOp(_shape, _pos) {
	return new JoinCandidate(JOIN_TYPE_WELD, false, new Vector2(0, 0))
}
