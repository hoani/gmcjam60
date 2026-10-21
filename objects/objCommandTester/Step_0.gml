for (var i = 0; i<array_length(Cmds()._command_list); i++) {
    var _cmd = Cmds()._command_list[i];
    if Cmds().Pressed(_cmd) {
        show_debug_message($"{_cmd} pressed");
    }
    if Cmds().Check(_cmd) {
        show_debug_message($"{_cmd} active");
    }
    if Cmds().Released(_cmd) {
        show_debug_message($"{_cmd} released");
    }
}
