#macro f_test fntTest
#macro f_mono fntMono  



function FontRegister(_font, _sprite) {
	if !variable_global_exists("fontLookup") {
        global.fontLookup = {}
    }
    struct_set(global.fontLookup, font_get_name(_font), new Font(_font, _sprite));
}

function FontLookup(_font) {
    if !variable_global_exists("fontLookup") {
        global.fontLookup = {}
    }
    // Auto-register if doesn't exist
    if !struct_exists(global.fontLookup, font_get_name(_font)) {
        struct_set(global.fontLookup, font_get_name(_font), new Font(_font, sprSymbol24));
    }
	return struct_get(global.fontLookup, font_get_name(_font));
}




function Font(_which, _symbol) constructor {
	f = _which
	s = _symbol
	s_width = sprite_get_width(_symbol)
    s_height = sprite_get_height(_symbol)
	
	f_width = array_create(128, 0)
	
	draw_set_font(f)
    f_height = string_height("H")
    
	for (var i = 0; i < 128; i++) {
		f_width[i] = string_width(chr(i))
	};
	
	static Dimensions = function(_str) {
        draw_set_font(f);
        return new Box(Width(_str), string_height(_str))
    }
	
	static Width = function(_str) {
		var xpos = 0;
		var width = 0;
        var cache = "";
        var scale = 1;
		// Iterate through each character, add to xpos, reset and record width on line breaks
        draw_set_font(f);
        for (var i = 0; i < string_length(_str); i++) {
            var c = string_char_at(_str, i+1);
            
            if c == "\n" {
                xpos += string_width(cache)*scale
                cache = ""
                width = max(xpos, width)
                xpos = 0
                continue
            }
            
            var oc = ord(c);
            
            if IsAscii(oc){
                cache += c;
                continue;
            }
            if IsSymbol(oc) {
                xpos += string_width(cache)*scale
                cache = ""
                xpos += s_width*scale;
                continue
            }
            
            if IsChScale(oc) {
                xpos += string_width(cache)*scale
                cache = ""
                scale = GetChScale(oc);
            }
        }
        xpos += string_width(cache)*scale
        cache = ""
        return max(xpos, width)
	}
    
    static Draw = function(_x, _y, _text, _color=c_white) {
        var d = {
            f_height: f_height,
            row: 0,
            xpos: _CarriageReturn(_x, 0, _text),
            ypos: _y,
            cache: "",
            str: _text.String(),
            prev: {
                cache: "",
                xpos: _CarriageReturn(_x, 0, _text),
                adjust_xpos: function(_xpos, _next, _scale) {
                    var x_est = _xpos + string_width(_next)*_scale;
                    var x_true = xpos + string_width(cache + _next)*_scale
                    var diff = x_true - x_est;
                    return _xpos + diff;
                }
            },
            color: _color,
            alpha: 1,
            fx: undefined,
            scale: 1,
            draw_cache: function() {
                var yScaleAdj = f_height*(1-scale)/2;
                
                xpos = prev.adjust_xpos(xpos, cache, scale)
                
                if is_undefined(fx) {
                    draw_text_transformed_color(xpos, ypos + yScaleAdj, cache, scale, scale, 0, color, color, color, color, alpha);
                } else {
                    var tfm = fx.Transform(xpos, ypos, color, alpha)
                    draw_text_colour(tfm.xpos, tfm.ypos + yScaleAdj, cache, tfm.color, tfm.color, tfm.color, tfm.color, tfm.alpha)
                }
                
                prev.cache = cache
                prev.xpos = xpos;
                xpos += string_width(cache)*scale;
                cache = "";
            },
        }
        
        draw_set_font(f);
        draw_set_halign(fa_left)
        draw_set_valign(fa_top)
        draw_set_color(d.color);
        draw_set_alpha(d.alpha);

        for (var i = 0; i < string_length(d.str); i++) {
            var c = string_char_at(d.str, i+1);
            
            if c == "\n" {
                d.row++;
                
                d.draw_cache();
                d.prev.cache = ""
                d.prev.xpos = _CarriageReturn(_x, d.row, _text);
                
                d.ypos += f_height
                d.xpos = d.prev.xpos;
                
                continue
            }
            
            var oc = ord(c);
            
            if IsAscii(oc) {
                if is_undefined(d.fx) {
                    d.cache += c;
                } else {
                    var yScaleAdj = f_height*(1-d.scale)/2;
                    d.xpos = d.prev.adjust_xpos(d.xpos, c, d.scale)
                    d.prev.cache += c
                    var tfm = d.fx.Transform(d.xpos, d.ypos, d.color, d.alpha)
                    draw_text_transformed_colour(tfm.xpos, tfm.ypos + yScaleAdj, c, d.scale, d.scale, 0, tfm.color, tfm.color, tfm.color, tfm.color, tfm.alpha)
                }
                
                continue;
            }
            
            if IsSymbol(oc) {
                d.draw_cache(d.cache)
                d.prev.cache = "" // Symbol, no prev caching necessary
                d.prev.xpos = d.xpos + (string_width(d.cache) + s_width)* d.scale
                
                // Symbols are centered - no scaling adjustment required
                var sx = d.xpos + s_width/2;
                var sy = d.ypos + f_height/2;
                
                if is_undefined(d.fx) {
                    draw_sprite_ext(s, SymbolIndex(oc), sx, sy, d.scale, d.scale, 0, d.color, d.alpha);
                } else {
                    var tfm = d.fx.Transform(sx, sy, d.color, d.alpha)
                    draw_sprite_ext(s, SymbolIndex(oc), tfm.xpos, tfm.ypos, d.scale, d.scale, 0, tfm.color, tfm.alpha);
                }
                
                d.xpos += s_width*d.scale;
                continue
            }
            
            if IsChColor(oc) {
                d.draw_cache()
                d.color = GetChColor(oc, _color);
            }
            
            if IsChAlpha(oc) {
                d.draw_cache()
                d.alpha = GetChAlpha(oc);
            }
            
            if IsChScale(oc) {
                d.draw_cache()
                d.scale = GetChScale(oc);
            }
            
            if IsChFx(oc) {
                d.draw_cache();
                d.fx = _text.GetFx(oc)
            }
        }
        d.draw_cache();
        draw_set_alpha(1);
    }
    
    
    function _CarriageReturn(_x0, _row, _text) {
        var lineWidth = array_get(_text.lineWidths, _row);
        var fullWidth = _text.box.w;
        if is_undefined(lineWidth) {
            lineWidth = fullWidth;
        }
        switch _text.alignment {
            case fa_center:
                return _x0 + (fullWidth - lineWidth)/2;
            case fa_right:
                return _x0 + (fullWidth - lineWidth);
            default:
                return _x0;
        }
    }
}



function FontTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    static test_subject="Font Tests"
    
    static should_get_dimensions = function() {
        var f = FontLookup(f_test)
        var d = f.Dimensions("Hello World");
        assert_that(d.w > 1 && d.h > 1, "font is dimensionless")
    }
    
    
    // f_mono is courier new, all characters have dimension w: 10, h: 16.
    static should_get_width = function() {
        var test_cases = [
            {name: "hello", input: "Hello World", expected: 110},
            {name: "ascii symbols", input: "-_+=?><.,;!", expected: 110},
            {name: "custom symbol", input: $"{CH_SYMBOL_HEART}", expected: 24},
            {name: "ascii and custom symbol", input: $"{CH_SYMBOL_HEART}Hello", expected: 24 + 50},
            {name: "ignore modifiers", input: $"{CH_COL_RED}Hello{CH_COL_RESET}", expected: 50},
            {name: "new lines", input: "Hello\nWor", expected: 50},
            {name: "new lines again", input: "Hello\nWorld!", expected: 60},
        ];
        
        for (var i = 0; i<array_length(test_cases); i++) {
            var tc = test_cases[i];
            var f = FontLookup(f_mono);
            assert_equal(tc.expected, f.Width(tc.input));
        }
    }
}
