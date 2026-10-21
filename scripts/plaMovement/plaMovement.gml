function PlaMovement() constructor {
    pressed = new Vec2()
    held = new Vec2()
    jump = {
        pressed: false,
        held: false
    }
    
    g = new Vec2(0, 1)
    
    static FromCommands = function(cmds) {
        pressed.x = 0
        pressed.y = 0
        held.x = 0
        held.y = 0
        
        if cmds.Pressed(CMD_LEFT) {
            pressed.x -= g.y;
            pressed.y -= g.x;
        }
        if cmds.Pressed(CMD_RIGHT) {
            pressed.x += 1;
            pressed.y += g.x;
        }
        if cmds.Pressed(CMD_DOWN) {
            pressed.x -= g.x;
            pressed.y += g.y;
        }
        if cmds.Pressed(CMD_UP) {
            pressed.x += g.x;
            pressed.y -= g.y;
        }
        
        if cmds.Check(CMD_LEFT) {
            held.x -= g.y;
            held.y -= g.x;
        }
        if cmds.Check(CMD_RIGHT) {
            held.x += g.y;
            held.y += g.x;
        }
        if cmds.Check(CMD_DOWN) {
            held.x -= g.x;
            held.y += g.y;
        }
        if cmds.Check(CMD_UP) {
            held.x += g.x;
            held.y -= g.y;
        }
        
        jump.pressed = cmds.Pressed(CMD_A)
        jump.held = cmds.Check(CMD_A)
    }
}


