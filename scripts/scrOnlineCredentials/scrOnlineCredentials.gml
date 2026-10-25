
#macro GameSpec "GMCJAM"
#macro LevelSizeUpper 4096


function OnlineCredentialsClass(_game) constructor {
    game=_game
    keys = {
        prefix: "",
        secret: "",
    }
    levels = {
        datastore: "",
        leaderboard: "",
    }
    zoo = {
        datastore: "",
    }
    
    static WithKeys = function(_prefix, _secret) {
        keys.prefix = _prefix
        keys.secret = _secret
        return self
    }
    
    static WithLevels = function(_datastore, _leaderboard) {
        levels.datastore = _datastore
        levels.leaderboard = _leaderboard
        return self
    }
    
    static WithZoo = function(_datastore) {
        zoo.datastore = _datastore
        return self
    }
    
    static Game = function() {
        return game
    }
    
    static Prefix = function() {
        return keys.prefix
    }
    
    static Secret = function() {
        return keys.secret
    }
    
    static LevelData = function() {
        return levels.datastore
    }
    
    static LevelBoard = function() {
        return levels.leaderboard
    }
    
    static ZooDatastore = function() {
        return zoo.datastore
    }
}

function OnlineCredentials() {
    switch (GameSpec) {
        case "GMCJAM": {
            var spec = (new OnlineCredentialsClass("NMEQhE0"))
                .WithKeys("8gZ4S3QvcjGbVcZP", "BYhyV4LbxrphYBbdAegP6hVhX4rDiFDbZT4Umj7T9NE")
                .WithZoo("1jsjU2jkfj")
            ;
            if Debug() {
                return spec.WithLevels("lQ5dlgsVBN", "N4UrM0IMaa")
            }
            return spec.WithLevels("JE3XQfXh7X", "k2yfPrKgnA")
        }
    }
    
    show_error($"No spec available for {GameSpec}", true)
    return new OnlineCredentialsClass("")
}