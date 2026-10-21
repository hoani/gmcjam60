event_inherited()


if !field.Active() {
    if keyboard_check_pressed(vk_enter) {
        field.Start()
    }
} else {
    field.Update()
}



