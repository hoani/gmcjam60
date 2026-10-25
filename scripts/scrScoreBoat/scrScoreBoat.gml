function ScoreBoat() {
    if !variable_global_exists("scoreboatHandler") {
        global.scoreboatHandler = new _ScoreBoatHandler();
    }
    return global.scoreboatHandler
}



function _ScoreBoatHandler() constructor {
    
    cb = {
        login: {
            failure: new CompoundCallback(),
            success: new CompoundCallback(),
        },
        upload: {
            failure: new CompoundCallback(),
            success: new CompoundCallback(),
        }
    }
    
    cred = OnlineCredentials()
    
    levelSpec = noone
    
    userId = ""
    static isReady = false
    
    static Login = function(_success = FuncNone, _fail = FuncNone) {
        if isReady {
            return sb_refresh().success(_success).fail(_fail); // Just give a request so that success etc still work
        }
        var loggingIn = cb.login.success.HasPending()
        cb.login.success.Push(_success)
        cb.login.failure.Push(_fail)
        if loggingIn {
            return
        }
        sb_init(cred.Game(), cred.Prefix(), cred.Secret())
            .success(function(_info) {
                DebugMessage($"Scoreboat is ready");
                sb_player_guest().success(function(p){
                    userId = p.id
                    DebugMessage($"Signed in as {userId}");
                    isReady = true
                    cb.login.success.Call(p)
                    cb.login.failure.Clear()
                })
                .fail(function(_error) {
                    DebugMessage("Guest sign in failed: " + _error.message);
                    cb.login.success.Clear()
                    cb.login.failure.Call(_error)
                })
            })
            .fail(function(_error) {
                DebugMessage("Scoreboat failed: " + _error.message);
                cb.login.success.Clear()
                cb.login.failure.Call(_error)
            })
    }


    static Ready = function() {
        return isReady && sb_ready()
    }
    
    static BrowseLevels = function(offset=0, limit=50, order="newest", _success = FuncNone, _fail = FuncNone) {
        return sb_leaderboard_scores(cred.LevelBoard(), {offset: offset, limit: limit, order: order}, _success, _fail)
    }
    
    static LevelIncrField = function(uuid, field, _success = FuncNone, _fail = FuncNone) {
        sb_datastore_incr(cred.LevelData(), uuid, field, 1, _success, _fail)
    }
    
    static UploadLevel = function(_levelSpec, _success = FuncNone, _fail = FuncNone) {
        levelSpec = _levelSpec
        cb.upload.success.Push(_success)
        cb.upload.failure.Push(_fail)
        // We attempt a delete first, this is necessary when editing.   
        sb_datastore_delete(cred.LevelData(), ScoreBoat().userId, function() {_UploadLevel()}, function() {_UploadLevel()})
    }
    
    static _UploadLevel = function() {
        var fields = {plays: 0, wins: 0, uplays: 0, likes: 0, level: levelSpec.level, name: levelSpec.name, username: levelSpec.username }
        var spec = { 
            plays: { op: "incr" }, 
            wins: { op: "incr", once_per_player: true },
            uplays: { op: "incr", once_per_player: true },
            likes: { op: "incr", once_per_player: true },
            level: { op: "set" },
            name: { op: "set" },
            username: { op: "set" },
        };
        
        sb_datastore_create(cred.LevelData(), ScoreBoat().userId, fields, spec)
            .fail(function(_error) {
                DebugMessage("Creating datastore failed "+ _error.message);
                cb.upload.success.Clear()
                cb.upload.failure.Call(_error)
            })
            .success(function() {
                var options = {
                    overwrite: true, 
                    extra_data: {
                        name: levelSpec.name
                    },
                }
                sb_leaderboard_submit(cred.LevelBoard(), levelSpec.username, 0, options).success(
                    function(_info) {
                        DebugMessage("Level added to index")
                        cb.upload.success.Call(_info)
                        cb.upload.failure.Clear()
                    }
                )
                .fail(
                    function(_error) {
                        DebugMessage("Failed to index level")
                        cb.upload.success.Clear()
                        cb.upload.failure.Call(_error)
                    }
                )
            });
    }

    
    static DownloadLevel = function(uuid, _success = FuncNone, _fail = FuncNone) {
        return sb_datastore_get(cred.LevelData(), uuid, _success, _fail)
    }
    
    static DownloadUserLevel = function(_success = FuncNone, _fail = FuncNone) {
        return DownloadLevel(userId, _success, _fail)
    }
    
}