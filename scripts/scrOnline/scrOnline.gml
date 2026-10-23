function ScoreBoat() {
    if !variable_global_exists("scoreboatHandler") {
        global.scoreboatHandler = new _ScoreBoatHandler();
    }
    return global.scoreboatHandler
}


function _ScoreBoatHandler() constructor {
    
    static levelsBucket = "4qQN3zUSLP"
    static userId = ""
    static isReady = false
    
    static Login = function(_success = FuncNone, _fail = FuncNone) {
        if sb_ready() {
            return;
        }
        return sb_init("8xvgXd2", "uejwbGmvN2VX8IhG", "NKkGVKBpyc38c83HMhqxs_FaEZ5QwtVU8BdmhNb7rUI")
            .success(function(_info) {
                DebugMessage($"Scoreboat is ready");
                sb_player_guest().success(function(p){
                    userId = p.id
                    DebugMessage($"Signed in as {userId}");
                    sb_folder_create(levelsBucket, $"/{userId}").success(function(_){
                        DebugMessage($"Levels bucket created");
                        isReady = true
                    }).fail(function(error){
                        if error.http_status == 409 {
                            isReady = true // Already exists
                            DebugMessage($"Levels bucket ready");
                        }
                    })
                })
            })
            .success(_success)
            .fail(function(_error) {
                DebugMessage("Scoreboat failed: " + _error.message);
            })
            .fail(_fail);
    }



    static Ready = function() {
        return isReady
    }
    
    static BrowseLevels = function(offset=0, limit=20, _success = FuncNone, _fail = FuncNone) {
        return sb_file_list(levelsBucket, "/", {offset: offset, limit: limit}, _success, _fail)
    }
    
    static UploadLevel = function(buffer, _success = FuncNone, _fail = FuncNone) {
        var path = $"/{userId}/level"
        DebugMessage($"Uploading {string_length(buffer)} bytes to {path}")
        return sb_file_upload_string(levelsBucket, path, buffer, {}, _success, _fail)
    }

    
    static DownloadLevel = function(_success = FuncNone, _fail = FuncNone) {
        var path = $"/{userId}/level"
        return sb_file_download_string(levelsBucket, path, _success, _fail)
    }
}