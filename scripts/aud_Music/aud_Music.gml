// Music is global.


/// Initializes the global controller for music.
function MusicClass() constructor {
    enabled = true
    bus = audio_bus_create()
    em = audio_emitter_create()
    prev = -1
    current = -1
    gain = 0.5
    
    musicEnter = 0
    musicPlay = 1
    musicStop = 2
    
    state = new State(musicStop)
	
	audio_emitter_bus(em, bus)
    
    
    static FadeIn = function(_track, fade_ms=5000, loop_offset=0){
    	FadeOut(fade_ms)
    	
    	current = audio_play_sound_on(em, _track, true, 3, 0)
    	audio_sound_gain(current, 1, fade_ms)
        if loop_offset != 0 {
            audio_sound_loop_start(current, loop_offset)
        }
    	state.Set(musicEnter)
    }
    
    static FadeOut = function(fade_ms){
    	if current != -1 && audio_is_playing(current) {
    		prev = current
    		audio_sound_gain(prev, 0, fade_ms)
    	}
    }
    
    static Start = function(_track, loop_offset){
    	Stop()
    	
    	current = audio_play_sound_on(em, _track, true, 3, 1)
        if loop_offset != 0 {
            audio_sound_loop_start(current, loop_offset)
        }
    	state.Set(musicPlay)
    }
    
    /// Stop the current track if playing.
    static Stop = function() {
    	if current != -1 && audio_is_playing(current) {
    		audio_stop_sound(current)
    	}
        state.Set(musicStop)
    }
    
    
    /// Music track management update.
    static Update = function() {
    	if state.Get() == musicEnter && state.mono > 60*5 {
    		if prev != -1 && audio_is_playing(prev) {
    			audio_stop_sound(prev)
    		}
            state.Set(musicPlay)
    	}
    }
    
    /// Mute all music
    static Disable = function() {
    	enabled = false
    	bus.gain = 0
    }
    
    /// Unmute music
    static Enable = function() {
    	enabled = true
    	bus.gain = gain
    }
    
    /// Toggle between music muted or not muted.
    static Toggle = function() {
    	enabled = !enabled
    	if enabled {
    		bus.gain = gain
    	} else {
    		bus.gain = 0
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

/// Fades in a new track and fades out the previous track (if playing).
/// @arg track - new track to fade in.
/// @arg fade_ms - the duration of the fade.
/// @arg loop_offset - the timestamp in milliseconds where the audio track should start looping.
function MusicFadeIn(track, fade_ms=5000, loop_offset=0){
	Music().FadeIn(track, fade_ms, loop_offset)
}

/// Starts a music track and stops the previous track (if playing)
/// @arg track - new track to play.
/// @arg loop_offset - the timestamp in milliseconds where the audio track should start looping.
function MusicStart(track, loop_offset){
	Music().Start(track, loop_offset)
}

/// Stop the current track if playing.
function MusicStop() {
	Music().Stop()
}

/// Fade out the current track if playing.
/// @arg fade_ms - how long the fade should last.
function MusicFadeOut(fade_ms){
	Music().FadeOut(fade_ms)
}

/// Mute all music
function MusicDisable() {
	Music().Disable()
}

/// Unmute music
function MusicEnable() {
	Music().Enable()
}

/// Toggle between music muted or not muted.
function MusicToggle() {
	Music().Toggle()
}


function SetMusicGain(_gain) {
	Music().SetGain(_gain)	
}

function GetMusicGain() {
	return Music().GetGain()
}
