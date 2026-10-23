event_inherited();

name = "Physics"

world = new PhysicsWorld()

assembly = new PhyAssembly(world)

active = 0
materials = [
    new MaterialWheel(),
    new MaterialBeam(),
    new MaterialBall(),
    new MaterialBlock(),
    new MaterialBox(),
]


pStart = new Vec2()


mBlock = new MaterialBlock()



placement = noone

grid = 16
gridOffset = 8

function clipToGrid(in) {
    return Clip(in, grid, gridOffset)
}


var p = mBlock.Placement() 
    
p.Confirm(clipToGrid(64), clipToGrid(480)) 
p.Confirm(clipToGrid(920), clipToGrid(512))
p.Confirm(clipToGrid(920), clipToGrid(512))
p.Confirm(clipToGrid(920), clipToGrid(512))

assembly.base = [p.Encode()]