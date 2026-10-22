event_inherited();

name = "Physics"

world = new PhysicsWorld()


active = 0
materials = [
    new MaterialBall(),
    new MaterialBox(),
]


pStart = new Vec2()


mBlock = new MaterialBlock()

mBlock.Place(64, 480, 920, 512)
