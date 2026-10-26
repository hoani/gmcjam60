// Inherit the parent event
event_inherited();

if !PhysicsWorld().Started() {
    return
}




with (objPhyMaterial) {
    if (id == other.id) {
        continue;
    }
    
    var KPull = 10*256*256

    var dv = new Vec2(other.phy_position_x - phy_position_x, other.phy_position_y - phy_position_y)
    var d = max(dv.Distance(), 32); // clamp so force doesn't explode at close range

    var f = KPull * phy_mass / (d*d);

    physics_apply_force(phy_position_x, phy_position_y, f * dv.x / d, f * dv.y / d);
}

