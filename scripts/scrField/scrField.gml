function Field(_maxLength = 32) constructor {
    uid = GetUniqueId()
    input = ""
    maxLength = _maxLength
    
    static Start = function() {
        input = ""
        PushControlStack(uid)
    }
    
    static Update = function() {
        if !IsActiveControl(uid) { 
            return
        }
        
        if keyboard_check_pressed(vk_backspace) {
            input = string_delete(input, string_length(input), 1);
        }
        
        var c = keyboard_lastchar;
        if c != "" {
            keyboard_lastchar = "";
            var o = ord(c);
            if o >= 32 && o <= 126 && string_length(input) < maxLength {
                input += c;
            }
        }
            
        if (keyboard_check_pressed(vk_enter)) {
            PopControlStack()
        }
       
    }
    
    static Active = function() {
        return IsActiveControl(uid)
    }
    
    static Get = function() {
        return input
    }
}