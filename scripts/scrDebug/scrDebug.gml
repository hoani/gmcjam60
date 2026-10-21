

#macro FPS_FILTER 64

#macro DEBUG_KEY_RESET vk_backspace
#macro DEBUG_KEY_FPS_UP ord("P")
#macro DEBUG_KEY_FPS_DOWN ord("O")
#macro DEBUG_KEY_GOTO_ZOO ord("T")
#macro DEBUG_KEY_SFX_TOGGLE ord("N")
#macro DEBUG_KEY_MUSIC_TOGGLE ord("M")

function DebugClass(_enabled=false, _promo=false) constructor {
    enabled = _enabled
    promo = _promo
    fps_avg = 0;
    
    static Update = function() {
        fps_avg = (fps_avg * (FPS_FILTER - 1)/FPS_FILTER) + fps_real/FPS_FILTER
        _HandleControls();
    }
    
    static Draw = function() {
        if !enabled || promo {
 		     return
     	}
        // I think there are better ways of doing things like this, but I haven't tried them...

        ResetTextAlign()
        draw_set_alpha(0.5);
        draw_set_color(c_black)
        draw_rectangle(0, 0, 64, 16, false)
        draw_set_alpha(1)
        draw_set_color(c_white)
        draw_set_font(f_mono)
        draw_text(0, 0, string(fps_avg))
        draw_set_alpha(1)
    }
    
    static _HandleControls = function() {
    	if !enabled {
    		return
    	}
    	
    	if keyboard_check_pressed(DEBUG_KEY_RESET) {
    		game_restart()
    	}
    	
    	if keyboard_check_pressed(DEBUG_KEY_FPS_UP) {
    		game_set_speed(game_get_speed(gamespeed_fps)*2.0, gamespeed_fps)
    	}
    	
    	if keyboard_check_pressed(DEBUG_KEY_FPS_DOWN) {
    		game_set_speed(game_get_speed(gamespeed_fps)*0.5, gamespeed_fps)
        }
        
        if keyboard_check_pressed(DEBUG_KEY_GOTO_ZOO) {
    		room_goto(rmZoo)
        }
        
        if keyboard_check_pressed(DEBUG_KEY_SFX_TOGGLE) {
    		SfxToggle()
    	}
    	
    	if keyboard_check_pressed(DEBUG_KEY_MUSIC_TOGGLE) {
    		MusicToggle()
    	}
    }
}


function DebugMessage(message) {
    if !Debug() {
        return
    }
    
    var args = array_create(argument_count);
    for (var i = 0; i < argument_count; i++) {
        args[i] = argument[i];
    }
    script_execute_ext(show_debug_message, args);
}

function DebugError(message, abort=false) {
    if !Debug() {
        return
    }
    
    show_error(message, abort);
}



