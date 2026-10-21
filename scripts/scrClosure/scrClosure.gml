function Closure(_callback) constructor {
    callback = _callback;
    args = array_create(argument_count - 1);
    for (var i = 1; i < argument_count; i++) {
        args[i - 1] = argument[i];
    }

    static Call = function() {
        return method_call(callback, args);
    }
}


function ClosureTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    
    static test_subject="Closure Tests"
    
    static should_execute = function() {
        
        var data = {
            val: 0,
            add: function(incr=1) {
                self.val+=incr;
            },
        }
        
        incrOne = new Closure(data.add)        
        incrTwo = new Closure(data.add, 2)
        
        incrOne.Call();
        assert_equal(1, data.val);
        
        incrTwo.Call();
        assert_equal(3, data.val);
        
        incrOne.Call();
        assert_equal(4, data.val);
    }
}