// Inherit the parent event
event_inherited();

exhibits = [] // Populate this.
index = 0
active = noone

Add = function(exhibit) {
    if active == noone {
        active = instance_create_depth(0, 0, 0, exhibit)
    }
    array_push(exhibits, exhibit)
}