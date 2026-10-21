
/// Lint a designated interaction
/// @arg _interaction - the interaction
function InteractionLinter(_interaction) constructor{
    interaction = _interaction
    reason = ""
    
    static Error = function(msg) {
        var name = "<unknown>"
        if struct_exists(interaction, "id") {
            name = interaction.id
        }
        reason = $"[{name}]: {msg}"
    }
    
    // Get all reachable nodes from the entry point
    static FindReachable = function() {
       var visited = [];
       var stack = [interaction.entry];
       
       while array_length(stack) > 0 {
           var current = stack[array_length(stack) - 1];
           array_delete(stack, array_length(stack) - 1, 1);
           
           if array_contains(visited, current) {
               continue;
           }
           array_push(visited, current);
           
           var sequence = struct_get(interaction.sequences, current);
           var next = sequence.next;
           
           if is_array(next) {
               for (var i = 0; i < array_length(next); i++) {
                   if is_string(next[i]) && !array_contains(visited, next[i]) {
                       array_push(stack, next[i]);
                   }
               }
           } else if is_string(next) && !array_contains(visited, next) {
               array_push(stack, next);
           }
       }
       
       return visited;
   }
    
    static ValidateKeys = function() {
        if !is_struct(interaction) {
            Error($"interaction not struct: {interaction}")
            return false;
        }
        var keys = ["id", "entry", "sequences"];
        for (var i = 0; i<array_length(keys); i++) {
            if !struct_exists(interaction, keys[i]) {
                Error($"missing '{keys[i]}'")
                return false;
            }
        }
        return true;
    }
    
    static ValidateEntry = function() {
        var entry = interaction.entry;
        var sequences = interaction.sequences;
        if !struct_exists(sequences, entry) {
            Error($"entry point '{entry}' doesn't exist'")
            return false;
        }
        return true;
    }
    
    static ValidateNextReference = function(name, which) {
        var sequences = interaction.sequences;
        if !struct_exists(sequences, which) {
            Error($"sequence {name}'s exit '{which}' doesn't exist'")
            return false;
        }
        return true;
    }
    
    static ValidateNext = function() {
        var sequences = interaction.sequences;
        var exits = [];
        var keys = struct_get_names(sequences);
        
        for (var i = 0; i<array_length(keys); i++) {
            var key = keys[i];
            var sequence = struct_get(sequences, key);
            if !struct_exists(sequence, "next") {
                Error($"sequence {key} missing next")
                return false;
            }
            
            var next = sequence.next;
            if is_array(next) {
                if !struct_exists(sequence, "option") {
                    Error($"sequence {key} has array next, but is missing an option field")
                    return false;
                }
                if sequence.option.outcomes != array_length(next) {
                    Error($"sequence {key} next length {array_length(next)} != {sequence.option.outcomes} option outcomes")
                    return false;
                }
                for (var j = 0; j<array_length(next); j++) {
                    if is_numeric(next[j]) {
                       array_push(exits, next[j]) 
                    }
                    else if is_string(next[j]) {
                        if !ValidateNextReference(key, next[j]) {
                            return false;
                        }
                        
                    } else {
                        Error($"sequence {key} has an invalid exit type {next[j]}")
                        return false;
                    }
                }
            } else {
                if is_numeric(next) {
                    array_push(exits, next) 
                }
                else if is_string(next) {
                    if !ValidateNextReference(key, next) {
                        return false;
                    }
                }
                else {
                    Error($"sequence {key} has an invalid exit type {next}")
                    return false;
                }
            }
        }
        
        // deduplicate exits before contiguity check
        var unique_exits = [];
        for (var i = 0; i < array_length(exits); i++) {
            if !array_contains(unique_exits, exits[i]) {
                array_push(unique_exits, exits[i]);
            }
        }
        array_sort(unique_exits, function(a, b) { return a - b; });
        
        for (var i = 0; i < array_length(unique_exits); i++) {
            if unique_exits[i] != i {
                Error($"exit {i} is missing")
                return false;
            }
        }
        
        var reachable = FindReachable();
        for (var i = 0; i < array_length(keys); i++) {
            if !array_contains(reachable, keys[i]) {
                Error($"sequence '{keys[i]}' is unreachable from entry")
                return false;
            }
        }

        return true;
    }
    
    /// Validate the sequence
    static Validate = function() {
        
        return ValidateKeys() && ValidateEntry() && ValidateNext();
    }
}

function InteractionLinterTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    
    
    taSpeech = function(who, msg) {
        return NewTestAction()
    }
    
    taChoice = function(choices) {
        return NewTestChoice(choices)
    }
    
    
    static test_subject="Linter Tests"
    
    static should_invalidate_empty = function() {
        var linter = new InteractionLinter({})
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_missing_id = function() {
        var linter = new InteractionLinter({
            entry: "greet",
            sequences: {
                greet: {
                    script: [
                        NewTestAction(), 
                    ],
                    next: 0,
                },
            },
        });
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_missing_entry = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            sequences: {
                greet: { script: [ NewTestAction() ], next: 0 },
            },
        });
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_missing_sequences = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "greet",
        });
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_unknown_entry = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "unknown",
            sequences: {
                greet: { script: [ NewTestAction() ], next: 0 },
            }
        });
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_multi_next_no_option = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "greet",
            sequences: {
                greet: { script: [ NewTestAction() ], next: [0, 1] },
            }
        });
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_incorrect_option_count = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "greet",
            sequences: {
                greet: { script: [ NewTestAction() ], option: taChoice(["Foo", "Bar"]), next: [0, 1, 2] },
            }
        });
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_missing_exits = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "greet",
            sequences: {
                greet: { script: [ NewTestAction() ], option: taChoice(["Foo", "Bar"]), next: [0, 2] },
            }
        });
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_missing_exits_single = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "greet",
            sequences: {
                greet: { script: [ NewTestAction() ], next: 2 },
            }
        })
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_unknown_next = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "greet",
            sequences: {
                greet: { script: [ NewTestAction() ], option: taChoice(["Foo", "Bar"]), next: [0, "unknown"] },
            }
        });
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_unknown_next_single = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "greet",
            sequences: {
                greet: { script: [ NewTestAction() ], next: "unknown" },
            }
        })
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_badtype_next = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "greet",
            sequences: {
                greet: { script: [ NewTestAction() ], option: taChoice(["Foo", "Bar"]), next: [0, {}] },
            }
        });
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_badtype_next_single = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "greet",
            sequences: {
                greet: { script: [ NewTestAction() ], next: {} },
            }
        })
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_unused_sequence = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "greet",
            sequences: {
                greet: { script: [ NewTestAction() ], next: 0 },
                unused: { script: [ NewTestAction() ], next: 0 },
            }
        })
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    
    static should_validate_simple = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "greet",
            sequences: {
                greet: { script: [ NewTestAction() ], next: 0 },
            }
        })
        assert_is_true(linter.Validate())
    }
    
    static should_validate_graph = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "greet",
            sequences: {
                greet: { script: [ taSpeech("Foo", "Will you proceed") ], option: taChoice(["Ye", "No"]), next: ["convince", "next"] },
                convince: { script: [ taSpeech("Foo", "Come on...") ], option: taChoice(["Reconsider", "No"]), next: ["greet", 0] },                                
                next: { script: [ taSpeech("Player", "I proceeded") ], next: 0 },
            }
        })
        assert_is_true(linter.Validate(), linter.reason)
    }
    
     static should_validate_minimum = function() {
        var linter = new InteractionLinter({
            id: "minimum",
            entry: "enter",
            sequences: {
                enter: { next: 0 },
            }
        });
        assert_is_true(linter.Validate())
    }
    
    static should_validate_merged_sequences = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "greet",
            sequences: {
                greet: { script: [ taSpeech("Foo", "Which way?") ], option: taChoice(["Left", "Right"]), next: ["left", "right"] },
                left:  { script: [ taSpeech("Foo", "Went left") ],  next: "end" },
                right: { script: [ taSpeech("Foo", "Went right") ], next: "end" },
                "end":   { script: [ taSpeech("Foo", "We meet again") ], next: 0 },
            }
        })
        assert_is_true(linter.Validate())
    }
    
    static should_invalidate_unused_with_merge = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "greet",
            sequences: {
                "greet":  { script: [ taSpeech("Foo", "Which way?") ], option: taChoice(["Left", "Right"]), next: ["left", "right"] },
                "left":   { script: [ taSpeech("Foo", "Went left") ],  next: "end" },
                "right":  { script: [ taSpeech("Foo", "Went right") ], next: "end" },
                "end":    { script: [ taSpeech("Foo", "We meet again") ], next: 0 },
                "orphan": { script: [ taSpeech("Foo", "Nobody reaches me") ], next: "end" },
            }
        })
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_orphaned_cycle = function() {
        var linter = new InteractionLinter({
            id: "hello_world",
            entry: "greet",
            sequences: {
                "greet":   { script: [ taSpeech("Foo", "Hello") ], next: 0 },
                "cycle_a": { script: [ taSpeech("Foo", "A") ], next: "cycle_b" },
                "cycle_b": { script: [ taSpeech("Foo", "B") ], next: "cycle_a" },
            }
        })
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
}