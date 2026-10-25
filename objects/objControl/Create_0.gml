

world = PhysicsWorld()
world.Reset()


help = Help(new Vec2(16, 8), sprHelpHover, sprHelp)

prevStack = []


assembly= {
    play: new PhyAssembly(world),
    build: new PhyAssembly(world),
}


function GoToOnline() {
    PopControlStack()
    PushControlStack(onlineStack)
    world.Destroy()
}


buttons = {
    start: Button(new Vec2(room_width-16, room_height-8), sprStart, function() {
        prevStack = PeekControlStack()
        c.play.WithOnRestart(function() {
            builder.Reset()
            PushControlStack(prevStack)
        })
        PopControlStack()
        world.Start()
        
        PushControlStack(c.play.uid)
    }).HRight().VBottom(),
    
    online: Button(new Vec2(room_width-16, 8), sprNavigateOnline, function() {
        GoToOnline()
    }).HRight().VTop(),
    
    back: {
        sandbox: Button(new Vec2(room_width-16, 8), sprNavigateBack, function() {
            PopControlStack()
            assembly.play.SetBase([])
            builder.SetBlueprint(0)
            builder.Reset(assembly.play)
            PushControlStack(sandboxStack)
        }).HRight().VTop(),
        online: Button(new Vec2(room_width-16, 8), sprNavigateOnline, function() {
            GoToOnline()
        }).HRight().VTop(),
        build: Button(new Vec2(room_width-16, 8), sprNavigateBuild, function() {
            PopControlStack()
            builder.Reset(assembly.build)
            builder.SetBlueprint(1)
            PushControlStack(buildStack)
        }).HRight().VTop(),
    },
    
    build: Button(new Vec2(room_width-16, room_height-8), sprBuild, function() {
        PopControlStack()
        builder.Reset(assembly.build)
        builder.SetBlueprint(1)
        PushControlStack(buildStack)
    }).HRight().VBottom(),
    
    test: Button(new Vec2(room_width-16, room_height-8), sprTest, function() {
        PopControlStack()
        assembly.play.SetBase(assembly.build.ConcatAssembly())
        builder.SetBlueprint(0)
        builder.Reset(assembly.play)
        PushControlStack(testStack)
    }).HRight().VBottom(),
}



play = new PhyPlay(world)
builder = new PhyBuilder(assembly.play)
browser = new Browser()


title = new Title(function() {
    PopControlStack()
    PushControlStack(builderStack)
})

c = {
    title: title,
    help: help,
    play: play,
    builder: builder,
    browser: browser,
    
    // Buttons
    bStart: buttons.start,
    bOnline: buttons.online,
    bBackToSandbox: buttons.back.sandbox,
    bBackToOnline: buttons.back.online,
    bBackToBuild: buttons.back.build,
    bBuild: buttons.build,
    bTest: buttons.test,
}

sandboxStack = [builder.uid, buttons.start.uid, help.uid, buttons.online.uid]
buildStack = [builder.uid, buttons.test.uid, buttons.back.online.uid]
testStack = [builder.uid, buttons.start.uid, buttons.back.build.uid]
onlineStack = [browser.uid, buttons.build.uid, buttons.back.sandbox.uid]
titleStack = [c.title.uid, buttons.online.uid]

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
    //PushControlStack(titleStack)
    PushControlStack(sandboxStack)
} else {
    PushControlStack(titleStack)
}





