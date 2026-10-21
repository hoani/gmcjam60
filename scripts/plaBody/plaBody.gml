

#macro PLA_DEBUG_KEY (vk_space)

function PlatBody(_x, _y, _w, _h) constructor {
    width = _w
    height = _h
    w_2 = _w/2
    h_2 = _h/2
    
    x = _x
    y = _y
    
    y_drop = false;
    y_up = false;
    
    landing = new Cooldown(8); // Typically set this to work with the landing animation
    turn = new Cooldown(4); 
    frame = new PlatFrame()
    lateral = new Lateral()
    jump = new PlatJump()
    spd = new Vec2()
    
    step_height = 8
    
    FaceLeft = -1
    FaceRight = 1
    
    face = FaceRight
    
    // These values affect slipping and climbing up slopes.
    frict = 1.0;
    slip = 2.0;
    slip_factor = 0.5; // Portion of max speed that is affected by slopes.
    
    
    wall = {
        friction_factor: 0.5
    }
    
    
    movement = new PlaMovement()
    
    
    lateral = {
        movement: new Lateral(),
        cooldown: new Cooldown(10),
        wallkick_cooldown: new Cooldown(5),
        floor: {
            max: 2,
            accel: 0.25 + frict,
            frict: frict,
        },
        air: {
            max: 2,
            accel: 0.25,
            decel: 1/32,
        },
        squish: 4,
    }
    
    
    terminal = {
        air: 8,
        wall: 1,
    }
    
    
    SquashFloor = FuncNone
    SquashBlock = function(_dx, _dy) {
        DebugMessage("Squashed")
    }
    
    static Update = function(cmds) {
        UpdateFrames()
        var had_floor = (frame.ground.inst != noone)
        movement.FromCommands(cmds)
        UpdateSpeed();
        UpdateMovement();
        if frame.ground.inst == noone && had_floor {
            jump.coyote.Trigger()
        }
    }
    
    
    function CheckCollisionRoof() {
        var _dx = (w_2-1);
        var _dy = -(h_2+1.5);
        var c = CollisionCoords(x, y, -_dx, _dy, _dx, _dy)
        return CheckCollisionLine(c, objPlaBlock, frame.excludes, frame.roof)
    }
    
    function CheckCollisionFloor() {
        if spd.y < 0 {
            return noone;
        }
        var _dx = (w_2-1);
        var _dy = h_2+0.5;
        var candidate = CheckCollisionLine(CollisionCoords(x, y, -_dx, _dy, _dx, _dy), objPlaFloor, frame.excludes, frame.ground.inst)
        if candidate != noone {
            return candidate
        }
        if frame.ground.inst == noone {
            return noone
        }
        _dy = h_2+1.5;
        return CheckCollisionLine(CollisionCoords(x, y, -_dx, _dy, _dx, _dy), frame.ground.inst, frame.excludes, frame.ground.inst)
    }
    
    function UpdateWallFrames() {
        var dx0 = w_2;
        var dy0 = h_2-step_height;
        var dy1 = -(h_2-jump.roof_clip);
        var r = CollisionCoords(x, y, -dx0, dy0, -(dx0+1), dy1);
        frame.wall.left = CheckCollisionRectangle(r, objPlaBlock, frame.excludes, frame.wall.left);
        r = CollisionCoords(x, y, dx0, dy0, dx0+1, dy1);
        frame.wall.right = CheckCollisionRectangle(r, objPlaBlock, frame.excludes, frame.wall.right);
    }
    
    
    static UpdateFrames = function() {
        frame.roof = CheckCollisionRoof()
        frame.SetFloor(CheckCollisionFloor(), x, y, width)
        UpdateWallFrames()
        frame.UpdateHang()
    }
    
    static UpdateExcludes = function() {
        var _dx = w_2-1;
        frame.UpdateExcludes(CollisionCoords(x, y, -_dx, -h_2, _dx, h_2));
    }
    
    
    static UpdateMovement = function() {
        UpdateExcludes(); // Need to update excludes at least once, even if not moving.
    
        if y_drop && instance_exists(frame.ground.inst) {
            MoveContactY(1, objPlaBlock)
        }
        
        lateral.movement.Update(spd.x, spd.y);
        
        var spdx = lateral.movement.dx;
        var spdy = lateral.movement.dy;
        if keyboard_check(PLA_DEBUG_KEY) {
            DebugMessage($" pos ({x},{y}) spd ({spd.x}, {spd.y}) d ({lateral.movement.dx}, {lateral.movement.dy})")
        }
        
        
        MoveContactX(spdx, objPlaBlock);
        
        if spdy > 0 {
            var _dx = (w_2*1.5)*face;
            var _dy = -h_2;
            var c = CollisionPoint(x, y, _dx, _dy);   
            var hang_candidate = face == FaceLeft ? frame.wall.left : frame.wall.right;
            var hang_start = collision_point(c.x, c.y, objPlaBlock, true, true) == noone;
            var hang_start_ledge = CheckCollisionLine(CollisionCoords(x, y, -_dx, _dy, _dx, _dy), objPlaFloor) == noone;
            frame.SetFloor(MoveContactY(spdy, objPlaFloor, true, false), x, y, width)
            frame.roof = CheckCollisionRoof()
            c = CollisionPoint(x, y, _dx, _dy)
            if hang_candidate != noone && hang_start && collision_point(c.x, c.y, hang_candidate, true, true) == hang_candidate {
                frame.hang = hang_candidate;
                spd.y = 0;
                MoveToHang(-spdy, frame.hang);
            } else if hang_start_ledge && movement.held.x == 0 {
                var hang_candidate = CheckCollisionLine(CollisionCoords(x, y, -_dx, _dy, _dx, _dy), objPlaFloor);
                if hang_candidate != noone && hang_candidate.plat.slope == 0 {
                    frame.hang = hang_candidate;
                    spd.y = 0;
                    spd.x = 0
                    MoveToHang(-spdy, frame.hang);
                }
            }
        } else if spdy < 0 {
            frame.roof = MoveContactY(spdy, objPlaBlock, true, true)
            if frame.roof != noone {
                spd.y = 0;
            }
        } else {
            frame.roof = CheckCollisionRoof()
            frame.SetFloor(CheckCollisionFloor(), x, y, width)
        }
        UpdateWallFrames();
    }
    
    
    static MoveContactX = function(_dx, obj, forcex=false, with_stepping=true) { 
        var dist = 0;
        var delta = min(_dx, width); // If dx > width, we cap delta to avoid clipping through walls.
        var inst = noone;
       
        if _dx == 0 {
            return noone;
        }
       
        var sx = 1.0;
        var sy = 0.0;
        if abs(frame.ground.scos) > 1/4 {
            sx = frame.ground.scos;
            sy = -sign(_dx)*frame.ground.ssin;
            if forcex {
                sy = sy/sx;
                sx = 1.0;
            }
        } else {
            sy = 0 // Treat slope as a wall.
        }
       
        while(dist < abs(_dx)) {
            var dx0 = sign(delta) < 0 ? floor(delta*sx) : ceil(delta*sx);
            var dx1 = dx0 + w_2*sign(delta);
            var dy0 = -h_2 + abs(delta)*sy;
            var dy1 = dy0 + height;
            inst = CheckCollisionRectangle(CollisionCoords(x, y, dx0, dy0, dx1, dy1), obj, frame.excludes) 
            if inst == noone {
                Move(delta*sx, abs(delta)*sy)
                if forcex {
                    dist += abs(delta)*point_distance(0, 0, sx, sy);
                } else {
                    dist += abs(delta);
                }
                continue;
            }
            // Check step logic, but only if the slope isn't too steep.
            if with_stepping && frame.FloorIsSteppable() {
                // Attempt step.
                var _step_height = step_height;
                var inst2 = CheckCollisionRectangle(CollisionCoords(x, y, dx0, dy0 - _step_height, dx1, dy1 - _step_height), obj, frame.excludes)
                if inst2 == noone {
                    inst = noone;
                    Move(delta*sx, abs(delta)*sy - _step_height)
                    if forcex {
                        dist += abs(delta)*point_distance(0, 0, sx, sy);
                    } else {
                        dist += abs(delta);
                    }
                    frame.SetFloor(MoveContactY(_step_height, objPlaFloor), x, y, width)
                    if abs(frame.ground.scos) > 1/4 {
                        sx = frame.ground.scos;
                        sy = -sign(_dx)*frame.ground.ssin;
                        if forcex {
                            sy = sy/sx;
                            sx = 1.0;
                        }
                    } else {
                        sx = 1
                        sy = 0 // Treat slope as a wall.
                    }
                    continue;
                }
                // Attempt roof clip.
                if frame.ground.inst == noone {
                    inst2 = CheckCollisionRectangle(CollisionCoords(x, y, dx0, dy0 + jump.roof_clip, dx1, dy1 + jump.roof_clip), obj, frame.excludes)
                    if inst2 == noone {
                        inst = noone;
                        Move(delta, jump.roof_clip)
                        dist += abs(delta);
                        
                        frame.roof = MoveContactY(-jump.roof_clip, objPlaBlock)
                        continue;
                    }
                }
            }
            if abs(delta) == 1.0 {
                break;
            }
            delta = sign(delta)*ceil(abs(delta/2.0));
        }
       
        if keyboard_check(PLA_DEBUG_KEY) {
            DebugMessage($"floor_angle {frame.ground.slope} sx, sy ({sx}, {sy}) spd ({spd.x}, {spd.y}), moved {dist}")
        }
        
        // Prevent jumping when reaching corners of slopes.
        if frame.ground.slope != 0 {
            if CheckCollisionFloor() == noone {
                frame.SetFloor(MoveContactY(abs(_dx), objPlaFloor, false), x, y, width)
            }
        }
        
        return inst
    }
    
    function MoveContactY(_dy, obj, _with_squish=false) {
        if abs(_dy) == 0.0 {
            return noone
        }
        var dist = 0;
        var delta = _dy;
        var inst = noone;
        while(dist < abs(_dy)) {
            var dx0 = - (w_2);
            var dx1 = w_2;
            var dy0 = h_2*sign(delta);
            var dy1 = dy0 + delta;
            var current = _dy > 0 ? frame.ground.inst : frame.roof; // Provide the current floor or roof for the collision rectangle.
            inst = CheckCollisionRectangle(CollisionCoords(x, y, dx0, dy0, dx1, dy1), obj, frame.excludes, current) 
            if inst == noone {
                Move(0, delta)
                dist += abs(delta);
            } else {
                if _with_squish && delta < 0 {
                    inst = DoLateralSquish(delta)
                    if inst == noone {
                        //DebugMessage($"did lateral squish {delta}");
                        
                        dist += abs(delta);
                    }
                }
                
                if abs(delta) == 1.0 {
                    break;
                }
                delta = sign(delta)*ceil(abs(delta/2.0));
            }
        }
        return inst
    }
    
    
    static MoveToHang = function(_dy, candidate) {
        if abs(_dy) == 0.0 {
            return
        }
        
        var plat = candidate.plat
        
        y = min(plat.p0.y, plat.p1.y, plat.p2.y, plat.p3.y) + h_2;
        UpdateExcludes();
    }
    
    
    // If there is a block in the way that would stop vertical movement, 
    // lateral squish will allow the body to move to the side of that object 
    // and slide along it instead.
    function DoLateralSquish(delta) {
        var inst = CheckLateralSquish(delta, -lateral.squish)
        if inst == noone {
            Move(-lateral.squish, delta)
            MoveContactX(lateral.squish, objPlaBlock, false, false)
            return noone
        }
        inst = CheckLateralSquish(delta, lateral.squish)
        if inst == noone {
            Move(lateral.squish, delta)
            MoveContactX(-lateral.squish, objPlaBlock, false, false)
            return noone
        }
        return inst
    }


    function CheckLateralSquish(_dy, _dx) {
        if abs(_dy) == 0.0 {
            return noone
        }
    
        var dx0 = -(w_2) + _dx;
        var dx1 = w_2 + _dx;
        var dy0 = h_2*sign(_dy);
        var dy1 = dy0 + (_dy + sign(_dy)*abs(_dx)); // Add in dx term to stop lateral squishes on shallow slopes
        var current = _dy > 0 ? frame.ground.inst : frame.roof; // Provide the current floor or roof for the collision rectangle.
        return CheckCollisionRectangle(CollisionCoords(x, y, dx0, dy0, dx1, dy1), objPlaBlock, frame.excludes, current) 
    }
    
    
    function UpdateSpeed() {
        var had_floor = false;
        if frame.ground.inst != noone && spd.y > 0 {
            spd.y = 0;
            had_floor = true;
        }
        if spd.y < 0 && !CanMoveUp() {
            spd.y = 0;
        }
        
    
        landing.Update()
        turn.Update()
        lateral.cooldown.Update()
        jump.Update()
        
        y_drop = (movement.held.y > 0);
        y_up = (movement.held.y < 0);
        
        if y_drop {
            if frame.hang != noone {
                frame.hang_exclude = frame.hang
                frame.hang = noone;
            }
             
            if frame.wall.pressing {
                if movement.held.x == 0 {
                    face = -face;
                }
            }
        }
        
        if frame.hang && spd.x != 0 && array_contains(frame.excludes, frame.hang) {
            frame.hang_exclude = frame.hang
            frame.hang = noone;
        }
        
        if movement.pressed.x != face && movement.pressed.x != 0 {
            face = movement.pressed.x
            if frame.ground.inst != noone || frame.wall.pressing {
                turn.Trigger() // Turning on the floor or pushing off wall.
            } else {
                turn.Trigger(0.5) // Lower cooldown in the air.
            }
            
            
            if frame.hang != noone {
                frame.hang = noone;
            }
        }
        
        var x_accel = 0;
        if !lateral.cooldown.Active() && !turn.Active() {
            x_accel = movement.held.x
        }
        
        //if commands_check_pressed(cmds, CMD_A) {
            //attack.buffering = attack.buffering_count;
        //}
        //
        //if attack.buffering != 0 && dash.cooldown == 0 {
            //if command_attack() {
                //attack.buffering = 0;
            //}
        //}
        //
        //if commands_check(cmds, CMD_B) && dash.cooldown == 0 {
            //dash.target = clamp(dash.target + GameSpeed.Get(1), dash.min, dash.max);
        //}
        //
        //if commands_check_released(cmds, CMD_B) && dash.cooldown == 0  {
            //dash.trigger = true;    
        //}
        //
        
        if frame.ground.inst != noone {
            var _slip = -slip*frame.ground.ssin
            if (sign(_slip) == FaceLeft && frame.wall.left == noone) || (sign(_slip) == FaceRight && frame.wall.right == noone) {
                spd.x = GameSpeed().Accelerate(spd.x, _slip);
            }
        }
        
        ApplyFriction(x_accel)
        
        
        AccelerateX(x_accel);
        
        if (sign(x_accel) == face || abs(spd.x) > 0.75 || frame.wall.pressing) {
            var _pressing_prev = frame.wall.pressing;
            frame.wall.pressing = PressingIntoWall();
            if _pressing_prev && !frame.wall.pressing { 
                if spd.y > 0 {
                    spd.y = 0
                    jump.wall_coyote.Trigger()
                }
            }
        }
        
        
        if movement.jump.pressed {
            jump.buffering.Trigger();
        }
        
        if jump.buffering.Active() {
            if (frame.ground.inst != noone || jump.coyote.Active()) {
                spd.y = -jump.speed.start * frame.ground.scos;
                spd.x += -jump.speed.start * frame.ground.ssin;
                jump.Triggered()
            } else if (frame.hang != noone) {
                spd.y = -jump.speed.hang;
                spd.x = 0;
                frame.hang = noone;
                jump.Triggered()
            } else if (frame.wall.pressing) {
                spd.y = -jump.speed.start;
                spd.x = -face * jump.speed.start * jump.wall_factor;
                face = -face
                lateral.cooldown.Trigger();
                jump.Triggered()
            } else if (jump.wall_coyote.Active()) {
                spd.y = -jump.speed.start;
                spd.x = face * jump.speed.start * jump.wall_factor;
                lateral.cooldown.Trigger();
                jump.Triggered()
            }
        }
        
    
        if frame.wall.pressing || spd.y < 0 {
            var _jump_factor = 1.0;
                if abs(spd.y) < 0.25 {
                    _jump_factor = 0.5;
                }
            
            if (spd.y > 0 || !movement.jump.held) {
                ApplyGravity(jump.speed.drop_factor*_jump_factor);
            } else {
                ApplyGravity(_jump_factor);
            }
        } else {
            ApplyGravity();
        }
    }
    
    
    static ApplyGravity = function(factor=1) {
        if frame.ground.inst != noone {
            return
        }
        if frame.hang != noone {
            return
        }
        
        var accel = PlaGravity() * factor;
        var y_spd_max = terminal.air;
        if frame.wall.pressing {
            y_spd_max = terminal.wall;
        }
        if spd.y > 0 {
            accel *= frame.wall.pressing ? wall.friction_factor : 1.0;
        }
        spd.y = GameSpeed().Accelerate(spd.y, accel)
            
        if spd.y > y_spd_max {
            spd.y = y_spd_max;
        }
    }
    

    
    static ApplyFriction = function(x_accel) {
        if abs(spd.x) == 0 {
            return;
        }
        
        var on_floor = instance_exists(frame.ground.inst);
        
        var apply = (sign(x_accel) != sign(spd.x) && !lateral.cooldown.Active())
        apply |= on_floor
        apply |= turn.Active()
        
        if !apply {
            return
        }
        
        // When on the floor, we always apply friction. When we are in the air, we only apply it when there's no input
        if !on_floor && x_accel != 0 {
            return
        }
        
        var _delta = on_floor ? lateral.floor.frict * abs(frame.ground.scos) : lateral.air.decel;
        if abs(spd.x) < _delta {
            spd.x = 0;
        } else {
            spd.x -= sign(spd.x)*_delta;
        }
    }
    
    
    static AccelerateX = function(_xdir) {
        if _xdir == 0 {
            return;
        }
        var _accel = (frame.ground.inst == noone) ? lateral.air.accel : lateral.floor.accel;
        var _max = (frame.ground.inst == noone) ? lateral.air.max : (1 - _xdir*slip_factor*frame.ground.ssin)*lateral.floor.max;
        
        if (_xdir == FaceLeft && frame.wall.left != noone) || (_xdir == FaceRight && frame.wall.right != noone) {
            _accel = 0;
            if frame.ground.inst == noone && sign(spd.x) == _xdir {
                spd.x = 0    
            }    
        }
    
        var _spd = spd.x + _xdir*_accel;
        if abs(_spd) <= _max || abs(_spd) < abs(spd.x) {
            spd.x = _spd    
        } else if abs(_spd) > _max && abs(spd.x) < _max {
            spd.x = sign(_spd) * _max;
        }
        
        if sign(spd.x) == _xdir && face != _xdir {
            face = _xdir;
        }
    }
    
    
    static PressingIntoWall = function() {
        var _facing_wall = (frame.ground.inst == noone) && ((frame.wall.left != noone && face == FaceLeft) || (frame.wall.right != noone && face == FaceRight))
        return (CheckCollisionPoint(CollisionPoint(x, y, face*(w_2 + 1), h_2), objPlaBlock) != noone) && _facing_wall
    }
    
    
    // used to verify whether we set our y speed to zero.
    function CanMoveUp() {
        if frame.roof == noone {
            return true
        }
        var dy = max(abs(spd.y), 1)
        return CheckLateralSquish(-dy, -lateral.squish) == noone || CheckLateralSquish(-dy, lateral.squish) == noone
    }
    
    
    static Move = function(_dx, _dy) {
        x += _dx;
        y += _dy;
        x = clamp(x, w_2, room_width - w_2)
        UpdateExcludes();
    }
}



