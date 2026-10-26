function BlackHoleBody(_c, _r, _draw) : MaterialBodyDynamic(_draw) constructor {
    shape = new Circle(_c, _r)
    
    static _Update = function(ctx) {
        shape.center.x = ctx.x
        shape.center.y = ctx.y
    }
}

function MaterialBlackHole() : Material("Black Hole") constructor {
    draw = new BlackHoleDraw()
    static Placement = function() {
        return new BlackHolePlacement(draw)
    }
    
    static _DrawContext = function(_x, _y) {
        return {
            c: new Vec2(_x, _y),
        }
    }
}


function BlackHoleDraw() : MaterialDraw() constructor {
    static Placement = function(ctx, color=c_white) {
        var c = ctx.c
        draw_sprite_ext(sprBlackHole, 0, c.x, c.y, 1, 1, 0, color, 1)
    }
    
    static Play = function(ctx) {
    }
}




function BlackHolePlacement(_draw) : MaterialPlacement(_draw) constructor {
    index = MATERIAL_BLACKHOLE
    PlaceDrag = 0
    
    c = new Vec2()
    r = 48
    
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
        return noone // No Joins
    }
    
    static _Mask = function() {
        return new Circle(c, r-1)
    }
    
    static _Place = function() {
        // Note made small so we don't kill everything
       	return CircleFixture(4). 
            Static().
            Object(objPhyBlackHole).
            Apply(c.x, c.y, new BlackHoleBody(c, r, draw))
        
    }
}

