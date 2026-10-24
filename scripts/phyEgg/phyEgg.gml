function EggBody(_c, _r, _draw) : MaterialBodyDynamic(_draw) constructor {
    shape = new Circle(_c, _r)
    
    static _Update = function(ctx) {
        shape.center.x = ctx.x
        shape.center.y = ctx.y
    }
}

function MaterialEgg() : Material() constructor {
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


function EggDraw() : MaterialDraw() constructor {
    static Placement = function(ctx) {
        with (ctx) {
            draw_sprite(sprPhyEgg, 0, c.x, c.y)
        }
    }
    
    static Play = function(ctx) {
        with(ctx) {
            draw_sprite_ext(sprPhyEgg, 0, x, y, 1, 1, image_angle, c_white, 1)
        }
    }
}




function EggPlacement(_draw) : MaterialPlacement(_draw) constructor {
    index = MATERIAL_EGG
    PlaceDrag = 0
    
    c = new Vec2()
    r = 64
    
    s = new State(PlaceDrag)
    
    static Drag = function(x, y) {
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

