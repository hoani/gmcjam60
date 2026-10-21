function NewTestAction(autotrigger=false) {
    return {
        ctx: {},
        isLast: false,
        autotrigger: autotrigger,
        callback: new Callback(),
        Done : function(){},
        SetLast: function() {
            isLast = true;
        },
        Trigger: function() {
            callback.Call();
        },
        Spawn: function(_ctx, _callback) {
            ctx = _ctx
            callback.Set(_callback);
            if autotrigger {
                callback.Call()
            }
        }
    };
}
    
function NewTestChoice(_choices) {
    return {
        outcomes: array_length(_choices),
        choices: _choices,
        holdLast: false,
        ctx: {},
        callback: new Callback(),
        Trigger: function(val) {
            callback.Call(val);
        },
        Spawn: function(_ctx, _callback) {
            ctx = _ctx
            callback.Set(_callback);
        }
    };
}




function InteractionEngineTestCases() {
    return [
        InteractionHandlerTests,
        SequenceHandlerTests,
        InteractionLinterTests,
        SequenceLinterTests,
    ]
}