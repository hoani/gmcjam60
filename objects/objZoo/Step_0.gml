if cooldown.Active() {
    cooldown.Update()
    return
}

if keyboard_check_pressed(ord(",")) || mouse_wheel_up() {
    if !is_undefined(zoo_prev) {
        room_goto(zoo_prev)
    }
}

if keyboard_check_pressed(ord("."))  || mouse_wheel_down() {
    if !is_undefined(zoo_next) {
        room_goto(zoo_next)
    }
}
