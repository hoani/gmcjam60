function BoxBody(_c, _p, _draw) : PolygonBodyDynamic(_c, _p, _draw) constructor {
    joinDelegate = new BoxJoiner(_p)
}

function BoxJoiner(_polygon) : EdgeWeldJoiner(_polygon) constructor { }

function MaterialBox() : MaterialRectangle() constructor {
    draw = new BoxDraw()
    static Placement = function() {
        return new BoxPlacement(draw)
    }
}


function BoxDraw() : MaterialDraw() constructor {
    static Placement = function(ctx, color=c_white) {
        ctx.DrawPoints()
        var p = Rectangle(ctx.c, ctx.width, ctx.height,  ctx.dir);
        DrawPolygonOutline(ctx.c, p.points, 2, color)
        
        if struct_exists(ctx, "s") && ctx.s.Get() == ctx.PlaceRotate {
            draw_sprite(sprTransform, 0, MouseX, MouseY)
        }
        if struct_exists(ctx, "s") && ctx.s.Get() == ctx.PlaceDrag {
            draw_sprite(sprTransform, 1, MouseX, MouseY)
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