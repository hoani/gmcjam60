

world = PhysicsWorld()
world.Reset()


var help = Help(new Vec2(16, 8), sprHelpHover, sprHelp)

var start = Button(new Vec2(room_width-16, room_height-8), sprStart, function() {
    PopControlStack()
    world.Start()
    PushControlStack(c.play.uid)
}).HRight().VBottom()

builder = new PhyBuilder(world)
play = new PhyPlay(world, function() {
    builder.Reset()
    PushControlStack([c.builder.uid, c.start.uid, c.help.uid])
})

title = new Title(function() {
    PopControlStack()
    PushControlStack([c.builder.uid, c.start.uid, c.help.uid])
})
    

c = {
    play: play,
    builder: builder,
    title: title,
    start: start,
    help: help,
}

StateTitle = 0
StateBuild = 1
StatePlay = 2
StateWin = 3
StateLose = 4

state = new State(StateTitle)

// Resize the window and surface
window_set_size(room_width, room_height);
surface_resize(application_surface, room_width, room_height);

PushControlStack(c.title.uid)


