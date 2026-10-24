#macro BLOCK_BASE_WIDTH 32
#macro BLOCK_BASE_HEIGHT 16

function BlockBody(_c, _p, _draw) : PolygonBodyDynamic(_c, _p, _draw) constructor {
    joinDelegate = new BlockJoiner(_p)
}

function BlockJoiner(_polygon) : EdgeWeldJoiner(_polygon) constructor { }

function MaterialBlock() : MaterialRectangle() constructor {
    draw = new BlockDraw()
    
    static Placement = function() {
        return new BlockPlacement(draw)
    }
}


function BlockPlacement(draw) : RectanglePlacement(draw) constructor {
    index = MATERIAL_BLOCK
    
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
            var p = Rectangle(c, width-5, height-5,  dir);
            DrawPolygonOutline(c, p.points, 2, c_white)
            p = Rectangle(c, width, height,  dir);
            DrawPolygonOutline(c, p.points, 2, c_white)
        }
    }
}


function MaterialRectangle() : Material() constructor {
    static _DrawContext = function(_x, _y) {
        return {
            c: new Vec2(_x+BLOCK_BASE_WIDTH/2, _y+BLOCK_BASE_HEIGHT/2),
            width: BLOCK_BASE_WIDTH,
            height: BLOCK_BASE_HEIGHT,
            dir: 0,
            DrawPoints: FuncNone,
        }
    }
}


function RectanglePlacement(_draw = new MaterialDraw()) : MaterialPlacement(_draw) constructor {
    static PlaceA = 0
    static PlaceB = 1
    static PlaceRotate = 2
    static PlaceDrag = 3
    
    
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
        UpdateJoins()
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
                dirZero = (new Vec2(x, y)).Subtract(c).Direction()
                break;
            case PlaceRotate:
                dir = (new Vec2(x, y)).Subtract(c).Direction() - dirZero
                break;
            case PlaceDrag:
                c = (new Vec2(x, y)).Add(o)
                break;
            
            
        }
    }
    
    static _Confirm = function(x, y) {
        switch s.Get() {
            case PlaceA:
                s.Set(PlaceB)
                return noone
            case PlaceB:
                s.Set(PlaceRotate)
                return noone
            case PlaceRotate:
                s.Set(PlaceDrag)
                return noone
            case PlaceDrag:
                return Place()
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
