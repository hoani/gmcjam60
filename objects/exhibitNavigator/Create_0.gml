event_inherited();


SelectAdd = 0
SelectRemove = 1

name = "navigator"


active = [
    "Item 0", 
    "Item 1", 
    "Item 2", 
    "Item 3", 
    "Item 4", 
    "Item 5",
    "Item 6", 
    "Item 7", 
    "Item 8", 
    "Item 9", 
    "Item 10"
]


onSelection = function(which) {
    DebugMessage($"Selected {which}")
    navigator.Refresh(active, onSelection)
}

navigator = Navigator(640, room_height/2);
navigator.Activate(active, onSelection)
PushControlStack(navigator.uid)

