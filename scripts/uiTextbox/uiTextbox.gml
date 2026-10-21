
#macro TextBoxStateIdle 0
#macro TextBoxStateAppearDelay 1
#macro TextBoxStateAppear 2
#macro TextBoxStateActive 3
#macro TextBoxStateHold 4
#macro TextBoxStateDisappear 5

#macro TextBoxAppearFrames 8

#macro ActiveTypeSpeech 0
#macro ActiveTypeNarrate 1
#macro ActiveTypeCaption 2


function TextBox(x, y, w, h, p=16) constructor {
    surfaceBox = new Box(w, h)
    pos = new Pos(x-w/2, y-h/2)
    label = undefined
    text = undefined
    surf = undefined
    padding = p;
    redraw = false;
    uid = GetUniqueId()
    onReady = new Callback()
    onDone = new Callback()
    closing = false;
    warmup = new Cooldown(5);
    coffset = 0;
    state = new State(TextBoxStateIdle)
    
    sfx = new SfxPlayer()
    
    cbox = new UiContainer(w, h, 64, 16, 2, 32, 16, 0);
    tbox = new UiContainer(256, 48, 32, 8, 2, 2);
    
    diamondPos = new Pos(cbox.outer.x, cbox.outer.y1);
    diamondCooldown = new Cooldown(15) 
    
    bcolors = [
        {
            dark: CUiDarkBorder,
            light: CUiBorder,
            button: CUiLightBack,
            text: c_white,
        },
        {
            dark: C_GRAY,
            light: C_LTGRAY,
            button: c_dkgray,
            text: c_white,
        },
        {
            dark: C_DKGREEN,
            light: C_GREEN,
            button: C_DKRED,
            text: c_white,
        }
    ]
    
    bcolor = bcolors[ActiveTypeSpeech]
    
    prim = new UiPrimitives()
    
    
    static Cleanup = function() {
        surface_free(surf)
        sfx.Cleanup()
    }
    
    DoOnReady = function() {
        onReady.Call()
        diamondCooldown.Trigger()
    }
    
    DoOnDone = function() {
        onDone.Call()
        closing = true;
    }
    
    static Set = function(_label, _text, _type = undefined) {
        if _label == "" {
            label = undefined;
            bcolor = bcolors[ActiveTypeNarrate]
        } else {
            label = new Text(_label, FontLookup(f_mono));
            label.Fit(surfaceBox);
            tbox = new UiContainer(label.dimensions.w + 32*2 + 4, 48, 32, 4, 2, 2);
            bcolor = bcolors[ActiveTypeSpeech]
        }
        
        if !is_undefined(_type) {
            bcolor = bcolors[_type];
        }
        
        text = _text.WithOnReady(DoOnReady).WithOnDone(DoOnDone);
        text.Fit(cbox.inner)
        
        coffset = (cbox.inner.h - text.dimensions.h)/2;
        
        if state.Get() == TextBoxStateIdle {
            state.Set(TextBoxStateAppearDelay);
        } else {
            state.Set(TextBoxStateActive);
            warmup.Trigger()
            //sfx.play(sndTextBoxNext);
        }
        redraw = true;
    }
    
    static OnReady = function(_onReady) {
        onReady.Set(_onReady)
    }
    
    static OnDone = function(_onDone) {
        onDone.Set(_onDone)
    }
    
    static DoRefreshSurface = function() {
        var prev = surf
        surf = RefreshSurface(surf, surfaceBox.w, surfaceBox.h)
        return surf != prev
    }
    
    static Update = function() {
        state.Update();
        
        
        switch state.Get() {
            case TextBoxStateIdle:
                break;
            case TextBoxStateAppearDelay:
                if state.mono >= TextBoxAppearFrames {
                    state.Set(TextBoxStateAppear);
                    //sfx.play(sndTextBoxOpen);
                }
                break;
            case TextBoxStateAppear:
                redraw = true;
                if state.mono >= TextBoxAppearFrames {
                    warmup.Trigger()
                    state.Set(TextBoxStateActive);
                }
                break;
            case TextBoxStateActive:
                _StepActive();
                break;
            case TextBoxStateHold:
                text.Step();
                if state.mono > 2 && text.IsDead() {
                    //sfx.play(sndTextBoxClose);
                    state.Set(TextBoxStateDisappear);
                }
                break;
            case TextBoxStateDisappear:
                redraw = true;
                if state.mono >= TextBoxAppearFrames {
                    state.Set(TextBoxStateIdle);
                }
                break;
        }
    }
        
    static _StepActive = function(){   
        text.Step();
        redraw = text.RequiresUpdate();
        
        if diamondCooldown.Active() {
            diamondCooldown.Update();
            if !diamondCooldown.Active() {
                redraw = true;
            }
        }
        
        if !is_undefined(label) {
            label.Step()
        }
        
        if IsActiveControl(uid) {
            warmup.Update()
            if !warmup.Active() && CommandsContinueCheck() {
                diamondCooldown.Cancel();
                if text.state.Get() == TEXT_STATE_APPEAR {
                    text.Advance();
                } else {
                    Close();
                }
            }
        }
    }
    
    static Clear = function() {
        if (is_undefined(text)) {
            return;
        }
        text.End()
    }
    
    static Close = function() {
        if state.Get() != TextBoxStateActive {
            return;
        }
        
        Clear();
        state.Set(TextBoxStateHold);
        if (IsActiveControl(uid)) {
            PopControlStack();
        }
    }
    
    static Draw = function() {
        if state.Get() == TextBoxStateIdle || state.Get() == TextBoxStateAppearDelay {
            return;
        }
        if DoRefreshSurface() || redraw {
            surface_set_target(surf)
            draw_clear_alpha(c_white, 0);
            
            _DrawBox(cbox.outer);
            
            if (state.Get() == TextBoxStateActive) {
                text.Draw(cbox.inner.x0, cbox.inner.y0 + coffset, bcolor.text);
                
                if !is_undefined(label) {
                    _DrawTitleBox(tbox.outer);
                    label.Draw(tbox.inner.x0, tbox.inner.y0)
                }
            }
            
            if onDone.HasPending() && text.IsReady() && !diamondCooldown.Active() {
                prim.Diamond(diamondPos, 20, 2, bcolor.light, bcolor.button)
            }
            
            surface_reset_target()
            redraw = false;
        }
        draw_surface(surf, pos.x, pos.y)
    }
    
    function _DrawTitleBox(b) {
        prim.RoundedRectangle(b.x0, b.y0, b.x1, b.y1, 2)
    }
    
    function _DrawBox(b) {
        var y0 = b.y0;
        var y1 = b.y1;
        if state.Get() == TextBoxStateAppear {
            y0 = b.y + (b.y0 - b.y) * (state.mono/TextBoxAppearFrames);
            y1 = b.y + (b.y1 - b.y) * (state.mono/TextBoxAppearFrames);
        } else if state.Get() == TextBoxStateDisappear {
            y0 = b.y + (b.y0 - b.y) * (1 - state.mono/TextBoxAppearFrames);
            y1 = b.y + (b.y1 - b.y) * (1 - state.mono/TextBoxAppearFrames);
        }
        
        prim.RectangleFill(b.x0, y0, b.x1, y1, CUiDarkBack, 15/16)
        
        if is_undefined(label) {
            prim.RectangleBorder(b.x0, y0, b.x1, y1, 2, bcolor.dark);
        } else {
            prim.RectangleBorder(b.x0, y0, b.x1, y1, 2, bcolor.dark);
            var m = 1;
            prim.RectangleCorners(b.x0-m, y0-m, b.x1+m, y1+m, 4, 16, bcolor.dark);
        }
    }
}

