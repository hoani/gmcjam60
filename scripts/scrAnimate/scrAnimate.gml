

/// Animate helper for sprites - plays animations in a loop.
/// @arg _start - frame index to start animation
/// @arg _count - how many frames are in the animation
/// @arg _steps_per_frame - how many steps to take for each frame
/// @arg _step - current step counter
/// @return index to show.
function Animate(_start, _count, _steps_per_frame, _step){
	var _offset = floor((_step % (_steps_per_frame * _count))/(_steps_per_frame))
	return _start + _offset;
}


function AnimateTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    static test_subject="Animate Tests"
    
    static should_animate = function() {
        
        var _test_cases = [
            { name: "simple", start: 0, count: 1, spf: 1, step: 0, expected: 0 },
            { name: "advance", start: 0, count: 2, spf: 1, step: 1, expected: 1 },
            { name: "wrap", start: 0, count: 2, spf: 1, step: 2, expected: 0 },
            { name: "offset", start: 2, count: 2, spf: 1, step: 0, expected: 2 },
            { name: "offset wrap", start: 2, count: 2, spf: 1, step: 2, expected: 2 },
            { name: "multi steps", start: 2, count: 2, spf: 4, step: 7, expected: 3 },
        ];
        
        for (var i = 0; i < array_length(_test_cases); i++) {
            var _tc = _test_cases[i];
            assert_equal(_tc.expected, Animate(_tc.start, _tc.count, _tc.spf, _tc.step), _tc.name);
        }
    }
}