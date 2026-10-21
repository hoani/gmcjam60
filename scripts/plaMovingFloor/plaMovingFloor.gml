
function PlatMoveBasic(ctx, lateral) {
    ctx.x += lateral.dx
    ctx.y += lateral.dy
}

function PlatMoveWrapAround(ctx, lateral) {
    ctx.x += lateral.dx
    var p = ctx.plat;
    if p.x0 > room_width && p.x1 > room_width && p.x2 > room_width && p.x3 > room_width {
        ctx.x -= (room_width + max(abs(p.x0 - p.x1), abs(p.x1 - p.x2)));
    }
    
    if p.x0 < 0 && p.x1 < 0 && p.x2 < 0 && p.x3 < 0 {
        ctx.x += (room_width + max(abs(p.x0 - p.x1), abs(p.x1 - p.x2)));
    }
    
    ctx.y += lateral.dy
    if p.y0 > room_height && p.y1 > room_height && p.y2 > room_height && p.y3 > room_height {
        ctx.y -= (room_height + 8 + max(abs(p.y0 - p.y1), abs(p.y1 - p.y2)));
    }
    
    if p.y0 < 0 && p.y1 < 0 && p.y2 < 0 && p.y3 < 0 {
        ctx.y += (room_height + 8 + max(abs(p.y0 - p.y1), abs(p.y1 - p.y2)));
    }
}


function PlatMovingFloor(_x, _y, xscale, yscale, spr, angle, _centered=false) : PlatFloor(_x, _y, xscale, yscale, spr, angle, _centered) constructor {
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
        // Collect all candidates.
        with (objPlaBody) {
            var l = other.lateral
            if self.body.frame.ground.inst == other.ctx.id {
                array_push(other.floor_bodies, id);
            } else if l.dy < 0 && place_meeting(x - l.dx, y - l.dy, other.ctx.id) && !place_meeting(x, y, other.ctx.id)  {
                array_push(other.push_bodies, id);
            }
        }
        
        
        for (var i = 0; i<array_length(floor_bodies); i++) {
            var body = floor_bodies[i];
            with(body) {
                var l = other.lateral
                if l.dy < 0 {
                    var contact = self.body.MoveContactY(l.dy, objPlaBlock);
                    if contact != noone {
                        self.body.SquashFloor(l.dx, l.dy);
                    }
                }
            }
        }
        
        for (var i = 0; i<array_length(push_bodies); i++) {
            var body = push_bodies[i];
            with(body) {
                var l = other.lateral
                var contact = self.body.MoveContactY(l.dy, objPlaBlock);
                if contact != noone {
                    self.body.SquashFloor(l.dx, l.dy);
                }
            }
        }
        
        
        doMove(ctx, lateral)
        
        UpdatePosition(ctx.x, ctx.y)
        
        
        for (var i = 0; i<array_length(push_bodies); i++) {
            var body = push_bodies[i];
            with(body) {
                var l = other.lateral
                self.body.MoveContactY(-l.dy, objPlaFloor);
            }
        }
        
        for (var i = 0; i<array_length(floor_bodies); i++) {
            var body = floor_bodies[i];
            with(body) {
                var l = other.lateral
                self.body.MoveContactX(l.dx, objPlaBlock);
                if l.dy > 0 {
                    self.body.MoveContactY(l.dy, objPlaFloor);
                }
            }
        }
        
    }
}