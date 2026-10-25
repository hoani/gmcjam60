event_inherited()

if !ScoreBoat().Ready() {
    return
}

if keyboard_check_pressed(ord("B")) {
    DebugMessage("Creating datastore")
    var fields = {plays: 0, wins: 0, name: "HoaniLand"}
    var spec = { plays: { op: "incr" }, wins: { op: "incr", once_per_player: true } };
    sb_datastore_create(DatastoreId, ScoreBoat().userId, fields, spec)
        .fail(function(_error) {
            show_debug_message("datastore failed: " + _error.message);
        });
}
    

if keyboard_check_pressed(ord("N")) {
    sb_datastore_incr(DatastoreId, ScoreBoat().userId, "plays")
        .success(function(_info) {
            show_debug_message("Plays incremented");
            sb_datastore_get(DatastoreId, ScoreBoat().userId)
                .success(function(_info){
                    DebugMessage(_info)
                })
        })
        .fail(function(_error) {
            show_debug_message("Incr plays failed: " + _error.message);
        });
}


if keyboard_check_pressed(ord("K")) {
    sb_datastore_get(DatastoreId, "unknown")
        .success(function(_info){
            DebugMessage(_info)
        })
        .fail(function(_info){
            DebugMessage(_info)
        })
}

if keyboard_check_pressed(ord("M")) {
    sb_datastore_incr(DatastoreId, ScoreBoat().userId, "wins")
        .success(function(_info) {
            show_debug_message("Wins incremented");
            sb_datastore_get(DatastoreId, ScoreBoat().userId)
                .success(function(_info){
                    DebugMessage(_info)
                })
        })
        .fail(function(_error) {
            show_debug_message("Incr wins failed: " + _error.message);
        });
}
