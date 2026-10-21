

function InteractionHandler(_ctx, _def, _callback) constructor {
    ctx = _ctx
    def = _def
    callback = _callback
    
    OnNext = function(which) {
        if is_string(which) {
            var seq = struct_get(def.sequences, which);
            var sequencer = new SequenceHandler(ctx, seq, OnNext);
        } else {
            callback(which)
        }
    }
    
    OnNext(def.entry)
}


function ScriptInteraction(iid, script) {
    return {
        id: iid,
        entry: "start",
        sequences: {
            start: {
                script: script, 
                next: 0,
            },
        },
    }; 
}


function SpeechInteraction(iid, who, text) {
    return ScriptInteraction(iid, [Speech(who, text)])
}


function NarrateInteraction(iid, text) {
    return ScriptInteraction(iid, [Narrate(text)])
}




function InteractionHandlerTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    static test_subject="InteractionHandler Tests"
    
    
    
    static should_handle_linear = function() {
        
        var ctx = {hello: "world"}
        var def = {
            id: "linear",
            entry: "start",
            sequences: {
                start: {
                    script: [
                        NewTestAction(),
                    ],
                    next: "finish",
                },
                finish: {
                    script: [
                        NewTestAction(),
                    ],
                    next: 0,
                },
            },
        }
        var data = {
            result: undefined,
            callback: function(val) {result = val},
        };
        
        
        assert_is_zero(struct_names_count(def.sequences.start.script[0].ctx))
        assert_is_zero(struct_names_count(def.sequences.finish.script[0].ctx))
        
        var s = new InteractionHandler(ctx, def, data.callback)
        assert_is_undefined(data.result);
        assert_equal("world", def.sequences.start.script[0].ctx.hello)
        
        def.sequences.start.script[0].Trigger();
        assert_equal("world", def.sequences.finish.script[0].ctx.hello)
        
        def.sequences.finish.script[0].Trigger();
        assert_equal(0, data.result);
    }
    
    static should_handle_branching = function() {
        
        var ctx = {hello: "world"}
        var newDef = function() {
            return {
                id: "linear",
                entry: "start",
                sequences: {
                    alive: {
                        script: [
                            NewTestAction(),
                        ],
                        next: 0,
                    },
                    dead: {
                        script: [
                            NewTestAction(),
                        ],
                        option: NewTestChoice(["revive", "die"]),
                        next: ["alive", 1],
                    },
                    start: {
                        script: [
                            NewTestAction(),
                        ],
                        option: NewTestChoice(["left", "right"]),
                        next: ["alive", "dead"],
                    },
                },
            }
        }
        
        // Subcase: live!
        {
            var def = newDef();
            var data = {
                result: undefined,
                callback: function(val) {result = val},
            };
            
            
            var s = new InteractionHandler(ctx, def, data.callback)
            assert_is_undefined(data.result);
            assert_equal("world", def.sequences.start.script[0].ctx.hello)
            
            def.sequences.start.script[0].Trigger();
            def.sequences.start.option.Trigger(0);
            def.sequences.alive.script[0].Trigger(0);

            assert_equal(0, data.result);
        }
        
        // Subcase: die!
        {
            var def = newDef();
            var data = {
                result: undefined,
                callback: function(val) {result = val},
            };
            
            
            var s = new InteractionHandler(ctx, def, data.callback)
            assert_is_undefined(data.result);
            assert_equal("world", def.sequences.start.script[0].ctx.hello)
            
            def.sequences.start.script[0].Trigger();
            def.sequences.start.option.Trigger(1);
            def.sequences.dead.script[0].Trigger();
            def.sequences.dead.option.Trigger(1);

            assert_equal(1, data.result);
        }

        // Subcase: revive!
        {
            var def = newDef();
            var data = {
                result: undefined,
                callback: function(val) {result = val},
            };
            
            
            var s = new InteractionHandler(ctx, def, data.callback)
            assert_is_undefined(data.result);
            assert_equal("world", def.sequences.start.script[0].ctx.hello)
            
            def.sequences.start.script[0].Trigger();
            def.sequences.start.option.Trigger(1);
            def.sequences.dead.script[0].Trigger();
            def.sequences.dead.option.Trigger(0);
            def.sequences.alive.script[0].Trigger(0);

            assert_equal(0, data.result);
        }
    }
}
