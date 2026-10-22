event_inherited()



if keyboard_check_pressed(vk_space) {
    enable = !enable
}

hole_data[index] = mouse_x
hole_data[index + 1] = mouse_y 
hole_data[index + 2] = 5

if mouse_check_button_pressed(mb_left) {
    index = (index + 3) % (8*3)
}

