#macro BLOCK_BASE_WIDTH 32
#macro BLOCK_BASE_HEIGHT 16

function BlockBody(_c, _p, _draw) : PolygonBodyDynamic(_c, _p, _draw) constructor {
    joinDelegate = new BlockJoiner(_p)
}

function BlockJoiner(_polygon) : EdgeWeldJoiner(_polygon) constructor { }

function MaterialBlock() : MaterialRectangle("Bricks") constructor {
    draw = new RectangleSpriteDraw(sprBlock)
    
    static Placement = function() {
        return new BlockPlacement(draw)
    }
}


function BlockPlacement(draw) : RectanglePlacement(draw, 64, 960, 16, 32) constructor {
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


function RectangleSpriteDraw(_spr) : MaterialDraw() constructor {
    spr = _spr
    static Placement = function(ctx, color=c_white) {
        ctx.DrawPoints()
        
        var xscale = ctx.width/sprite_get_width(spr)
        var yscale = ctx.height/sprite_get_height(spr)
        draw_sprite_ext(spr, 0, ctx.c.x, ctx.c.y, xscale, yscale, ctx.dir, color, 0.75)
        
        if struct_exists(ctx, "s") && ctx.s.Get() == ctx.PlaceRotate {
            draw_sprite(sprTransform, 0, MouseX, MouseY)
        }
        if struct_exists(ctx, "s") && ctx.s.Get() == ctx.PlaceDrag {
            draw_sprite(sprTransform, 1, MouseX, MouseY)
        }
    }
    
    static Play = function(ctx) {
        var xscale = ctx.placement.width/sprite_get_width(spr)
        var yscale = ctx.placement.height/sprite_get_height(spr)
        draw_sprite_ext(spr, 0, ctx.x, ctx.y, xscale, yscale, ctx.image_angle + ctx.placement.dir, c_white, 1)
    }
}


function MaterialRectangle(_name) : Material(_name) constructor {
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


function RectanglePlacement(_draw = new MaterialDraw(), _wmin=32, _wmax=256, _hmin=16, _hmax=128) : MaterialPlacement(_draw) constructor {
    static PlaceA = 0
    static PlaceB = 1
    static PlaceRotate = 2
    static PlaceDrag = 3
    static PlaceDone = 4
    
    
    a = new Vec2()
    b = new Vec2()
    bdraw = new Vec2()
    c = new Vec2()
    o = new Vec2()
    dir = 0
    dirZero = 0
    width = _wmin
    height = _hmin
    
    wmin = _wmin
    wmax = _wmax
    hmin = _hmin 
    hmax = _hmax
    
    
    s = new State(PlaceA)
    
    static _Drag = function(x, y) {
        UpdateJoins()
        switch s.Get() {
            case PlaceA:
                a = new Vec2(x, y)
                c = new Vec2(a.x + width/2, a.y + height/2)
                bdraw = new Vec2(x, y)
                break;
            case PlaceB:
                b = new Vec2(x, y)
                c = a.Add(b).Multiply(0.5)
                var delta = c.Subtract(a)
                width = abs(delta.x)*2
                height = abs(delta.y)*2
                
                width = clamp(width, wmin, wmax)
                height = clamp(height, hmin, hmax)
                
                c.x = a.x + width/2
                c.y = a.y + height/2
                
                var l = PointsLine(a, c).Multiply(2)
                bdraw = l.p1.Subtract(a.Subtract(c).Multiply(0.5))
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
                s.Set(PlaceDone)
                return Place()
        }
    }
    
    static _Place = function() {
        DebugError("Missing Place Method")
    }
    
    static _Shape = function() {
        return Rectangle(c, width, height,  dir)
    }
    
    static _Mask = function() {
        return Rectangle(c, width-1, height-1,  dir)
    }
    
    static DrawPoints = function() {
        switch s.Get() {
            case PlaceA:
                DrawCircleOutline(a, 5, 2);
                break
            case PlaceB:
                DrawCircleOutline(a, 3, 2);
                DrawCircleOutline(bdraw, 5, 2);
                var l = bdraw.Subtract(a)
                var u = l.Unit()
                for (var i = 0; i <l.Distance(); i+=16) {
                    DrawLine(a.Add(u.Multiply(i)), a.Add(u.Multiply(i + 8)), 2)
                }
                break
            case PlaceDrag:
                DrawPlus(c, 8, 2)
                break
            case PlaceRotate:
                DrawCircleOutline(c, 8, 2);
                break
        }
    }
}
