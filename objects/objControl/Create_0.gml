

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
    canPublish = false
    world.Destroy()
}

function GoToSandbox() {
    PopControlStack()
    assembly.play.SetBase([])
    builder.SetBlueprint(0)
    builder.Reset(assembly.play)
    canPublish = false
    PushControlStack(sandboxStack)
}

function GoToBuild() {
    PopControlStack()
    builder.Reset(assembly.build)
    builder.SetBlueprint(1)
    canPublish = true
    PushControlStack(buildStack)
}

canPublish = false

publish = new Publish(
    function(){
        DebugMessage("Publish Done")
        publish.Done("Publish Succeeded")
        canPublish = false
    },
    function() {
        PopControlStack()
        PushControlStack(prevStack)
    }
)

buttons = {
    start: Button(new Vec2(room_width-16, room_height-8), sprStart, function() {
        prevStack = PeekControlStack()
        c.play.WithOnRestart(function() {
            builder.Reset()
            PushControlStack(prevStack)
        })
        
        if canPublish {
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
            GoToBuild()
        }).HRight().VTop(),
        test: Button(new Vec2(room_width-16, 8), sprNavigateBack, function() {
            PopControlStack()
            PushControlStack(prevStack)
        }).HRight().VTop(),
    },
    
    build: Button(new Vec2(room_width-16, room_height-8), sprBuild, function() {
        GoToBuild()
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
    publish: publish,
    
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

sandboxStack = [builder.uid, buttons.start.uid, help.uid, buttons.online.uid]
buildStack = [builder.uid, buttons.test.uid, buttons.back.online.uid]
testStack = [builder.uid, buttons.start.uid, buttons.back.build.uid]
onlineStack = [browser.uid, buttons.build.uid, buttons.back.sandbox.uid]
titleStack = [c.title.uid, buttons.online.uid]
publishStack = [c.publish.uid, buttons.back.test.uid]

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





