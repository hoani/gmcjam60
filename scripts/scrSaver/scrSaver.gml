function Saver(_secretKey) constructor{
    skey = _secretKey
    
    static Save = function(data) {
        var hash = sha1_string_utf8($"{data}{skey}");

        var buf = buffer_create(0, buffer_grow, 1);
        buffer_write(buf, buffer_string, data);
        buffer_write(buf, buffer_string, hash);
        
        buffer_seek(buf, buffer_seek_start, 0);
        
        return buf;
    }
    
    static Load = function(buf) {
        buffer_seek(buf, buffer_seek_start, 0);
        
        var data = buffer_read(buf, buffer_string);
        var hash = buffer_read(buf, buffer_string);
        
        var bhash = sha1_string_utf8($"{data}{skey}");
        
        if (hash != bhash) {
        	return ""; // New Game :/
        }
        
        return data;
    }
}


function SaverTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    static test_subject="Saver Tests"
    
    
    static should_save_and_load = function() {
        var data = "Hello World";
        var s = new Saver("my_secret_key");
        var b = s.Save(data);
        var loaded = s.Load(b);
        
        
        assert_equal(data, loaded);
        
        var s2 = new Saver("my_other_key");
        var b2 = s2.Save(data);
        var loaded2 = s2.Load(b2);
        
        assert_equal(data, loaded2);
        
        var loadedWrongKey = s2.Load(b);
        assert_equal("", loadedWrongKey);
        
        buffer_delete(b2);
        buffer_delete(b);
    }
}