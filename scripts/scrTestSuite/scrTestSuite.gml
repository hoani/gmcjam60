function TestableSuite() : VerrificSuiteGroup("All tests") constructor {
    with (add_group("Utilities")) {
        add_methods_from(AnimateTests);
        add_methods_from(CommonTests);
        add_methods_from(ControlStackTests);
        add_methods_from(ClosureTests)
        add_methods_from(StateTests);
        add_methods_from(Vec2Tests);
        add_methods_from(ChainOfCommandTests)        
        add_methods_from(SaverTests)
        add_methods_from(RunnerTests)        
        add_methods_from(HistoryTests)
    }
    
    with (add_group("Interaction Engine")) {
        tc = InteractionEngineTestCases()
        for (var i = 0; i<array_length(tc); i++) {
            add_methods_from(tc[i])
        }
    }
    
    with (add_group("Events Engine")) {
        tc = EventsEngineTestCases()
        for (var i = 0; i<array_length(tc); i++) {
            add_methods_from(tc[i])
        }
    }
    
    with (add_group("Geometry Engine")) {
        tc = GeometryEngineTestCases()
        for (var i = 0; i<array_length(tc); i++) {
            add_methods_from(tc[i])
        }
    }
    
    with (add_group("Platform Engine")) {
        tc = PlatformEngineTestCases()
        for (var i = 0; i<array_length(tc); i++) {
            add_methods_from(tc[i])
        }
    }
    
    with (add_group("Text Engine")) {
        tc = TextEngineTestCases()
        for (var i = 0; i<array_length(tc); i++) {
            add_methods_from(tc[i])
        }
    }
    
    with (add_group("Physics Engine")) {
        tc = PhysicsEngineTestCases()
        for (var i = 0; i<array_length(tc); i++) {
            add_methods_from(tc[i])
        }
    }
}