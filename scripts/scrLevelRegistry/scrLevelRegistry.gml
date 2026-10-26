function LevelRegistry() constructor {
    levels = {}
    levelsList = []
    active = []
    activeDisplay = []
    refresh = false
    
    static OnLevel = function(input) {
        var exists = struct_exists(levels, input.uuid)
        struct_set(levels, input.uuid, input)
        if !exists {
            array_push(levelsList, input.uuid)
        }
        refresh = true
    }
    
    static Populate = function(uuid, s) {
        if !struct_exists(levels, uuid) {
            return
        }
        struct_get(levels, uuid).Populate(s)
        refresh = true
    }
    
    static GetActiveList = function() {
        if refresh {
            refresh = false
            _RefreshActive()
        }
        return active
    }
    
    static GetActive = function(index) {
        var list = GetActiveList()
        return active[index % array_length(list)]
    }
    
    static GetDisplay = function() {
        if refresh {
            refresh = false
            _RefreshActive()
        }
        return activeDisplay
    }
    
    static _RefreshActive = function() {
        active = []
        activeDisplay = []
        for (var i = 0; i<array_length(levelsList); i++) {
            var level = struct_get(levels, levelsList[i])
            if level.IsPopulated() {
                array_push(active, level)
                array_push(activeDisplay, level.Display())
            }
        }
    }
}


function LevelEntry(_uuid, _name, _username) {
    return new LevelEntryClass(_uuid, _name, _username)
}

function LevelEntryClass(_uuid, _name, _username) constructor {
    uuid = _uuid
    name = _name
    username = _username
    likes = 0
    plays = 0
    wins = 0
    uplays = 0
    level = ""
    
    static winPercent = function() {
        if uplays = 0 {
            return 0
        }
        return floor(100*wins/uplays)
    }
    
    static IsPopulated = function() {
        return level != ""
    }
    
    static Populate = function(s) {
        if struct_exists(s, "likes") { likes = _SafeReal(s.likes, likes) }
        if struct_exists(s, "plays") { plays = _SafeReal(s.plays, plays) }
        if struct_exists(s, "wins") { wins = _SafeReal(s.wins, wins) }
        if struct_exists(s, "uplays") { uplays = _SafeReal(s.uplays, uplays) }
        if struct_exists(s, "level") && !is_undefined(s.level) { level = s.level }
        if struct_exists(s, "username") && !is_undefined(s.username) { username = s.username }
        if struct_exists(s, "name") && !is_undefined(s.name) { name = s.name }
        
        return self
    }
    
    static Display = function() {
        return $"{name} by {username}\n{plays} {CH_SYMBOL_PLAY}   Win {winPercent()}%"
    }
    
    static _SafeReal = function(val, def) {
        try {
            return real(val)
        } catch(_e) {
            return def
        }
    }
}