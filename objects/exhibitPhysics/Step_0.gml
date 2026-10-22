event_inherited()

if mouse_check_button_pressed(mb_left) {
    if placement == noone {
        placement = materials[active].Placement()
    }
}

if placement != noone {
    placement.Drag(MouseX, MouseY)
}

if mouse_check_button_released(mb_left) {
    if placement.Confirm(MouseX, MouseY) != noone {
        placement = noone
    }
} 

if keyboard_check(vk_enter) {
    world.Start()
}

if mouse_check_button_pressed(mb_right) {
    active = (active + 1) % array_length(materials) 
}

