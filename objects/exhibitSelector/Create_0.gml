event_inherited();


SelectAdd = 0
SelectRemove = 1

name = "Selector"


base = ["Add", "Remove"]
active = ["Add", "Remove"]


onSelection = function(which) {
    switch (which) {
        case SelectAdd:
            DebugMessage($"Added {array_length(active)}")
            if array_length(active) >= array_length(base) {
                array_push(active, $"option {array_length(active)}")
            } else {
                array_push(active, array_get(base, array_length(active)))
            }
            break;
        case SelectRemove:
            DebugMessage($"Removed {array_length(active)-1}")
            array_delete(active, array_length(active)-1, 1)
            break;
        default:
            DebugMessage($"Selected {which}")
            break;
    }
    selector.Refresh(active, onSelection)
    PushControlStack(selector.uid)
}

selector = new Selector(640, room_height/2+64);
selector.Activate(active, onSelection)
PushControlStack(selector.uid)

