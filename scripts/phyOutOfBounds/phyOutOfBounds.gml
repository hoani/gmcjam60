
function OutOfBoundsSfx() {
    if !variable_global_exists("outOfBoundsSfx") {
        global.outOfBoundsSfx = new SfxSequence([sndFall0, sndFall1, sndFall2, sndFall3])
    }
    return global.outOfBoundsSfx.Get()
}

function CommonOutOfBounds() {
    InstanceCreate(phy_position_x, phy_position_y, objOutOfRing, {spd: new Vec2(phy_speed_x, phy_speed_y)})
    instance_destroy()
}
