var others = impulseDetect.GetOthers()

cooldown.Update()

array_foreach(others, function(o) {
    with (o) {
        var Force = 6
        var f = (new Vec2(phy_position_x - other.phy_position_x, phy_position_y- other.phy_position_y )).Unit().Multiply(Force)
        
    
        physics_apply_force(phy_position_x, phy_position_y, f.x, f.y);
    }
    
    if !cooldown.Active() {
        cooldown.Trigger()
        CreateSfx(BumperSfx())
    }
})