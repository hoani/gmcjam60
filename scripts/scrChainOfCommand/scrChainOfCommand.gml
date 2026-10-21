/// Chain of command handler - goes down a chain to see if anything will handle a particular execution
/// useful for layering behaviors
/// @arg {function} _base - the base handler
function ChainOfCommand(_base=DoNothing) constructor{
    chain = []
    base = _base
    
    /// Add a handler to the chain. The chain is resolved in reverse order, so this handler has priority over all previously added handlers.
    /// @arg {function} next - the next handler on the chain - must return a function(ctx) if resolved, otherwise returns undefined
    static With = function(next) {
        var reversed = array_reverse(chain)
        array_push(reversed, next)
        chain = array_reverse(reversed)
        return self
    }
    
    /// Execute with a given context.
    ///@arg {struct} ctx - contextual information to pass to the link
    static Execute = function(ctx) {
        for (var i = 0; i<array_length(chain); i++) {
            var run = chain[i](ctx)
            // If the item returned a callable, execute it, otherwise keep trying.
            if !is_undefined(run) {
                return run(ctx)
            }
        }
        return base(ctx)
    }
}

function NewChainOfCommand(base) {
    return new ChainOfCommand(base)
}


function ChainOfCommandTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    
    static test_subject="ChainOfCommand Tests"
    
    static should_call_base_on_single_link_chain = function() {
        base = function(ctx) {
            return ctx*2
        }
        c = NewChainOfCommand(base)
        
        assert_equal(c.Execute(2), 4);
    }
    
    static should_call_down_the_chain = function() {
        base = function(ctx) {
            return ctx*2
        }
        handle_negatives = function(ctx) {
            if ctx < 0 {
                return function(ctx) {
                    return -ctx
                }
            }
            return undefined
        }
        handle_odds = function(ctx) {
            if abs(ctx) % 2 == 1 {
                return function(ctx) {
                    return ctx*10
                }
            }
            return undefined
        }
        c = NewChainOfCommand(base).With(handle_negatives).With(handle_odds)
        
        assert_equal(c.Execute(-3), -30); // Handled by handle_odds who has first priority
        assert_equal(c.Execute(-2), 2); // Hanlded by handle_negatives, who has second priority
        assert_equal(c.Execute(2), 4); // All the way down the chain
    }
}