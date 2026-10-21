
/// Register an interaction with the global registry. Interactions can be registered at any time
/// @arg which - the interaction to register
function RegisterInteraction(which) {
    if !variable_global_exists("interactionRegistry") {
        global.interactionRegistry = new InteractionRegistry();
    }
    global.interactionRegistry.Register(which)
}

function GetInteraction(name) {
    var interaction = undefined;
    if variable_global_exists("interactionRegistry") {
        return global.interactionRegistry.Get(name)
    }
    DebugError($"Attempted to access unregistered interaction {interactionId}", true);

    return EmptyInteraction();
}

function InteractionRegistry() constructor{
    interactions = {}
    static Register = function(interaction) {
        if Debug() {
            var l = Linter(interaction);
            if l.validate(l) == false {
                DebugError(l.reason, true);
            }
            if struct_exists(interactions, interaction.id) {
                show_error($"Attempted to register registered interaction {interaction.id}", true);
            }
        }
        
        struct_set(interactions, interaction.id, interaction);
    }
    
    static Get = function(interactionId) {
        if struct_exists(interactions, interactionId) {
            return struct_get(interactions, interactionId)
        }

        DebugError($"Attempted to access unregistered interaction {interactionId}", true);
        
        return EmptyInteraction();
    }
}
    
    
function EmptyInteraction() {
    
    return {
        id: "empty_interaction",
        entry: "error",
        sequences: {
            error: {
                script: [],
                next: 0,
            },
        }
    }
}