// SFX Controls. Individual SFX objects can be used to control individual emitters, but SFX also has some global controls.

function SfxClass() constructor {
    enabled= true
    gain = 0.5
    
    static Disable = function() {
        enabled = false
    }
    
    static Enable = function() {
        enabled = true
    }
    
    static IsEnabled = function() {
        return enabled
    }
    
    static Toggle = function() {
        if enabled {
            Disable()
        } else {
            Enable()
        }
    }
    
    static SetGain = function(_gain) {
        gain = _gain
    	if gain >= 0 {
    		Enable()
    	} else {
    		Disable()	
    	}
    }
    
    static GetGain = function() {
        return gain
    }
}

function CreateSfx(_snd, _gain=1, _x=room_width/2, _y=room_height/2) {
	InstanceCreate(_x, _y, objSfx, {snd: _snd, gain: _gain})
}

function SfxDisable() {
	Sfx().Disable()
}

function SfxEnable() {
	Sfx().Enable()
}

function SfxIsEnabled() {
	return Sfx().IsEnabled()
}

function SfxToggle() {
    Sfx().Toggle()
}

function SetSfxGain(_gain) {
	Sfx().SetGain(_gain)	 
}

function GetSfxGain() {
 	return Sfx().GetGain()
}
 
function SfxResume() {
	var _ids = tag_get_assets("sfx");
	for (var _i = 0; _i < array_length(_ids); _i++) {
		var _snd = asset_get_index(_ids[_i])
		audio_resume_sound(_snd)	
	}
}

function SfxPause() {
	var _ids = tag_get_assets("sfx");
	for (var _i = 0; _i < array_length(_ids); _i++) {
		var _snd = asset_get_index(_ids[_i])
		audio_pause_sound(_snd)	
	}
}


function SfxPlayer(_x = room_width/2, _y = room_height/2) constructor {
    e = audio_emitter_create()
    gain = 1
    audio_emitter_gain(e, Sfx().GetGain());
    audio_emitter_position(e, room_width/2 - _x, room_height/2 - _y, 0)	
    
    static Gain = function(_gain) {
        gain = _gain
        audio_emitter_gain(e, _gain*Sfx().GetGain());
    }
    
    static Play = function(_snd, _gain=undefined, _loop=false) {
        if SfxIsEnabled() {
            if is_undefined(_gain) {
                return audio_play_sound_on(e, _snd, false, 2.5);
            } else {
                return audio_play_sound_on(e, _snd, false, 2.5, _gain);
            }
    	}
    	return -1;
    }
    
    static Loop = function(_snd, _gain=undefined) {
        Play(_snd, _gain, true);
    }
    
    static Update = function(_x, _y) {
        audio_emitter_position(e, room_width/2 - _x, room_height/2 - _y, 0)
        audio_emitter_gain(e, gain*Sfx().GetGain());
    }
    
    static Cleanup = function() {
        audio_emitter_free(e);
    }
}



function SfxSequence(_snds) constructor {
    snds = _snds;
    index = 0;
    static With = function(snd) {
        array_push(snds, snd);
        return self;
    }
    
    static Get = function() {
        var snd = snds[index];
        index = (index + 1) % array_length(snds);
        return snd;
    }
    
    static Randomize = function() {
        index = irandom(array_length(snds)-1)
    }
}




