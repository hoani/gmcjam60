
#macro BOWLING_BALL_RADIUS 32
#macro SHOTPUT_RADIUS 16
#macro YOGA_RADIUS 64
#macro PEG_RADIUS 16

function MaterialPeg() : MaterialSimpleBall("Peg", sprPeg) constructor {
    static Placement = function() {
        return new PegPlacement(draw)
    }
}

function MaterialYoga() : MaterialSimpleBall("Yoga Ball", sprYoga) constructor {
    static Placement = function() {
        return new YogaPlacement(draw)
    }
}

function MaterialShotput() : MaterialSimpleBall("Shotput", sprShotput) constructor {
    static Placement = function() {
        return new ShotputPlacement(draw)
    }
}

function MaterialBowlingBall() : MaterialSimpleBall("Bowling Ball", sprBowlingBall) constructor {
    static Placement = function() {
        return new BowlingBallPlacement(draw)
    }
}

function PegPlacement(_draw) : BallSimplePlacement(_draw, PEG_RADIUS) constructor {
    index = MATERIAL_PEG
    
    static _Place = function() {
       	return CircleFixture(r).
            Static().
            JoinCandidates(joinCandidates).
            Apply(c.x, c.y, new BallBody(c, r, draw))
    }
    
}

function YogaPlacement(_draw) : BallSimplePlacement(_draw, YOGA_RADIUS) constructor {
    index = MATERIAL_YOGA
    
    static _Place = function() {
       	return CircleFixture(r).
            Density(1/64).
            Restitution(0.95).
            Friction(1).
            LinearDamping(0.5).
            Bullet().
            JoinCandidates(joinCandidates).
            Apply(c.x, c.y, new BallBody(c, r, draw))
    }
    
}

function ShotputPlacement(_draw) : BallSimplePlacement(_draw, SHOTPUT_RADIUS) constructor {
    index = MATERIAL_SHOTPUT
    
    static _Place = function() {
       	return CircleFixture(r).
            Density(0.5).
            Restitution(0.25).
            Friction(1).
            LinearDamping(0.125).
            Bullet().
            JoinCandidates(joinCandidates).
            Apply(c.x, c.y, new BallBody(c, r, draw))
    }
}


function BowlingBallPlacement(_draw) : BallSimplePlacement(_draw, BOWLING_BALL_RADIUS) constructor {
    index = MATERIAL_BOWLING
    
    static _Place = function() {
       	return CircleFixture(r).
            Density(0.25).
            Restitution(0.5).
            Friction(1).
            LinearDamping(0.125).
            Bullet().
            JoinCandidates(joinCandidates).
            Apply(c.x, c.y, new BallBody(c, r, draw))
    }
}


function MaterialSimpleBall(name, _spr) : Material(name) constructor {
    draw = new BallSimpleDraw(_spr)
    spr = _spr
    
    static _DrawContext = function(_x, _y) {
        return {
            c: new Vec2(_x, _y),
            r: sprite_get_width(spr),
        }
    }
}






function BallSimpleDraw(_spr) : MaterialDraw() constructor {
    sprite = _spr

    
    static Placement = function(ctx, color=c_white) {
        DrawPlus(ctx.c, 8, 2, color)
        
        draw_sprite_ext(sprite, 0, ctx.c.x, ctx.c.y, 1,1, 0, color, 0.75)
    }
    
    static Play = function(ctx) {
        draw_sprite_ext(sprite, 0, ctx.x, ctx.y, 1, 1, ctx.image_angle, c_white, 1)
    }
}


function BallSimplePlacement(_draw, _r) : MaterialPlacement(_draw) constructor {
    PlaceDrag = 2
    PlaceDone = 3
    
    c = new Vec2()
    r = _r
    
    s = new State(PlaceDrag)
    
    static _Drag = function(x, y) {
        UpdateJoins()
        switch s.Get() {
            case PlaceDrag:
                c.x = x
                c.y = y
                break
        }
    }
    
    static _Confirm = function(x, y) {
        switch s.Get() {
            case PlaceDrag:
                s.Set(PlaceDone)
                return Place()
        }
    }
    
    static _Shape = function() {
        return new Circle(c, r)
    }
    
    static _Mask = function() {
        return new Circle(c, r-1)
    }
}

