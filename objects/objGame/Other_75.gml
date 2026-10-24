if ds_map_find_value(async_load, "event_type") == "gamepad discovered" {
    var _index = ds_map_find_value(async_load, "pad_index");
    if _index == 0 {
        CommandsRegisterGamepad(Cmds(), _index) ;
    }
}