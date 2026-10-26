function EggBody(_c, _r, _draw) : MaterialBodyDynamic(_draw) constructor {
    shape = new Circle(_c, _r)
    
    static _Update = function(ctx) {
        shape.center.x = ctx.x
        shape.center.y = ctx.y
    }
}




function MaterialEgg() : Material("Egg") constructor {
    draw = new EggDraw()
    static Placement = function() {
        return new EggPlacement(draw)
    }
    
    static _DrawContext = function(_x, _y) {
        return {
            c: new Vec2(_x, _y),
        }
    }
}

function MaterialSmallEgg() : Material("Small Egg") constructor {
    draw = new EggDraw(sprSmallEgg)
    static Placement = function() {
        return new SmallEggPlacement(draw)
    }
    
    static _DrawContext = function(_x, _y) {
        return {
            c: new Vec2(_x, _y),
        }
    }
}

function MaterialEaster() : Material("Easter") constructor {
    draw = new EggDraw(sprEasterEgg)
    static Placement = function() {
        return new EasterEggPlacement(draw)
    }
    
    static _DrawContext = function(_x, _y) {
        return {
            c: new Vec2(_x, _y),
        }
    }
}


function EggDraw(_spr = sprPhyEgg) : MaterialDraw() constructor {
    spr = _spr
    static Placement = function(ctx, color=c_white) {
        var c = ctx.c
        draw_sprite_ext(spr, 0, c.x, c.y, 1, 1, 0, color, 1)
    }
    
    static Play = function(ctx) {
        var img = clamp(floor((1-ctx.hp/ctx.maxhp)*8), 0, 7)
        draw_sprite_ext(spr, img, ctx.x, ctx.y, 1, 1, ctx.image_angle, c_white, 1)
        
    }
}

function EasterEggPlacement(_draw) : EggPlacement(_draw, MATERIAL_EASTER) constructor {
}


function SmallEggPlacement(_draw) : EggPlacement(_draw, MATERIAL_SMALLEGG, 16) constructor {
    static _Place = function() {
       	var inst = CircleFixture(12).
            Offset(0, 8).
            Density(0.5).
            Restitution(0.125).
            Friction(1).
            LinearDamping(0.125).
            Bullet().
            Object(objPhyEgg).
            Apply(c.x, c.y, new EggBody(c, r, draw))
        inst.damageMultiplier = 6
        
        var p = new Polygon([[-24, 8], [24, 8], [8, -24], [-8, -24]])
        
        CircleFixture(8).Offset(0, -4).Density(0.25).AppendTo(inst)
        CircleFixture(7).Offset(0, 8).Density(0.75).AppendTo(inst)
        return inst
    }
}




function EggPlacement(_draw, _index=MATERIAL_EGG, _r=32) : MaterialPlacement(_draw) constructor {
    index = _index
    PlaceDrag = 0
    
    c = new Vec2()
    r = _r
    
    s = new State(PlaceDrag)
    
    static _Drag = function(x, y) {
        switch s.Get() {
            case PlaceDrag:
               c = new Vec2(x, y)
                break
        }
    }
    
    static _Confirm = function(x, y) {
        switch s.Get() {
            case PlaceDrag:
                return Place()
        }
    }
    
    static _Shape = function() {
        return new Circle(c, r)
    }
    
    static _Mask = function() {
        return new Circle(c, r-1)
    }
    
    static _Place = function() {
       	var inst = CircleFixture(24).
            Offset(0, 8).
            Density(0.5).
            Restitution(0.125).
            Friction(1).
            LinearDamping(0.125).
            Bullet().
            Object(objPhyEgg).
            Apply(c.x, c.y, new EggBody(c, r, draw))
        
        var p = new Polygon([[-24, 8], [24, 8], [8, -24], [-8, -24]])
        
        CircleFixture(16).Offset(0, -8).Density(0.25).AppendTo(inst)
        CircleFixture(14).Offset(0, 16).Density(0.75).AppendTo(inst)
        return inst
    }
}

