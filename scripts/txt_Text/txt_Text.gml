#macro TEXT_STATE_APPEAR 0
#macro TEXT_STATE_IDLE 1
#macro TEXT_STATE_DISAPPEAR 2
#macro TEXT_STATE_DEAD 3

function NewText(_str, _font, _appear=new TextAppear(), _disappear=new TextAppear()) {
    if !is_struct(_font) {
        _font = FontLookup(_font)
    }
    return new Text(_str, _font, _appear, _disappear)
}

function Text(_str, _font, _appear=new TextAppear(), _disappear=new TextAppear()) constructor {
    original = _str
    str = _str
    font = _font
    fx = {}
    update = true;
    appear = _appear;
    disappear = _disappear;
    showStr = _str;
    state = new State(TEXT_STATE_APPEAR)
    lineWidths = []
    alignment = fa_left
    box = new Box(room_width, room_height)
    dimensions = font.Dimensions(str)
    cb = {
        onReady: new Callback(),
        onDone: new Callback(),
    }
    
    if !is_struct(_font) {
        DebugError("font is not a struct - make sure you use a lookup", true)
    }
    
    static WithAlign = function(fa) {
        alignment = fa;
        return self
    }
    
    static WithFit = function(b) {
        Fit(b) // Note ignores failure... but whatever... yolo
        return self
    }
    
    static WithOnReady = function(onReady) {
        cb.onReady.Set(onReady)
        return self
    }
    
    static WithOnDone = function(onDone) {
        cb.onDone.Set(onDone)
        return self
    }
    
    static GetFx = function(oc) {
        if struct_exists(fx, chr(oc)) {
            return struct_get(fx, chr(oc))
        }
        var _fx = GetChFx(oc)
        if !is_undefined(_fx) {
            _fx.Setup(font)
        }
        struct_set(fx, chr(oc), _fx)
        return _fx
    }
    
    static Set = function(_str) {
        original = _str;
        str = _str;
        Fit(box);
    }
    
    static Restart = function() {
        state.Set(TEXT_STATE_APPEAR)
        appear.Setup(str)
        disappear.Setup(str)
    }
    
    static End = function() {
        state.Set(TEXT_STATE_DISAPPEAR)
    }
    
    static IsReady = function() {
        return state.Get() == TEXT_STATE_IDLE
    }
    
    static IsDead = function() {
        return state.Get() == TEXT_STATE_DEAD
    }
    
    static Step = function() {
        state.Update()
        _Refresh();
        
        // Transitions only.
        switch state.Get() {
            case TEXT_STATE_APPEAR:
                if appear.Done() {
                    state.Set(TEXT_STATE_IDLE)
                    cb.onReady.Call()
                }
                break;
            case TEXT_STATE_IDLE:
                break;
            case TEXT_STATE_DISAPPEAR:
                if disappear.Done() {
                    state.Set(TEXT_STATE_DEAD)
                    cb.onDone.Call()
                }
                break;
            case TEXT_STATE_DEAD:
                break;
        }
    }
    
    static Advance = function() {
        var current = state.Get();
        switch state.Get() {
            case TEXT_STATE_APPEAR:
            case TEXT_STATE_DISAPPEAR:
                while (current == state.Get()) {
                    Step();
                }
                break;
            default:
                break;
        }
    }
    
    static _Refresh = function() {
        switch state.Get() {
            case TEXT_STATE_APPEAR:
                update = true;
                appear.Step()
                showStr = appear.Get()
                break;
            case TEXT_STATE_IDLE:
                update = state.mono <= 1;
                showStr = str
                break;
            case TEXT_STATE_DISAPPEAR:
                update = true
                disappear.Step()
                showStr = disappear.Get()
                break;
            case TEXT_STATE_DEAD:
                update = state.mono <= 1;
                showStr = "";
                break;
        }
    }
    
    static RequiresUpdate = function() {
        var _update = update || (struct_names_count(fx) > 0 && Mono() % 2 == 0);
        update = false;
        return _update;  
    }
    
    static Dimensions = function() {
        return dimensions
    }
    
    /// Create a simple state machine.
    /// @arg box - the box to fit the text into.
    static Fit = function(b) {
        var lines = string_split(original, "\n");
        box.w = b.w
        box.h = b.h
        lineWidths = []
        str = ""
        
        var wordsFit = true;
        
        for (var j = 0; j < array_length(lines); j++) {
            var words = string_split(lines[j], " ");
            var cache = "";
            
            
            for (var i = 0; i<array_length(words); i++) {
                var word = Runes(words[i]);
                var width = font.Width(word)
                if (width > b.w) {
                    wordsFit = false; // Can't make it work.
                }
                
                if cache == "" {
                    cache = words[i]
                } else if font.Width($"{cache} {words[i]}") <= b.w {
                    cache = $"{cache} {words[i]}";
                } else {
                    array_push(lineWidths, font.Width(cache))
                    str += $"{cache}\n";
                    cache = words[i];
                }
            }
            array_push(lineWidths, font.Width(cache))
            str += cache;
            if j != array_length(lines) - 1 {
                str+="\n"
            }
        }
        dimensions = font.Dimensions(str)
        appear.Setup(str)
        disappear.Setup(str)
        _Refresh()
        return b.Contains(Dimensions()) && wordsFit
    }
    
    static String = function() {
        return showStr
    }
    
    static Draw = function(_x, _y, _c=c_white) {
        if array_length(lineWidths) == 0 {
            Fit(box)
        }
        font.Draw(_x, _y, self, _c)
    }
}



function TextTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    static test_subject="Text Tests"
    

    
    // f_mono is courier new, all characters have dimension w: 10, h: 18.
    static should_fit_width = function() {
        var test_cases = [
            {name: "split minimum", input: "Hello World", expected: "Hello\nWorld", box: new Box(50, 1000)},
            {name: "split maximum", input: "Hello World", expected: "Hello\nWorld", box: new Box(109, 1000)},
            {name: "no split", input: "Hello World", expected: "Hello World", box: new Box(110, 1000)},
            {name: "symbol", input: $"Hello {CH_SYMBOL_HEART}World", expected: $"Hello\n{CH_SYMBOL_HEART}World", box: new Box(118, 1000)},
            {name: "symbol no split", input: $"Hello {CH_SYMBOL_HEART}World", expected: $"Hello {CH_SYMBOL_HEART}World", box: new Box(134, 1000)},
        ];
        
        for (var i = 0; i<array_length(test_cases); i++) {
            var tc = test_cases[i];
            var t = new Text(tc.input, FontLookup(f_mono));
            assert_is_true(t.Fit(tc.box), tc.name);
            assert_equal(tc.expected, t.str);
        }
    }
    
    static should_fail_when_wont_fit = function() {
        var test_cases = [
            {name: "not wide enough", input: "Hello World", expected: "Hello\nWorld", box: new Box(40, 1000)},
            {name: "not tall enough", input: "Hello World", expected: "Hello\nWorld", box: new Box(50, 35)},
        ];
        
        for (var i = 0; i<array_length(test_cases); i++) {
            var tc = test_cases[i];
            var t = new Text(tc.input, FontLookup(f_mono));
            assert_is_false(t.Fit(tc.box), tc.name);
        }
    }
    
    static should_size_correctly = function() {
        var test_cases = [
            {name: "hello world", input: "Hello World", expected: new Box(10*11, 18)},
            {name: "grow", input: $"{ChScale(2)}Hello World{CH_SCALE_RESET}", expected: new Box(2*10*11, 18)},
            //{name: "shrink", input: $"{chScale(0.5)}Hello World{CH_SCALE_RESET}", expected: new Box(0.5*10*11, 18)},
        ];
        
        for (var i = 0; i<array_length(test_cases); i++) {
            var tc = test_cases[i];
            var t = new Text(tc.input, FontLookup(f_mono));
            assert_is_true(t.Fit(t.box), tc.name);
            assert_equal(tc.expected.w, t.dimensions.w);
            assert_equal(tc.expected.h, t.dimensions.h);
        }
    }
}


