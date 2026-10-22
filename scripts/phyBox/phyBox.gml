function PhyBodyBox(_c, _p, draw) : PhyBodyMaterial(draw) constructor {
    c = _c
    p = _p
}



function MaterialBox() constructor {
    draw = new BoxDraw()
    static Placement = function() {
        return new BoxPlacement(draw)
    }
}


function BoxDraw() : MaterialDraw() constructor {
    static Placement = function(ctx) {
        with (ctx) {
            draw_circle(c.x, c.y, 3, true)
            draw_circle(lp.x, lp.y, 5, true)
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
    static _Place = function() {
        var p = Rectangle(c, width, height, dir);
        return PolygonFixture(c, p).
            Density(0.125).
            Friction(0.2).
            Restitution(0.25).
            Bullet().
            Apply(c.x, c.y, new PhyBodyBox(c, p, draw))
    }
}