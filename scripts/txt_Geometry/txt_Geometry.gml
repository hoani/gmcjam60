
function Pos(_x, _y) constructor {
	x = _x
    y = _y
}

/// Box geometry
function Box(_width, _height) constructor {
	w = _width
    h = _height
    
    static Pad = function(hpad, vpad) {
        return new Box(max(0, w - 2 * hpad), max(0, h - 2 *vpad))
    }
    
    static Contains = function(o) {
        return Inside(o.w, o.h)
    }
    
    static Inside = function(x, y) {
        return x >= 0 && x <= w && y >= 0 && y <= h;
    }
}


function PositionedBox(_x, _y, _w, _h) : Box(_w, _h) constructor {
    x = _x;
    y = _y;
    x0 = _x - w/2;
    x1 = _x + w/2;
    y0 = _y - h/2;
    y1 = _y + h/2;
    
    static SetX = function(_x) {
        x = _x;
        _Refresh();
    }
    
    static SetY = function(_y) {
        y = _y;
        _Refresh();
    }
    
    static _Refresh = function() {
        x0 = x - w/2;
        x1 = x + w/2;
        y0 = y - h/2;
        y1 = y + h/2;
    }
    
    static Inside = function(x, y) {
        return x >= x0 && x <= x1 && y >= y0 && y <= y1;
    }
}


function BoxTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    static test_subject="Box Tests"
    
    static should_contains = function() {
        
        var _test_cases = [
            { name: "contained", base: new Box(5, 5), other: new Box(1, 1), expected: true },            
            { name: "equal", base: new Box(5, 5), other: new Box(5, 5), expected: true },            
            { name: "too_wide", base: new Box(5, 15), other: new Box(6, 4), expected: false },
            { name: "too_tall", base: new Box(15, 5), other: new Box(2, 6), expected: false },
        ];
        
        for (var i = 0; i < array_length(_test_cases); i++) {
            var _tc = _test_cases[i];
            assert_equal(_tc.expected, _tc.base.Contains(_tc.other), _tc.name);
        }
    }
    
    static should_inside = function() {
        
        var _test_cases = [
            { name: "within", base: new Box(5, 15), pos: {x: 3, y: 13}, expected: true },            
            { name: "outside", base: new Box(5, 15), pos: {x: 10, y:2}, expected: false },
        ];
        
        for (var i = 0; i < array_length(_test_cases); i++) {
            var _tc = _test_cases[i];
            assert_equal(_tc.expected, _tc.base.Inside(_tc.pos.x, _tc.pos.y), _tc.name);
        }
    }
}