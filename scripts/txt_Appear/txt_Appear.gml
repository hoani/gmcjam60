
// Appear effects apply appear/dissapear effects to full text strings.

function TextAppear() constructor {
    show = ""
    static Setup = function(_str) { show = _str }
    static Step = function() {}
    static Done = function() { return true; }
    static Get = function() { return show; }
}


/// Fade in characters
/// @arg _fade_frames int the number of frames each fade in will use
/// @arg _cps int the number of characters per step.
function FadeAppear(_fade_frames, _cps) constructor {
    ff = _fade_frames;
    cps = _cps;
    index = 0;
    str = "";
    show = "";
    
    static Setup = function(_str) {
        str = _str
        index = 0;
        show = "";
    }
    
    static Step = function() {
        index += cps;
        show = ""
        if (index >= ff + 1) {
            show = string_copy(str, 1, index - ff); 
        }
        for (var i = max(1, 1 + index - ff); i < index; i++) {
            if i > string_length(str) {
                break;
            }
            var d = index-i;
            var a = d/ff;
            show += $"{ChAlpha(a)}{string_char_at(str, i)}"
        }
    }
    
    static Done = function() { 
        return index > string_length(str) + ff; 
    }
    
    static Get = function() { 
        return show; 
    }
}



/// Fade out text
/// @arg _fade_frames int the number of frames for fade out.
function FadeOut(_fade_frames) constructor {
    ff = _fade_frames;
    index = 0;
    str = "";
    show = "";
    
    static Setup = function(_str) {
        str = _str
        index = 0;
        show = _str;
    }
    
    static Step = function() {
        index += 1;
        var a = max(0, 1 - index/ff);
        show = $"{ChAlpha(a)}{str}{CH_ALPHA_RESET}"
    }
    
    static Done = function() { 
        return index >= ff; 
    }
    
    static Get = function() { 
        return show; 
    }
}

