event_inherited();

name = "Physics"

world = new PhysicsWorld()


active = 0
materials = [
    new MaterialBall(),
    new MaterialBeam(),
    new MaterialBlock(),
    new MaterialBox(),
    
]


pStart = new Vec2()


mBlock = new MaterialBlock()

mBlock.Place(64, 480, 920, 512)

placement = noone

grid = 16

