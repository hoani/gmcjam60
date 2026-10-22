event_inherited()


var mx = round(MouseX/grid)*grid
var my = round(MouseY/grid)*grid

if mouse_check_button_pressed(mb_left) {
    if placement == noone {
        placement = materials[active].Placement()
    }
}

if placement != noone {
    placement.Drag(mx, my)
}

if mouse_check_button_released(mb_left) {
    if placement.Confirm(mx, my) != noone {
        placement = noone
    }
} 

if keyboard_check(vk_enter) {
    world.Start()
}

if mouse_check_button_pressed(mb_right) {
    active = (active + 1) % array_length(materials) 
}

