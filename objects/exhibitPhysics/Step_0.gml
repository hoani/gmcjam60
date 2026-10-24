event_inherited()


builder.Update()

if keyboard_check(vk_enter) {
    world.Start()
}

if mouse_check_button_pressed(mb_right) {
    builder.SelectNext()
}


if keyboard_check_pressed(ord("Z")) {
    builder.Undo()
}

if keyboard_check_pressed(ord("X")) {
    builder.Redo()
}


if keyboard_check_pressed(ord("N")) {
    ScoreBoat().UploadLevel(builder.assembly.EncodeFull()).success(function(_info){
        DebugMessage("File Uploaded")
    }).fail(function(_info){
        DebugMessage("Failed to Upload")
    })
}

if keyboard_check_pressed(ord("M")) {
    ScoreBoat().DownloadLevel().success(function(_file){
        DebugMessage("Level downloaded")
        builder.assembly.LoadBase(_file.text)
    }).fail(function(_info){
        DebugMessage("Failed to Upload")
    })
}

