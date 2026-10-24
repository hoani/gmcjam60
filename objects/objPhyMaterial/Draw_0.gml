if (PhysicsWorld().Started()) {
    body.Draw(self)
}

if Debug() && keyboard_check(vk_space) {
    physics_draw_debug()
}