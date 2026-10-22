event_inherited()

if mouse_check_button_pressed(mb_left) {
    pStart.x = MouseX
    pStart.y = MouseY
}

if mouse_check_button_released(mb_left) {
    materials[active].Place(pStart.x, pStart.y, MouseX, MouseY)
} 

if keyboard_check(vk_enter) {
    world.Start()
}

if mouse_check_button_pressed(mb_right) {
    active = (active + 1) % array_length(materials) 
}

