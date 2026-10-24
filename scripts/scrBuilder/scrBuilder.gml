function PhyBuilder(world) constructor {
    
    static Grid = 16
    static GridOffset = 8
    
    assembly = new PhyAssembly(world)

    active = 0
    materials = [
        new MaterialEgg(),
        new MaterialWheel(),
        new MaterialBeam(),
        new MaterialBall(),
        new MaterialBlock(),
        new MaterialBox(),
    ]
    
    placement = noone
    
    
    static SelectPrevious = function() {
        active = (active - 1) % array_length(materials) 
    }
    
    static SelectNext = function() {
        active = (active + 1) % array_length(materials) 
    }
    
    static Update = function() {
        var mx = ClipToGrid(MouseX)
        var my = ClipToGrid(MouseY)
        
        if placement == noone {
            if mouse_check_button_pressed(mb_left) { 
                placement = materials[active].Placement()
            }
            
            if mouse_wheel_up() {
                SelectPrevious()
            }
            
            if mouse_wheel_down() {
                SelectNext()
            }
        }
        
        if placement != noone {
            placement.Drag(mx, my)
        }
        
        if mouse_check_button_released(mb_left) {
            if placement.Confirm(mx, my) != noone {
                assembly.Add(placement)
                placement = noone
            }
        }
    }
    
    static Undo = function() {
        if placement == noone {
            assembly.Undo()
        }
    }
    
    static Redo = function() {
        if placement == noone {
            assembly.Redo()
        }
    }
    
    
    static Draw = function() {
        if placement != noone {
            placement.Draw()
        } else {
            active = (active) % array_length(materials) 
            materials[active].Draw(MouseX, MouseY)
        }
    }
    
    static ClipToGrid = function(in) {
        return Clip(in, Grid, GridOffset)
    }
}