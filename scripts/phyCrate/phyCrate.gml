#macro CRATE_BASE_WIDTH 64
#macro CRATE_BASE_HEIGHT 64

function CrateBody(_c, _p, _draw) : PolygonBodyDynamic(_c, _p, _draw) constructor {
    joinDelegate = new CrateJoiner(_p)
}

function CrateJoiner(_polygon) : EdgeWeldJoiner(_polygon) constructor { }

function MaterialCrate() : MaterialRectangle("Crate") constructor {
    draw = new RectangleSpriteDraw(sprCrate)
    
    static Placement = function() {
        return new CratePlacement(draw)
    }
}


function CratePlacement(draw) : RectanglePlacement(draw, 64, 128, 64, 128) constructor {
    index = MATERIAL_CRATE
    
    
    static _Place = function() {
        var p = Rectangle(c, width, height, dir);
        return PolygonFixture(c, p).
            Restitution(0.25).
            Density(0.125).
            JoinCandidates(joinCandidates).
            Apply(c.x, c.y, new CrateBody(c, p, draw))
    }
}


