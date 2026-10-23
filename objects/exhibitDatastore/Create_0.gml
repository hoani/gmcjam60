event_inherited();


SelectAdd = 0
SelectRemove = 1

name = "Scoreboat V" + SB_VERSION + " Datastore"


step = 0;


ScoreBoat().Login()
        .success(function(_info) {
            show_debug_message("Scoreboat is ready");
        })
        .fail(function(_error) {
            show_debug_message("Scoreboat failed: " + _error.message);
        });

DatastoreId = "1TYp9YFDwQ"