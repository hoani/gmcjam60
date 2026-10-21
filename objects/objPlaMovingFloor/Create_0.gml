plat = new PlatMovingFloor(x, y, image_xscale, image_yscale, sprite_index, image_angle, false)

FloorAngle = function(_x, _y, _w, _gdir=-90)  {
    return plat.FloorAngle(_x, _y, _w, _gdir) 
}

xspd = 0.25
yspd = 0

