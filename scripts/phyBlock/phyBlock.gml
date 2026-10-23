function BlockBody(_c, _p, _draw) : MaterialBody(_draw) constructor {
    c = _c
    p = _p
    joinDelegate = new BlockJoiner(p)
}

function BlockJoiner(_polygon) : EdgeWeldJoiner(_polygon) constructor { }

function MaterialBlock() constructor {
    draw = new BlockDraw()
    
    static Placement = function() {
        return new BlockPlacement(draw)
    }
    
    static Place = function(_x0, _y0, _x1, _y1) {
        var p = new BlockPlacement()
       	p.c.x = (_x0 + _x1)/2;
       	p.c.y = (_y0 + _y1)/2;
       	p.dir = 0
       	p.width = _x1 - _x0  	
        p.height = _y1 - _y0
       	
        return p._Place()
    }
}


function BlockPlacement(draw) : RectanglePlacement(draw) constructor {
    static _Place = function() {
        var p = Rectangle(c, width, height, dir);
        return PolygonFixture(c, p).
            Static().
            Restitution(0.25).
            JoinCandidates(joinCandidates).
            Apply(c.x, c.y, new BlockBody(c, p, draw))
       
    }
}


function BlockDraw() : MaterialDraw() constructor {
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





function RectanglePlacement(_draw = new MaterialDraw()) : MaterialPlacement(_draw) constructor {
    static PlaceA = 0
    static PlaceB = 1
    static PlaceDrag = 2
    static PlaceRotate = 3
    
    a = new Vec2()
    b = new Vec2()
    c = new Vec2()
    o = new Vec2()
    dir = 0
    dirZero = 0
    width = 32
    height = 16
    
    s = new State(PlaceA)
    
    static Drag = function(x, y) {
        switch s.Get() {
            case PlaceA:
                a = new Vec2(x, y)
                c = new Vec2(a.x + width/2, a.y + height/2)
                break;
            case PlaceB:
                b = new Vec2(x, y)
                c = a.Add(b).Multiply(0.5)
                var delta = c.Subtract(a)
                width = abs(delta.x)*2
                height = abs(delta.y)*2
                
                if width < 16 {
                    width = 16
                    c.x = a.x + width/2
                }
                if height < 16 {
                    height = 16
                    c.y = a.y + height/2
                }
                o = c.Subtract(b)
                break;
            case PlaceDrag:
                c = (new Vec2(x, y)).Add(o)
                dirZero = (new Vec2(x, y)).Subtract(c).Direction()
                break;
            case PlaceRotate:
                dir = (new Vec2(x, y)).Subtract(c).Direction() - dirZero
                break;
            
        }
    }
    
    static Confirm = function(x, y) {
        Drag(x, y)
        switch s.Get() {
            case PlaceA:
                s.Set(PlaceB)
                return noone
            case PlaceB:
                s.Set(PlaceDrag)
                return noone
            case PlaceDrag:
                UpdateJoins()
                s.Set(PlaceRotate)
                return noone
            case PlaceRotate:
                UpdateJoins()
                return _Place()
        }
    }
    
    static _Place = function() {
        DebugError("Missing Place Method")
    }
    
    static _Shape = function() {
        return Rectangle(c, width, height,  dir)
    }
    
    static DrawPoints = function() {
        switch s.Get() {
            case PlaceA:
                draw_circle(a.x, a.y, 5, true);
                break
            case PlaceB:
                draw_circle(a.x, a.y, 3, true);
                draw_circle(b.x, b.y, 5, true);
                break
            case PlaceDrag:
                draw_line(c.x, c.y-8, c.x, c.y+8)
                draw_line(c.x-8, c.y, c.x+8, c.y)
                break
            case PlaceRotate:
                draw_circle(c.x, c.y, 6, true);
                break
        }
    }
}
