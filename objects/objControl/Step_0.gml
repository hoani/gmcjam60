state.Update()

switch state.Get() {
    case StateTitle:
        if !IsActiveControl(c.title.uid) {
            state.Set(StateBuild)
        }
        break;
    case StateBuild:
        if world.Started() {
            state.Set(StatePlay)
        }
        break;
    case StatePlay:
        
        break;
    case StateWin:
        
        break;
    case StateLose:
        
        break;
}


struct_foreach(c, function(_, v) {
    v.Update()
})


struct_foreach(help, function(_, v) {
    v.Update()
})


if Debug() {
    if keyboard_check_pressed(vk_space) {
        //InstanceCreate(room_width/2, room_height/2, objEggSplat, {impulse: new Vec2(0, 2)})
        InstanceCreate(room_width/2, room_height/2, objJoinSplat)
    }
}