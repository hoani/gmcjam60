function NewConditions() {
    var _conditions = []
    for (var i = 0; i < argument_count; i++) {
        array_push(_conditions, argument[i]);
    }
    return new Conditions(_conditions);
}

function ConditionBase() constructor {
    static Check = function(ctx) {
        return true;
    }
}

function OnRandom(_fraction) {
    return new OnRandomCondition(_fraction);
}

function OnRandomCondition(_fraction=0.5) constructor {
    fraction = _fraction;
    static Check = function(ctx) {
        return random(1) <= fraction;
    }
}

function Conditions(_conditions) :  ConditionBase() constructor{
    conditions=_conditions;
    
    static Check = function(ctx) {
        for (var i = 0; i<array_length(conditions); i++) {
            var c = conditions[i];
            if is_string(c) {
                if !_CheckCondition(ctx, conditions[i]) {
                    return false;
                }
            } else if is_struct(c) {
                try {
                    if !c.Check(ctx) {
                        return false;
                    }
                } catch (expection) {
                    DebugError($"bad condition {expection.message}", true);
                    return false;
                }
            }
            
        }
        return true;
    }
    
    // Private
    static _CheckCondition = function(ctx, c) {
        var ev = ctx.Events()
        if string_starts_with(c, "flag.") {
            return _CheckFlag(ev, c);
        }
        if string_starts_with(c, "event.") {
            return _CheckEvent(ev, c);
        }
        if string_count("==", c) == 1 {
            return _CheckEquality(ctx, c);
        }
        if string_count("<", c) == 1 {
            return _CheckLessThan(ctx, c);
        }
        if string_count(">", c) == 1 {
            return _CheckGreaterThan(ctx, c);
        }
        
        DebugError($"unable to process condition syntax {c}", true);

        return false;
    }
    
    static _CheckFlag = function(events, c) {
        var name = string_trim_start(c, ["flag."]);
        return events.GetFlag(name) > 0;
    }
    
    static _CheckEvent = function(events, c) {
        var name = string_trim_start(c, ["event."]);
        return events.GetEvent(name) > 0;
    }
    
    static _CheckEquality = function(ctx, c) {
        var values = _GetValues(ctx, c, "==");
        
        if (is_undefined(values)) {
            return false;
        }
        
        return values.lhs == values.rhs;
    }
    
    static _CheckLessThan = function(ctx, c) {
        var values = _GetValues(ctx, c, "<");
        
        if (is_undefined(values)) {
            return false;
        }
        
        return values.lhs < values.rhs;
    }
    
    static _CheckGreaterThan = function(ctx, c) {
        var values = _GetValues(ctx, c, ">");
        
        if (is_undefined(values)) {
            return false;
        }
        
        return values.lhs > values.rhs;
    }
    
    static _GetValues = function(ctx, c, _sep) {
        var parts = string_split(c, _sep)
        if array_length(parts) != 2 {
            DebugError($"attempted to access unknown variable {c} in {ctx}", true);
            return undefined;
        }
        var lhs = _Lookup(ctx, string_trim(parts[0]));
        var rhs = real(string_trim(parts[1]));
        
        if (is_undefined(lhs)) {
            DebugError($"attempted to access unknown variable {c} in {ctx}", true);
            return undefined;
        }
        
        return {lhs: lhs, rhs: rhs}
    }
    
    static _Lookup = function(ctx, name) {
        var parts = string_split(name, ".");
        var s = ctx;
        for (var i = 0; i<array_length(parts); i++) {
            var part = parts[i]
            if is_struct(s) {
                if struct_exists(s, part) {
                    s = struct_get(s, part)
                } else {
                    return undefined;
                }
            } 
            else if is_array(s) {
                try {
                    var index = real(part);
                    if index == round(index) {
                        s = array_get(s, index);
                    }
                }
                catch (_exception) {
                    return undefined; 
                }
            } else {
                return undefined;
            }
            
        }
        if is_real(s) {
            return s;
        }
        return undefined;
    }
}


// Tests

function ConditionsTest(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    static test_subject="Event Conditions"
    
    static should_empty_conditions = function() {
        var c = NewConditions()
        var ctx = new TestEventsContext()
        assert_is_true(c.Check(ctx))
    }
    
    static should_flag_conditions = function() {
        var c = NewConditions("flag.testing")
        var ctx = new TestEventsContext()
        
        ctx.Events().RegisterFlag("testing")
        assert_is_false(c.Check(ctx))
        
        ctx.Events().FlagIncr("testing")
        assert_is_true(c.Check(ctx))
        
        ctx.Events().FlagDecr("testing")
        assert_is_false(c.Check(ctx))
    }
    
    static should_check_events = function() {
        var c = NewConditions("event.intro")
        var ctx = new TestEventsContext()
        
        ctx.Events().RegisterEvent("intro")
        assert_is_false(c.Check(ctx))
        
        ctx.Events().EventIncr("intro")
        assert_is_true(c.Check(ctx))
    }
    
    static should_check_number_equality = function() {
        var c = NewConditions("game.day==2")
        var ctx = new TestEventsContext()
        
        assert_is_false(c.Check(ctx))
        
        ctx.game.day = 2;
        assert_is_true(c.Check(ctx))
        
        ctx.game.day = 3;
        assert_is_false(c.Check(ctx))
    }
    
    static should_check_number_Inequality = function() {
        var c = NewConditions("game.day > 1", "game.day < 4")
        var ctx = new TestEventsContext()
        
        assert_is_false(c.Check(ctx))
        
        ctx.game.day = 2;
        assert_is_true(c.Check(ctx))
        
        ctx.game.day = 3;
        assert_is_true(c.Check(ctx))
        
        ctx.game.day = 4;
        assert_is_false(c.Check(ctx))
    }
    
    static should_check_nested_number_equality = function() {
        var c = NewConditions("game.upgrades.mine.level == 1")
        var ctx = new TestEventsContext()
        
        assert_is_false(c.Check(ctx))
        
        ctx.game.upgrades.mine.level = 1;
        assert_is_true(c.Check(ctx))
    }
    
    static should_check_number_array = function() {
        var c = NewConditions("game.quest.wins.0 == 2")
        var ctx = new TestEventsContext()
        
        assert_is_false(c.Check(ctx))
        
        ctx.game.quest.wins[0] = 2;
        assert_is_true(c.Check(ctx))
        
        ctx.game.quest.wins[0] = 4;
        assert_is_false(c.Check(ctx))
    }

}