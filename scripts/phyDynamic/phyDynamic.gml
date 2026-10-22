function BodyDynamic()  constructor {
    prev = {
        spd: new Vec2(),
        angle: 0,
    }
    
    static PreUpdate = function(ctx) {
        prev.spd.x = ctx.phy_speed_x
        prev.spd.y = ctx.phy_speed_y
        prev.angle = -ctx.phy_rotation
    }
}



