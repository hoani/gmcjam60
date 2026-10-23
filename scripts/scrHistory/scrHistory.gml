function History() constructor {
    previous = []
    current = -1
    next = []
    
    static Add = function(assembly) {
        if current != -1 {
      		array_push(previous, current)
      		next = [] // No more redo
      	}
      	current = assembly
    }
    
    static CanUndo = function() {
        return current != -1
    }
    
    static CanRedo = function() {
        return array_length(next) > 0
    }
    
    static Undo = function() {
        if !CanUndo() {
            return ""
        }
        
        array_push(next, current);
        if array_length(previous) == 0 {
            current = -1
            return ""
        } 
        current = array_pop(previous);
        return current
    }
    
    static Redo = function() {
        if !CanRedo() {
            if current == -1 {
                return ""
            }
            return current
        }
        
        array_push(previous, current);
		current = array_pop(next);
        return current
    }
}


function HistoryTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    
    static test_subject="History Tests"

    
    static should_handle_history = function() {
        h = new History()
        assert_is_false(h.CanUndo());
        assert_is_false(h.CanRedo());
        assert_equal("", h.Undo());
        assert_equal("", h.Redo());
        
        h.Add("A")
        assert_is_false(h.CanRedo());
        assert_is_true(h.CanUndo());
        assert_equal("", h.Undo());
        assert_is_true(h.CanRedo());
        assert_equal("A", h.Redo());
        
        h.Add("B")
        h.Add("C")
        h.Add("D")
        
        assert_equal("C", h.Undo());
        assert_equal("B", h.Undo());
        assert_equal("A", h.Undo());
        assert_equal("B", h.Redo());
        assert_equal("C", h.Redo());
        assert_equal("D", h.Redo());
        assert_equal("D", h.Redo());
    }
}

