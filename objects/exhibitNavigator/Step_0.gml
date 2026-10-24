event_inherited()


if keyboard_check(ord("N")) {
    array_push(active, $"item{array_length(active)}")
    navigator.Refresh(active, onSelection)
}

navigator.Update()

