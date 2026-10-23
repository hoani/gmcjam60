function PhyAssembly(_world) constructor {
    history = new History()
    world = _world
    factory = new MaterialFactory()
    
    base = []
    parts = []
    
    static Add = function(spec) {
        array_push(parts, spec.Encode())
        history.Add(Encode())
    }
    
    static Delete = function(spec) {
        var enc = spec.Encode()
        for (var i = 0; i < array_length(parts); i++) {
            if parts[i] == enc {
      			array_delete(parts, i, 1);
      			return
      		}
      	}
        history.Add(Encode())
    }

    static Encode = function() {
        var partsEnc = json_stringify(parts);
	
       	var _payload = {
       		parts: partsEnc,
       		hash: md5_string_utf8(partsEnc)
       	}
	   return base64_encode(json_stringify(_payload));
    }
    
    
    static Load = function (b64Enc) {
        var data = Decode(b64Enc)
        if !struct_exists(data, "parts") {
            return false
        }
        var _parts = json_parse(data.parts)
        for (var i = 0; i < array_length(_parts); i++) {
            factory.PlaceEncoded(_parts[i])
        }
        return _parts
    }
    
    
    static Decode = function(b64Enc) {
        try {
      		var _payload = json_parse(base64_decode(b64Enc))
      		if !struct_exists(_payload, "parts") || !struct_exists(_payload, "hash") {
                DebugError($"Missing parts or hash in payload {payload}", true)
      			return {}
      		}
      		var _hash = md5_string_utf8(_payload.parts)
      		if _hash != _payload.hash {
                DebugError($"Hash mismatch {payload}", true)
      			return {}
      		}
            return _payload
      	}
      	catch(_e) {
      		return {}
      	}
    }
    
    static Reset = function() {
        world.Reset()
        for (var i = 0; i < array_length(base); i++) {
            factory.PlaceEncoded(base[i])
        }
    }
    
    
    static CanUndo = function() {
        return history.CanUndo()
    }
    
    static CanRedo = function() {
        return history.CanRedo()
    }
    
    static Undo = function() {
        var encoded = history.Undo()
        Reset()
        if encoded == "" {
            return;
        }
        parts = Load(encoded)
    }
    
    static Redo = function() {
        var encoded = history.Redo()
        Reset()
        if encoded == "" {
            return;
        }
        parts = Load(encoded)
    }
}

