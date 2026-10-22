function PhyBodyBox(_c, _p) constructor {
    c = _c
    p = _p
    static PreUpdate = function(ctx) {
    }
    
    static Update = function(ctx) {
    }
    
    static Draw = function(ctx) {
        with(ctx) {
            physics_draw_debug()
        }
    }
    
}



function MaterialBox() constructor {
    static Placement = function() {
        return new BoxPlacement()
    }
}



function BoxPlacement() : RectanglePlacement() constructor {
    static _Place = function() {
        var p = Rectangle(c, width, height, dir);
        return PolygonFixture(c, p).
            Density(0.125).
            Friction(0.2).
            Restitution(0.25).
            Rotation(dir).
            Bullet().
            Apply(c.x, c.y, new PhyBodyBox(c, p))
    }
}