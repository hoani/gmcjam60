
online = new OnlineHandler()
online.OnLevelRegistry(function(){
    var levelStr = "eyJoYXNoIjoiYzliOWU1NzNkYWQyOWY0ZWI0NmNkYjdiYThkYWE5M2MiLCJwYXJ0cyI6Ilt7XCJwb2ludHNcIjpbNTg0LjAsMjk2LjBdLFwiaW5kZXhcIjo1LjB9LHtcInBvaW50c1wiOlsyOTYuMCw2MDAuMCw5NTIuMCw2MDAuMCw5NTIuMCw2MDAuMCw5MDQuMCw2NDguMF0sXCJpbmRleFwiOjEuMH0se1wicG9pbnRzXCI6WzU4NC4wLDcyLjAsNjAwLjAsMTM2LjAsNjAwLjAsMTg0LjBdLFwiaW5kZXhcIjozLjB9XSJ9"

    //levelRegistry.OnLevel(LevelEntry("abcdd", "Test 0", "Steve1").Populate({likes: 0, plays: 0, wins: 0, uplays: 0, level: levelStr}))
    //levelRegistry.OnLevel(LevelEntry("abcde", "Test 1", "Steve2").Populate({likes: 0, plays: 0, wins: 0, uplays: 0, level: levelStr}))
    //levelRegistry.OnLevel(LevelEntry("abcdf", "Test 2", "Steve3").Populate({likes: 0, plays: 0, wins: 0, uplays: 0, level: levelStr}))
    //levelRegistry.OnLevel(LevelEntry("abcdg", "Test 3", "Steve4").Populate({likes: 0, plays: 0, wins: 0, uplays: 0, level: levelStr}))
    //levelRegistry.OnLevel(LevelEntry("abcdh", "Test 4", "Steve5").Populate({likes: 0, plays: 0, wins: 0, uplays: 0, level: levelStr}))
    //levelRegistry.OnLevel(LevelEntry("abcdi", "Test 5", "Steve6").Populate({likes: 0, plays: 0, wins: 0, uplays: 0, level: levelStr}))
    
    browser.Refresh(levelRegistry.GetDisplay())
})
levelRegistry = online.GetLeaderboard()
onlineLevel = noone

world = PhysicsWorld()
world.Reset()


help = {
    sandbox: Help(new Vec2(16, 8), sprHelpHover, sprHelpSandbox),
    lobby: Help(new Vec2(16, 8), sprHelpHover, sprHelpLobby),
    build: Help(new Vec2(16, 8), sprHelpHover, sprHelpBuild),
    play: Help(new Vec2(16, 8), sprHelpHover, sprHelpPlay),
}

prevStack = []


assembly= {
    play: new PhyAssembly(world),
    build: new PhyAssembly(world),
}

assembly.play.LoadBase(EggInTheMiddle())


function GoToOnline() {
    ClearControlStack()
    PushControlStack(onlineStack)
    canPublish = false
    onlineLevel = noone
    world.Destroy()
}

function GoToSandbox() {
    PopControlStack()
    assembly.play.LoadBase(EggInTheMiddle())
    builder.SetMode(BuildModePlay)
    builder.Reset(assembly.play)
    canPublish = false
    PushControlStack(sandboxStack)
}

function GoToBuild() {
    PopControlStack()
    
    // Put an egg in the middle if the assembly is empty
    var _enc = assembly.build.GetCurrent()
    if _enc == "" {
        _enc = EggInTheMiddle()
    }
    builder.Reset(assembly.build, _enc)
    builder.SetMode(BuildModeCreate)
    canPublish = true
    if online.HasUserLevelSpec() {
        publish.name = online.GetUserLevelSpec().name
        publish.username = online.GetUserLevelSpec().username
    }
    PushControlStack(buildStack)
}

canPublish = false

publish = new Publish(
    function(name, username){
        var enc = assembly.build.EncodeFull()
        DebugMessage($"Publishing: {enc}")
        
        online.PublishLevel(name, username, enc, 
            function(){
                DebugMessage("Publishing succeeded")
                publish.Done("Publish Succeeded")
                canPublish = false
                online.RequestPopulateRegistry()
            },
            function(_error){
                DebugMessage($"Publishing failed {_error}")
                publish.Done("Publish Failed... Please Try Again")
            }
        )
    },
    function() {
        GoToBuild()
    }
)

buttons = {
    start: Button(new Vec2(room_width-16, room_height-8), sprStart, function() {
        prevStack = PeekControlStack()
        c.play.WithOnRestart(function() {
            builder.Reset()
            PushControlStack(prevStack)
        })
        
        if canPublish && online.IsOnline() {
            // Setup publish names if available
            if online.HasUserLevelSpec() {
                publish.name = online.GetUserLevelSpec().name
                publish.username = online.GetUserLevelSpec().username
            }
            
            c.play.WithOnPublish(function(){
                builder.Reset()
                PushControlStack(publishStack)
            })
        } else {
            c.play.WithOnPublish()
        }
        
        world.Start()
        PopControlStack()
        PushControlStack(c.play.uid)
    }).HRight().VBottom(),
    
    online: Button(new Vec2(room_width-16, 8), sprNavigateOnline, function() {
        GoToOnline()
    }).HRight().VTop(),
    
    back: {
        sandbox: Button(new Vec2(room_width-16, 8), sprNavigateBack, function() {
            GoToSandbox() 
        }).HRight().VTop(),
        online: Button(new Vec2(room_width-16, 8), sprNavigateOnline, function() {
            GoToOnline()
        }).HRight().VTop(),
        build: Button(new Vec2(room_width-16, 8), sprNavigateBuild, function() {
            GoToBuild()
        }).HRight().VTop(),
        test: Button(new Vec2(room_width-16, 8), sprNavigateBack, function() {
            if publish.state.Get() == publish.StateDone {
                GoToBuild()
                return
            }
            PopControlStack()
            PushControlStack(prevStack)
        }).HRight().VTop(),
    },
    
    build: Button(new Vec2(room_width-16, room_height-8), sprBuild, function() {
        GoToBuild()
    }).HRight().VBottom(),
    
    test: Button(new Vec2(room_width-16, room_height-8), sprTest, 
        function() {
            PopControlStack()
            assembly.play.SetBase(assembly.build.ConcatAssembly())
            builder.SetMode(BuildModePlay)
            builder.Reset(assembly.play)
            PushControlStack(testStack)
        })
        .HRight().VBottom()
        .WithEnableCondition(function() {
            return instance_number(objPhyEgg) > 0
        }
    ),
}



play = new PhyPlay(world)
builder = new PhyBuilder(assembly.play)
browser = new Browser()

play.WithOnWin(function(){
    if onlineLevel != noone {
        online.LevelIncrWins(onlineLevel.uuid)
    }
})

play.WithOnPlay(function(){
    if onlineLevel != noone {
        online.LevelIncrPlays(onlineLevel.uuid)
    }
})




browser.Refresh(
    levelRegistry.GetDisplay(), 
    function(which) {
        PopControlStack()
        DebugMessage($"Selected {which}")
        onlineLevel = levelRegistry.GetActive(which)
        
        assembly.play.SetBase([])
        assembly.play.LoadBase(onlineLevel.level)
        assembly.play.Reset()
        builder.SetMode(BuildModePlay)
        builder.Reset(assembly.play)
        
        PushControlStack(levelStack)
    }
)


title = new Title(function() {
    PopControlStack()
    PopControlStack() // Builder was in the stack just to show graphics
    PushControlStack(sandboxStack)
})

c = {
    title: title,
    
    play: play,
    builder: builder,
    browser: browser,
    publish: publish,
    online: online,
    
    
    // Buttons
    bStart: buttons.start,
    bOnline: buttons.online,
    bBackToSandbox: buttons.back.sandbox,
    bBackToOnline: buttons.back.online,
    bBackToBuild: buttons.back.build,
    bBackToTest: buttons.back.test,
    bBuild: buttons.build,
    bTest: buttons.test,
}

sandboxStack = [builder.uid, buttons.start.uid, help.sandbox.uid, buttons.online.uid]
buildStack = [builder.uid, buttons.test.uid, buttons.back.online.uid, help.build.uid]
testStack = [builder.uid, buttons.start.uid, buttons.back.build.uid, help.build.uid]
onlineStack = [browser.uid, buttons.build.uid, buttons.back.sandbox.uid, help.lobby.uid]
titleStack = [c.title.uid, buttons.online.uid]
publishStack = [c.publish.uid, buttons.back.test.uid]
levelStack = [builder.uid, buttons.back.online.uid, buttons.start.uid, help.play.uid]

StateTitle = 0
StateBuild = 1
StatePlay = 2
StateWin = 3
StateLose = 4

state = new State(StateTitle)

// Resize the window and surface
window_set_size(room_width, room_height);
surface_resize(application_surface, room_width, room_height);


if Debug() {
    PushControlStack(builder.uid)
    PushControlStack(titleStack)
    //PushControlStack(onlineStack)
} else {
    PushControlStack(builder.uid)
    PushControlStack(titleStack)
}





