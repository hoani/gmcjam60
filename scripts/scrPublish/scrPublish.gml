


function Publish(_doPublish, _onPublish) : ActiveController() constructor {
    static StateIdle = 0
    static StateName = 1
    static StateUser = 2
    static StatePublish = 3
    static StateDone = 4
    
    state = new State(StateIdle)

    doPublish = _doPublish
    onPublish = _onPublish
    
    name = "My Level"
    username = "Steve"
    
    input = new Field(20)
    
    
    minLength = 4
    
    
    instructionText = NewText("", FontLookup(fScrawlingPadLg)).WithAlign(fa_middle)
    formText = NewText("", FontLookup(fGoblinAppears)).WithAlign(fa_middle)
    errorText = NewText("", FontLookup(fScrawlingPadSm)).WithAlign(fa_middle)
    
    
    texts = [
        instructionText,
        formText,
        errorText
    ]
    
    static Reset = function() {
        instructionText.Set("")
        formText.Set("")
        errorText.Set("")
        input.Set("")
        state.Set(StateIdle)
    }
    
    static Done = function(message) {
        instructionText.Set(message)
        state.Set(StateDone)
        input.Set("")
        formText.Set("")
        errorText.Set("")
    }
    
    static Update = function() {
        if !InControlStack(uid) {
            state.Set(StateIdle)
            return
        }
        
        state.Update()
        
        var proceed = false
        var offensive = FilterOffensive(input.Get()) 
        
        var stringLength = string_length(input.Get())
        if stringLength >= minLength {
            errorText.Set("")
        }
        
        if offensive != "" {
            errorText.Set($"Input contains slur {CH_COL_RED + offensive + CH_COL_RESET}, please choose a different name")
        } else if keyboard_check_pressed(vk_enter) {
            if string_length(input.Get()) < minLength {
                errorText.Set($"Please use at least {minLength} characters")
            } else {
                proceed = true
            }
        }
        
        input.Update()
        
        
        switch state.Get() {
            case StateIdle:
                instructionText.Set("Please enter the name of this level")
                state.Set(StateName)
                input.Set(name)
                break;
            case StateName:
                formText.Set(input.Get())
                if proceed {
                    instructionText.Set("Please enter your username")
                    state.Set(StateUser)
                    name = input.Get()
                    input.Set(username)
                }
                break
            case StateUser:
                formText.Set(input.Get())
                if proceed {
                    instructionText.Set("Publishing in progress")
                    state.Set(StatePublish)
                    username = input.Get()
                    input.Set("")
                    doPublish(name, username)
                }
                break
            case StatePublish:
                break
            case StateDone:
                if keyboard_check_pressed(vk_enter) && state.Mono() > 20 {
                    Reset()
                    onPublish(name, username)
                }
                break
        }
        
        array_foreach(texts, function(text){ text.Step(); })
    }
    
    static Draw = function() {
        if !InControlStack(uid) {
            return
        }
        
        instructionText.Draw(0, room_height/4)
        formText.Draw(0, room_height/2)
        errorText.Draw(0, room_height*3/4, C_YELLOW)
        
    }

}