
// Symbols are provided by sprite are preceeded by \u8000

#macro CH_COLOR (0x90)
#macro CH_COL_RESET "\u9000"
#macro CH_COL_WHITE "\u9001"
#macro CH_COL_LTGRAY "\u9002"
#macro CH_COL_GRAY "\u9003"
#macro CH_COL_DKGRAY "\u9004"
#macro CH_COL_BLACK "\u9005"
#macro CH_COL_LTRED "\u9006"
#macro CH_COL_PINK "\u9006"
#macro CH_COL_RED "\u9007"
#macro CH_COL_DKRED "\u9008"
#macro CH_COL_LTGREEN "\u9009"
#macro CH_COL_GREEN "\u900a"
#macro CH_COL_DKGREEN "\u900b"

#macro CH_ALPHA (0x91)
#macro CH_ALPHA_RESET "\u9180" // Note - this equals alpha 1

#macro CH_SCALE (0x92)
#macro CH_SCALE_RESET "\u9240" // Note - equals scale 1


#macro CH_FX (0xa0) // All of 0xa0XX are effects
#macro CH_FX_WAVE "\ua000"


#macro CH_FX_RESET "\uafff"

function IsChFx(_oc) {
    return (_oc >> 8) & 0xF0 == CH_FX;
}

function GetChFx(_oc) {
    if IsChWave(_oc) {
        return GetChWave(_oc)
    }
    return undefined;
}

function IsChWave(_oc) {
    return (_oc >> 8) == (ord(CH_FX_WAVE) >> 8);
}

/// Create a wave effect
/// @arg amp - the amplitude - This has a range of [0.5/16, 0.5]
/// @arg freq - speed of wave - This has a range of [2/16, 2]
function ChWave(amp, freq) {
    var _amp_nibble = floor((0x10 * (clamp(amp, 0.5/16, 0.5))/0.5) - 1)
    var _freq_nibble = floor((0x10 * (clamp(freq, 2/16, 2))/2) - 1)
    
    return chr(ord(CH_FX_WAVE) | _amp_nibble << 4 | _freq_nibble)
}

function GetChWave(_oc) {
    var _amp = clamp(1 + ((_oc & 0xf0)>> 4), 1, 0x10) * (0.5/16);
    var _freq = clamp(1 + (_oc & 0x0f), 1, 0x10) * (2/16);
    return new RuneFxWave(_amp, _freq)
}

function IsChAlpha(_oc) {
    return _oc >> 8 == CH_ALPHA
}

// We limit ch_alpha to only 129 possible values [0, 128] - because this makes the division clean.
function ChAlpha(amt) {
    return chr(ord("\u9100") | round(clamp(amt, 0, 1)*0x80))
}

function GetChAlpha(_oc) {
    return clamp((_oc & 0xff)/0x80, 0, 1)
}

function IsChScale(_oc) {
    return _oc >> 8 == CH_SCALE
}

// We limit chScale to 0-2 using 129 possible values [0, 128] - because this makes the division clean.
function ChScale(amt) {
    return chr(ord("\u9200") | round(clamp(amt, 0, 2)*0x40))
}

function GetChScale(_oc) {
    return clamp((_oc & 0xff)/0x40, 0, 2)
}

global.ch_colors = {
    CH_COL_WHITE: c_white,
    CH_COL_LTGRAY: c_ltgray,
    CH_COL_GRAY: c_gray,
    CH_COL_DKGRAY: c_dkgray,
    CH_COL_BLACK: c_black,
    CH_COL_LTRED: C_PINK,
    CH_COL_RED: C_RED,
    CH_COL_DKRED: C_DKRED,
    CH_COL_LTGREEN: c_lime,
    CH_COL_GREEN: C_GREEN,
    CH_COL_DKGREEN: C_DKGREEN,
};


function IsSymbol(_oc) {
    return _oc >> 8 == CH_SYMBOL
}

function SymbolIndex(_oc) {
    return _oc & 0xFF;
}

function IsChColor(_oc) {
    return _oc >> 8 == CH_COLOR
}

function GetChColor(_oc, _default) {
    if struct_exists(global.ch_colors, chr(_oc)) {
        var _col = struct_get(global.ch_colors, chr(_oc))
        return _col;
    }
    return _default;
}

function IsAscii(_oc) {
    return _oc <= 126
}


function Runes(_str) {
    var _runes = ""
    for (var i = 0; i < string_length(_str); i++) {
        var _c = string_char_at(_str, i + 1);
        
        var _oc = ord(_c)
        
        if IsAscii(_oc) {
            _runes = _runes + _c;
            continue
        }
         
        if (IsSymbol(_oc)) {
            _runes = _runes + _c;
            continue;
        }
        // All other characters are non-runes, so we skip them.
    }
    
    
    return _runes
}




function RunesTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    static test_subject="Runes Tests"
    
    static should_omit_non_visual = function() {
        var test_cases = [
            {name: "ascii", input: "Hello World", expected: "Hello World"},
            {name: "Symbols accepted", input: $"Hello {CH_SYMBOL_HEART}World", expected: $"Hello {CH_SYMBOL_HEART}World"},
            {name: "Modifiers rejected", input: $"Hello {CH_COL_RED}World{CH_COL_RESET}", expected: $"Hello World"},
            {name: "Mixed", input: $"{CH_SYMBOL_HEART}Hello {CH_COL_RED}{CH_SYMBOL_HEART}{CH_COL_RESET}", expected: $"{CH_SYMBOL_HEART}Hello {CH_SYMBOL_HEART}"},
        ];
        
        for (var i = 0; i<array_length(test_cases); i++) {
            var tc = test_cases[i];
            assert_equal(tc.expected, runes(tc.input));
        }
    }
}


