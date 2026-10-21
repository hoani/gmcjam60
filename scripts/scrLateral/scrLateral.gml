function Lateral() constructor {
    xmove = 0;
    ymove = 0;
    
    dx = 0;
    dy = 0;
    
    gs = GameSpeed()
    
    static Update = function(_xspd, _yspd) {
        xmove += gs.Get(_xspd);
        dx = sign(xmove) * floor(abs(xmove));
        xmove -= dx;
        
        ymove += gs.Get(_yspd);
        dy = sign(ymove) * floor(abs(ymove));
        ymove -= dy;
        
        if dx == 0 && dy == 0 {
            return false;
        }
        
        return true
    }
}

