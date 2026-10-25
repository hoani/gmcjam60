function PhyAssembly(_world) constructor {
    history = new History()
    world = _world
    factory = new MaterialFactory()
    
    base = []
    parts = []
    
    
    static ConcatAssembly = function() {
        return array_concat(base, parts)
    }
    
    static SetBase = function(_base=[]) {
        base = _base
        parts = []
        history = new History()
    }
    
    static Add = function(spec) {
        array_push(parts, spec.Encode())
        history.Add(Encode())
    }
    
    static Delete = function(spec) {
        var enc = spec.Encode()
        for (var i = 0; i < array_length(parts); i++) {
            if json_stringify(parts[i]) == json_stringify(enc) {
      			array_delete(parts, i, 1);
      			break
      		}
      	}
        history.Add(Encode())
    }
    
    
    
    static EncodeFull = function() {
        var full = array_concat(base, parts)
        var partsEnc = json_stringify(full);
	
       	var _payload = {
       		parts: partsEnc,
       		hash: md5_string_utf8(partsEnc)
       	}
	   return base64_encode(json_stringify(_payload));
    }

    static Encode = function() {
        var partsEnc = json_stringify(parts);
	
       	var _payload = {
       		parts: partsEnc,
       		hash: md5_string_utf8(partsEnc)
       	}
	   return base64_encode(json_stringify(_payload));
    }
    
    
    static Load = function (b64Enc, deletable=true) {
        var data = Decode(b64Enc)
        if !struct_exists(data, "parts") {
            return false
        }
        var _parts = json_parse(data.parts)
        for (var i = 0; i < array_length(_parts); i++) {
            var inst = factory.PlaceEncoded(_parts[i])
            if deletable {
                inst.body.SetDeletable()
            }
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
    
    static LoadBase = function(encoded) {
        base = []
        parts = []
        Reset()
        if encoded == "" {
            return;
        }
        base = Load(encoded, false)
    }
    
    static CanUndo = function() {
        return history.CanUndo()
    }
    
    static CanRedo = function() {
        return history.CanRedo()
    }
    
    
    static GetCurrent = function() {
        var encoded = history.current
        if encoded == -1 {
            return ""
        }
        return encoded
    }
    
    
    static Rebuild = function(encoded="") {
        if encoded == "" {
            encoded = GetCurrent()
        }
        Reset()
        if encoded == "" {
            return;
        }
        parts = Load(encoded, true)
    }
    
    static Undo = function() {
        var encoded = GetCurrent()
        Reset()
        if encoded == "" {
            return;
        }
        parts = Load(encoded, true)
    }
    
    static Redo = function() {
        var encoded = GetCurrent()
        Reset()
        if encoded == "" {
            return;
        }
        parts = Load(encoded, true)
    }
}

