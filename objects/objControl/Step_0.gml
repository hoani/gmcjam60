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