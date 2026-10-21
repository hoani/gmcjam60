

// hk stands for hero key
#macro CMD_LEFT "hk_left"
#macro CMD_RIGHT "hk_right"
#macro CMD_UP "hk_up"
#macro CMD_DOWN "hk_down"
#macro CMD_A "hk_a"
#macro CMD_B "hk_b"


#macro KEYBOARD_A ord("Z")
#macro KEYBOARD_B ord("X")

function InitCommands() {
    var list = CommandList();
    var cmds = new Commands(list);
    CommandsRegisterKeyboard(cmds);
    return cmds;
}

function CommandsContinueCheck() {
    
	return GamepadContinueCheck() && keyboard_check_pressed(vk_anykey) || mouse_check_button_pressed(mb_any);	
}


function CommandList() {
    return [
        CMD_LEFT,
        CMD_RIGHT,
        CMD_UP,
        CMD_DOWN,
        CMD_A,
        CMD_B,
    ];
}


function CommandsRegisterKeyboard(_cmds) {
    if !_cmds.RegisterInputDevice("keyboard") {
        return; // Already registered.
    }
	// Movement
    _cmds.Register(CMD_LEFT, new Closure(function(_){return keyboard_check(vk_left)}));
	_cmds.Register(CMD_RIGHT, new Closure(function(_){return keyboard_check(vk_right)}))
	_cmds.Register(CMD_UP, new Closure(function(_){return keyboard_check(vk_up)}))
	_cmds.Register(CMD_DOWN, new Closure(function(_){return keyboard_check(vk_down)}))
    _cmds.Register(CMD_LEFT, new Closure(function(_){return keyboard_check(ord("A"))}))
	_cmds.Register(CMD_RIGHT, new Closure(function(_){return keyboard_check(ord("D"))}))
	_cmds.Register(CMD_UP, new Closure(function(_){return keyboard_check(ord("W"))}))
	_cmds.Register(CMD_DOWN, new Closure(function(_){return keyboard_check(ord("S"))}))
    
    // Actions
	_cmds.Register(CMD_A, new Closure(function(_){return keyboard_check(KEYBOARD_A)}))
	_cmds.Register(CMD_B, new Closure(function(_){return keyboard_check(KEYBOARD_B)}))	
}


function HasGamepad(_cmds) {
	return _cmds.HasInputDevice("gamepad")
}

function CommandsRegisterGamepad(_cmds, _device) {
	if !_cmds.RegisterInputDevice("gamepad") {
		return
	}
    
	_cmds.Register(CMD_LEFT,  new Closure(function(ctx){return gamepad_button_check(ctx, gp_padl)}, _device))
	_cmds.Register(CMD_RIGHT, new Closure(function(ctx){return gamepad_button_check(ctx, gp_padr)}, _device))
	_cmds.Register(CMD_UP,    new Closure(function(ctx){return gamepad_button_check(ctx, gp_padu)}, _device))
	_cmds.Register(CMD_DOWN,  new Closure(function(ctx){return gamepad_button_check(ctx, gp_padd)}, _device))
	_cmds.Register(CMD_A,     new Closure(function(ctx){return gamepad_button_check(ctx, gp_face1)}, _device))
	_cmds.Register(CMD_A,     new Closure(function(ctx){return gamepad_button_check(ctx, gp_face2)}, _device))
	_cmds.Register(CMD_B,     new Closure(function(ctx){return gamepad_button_check(ctx, gp_face3)}, _device))
	_cmds.Register(CMD_B,     new Closure(function(ctx){return gamepad_button_check(ctx, gp_face4)}, _device))
}



function GamepadContinueCheck() {
    var _gp_input = gamepad_is_supported() && gamepad_is_connected(0) && (
    	gamepad_button_check_pressed(0, gp_start) || 
    	gamepad_button_check_pressed(0, gp_select) ||
    	gamepad_button_check_pressed(0, gp_face1) || 
    	gamepad_button_check_pressed(0, gp_face2) || 
    	gamepad_button_check_pressed(0, gp_face3) || 
    	gamepad_button_check_pressed(0, gp_face4) || 
    	gamepad_button_check_pressed(0, gp_padl) || 
    	gamepad_button_check_pressed(0, gp_padr) || 
    	gamepad_button_check_pressed(0, gp_padu) || 
    	gamepad_button_check_pressed(0, gp_padd)
	);
    return _gp_input;
}
