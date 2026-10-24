event_inherited();

name = "Physics"

world = new PhysicsWorld()

builder = new PhyBuilder(world)

ScoreBoat().Login()


var mBlock = new MaterialBlock()
var p = mBlock.Placement() 
    
p.Confirm(builder.ClipToGrid(64),  builder.ClipToGrid(480)) 
p.Confirm(builder.ClipToGrid(920), builder.ClipToGrid(512))
p.Confirm(builder.ClipToGrid(920), builder.ClipToGrid(512))
p.Confirm(builder.ClipToGrid(920), builder.ClipToGrid(512))

builder.assembly.base = [p.Encode()]