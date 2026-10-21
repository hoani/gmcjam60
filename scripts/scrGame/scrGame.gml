// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information


#macro WINDOW_SCALE 1

#macro MouseX Mouse().Get().x
#macro MouseY Mouse().Get().y


function Mouse() {
    return global.g.mouse;
}

function InitGame() {
    global.g = new GameClass()
}

function Game() {
    return global.g
}

function Audio() {
    return global.g.audio
}

function Sfx() {
    return global.g.audio.sfx
}

function Music() {
    return global.g.audio.music
}

function GameSpeed() {
    return global.g.s
}

function Debug() {
    return global.g.debug.enabled
}

function Cmds() {
    return global.g.cmds
}

function Mono() {
    return global.g.mono
}

function ControlStack() {
    return global.g.controlStack
}


function GameClass() constructor {
    if os_browser == browser_not_a_browser {
		window_set_size(room_width*WINDOW_SCALE, room_height*WINDOW_SCALE)
	}
    
    s = new GameSpeedClass()
    
    controlStack = new ControlStackClass()
    
    debug = new DebugClass(true, false);
    cmds = InitCommands();
    
	mono = 0
    step = 0
	
	audio = new AudioClass()
    mouse = new MouseHandler();
    
    
    static Update = function() {
        mono++
        step += s.Get(1)
        debug.Update()
        cmds.Update()
        audio.Update()
        mouse.Update()
    }
    
    static Draw = function() {

    }
    
    static DrawUi = function() {
        debug.Draw()
    }
    
}



