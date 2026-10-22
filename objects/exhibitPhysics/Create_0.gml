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



placement = noone

grid = 16
gridOffset = 8

function clipToGrid(in) {
    return gridOffset + round((in-gridOffset)/grid)*grid
}


mBlock.Place(clipToGrid(64), clipToGrid(480), clipToGrid(920), clipToGrid(512))