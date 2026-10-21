


function PlatMovingBlock(_x, _y, xscale, yscale, spr, angle, _centered=false) : PlatMovingFloor(_x, _y, xscale, yscale, spr, angle, _centered) constructor {
    doMove = PlatMoveBasic
    lateral = new Lateral()
    ctx = noone
    
    
    static Update = function(_ctx) {
        ctx = _ctx
        if !lateral.Update(ctx.xspd, ctx.yspd) {
            return
        }
        
        floor_bodies = [];
        push_bodies = [];
        wall_bodies = [];
        // Collect all candidates.
        with (objPlaBody) {
            var l = other.lateral
            var f = self.body.frame;
            var face = self.body.face;
            if f.ground.inst == other.ctx.id || f.hang == other.ctx.id {
                array_push(other.floor_bodies, id);
            } else if ((f.wall.left == other.ctx.id && face == self.body.FaceLeft) || (f.wall.right == other.ctx.id && face == self.body.FaceRight)) && f.wall.pressing {
                array_push(other.wall_bodies, id);
            } else if place_meeting(x - l.dx, y - l.dy, other.ctx.id) && !array_contains(f.excludes, other.ctx.id)   {
                array_push(other.push_bodies, id);
            }
        }
        
        
        for (var i = 0; i<array_length(floor_bodies); i++) {
            var body = floor_bodies[i];
            with(body) {
                var l = other.lateral
                var f = self.body.frame;
                var face = self.body.face;
                if sign(face) != sign(l.dx) {
                    var contact = self.body.MoveContactX(l.dx, objPlaBlock); // Only move x if it is moving away from the block.
                    if contact != noone && other.ctx.id == f.hang {
                        self.body.SquashBlock(l.dx, l.dy);
                    }
                }
                if l.dy < 0 {
                    var contact = self.body.MoveContactY(l.dy, objPlaBlock, true);
                    if contact != noone {
                        if other.ctx.id == f.hang {
                            f.hang = noone;
                        } else {
                            self.body.SquashBlock(l.dx, l.dy);
                        }
                    }
                }
            }
        }
        
        for (var i = 0; i<array_length(push_bodies); i++) {
            var body = push_bodies[i];
            with(body) {
                var l = other.lateral
                var f = self.body.frame;
                var face = self.body.face;
                var contact = self.body.MoveContactX(l.dx, objPlaBlock, true, true);
                if contact != noone && (contact != f.ground.inst || f.ground.inst == noone) {
                    self.body.SquashBlock(l.dx, l.dy);
                }
                contact = self.body.MoveContactY(l.dy, objPlaBlock, true);
                if contact != noone {
                    // See if we can move out of the way of the block.
                    if self.body.DoLateralSquish(-l.dy) == noone {
                        contact = self.body.MoveContactY(l.dy, objPlaBlock, true);
                        self.body.MoveContactY(l.dy, objPlaBlock, false); // Don't count the second move as squishable.
                    }
                }
                if contact != noone {
                    self.body.SquashBlock(l.dx, l.dy);
                }
            }
        }
        
        for (var i = 0; i<array_length(wall_bodies); i++) {
            var body = wall_bodies[i];
            with(body) {
                var l = other.lateral
                var f = self.body.frame;
                var face = self.body.face;
                if sign(face) != sign(l.dx) {
                    var contact = self.body.MoveContactX(l.dx + sign(l.dx), objPlaBlock); // Only move x if it is moving away from the block.
                    if contact != noone {
                        self.body.SquashBlock(l.dx, l.dy);
                    }
                }
            }
        }
        
        
        doMove(ctx, lateral)
        
        UpdatePosition(ctx.x, ctx.y)
        
        
        for (var i = 0; i<array_length(push_bodies); i++) {
            var body = push_bodies[i];
            with(body) {
                var l = other.lateral
                if abs(l.dx) > 1.0 {
                    // Move back into the block, but only if the block is moving fast enough.
                    self.body.MoveContactX(-abs(l.dx-1.0)*sign(l.dx), objPlaBlock, true);
                } 
                self.body.MoveContactY(-l.dy, objPlaFloor);
            }
        }
        
        for (var i = 0; i<array_length(wall_bodies); i++) {
        var body = wall_bodies[i];
        with(body) {
            var l = other.lateral
            var face = self.body.face;
            if sign(face) == sign(l.dx) {
                self.body.MoveContactX(l.dx, objPlaBlock, true, false);
            } else {
                self.body.MoveContactX(-l.dx, objPlaBlock, true, false);
            }
        }
    }
        
        for (var i = 0; i<array_length(floor_bodies); i++) {
            var body = floor_bodies[i];
            with(body) {
                var l = other.lateral
                var face = self.body.face;
                //self.body.MoveContactX(l.dx, objPlaBlock);
                if sign(face) == sign(l.dx) {
                    self.body.MoveContactX(l.dx, objPlaBlock);
                } 
                if l.dy > 0 {
                    self.body.MoveContactY(l.dy, objPlaFloor);
                }
            }
        }
        
    }
}