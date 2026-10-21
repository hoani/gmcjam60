
/// Lint a designated sequence
/// @arg _sequence - the sequence
function SequenceLinter(_sequence) constructor{
    sequence = _sequence
    reason = ""
    
    static Error = function(msg) {
        var name = "<unknown>"
        if struct_exists(sequence, "id") {
            name = sequence.id
        }
        reason = $"[{name}]: {msg}"
    }
    
    static ValidateKeys = function() {
        var optional = ["id", "script", "option"];
        var mandatory = ["next"];
        for (var i = 0; i<array_length(mandatory); i++) {
            if !struct_exists(sequence, mandatory[i]) {
                Error($"missing '{mandatory[i]}'")
                return false;
            }
        }
        var keys = struct_get_names(sequence);
        for (var i = 0; i<array_length(keys); i++) {
            var key = keys[i];
            if !(array_contains(optional, key) || array_contains(mandatory, key)) {
                Error($"unexpected '{keys[i]}'")
                return false;
            }
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

        var next = sequence.next;
        if is_array(next) {
            if !struct_exists(sequence, "option") {
                Error($"has array next, but is missing an option field")
                return false;
            }
            if sequence.option.outcomes != array_length(next) {
                Error($"next length {array_length(next)} != {sequence.option.outcomes} option outcomes")
                return false;
            }
            for (var i=0; i<array_length(next); i++) {
                if !(is_numeric(next[i]) || is_string(next[i])) {
                    Error($"invalid exit type {next[i]}")
                    return false;
                }
            }
        } else {
            if !(is_numeric(next) || is_string(next)) {
                Error($"invalid exit type {next}")
                return false;
            }
        }

        return true;
    }
    
    /// Validate the sequence
    static Validate = function() {
        return ValidateKeys() && ValidateNext();
    }
}

function SequenceLinterTests(_run, _method) : VerrificMethodTest(_run, _method) constructor {
    
    static test_subject="Sequence Linter Tests"
    
    static should_invalidate_empty = function() {
        var linter = new SequenceLinter({})
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_multi_next_no_option = function() {
        var linter = new SequenceLinter({ id: "foo", script: [ NewTestAction() ], next: [0, 1] });
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_incorrect_option_count = function() {
        var linter = new SequenceLinter({ id: "foo", script: [ NewTestAction() ], option: NewTestChoice(["Foo", "Bar"]), next: [0, 1, 2] });
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_badtype_next = function() {
        var linter = new SequenceLinter({ id: "foo", script: [ NewTestAction() ], option: NewTestChoice(["Foo", "Bar"]), next: [0, {}] });
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_invalidate_badtype_next_single = function() {
        var linter = new SequenceLinter({ id: "foo", script: [ NewTestAction() ], next: {} });
        assert_is_false(linter.Validate())
        assert_is_true(string_length(linter.reason) > 0)
    }
    
    static should_validate_simple = function() {
        var linter = new SequenceLinter({ id: "foo", script: [ NewTestAction() ], option: NewTestChoice(["Foo", "Bar"]), next: [0, "test"] });
        assert_is_true(linter.Validate())
    }
    
    static should_validate_simple_single = function() {
        var linter = new SequenceLinter({ id: "foo", script: [ NewTestAction() ], next: 0 });
        assert_is_true(linter.Validate())
    }
    
    static should_validate_minimum = function() {
        var linter = new SequenceLinter({ next: 0 });
        assert_is_true(linter.Validate())
    }
}