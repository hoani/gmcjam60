function EventsDispatch(_definitions) constructor {
    
    engine = new EventsEngine(_definitions);
    callback = {
        ctx: undefined,
        callback: undefined,
        Call: function() {
            ctx.Events().ClearAllFlags();
            callback();
        },
    }
    
    static Spawn = function(_ctx, _callback) {
        callback.ctx = _ctx;
        callback.callback = _callback;
        engine.Spawn(_ctx, callback.Call)
    }
}

function EventsEngine(_definitions, _multievent=true) constructor {
    events = _definitions;
    ctx = noone;
    callback = noone;
    multievent = _multievent
    
    static Spawn = function(_ctx, _callback) {
        ctx = _ctx;
        callback = _callback;
        _RunEvents();
    }
    
    _RunEvents = function() {    
        for (var i = 0; i<array_length(events); i++) {
            var eventDef = events[i];
            if eventDef.Ready(ctx) {
                var cb = multievent ? _RunEvents : callback;
                eventDef.Spawn(ctx, cb)
                return;
            }
        }
        callback();
    }
}


function NewEvent(_name, _condition, _interaction, _allowMultiple=false) {

    if _name != _interaction.id {
        show_error($"Misnamed event {_name} != {_interaction.id}", true)
    }
    
    return new EventDefinition(_name, _condition, _interaction, _allowMultiple)
}



function EventsDispatchTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    static test_subject="Dispatch Events"
    
    static should_trigger_events = function() {
        
        var ctx = new TestEventsContext()
        ctx.Events().RegisterEvent(["intro", "ending"]);
        ctx.Events().RegisterFlag(["gameover"]);
        
        var definitions = [
            NewEvent("intro", NewConditions("game.day==0"), {
                    id: "intro",
                    entry: "start",
                    sequences: {
                        start: { script: [ NewTestAction(true) ], next: 0 },
                    },
                }
            ),
            NewEvent("ending", NewConditions("game.day>7", "flag.gameover"), {
                    id: "ending",
                    entry: "start",
                    sequences: {
                        start: { script: [ NewTestAction(true) ], next: 0 },
                    },
                }
            ),
        ]
        
        var e = new EventsDispatch(definitions)
        
        var data = {
            result: false,
            callback: function() {result = true},
        };
        
        
        e.Spawn(ctx, data.callback);
        assert_is_true(data.result);
        
        // Check the intro was run.
        assert_equal(ctx.Events().GetEvent("intro"), 1)
        
        ctx.game.day++;
        e.Spawn(ctx, data.callback);
        // Check nothing new was run
        assert_equal(ctx.Events().GetEvent("intro"), 1)
        assert_equal(ctx.Events().GetEvent("ending"), 0)
        
        ctx.game.day = 8
        e.Spawn(ctx, data.callback);
        
        // Check nothing new was run
        assert_equal(ctx.Events().GetEvent("intro"), 1)
        assert_equal(ctx.Events().GetEvent("ending"), 0)
        
        ctx.Events().FlagIncr("gameover");
        
        e.Spawn(ctx, data.callback);
        
        // Check ending is run
        assert_equal(ctx.Events().GetEvent("intro"), 1)
        assert_equal(ctx.Events().GetEvent("ending"), 1)
    }
    
    static should_trigger_events_sequentially = function() {
        
        var ctx = new TestEventsContext()
        ctx.Events().RegisterEvent(["hello", "world"]);
        
        var actionA = NewTestAction()
        var actionB = NewTestAction()
        
        var definitions = [
            NewEvent("hello", NewConditions(), {
                    id: "hello",
                    entry: "start",
                    sequences: {
                        start: { script: [ actionA ], next: 0 },
                    },
                }
            ),
            NewEvent("world", NewConditions(), {
                    id: "world",
                    entry: "start",
                    sequences: {
                        start: { script: [ actionB ], next: 0 },
                    },
                }
            ),
        ]
        
        var e = new EventsDispatch(definitions)
        
        var data = {
            result: false,
            callback: function() {result = true},
        };
        
        
        e.Spawn(ctx, data.callback);
        assert_is_false(data.result);
        
        actionB.Trigger();
        assert_equal(ctx.Events().GetEvent("world"), 0)
        assert_equal(ctx.Events().GetEvent("hello"), 0)
        actionA.Trigger();
        // Demonstrates that A is actually first
        assert_is_false(data.result);
        assert_equal(ctx.Events().GetEvent("hello"), 1)
        assert_equal(ctx.Events().GetEvent("world"), 0)
        actionB.Trigger();
        assert_equal(ctx.Events().GetEvent("world"), 1)
        
        assert_is_true(data.result); // Now both a and b have run.
        
        
        
    }
}