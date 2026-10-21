// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function AudioClass() constructor {
	audio_falloff_set_model(audio_falloff_linear_distance)
	audio_channel_num(128)

	enabled = true

    sfx = new SfxClass()
    music = new MusicClass()
	
	sfx.SetGain(1/4)
	music.SetGain(1/4)
    
    
    static Update = function() {
        music.Update()
    }
    
    
    static On = function(){
    	audio_master_gain(1)
        enabled = true
    }
    
    static Off = function(){
    	audio_master_gain(0)
        enabled = false
    }
    
    static Toggle = function() {
    	if enabled {
    		Off()
    	} else {
    		On()
    	}
    }
}

