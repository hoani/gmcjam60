function BoxBody(_c, _p, draw) : MaterialBodyDynamic(draw) constructor {
    c = _c
    p = _p
    joinDelegate = new BoxJoiner(p)
}

function BoxJoiner(_polygon) : EdgeWeldJoiner(_polygon) constructor { }

function MaterialBox() : MaterialRectangle() constructor {
    draw = new BoxDraw()
    static Placement = function() {
        return new BoxPlacement(draw)
    }
}


function BoxDraw() : MaterialDraw() constructor {
    static Placement = function(ctx) {
        with (ctx) {
            ctx.DrawPoints()
            var p = Rectangle(c, width, height,  dir);
            DrawPolygonOutline(c, p.points, 2, c_white)
        }
    }
    
    static Build = function(ctx) {
        with (ctx) {
            physics_draw_debug()
        }
    }
}


function BoxPlacement(draw) : RectanglePlacement(draw) constructor {
    index = MATERIAL_BOX
    
    static _Place = function() {
        var p = Rectangle(c, width, height, dir);
        return PolygonFixture(c, p).
            Density(0.125).
            Friction(0.2).
            Restitution(0.25).
            Bullet().
            JoinCandidates(joinCandidates).
            Apply(c.x, c.y, new BoxBody(c, p, draw))
    }
}