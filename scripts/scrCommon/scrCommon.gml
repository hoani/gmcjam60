
/// Valid callable that does nothing at all.
/// @arg a - a to f defines a series of unused placeholders in case do_nothing takes arguments.
function FuncNone(a=undefined, b=undefined, c=undefined, d=undefined, e=undefined, f=undefined){
}

/// Check a value is within some bounds
/// @arg _value - value to check
/// @arg _min - minimum value
/// @arg _max - maximum bound
/// @return bool if value is within the bounds
function Within(v, vmin, vmax){
    return (v >= vmin && v <= vmax);
}

/// Wrap an index to be between zero and a specific length
/// @arg i index
/// @arg len length to wrap at
/// @return wrapped index.
function WrapIndex(i, len) {
    if len <= 0 {
        return i;
    }
    
    while i < 0 {
        i += len;
    }
    while i >= len {
        i -= len;
    }
    return i;
}


function CommonTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    static test_subject="Common Tests"
    
    static should_do_within = function() {
        var _test_cases = [
            { name: "between", value: 1, min: 0, max: 2, expected: true },
            { name: "at min", value: 0, min: 0, max: 2, expected: true },
            { name: "at max", value: 2, min: 0, max: 2, expected: true },
            { name: "below", value: -1, min: 0, max: 2, expected: false },
            { name: "above", value: 3, min: 0, max: 2, expected: false },
            { name: "negative bounds", value: -5, min: -6, max: -5, expected: true },
        ];
        
        for (var i = 0; i < array_length(_test_cases); i++) {
            var _tc = _test_cases[i];
            assert_equal(_tc.expected, Within(_tc.value, _tc.min, _tc.max), _tc.name);
        }
    }
    
    static should_wrap_index = function() {
        var _test_cases = [
            { name: "invalid length", value: 5, length: 0, expected: 5 },
            { name: "within length", value: 5, length: 10, expected: 5 },
        ];
        
        for (var i = 0; i < array_length(_test_cases); i++) {
            var _tc = _test_cases[i];
            assert_equal(_tc.expected, WrapIndex(_tc.value, _tc.length), _tc.name);
        }
    }
}