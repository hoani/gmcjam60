


function SequenceHandler(_ctx, _def, _callback) constructor {
    ctx = _ctx
    index = 0;
    def = _def 
    callback = _callback
    
    OnNext = function() {
        if index < array_length(def.script) {
            if (index + 1 == array_length(def.script) && struct_exists(def, "option") && struct_get(def, "option").holdLast) {
                def.script[index].SetLast();
            }
            // We increment the index prior to calling Spawn, because it may call OnNext immediately.
            var script = def.script[index];
            index++;
            script.Spawn(ctx, OnNext);
            return;
        }
        
        if struct_exists(def, "option") {
            var opt = def.option;
            opt.Spawn(ctx, OnChoice);
            return;
        }
        
        if array_length(def.script) > 0 {
            def.script[array_length(def.script)-1].Done();
        }
        
        callback(def.next);
    }
    
    OnChoice = function(val) {
        if array_length(def.script) > 0 {
            def.script[array_length(def.script)-1].Done();
        }
        
        if is_array(def.next) {
            callback(def.next[val])
            return;
        }
        
        callback(def.next)
    }
    
    OnNext()
}


function SequenceHandlerTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    static test_subject="Sequencer Tests"
    
    
    static should_handle_no_options = function() {
        
        var ctx = {hello: "world"}
        var def = {
              script: [
                NewTestAction(),
                NewTestAction(),
            ],
            next: "lost",
        };
        var data = {
            result: undefined,
            callback: function(val) {result = val},
        };
        
        
        assert_is_zero(struct_names_count(def.script[0].ctx))
        assert_is_zero(struct_names_count(def.script[1].ctx))
        
        var s = new SequenceHandler(ctx, def, data.callback)
        assert_is_undefined(data.result);
        
        assert_equal("world", def.script[0].ctx.hello)
        
        def.script[0].Trigger();
        assert_equal("world", def.script[1].ctx.hello)
        
        assert_equal(false, def.script[0].isLast)
        assert_equal(false, def.script[1].isLast)
        
        def.script[1].Trigger();
        assert_equal("lost", data.result);
    }

    
    static should_handle_options = function() {
        
        var ctx = {hello: "world"}
        var def = {
            script: [
                NewTestAction(),
                NewTestAction(),
            ],
            option: NewTestChoice([
                "I'm lost.",
                "I came looking for you.",
            ]),
            next: ["lost", "seeking"],
        };
        var data = {
            result: undefined,
            callback: function(val) {result = val},
        };
        
        def.option.holdLast = true;
        
        assert_is_zero(struct_names_count(def.script[0].ctx))
        assert_is_zero(struct_names_count(def.script[1].ctx))
        assert_is_zero(struct_names_count(def.option.ctx))
        
        var s = new SequenceHandler(ctx, def, data.callback)
        assert_is_undefined(data.result);
        
        assert_equal("world", def.script[0].ctx.hello)
        
        def.script[0].Trigger();
        assert_equal("world", def.script[1].ctx.hello)
        
        assert_equal(false, def.script[0].isLast)
        assert_equal(true, def.script[1].isLast)
        
        def.script[1].Trigger();
        assert_equal("world", def.option.ctx.hello)
        
        assert_is_undefined(data.result);
        def.option.Trigger(1);
        assert_equal("seeking", data.result);
    }
}







