event_inherited()

if !variable_global_exists("zooctx") {
    global.zooctx = {}
}


zoo_prev = undefined
zoo_next = undefined
if string_starts_with(room_get_name(room_previous(room)), "zoo") {
    zoo_prev = room_previous(room)
}

if string_starts_with(room_get_name(room_next(room)), "zoo") {
    zoo_next = room_next(room)
}

cooldown = new Cooldown(30);
cooldown.Trigger()

// Resize the window and surface for the zoo
window_set_size(room_width, room_height);
surface_resize(application_surface, room_width, room_height);
