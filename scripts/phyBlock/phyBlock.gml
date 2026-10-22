function PhyBodyBlock(_c, _p) constructor {
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



function MaterialBlock() constructor {
    
    static Placement = function() {
        return new BlockPlacement()
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


function BlockPlacement() : RectanglePlacement() constructor {
    static _Place = function() {
        var p = Rectangle(c, width, height, dir);
        return PolygonFixture(c, p).
            Static().
            Restitution(0.25).
            Apply(c.x, c.y, new PhyBodyBlock(c, p))
       
    }
}


function RectanglePlacement() : Placement() constructor {
    static PlaceCenter = 0
    static PlaceWidth = 1
    static PlaceHeight = 2
    static PlaceDrag = 3
    
    c = new Vec2()
    dir = 0
    width = 32
    height = 32
    o = new Vec2()
    lp = new Vec2()
    
    s = new State(PlaceCenter)
    
    static Drag = function(x, y) {
        switch s.Get() {
            case PlaceCenter:
                c = new Vec2(x, y)
                break;
            case PlaceWidth:
                lp = new Vec2(x, y)
                var delta = c.Subtract(lp)
                width = delta.Distance()*2
                dir = delta.Direction()
                DebugMessage($"dir {dir}")
                
                if width < 32 {
                    width = 32
                }
                break;
            case PlaceHeight:
                var po = new Vec2(x, y)
                o = c.Subtract(po)
                
                var line = new Line(c.x, c.y, lp.x, lp.y)
                height = po.Subtract(line.ClosestPointInfinite(po)).Distance()*2
                if height < 32 {
                    height = 32
                }
                break;
            case PlaceDrag:
                c = (new Vec2(x, y)).Add(o)
                break;
        }
    }
    
    static Confirm = function(x, y) {
        Drag(x, y)
        switch s.Get() {
            case PlaceCenter:
                s.Set(PlaceWidth)
                return noone
            case PlaceWidth:
                s.Set(PlaceHeight)
                return noone
            case PlaceHeight:
                s.Set(PlaceDrag)
                return noone
            case PlaceDrag:
                return _Place()
        }
    }
    
    static _Place = function() {
        DebugError("Missing Place Method")
    }
    
    static Draw = function() {
        draw_circle(c.x, c.y, 3, true)
        draw_circle(lp.x, lp.y, 5, true)
        var p = Rectangle(c, width, height,  dir);
        DrawPolygonOutline(c, p.points, 2, c_white)
    }
}
