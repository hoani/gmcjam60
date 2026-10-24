function PhyBuilder(world) : ActiveController() constructor {
    
    static Grid = 16
    static GridOffset = 8
    
    assembly = new PhyAssembly(world)
    
    draftSurface = surface_create(room_width, room_height)
    assemblySurface = surface_create(room_width, room_height)
    
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
    placed = noone
    deleting = false
    deleteCircle = new Circle(new Vec2(0, 0), 8)
    refreshAssembly = true
    
    
    static SelectPrevious = function() {
        active = (active + array_length(materials) - 1) % array_length(materials) 
        DebugMessage($"Set active to {active}")
    }
    
    static SelectNext = function() {
        active = (active + 1) % array_length(materials) 
    }
    
    static _Update = function() {
        var mx = ClipToGrid(MouseX)
        var my = ClipToGrid(MouseY)
        
        if placement == noone && deleting == false {
            if mouse_check_button_pressed(mb_left) { 
                DebugMessage($"Placing {active}")
                placement = materials[active].Placement()
                PushControlStack(uid)
                return
            }
            
            if mouse_wheel_up() {
                SelectPrevious()
            }
            
            if mouse_wheel_down() {
                SelectNext()
            }
            
            if mouse_check_button_pressed(mb_right) {
                PushControlStack(uid)
                deleting = true
            }
            
            return
        }
        

        if placement != noone {
            placement.Drag(mx, my)
            
            if mouse_check_button_released(mb_left) {
                placed = placement.Confirm(mx, my)
                if placed != noone {
                    placed.body.SetDeletable()
                    placed = noone
                    refreshAssembly = true
                    assembly.Add(placement)
                    placement = noone
                    PopControlStack()
                }
            }
        }
        
        if deleting {
            deleteCircle.center.x = MouseX
            deleteCircle.center.y = MouseY
            
            with(objPhyMaterial) {
                body.RegisterDeleteCandidate(other.deleteCircle)
            }
            
            if mouse_check_button_released(mb_right) {
                deleting = false
                with(objPhyMaterial) {
                    if body.deleteCandidate {
                        other.assembly.Delete(placement)
                        instance_destroy()
                        other.refreshAssembly = true
                    }
                }
                
                PopControlStack()
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
    
    static Reset = function() {
        assembly.Rebuild()
    }
    
    
    static Draw = function() {
        if PhysicsWorld().Started() {
            return 
        }
        _DrawAssembly()
        _DrawPlacement()
    }
    
    static _DrawAssembly = function() {
        var surf = RefreshSurface(assemblySurface, room_width, room_height)
        if assemblySurface != surf || refreshAssembly {
            refreshAssembly = false
            assemblySurface = surf
            surface_set_target(assemblySurface)
            draw_clear_alpha(c_white, 0)
            with (objPhyMaterial) {
                self.body.Draw(self)
            }
            surface_reset_target()
        }
        
        shader_set(shWobble);
        shader_set_uniform_f(shader_get_uniform(shWobble, "u_frame"), 0);
        shader_set_uniform_f(shader_get_uniform(shWobble, "u_amount"), 0.5);
        
        draw_surface(assemblySurface, 0, 0)
        
        shader_reset()
        
    }
    
    static _DrawPlacement = function() {
        if !IsActiveControl(uid) {
            return
        }
        draftSurface = RefreshSurface(draftSurface, room_width, room_height)
        
        if placement != noone {
            surface_set_target(draftSurface)
            draw_clear_alpha(c_white, 0)
            placement.Draw()
            surface_reset_target()
            
            shader_set(shWobble);
            shader_set_uniform_f(shader_get_uniform(shWobble, "u_frame"), MonoSlowed(4));
            shader_set_uniform_f(shader_get_uniform(shWobble, "u_amount"), 1);
            
            draw_surface(draftSurface, 0, 0)
            
            shader_reset()
            
        } else {
            surface_set_target(draftSurface)
            draw_clear_alpha(c_white, 0)
            active = (active) % array_length(materials) 
            materials[active].Draw(MouseX, MouseY)
            surface_reset_target()
            
            shader_set(shSketch);
            shader_set_uniform_f(shader_get_uniform(shSketch, "u_frame"), MonoSlowed(4));
            
            draw_surface(draftSurface, 0, 0)
            
            shader_reset()
        }
    }
    
    static ClipToGrid = function(in) {
        return Clip(in, Grid, GridOffset)
    }
}