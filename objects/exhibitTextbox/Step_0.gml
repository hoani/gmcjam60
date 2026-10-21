event_inherited()

if keyboard_check_pressed(vk_space) {
    var msg = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    textbox.Set("Bilbo Baggins", new Text(msg, FontLookup(f_test)))
    PushControlStack(textbox.uid)
}

textbox.Update()

