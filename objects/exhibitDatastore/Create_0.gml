event_inherited();


SelectAdd = 0
SelectRemove = 1

name = "Scoreboat V" + SB_VERSION + " Datastore"


step = 0;


ScoreBoat().Login(
    function(_info) {
        show_debug_message("Scoreboat is ready");
    },
    function(_error) {
        show_debug_message("Scoreboat failed: " + _error.message);
    }
);

DatastoreId = ScoreBoat().cred.ZooDatastore()