
function TestEventsContext() constructor {
    events = new EventsRegistry()
    game = {
        day: 0,
        upgrades: {
            mine: {
                level: 0,
            }
        },
        quest: {
            wins: [0, 0, 0, 0],
        },
        
    }
    
    static Events = function() {
        return events
    }
}



function EventsEngineTestCases() {
    return [
        ConditionsTest,
        EventsRegistryTests,
        EventsDispatchTests,
    ]
}