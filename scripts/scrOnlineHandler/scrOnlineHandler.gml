function OnlineHandler() constructor {
    levelSpec = noone
    online = ScoreBoat()
    registry = new LevelRegistry()
    offset = 0
    pending = []
    
    StateIdle = 0
    StateActive = 1
    StateCooldown = 2
    s = new State(StateIdle)
    
    onLevelRegistry = FuncNone
    
    
    static Update = function() {
        s.Update()
        switch s.Get() {
            case StateIdle:
                // Try to do something
                if UpdateAction() {
                    s.Set(StateActive)
                }
                break;
            case StateActive: 
                // Taking too long 5s, assume we are idle again
                if s.Mono() > 300 {
                    s.Set(StateIdle)
                }
                break;
            case StateCooldown:
                // We failed, so wait a little bit
                if s.Mono() > 60 {
                    s.Set(StateIdle)
                }
                break;
        }
    }
    
    // Not used, just expected
    static Draw = function() {}
    
    
    static OnLevelRegistry = function(_onLevelRegistry) {
        onLevelRegistry = _onLevelRegistry
    }
    
    static UpdateAction = function() {
        if !online.Ready() {
            Login()
            return true
        }
        
        if levelSpec == noone {
            FetchLevelSpec()
            return true
        }
        
        if array_length(registry.GetActiveList()) == 0 {
            PopulateRegistry()
            return true
        }
        
        if array_length(pending) != 0 {
            UpdatePending()
            return true
        }
        
        // Every 5 minutes, repopulate the registry
        if s.Mono() > 60*60*5 {
            PopulateRegistry()
        }
        
        return false
    }
    
    static RequestPopulateRegistry = function() {
        PopulateRegistry()
    }
    
    static Login = function() {
        online.Login(
            function(spec){
                if online.Ready() {
                    s.Set(StateIdle)
                    return
                }
                s.Set(StateCooldown)
            },
            function(error){
                s.Set(StateCooldown)
            }
        )
    }
    
    static FetchLevelSpec = function() {
        online.DownloadUserLevel(
            function(spec){
                s.Set(StateIdle)
                var levelname = struct_get(spec.data, "name") ?? "My Level"
                var username = struct_get(spec.data, "username") ?? "Guest"
                levelSpec = new LevelEntryClass(online.userId, levelname, username)
                levelSpec.Populate(spec.data)
            },
            function(error){
                if error.http_status == 404 {
                    DebugMessage("No level spec, creating default")
                    s.Set(StateIdle)
                    levelSpec = new LevelEntryClass(online.userId, "My Level", "Guest")
                    return
                }
                DebugMessage("Getting level spec failed... cooling down")
                s.Set(StateCooldown)
            }
        )
    }
    
    static UpdatePending = function() {
        var uuid = array_last(pending)
        
        online.DownloadLevel(
            uuid,
            function(spec){
                DebugMessage($"Downloaded level {spec}")
                var uuid = array_last(pending)
                array_pop(pending)
                registry.Populate(uuid, spec.data)
                onLevelRegistry()
                s.Set(StateIdle)
            },
            function(error){
                array_pop(pending) // abandon, it's not worth fussing over.
                DebugMessage("Getting level spec failed... cooling down")
                s.Set(StateCooldown)
            }
        )
    }
    
    
    static PopulateRegistry = function() {
        online.BrowseLevels(0, 200, "newest", 
            function(spec){
                var len = array_length(spec.scores)
                DebugMessage($"Got {len}")
                if len == 0 {
                    s.Set(StateCooldown)
                    return
                }
                
                for (var i = 0; i<len; i++) {
                    var levelSpec = spec.scores[i]
                    var extraData = struct_get(levelSpec, "extra_data") ?? {}
                    var levelName = struct_get(extraData, "name") ?? "Unknown"
                    var username = struct_get(levelSpec, "player_name") ?? "Guest"
                    var player = struct_get(levelSpec, "player") ?? ""
                    if player == "" {
                        continue
                    }
                    levelSpec = new LevelEntryClass(player, levelName, username)
                    registry.OnLevel(levelSpec)
                    array_push(pending, player)
                }
                onLevelRegistry()
                s.Set(StateIdle)
            },
            function(error){
                DebugMessage("Getting level registry failed... cooling down")
                s.Set(StateCooldown)
            }
        )
    }
    
    
    
    
    static PublishLevel = function(name, username, enc, _success, _failure) {
        var _levelSpec = new LevelEntryClass(online.userId, name, username)
        _levelSpec.level = enc
        online.UploadLevel(_levelSpec, _success, _failure)
    }
    
    static IsOnline = function() {
        return online.Ready()
    }
    
    static HasUserLevelSpec = function() {
        return levelSpec != noone
    }
    
    static GetUserLevelSpec = function() {
        return levelSpec
    }
    
    
    static GetLeaderboard = function() {
        return registry
    }

}