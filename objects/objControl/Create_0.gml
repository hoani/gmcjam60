

world = PhysicsWorld()
world.Reset()

c = {
    builder: new PhyBuilder(world),
    title: new Title()
}

//StateTitle = 0
//StateBuild = 1
//StatePlay = 2
//StateWin = 3
//StateLose = 4
//
//state = new State(StateTitle)

// Resize the window and surface
window_set_size(room_width, room_height);
surface_resize(application_surface, room_width, room_height);

PushControlStack(c.builder.uid)
PushControlStack(c.title.uid)


