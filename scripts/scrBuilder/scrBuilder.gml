#macro BuildModePlay 0
#macro BuildModeCreate 1

function PhyBuilder(_assembly) : ActiveController() constructor {
    
    static Grid = 16
    static GridOffset = 8
    
    assembly = _assembly
    
    draftSurface = surface_create(room_width, room_height)
    assemblySurface = surface_create(room_width, room_height)
    
    active = 0
    
    playMaterials = [
        new MaterialWheel(),
        new MaterialBeam(),
        new MaterialBall(),
        new MaterialBlock(),
        new MaterialBox(),
    ]
    createMaterials = [
        new MaterialEgg(),
    ]
    
    materials = array_concat(playMaterials, [])
    
    
    materialName = NewText(materials[active].name, fScrawlingPadSm).WithAlign(fa_center)
    
    canPlace = true
    placement = noone
    placeableChecker = materials[active].Placement()
    placed = noone
    deleting = false
    deleteCircle = new Circle(new Vec2(0, 0), 8)
    refreshAssembly = true
    cancelling = false
    blueprintIndex = BuildModePlay
    
    mouse = new Vec2()
    
    static SetMode = function(index=BuildModePlay) {
        if index != blueprintIndex {
            active = 0
        }
        blueprintIndex = index
        switch (blueprintIndex) {
            case BuildModePlay: {
                materials = array_concat(playMaterials, [])
                break;
            }
            case BuildModeCreate: {
                materials = array_concat(createMaterials, playMaterials)
                break;
            }
        }
    }
    
    static SelectPrevious = function() {
        active = (active + array_length(materials) - 1) % array_length(materials) 
        materialName.Set(materials[active].name)
        placeableChecker = materials[active].Placement()
    }
    
    static SelectNext = function() {
        active = (active + 1) % array_length(materials)
        materialName.Set(materials[active].name)
        placeableChecker = materials[active].Placement()
    }
    
    
    static _Update = function() {
        mouse.x = clamp(ClipToGrid(MouseX), 40, room_width - 40)
        mouse.y = clamp(ClipToGrid(MouseY), 40, room_height - 40)
        placeableChecker.Drag(mouse.x, mouse.y) // Always update so when we place it is in the correct location
        

        
        if placement == noone && deleting == false {
            canPlace = placeableChecker.CanPlace()
            
            
            if mouse_check_button_pressed(mb_left) && canPlace{ 
                DebugMessage($"Placing {active}")
                placement = materials[active].Placement()
                placement.Drag(mouse.x, mouse.y)
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
            
            if Debug() && keyboard_check_pressed(vk_space) {
                DebugMessage($"Spec: {assembly.GetCurrent()}")
                DebugMessage($"{string_length(assembly.GetCurrent())} bytes")
            }
            
            
            
            return
        }
        

        if placement != noone {
            placement.Drag(mouse.x, mouse.y)
            canPlace = placement.CanPlace()
            
            if mouse_check_button_released(mb_left) && !cancelling && canPlace {
                placed = placement.Confirm(mouse.x, mouse.y)
                if placed != noone {
                    placed.body.SetDeletable()
                    placed = noone
                    refreshAssembly = true
                    assembly.Add(placement)
                    placement = noone
                    PopControlStack()
                    
                }
            }
            
            if mouse_check_button_pressed(mb_right) {
                cancelling = true
            }
            
            if mouse_check_button_released(mb_right) && cancelling {
                cancelling = false
                placement = noone
                PopControlStack()
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
    
    static Reset = function(_assembly=noone, _encoded="") {
        if _assembly != noone {
            assembly = _assembly
            refreshAssembly = true
        }
        
        assembly.Rebuild(_encoded)
    }
    
    
    static Draw = function() {
        if !InControlStack(uid) || PhysicsWorld().Started() {
            refreshAssembly = true
            return
        }
        
        draw_sprite_stretched(sprBlueprint, blueprintIndex, 0, 0, room_width, room_height)
        _DrawAssembly()
        _DrawPlacement()
    }
    
    static _DrawAssembly = function() {
        var surf = RefreshSurface(assemblySurface, room_width, room_height)
        if assemblySurface != surf || refreshAssembly || deleting {
            refreshAssembly = false
            assemblySurface = surf
            surface_set_target(assemblySurface)
            draw_clear_alpha(c_white, 0)
            with (objPhyJoin) {
                self.join.Draw(self)
            }
            with (objPhyMaterial) {
                if !body.deleteCandidate {
                    self.placement.Draw()
                }
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
        
        materialName.Draw(0, 0)
        
        draftSurface = RefreshSurface(draftSurface, room_width, room_height)
        
        if placement != noone {
            
            var c = cancelling || !canPlace ? C_DELETE : C_PLACABLE;
            surface_set_target(draftSurface)
            draw_clear_alpha(c_white, 0)
            placement.Draw(c)
            surface_reset_target()
            
            shader_set(shWobble);
            shader_set_uniform_f(shader_get_uniform(shWobble, "u_frame"), MonoSlowed(4));
            shader_set_uniform_f(shader_get_uniform(shWobble, "u_amount"), 1);
            
            draw_surface(draftSurface, 0, 0)
            
            shader_reset()
            return
            
        } 
        
        if deleting {
            surface_set_target(draftSurface)
            draw_clear_alpha(c_white, 0)
            with (objPhyMaterial) {
                if body.deleteCandidate {
                    self.placement.Draw(C_DELETE)
                }
            }
            surface_reset_target()
            
            shader_set(shWobble);
            shader_set_uniform_f(shader_get_uniform(shWobble, "u_frame"), MonoSlowed(4));
            shader_set_uniform_f(shader_get_uniform(shWobble, "u_amount"), 0.5);
            
            draw_surface(draftSurface, 0, 0)
            
            shader_reset()
        }
        
        surface_set_target(draftSurface)
        draw_clear_alpha(c_white, 0)
        var c = canPlace ? c_white : C_DELETE
        placeableChecker.Draw(c)
        surface_reset_target()
        
        shader_set(shSketch);
        shader_set_uniform_f(shader_get_uniform(shSketch, "u_frame"), MonoSlowed(4));
        
        draw_surface(draftSurface, 0, 0)
        
        shader_reset()
    }
    
    static ClipToGrid = function(in) {
        return Clip(in, Grid, GridOffset)
    }
}