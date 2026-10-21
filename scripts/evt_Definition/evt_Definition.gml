
function EventDefinition(_name, _condition, _interaction, _allowMultiple) constructor {
    name = _name;
    condition = _condition;
    interaction = _interaction;
    ctx = noone;
    callback = new Callback();
    allowMultiple = _allowMultiple;
    
    static Name = function() {
        return name;
    }
    
    static Ready = function(ctx) {
        var eventCountCheck = allowMultiple || ctx.Events().GetEvent(name) == 0
        return eventCountCheck && condition.Check(ctx);
    }
    
    static Spawn = function(_ctx, _callback) {
        ctx = _ctx;
        callback.Set(_callback)
        new InteractionHandler(_ctx, interaction, _OnDone);
    }
    
    _OnDone = function() {
        ctx.Events().EventIncr(name);
        callback.Call();
    }
}