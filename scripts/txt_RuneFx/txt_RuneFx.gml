
// Rune effects apply animations to text strings. Everything contained withing the FX runes will be impacted by the transform method.



function RuneFx() constructor {
    static Setup = function(font) {}
    static Transform = function(xpos, ypos, color, alpha) {}
}


function RuneFxWave(_amp, _freq) : RuneFx() constructor  {
    amp_base = _amp
    amp = _amp
    freq = _freq / game_get_speed(gamespeed_fps)
    xscale = 1;
    
    static Setup = function(font) {
        amp = font.f_height * 0.5 * amp_base
        xscale = 3*font.f_height
    }
    
    static Transform = function(xpos, ypos, color, alpha) {
        var tick = Mono()*freq
        var omega = 2*pi*(xpos/xscale + tick);
        ypos = ypos + amp * sin(omega);
        
        return {xpos: xpos, ypos: ypos, color: color, alpha: alpha};
    }
}


