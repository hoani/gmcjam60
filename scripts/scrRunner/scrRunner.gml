function RunItem() constructor {
    static IsDone = function() { return true; };   
    static Step = function() {};    
    static Draw = function() {};
}



function Runner() constructor {
    items = [];
    
    static Pop = function() {
        var item = array_get(items, 0)
        array_delete(items, 0, 1);
        return item;
    }
    
    static Push = function(item) {
        array_push(items, item);
    }
    
    static ClearDone = function() {
        var keepGoing = false;
        for (var i = 0; i < array_length(items); i++) {
            var item = items[i];
            if item.IsDone() {
                keepGoing = true;
                array_delete(items, i, 1);
                break;
            }
        }
        if keepGoing {
            ClearDone(); // See if there's more to clear.
        }
    }
    
    static Step = function() {
        ClearDone();
        array_foreach(items, function(item) {
            item.Step();
        })
    }
    
    static Draw = function() {
        array_foreach(items, function(item) {
            item.Draw();
        })
    }
}



function RunnerTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    static test_subject="Runner Tests"
    
    static NewTestRunItem = function(target) {
        return {
            steps: 0,
            draws: 0,
            target: target,
            IsDone: function() { return steps >= target },
            Step: function() { steps++; },
            Draw: function() { draws++; },
            
        };
    }
    
    static should_run_item = function() {
        var runner = new Runner();
        var a = NewTestRunItem(1);
        
        runner.Push(a);
        assert_is_false(a.IsDone());
        assert_equal(a.steps, 0);
        runner.Step();
        assert_is_true(a.IsDone());
        assert_equal(a.steps, 1);
        runner.Step();
        assert_equal(a.steps, 1);
    }

    static should_run_multiple = function() {
        var runner = new Runner();
        var a = NewTestRunItem(1);
        var b = NewTestRunItem(5);
        
        runner.Push(a);
        runner.Push(b);

        runner.Step();
        runner.Step();
        runner.Step();
        runner.Step();
        assert_is_true(a.IsDone());
        assert_equal(a.steps, 1);
        assert_equal(b.steps, 4);
    }
}