if active == noone {
    show_error($"Keeper {name} has no exhibits", true)
}

if cooldown.Active() {
    cooldown.Update()
    return
}

if keyboard_check_pressed(ord(",")) || mouse_wheel_up() {
    if index == 0 {
        event_inherited()
        return
    }
    index--
    instance_destroy(active)
    active = instance_create_depth(0, 0, 0, exhibits[index])
}

if keyboard_check_pressed(ord("."))  || mouse_wheel_down() {
    if index >= array_length(exhibits) - 1 {
        event_inherited()
        return
    }
    index++
    instance_destroy(active)
    active = instance_create_depth(0, 0, 0, exhibits[index])
}