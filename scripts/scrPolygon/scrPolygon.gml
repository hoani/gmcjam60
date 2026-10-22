function DrawPolygonFill(center, n, r, angle, col, alpha=1) {
    if n < 3 || r <= 0 {
        return;
    }
    
    draw_primitive_begin(pr_trianglefan);
    
    draw_vertex_colour(center.x, center.y, col, alpha);
    
    // Draws all sides, but repeats the initial point to close the polygon.
    for (var i = 0; i < n + 1; i++) {
        var aoff = angle + (i * 360 / n);
        var xcos = dcos(aoff);
        var ysin = -dsin(aoff);
        
        // To support line thickness, we draw outer and inner vertices
        draw_vertex_colour(center.x + r * xcos, center.y + r * ysin, col, alpha);
    }
    
    draw_primitive_end();
}


function DrawSymmetricPolygonOutline(center, n, r, width, angle, col, alpha=1) {
    if n < 3 || r <= 0 {
        return;
    }
    
    // Calculate the inner/outer radius, this applies a correcton to ensure width is line width.
    var outer_r = r + (0.5*width / dcos(180 / n)); 
    var inner_r = r - (0.5*width / dcos(180 / n)); 
    
    draw_primitive_begin(pr_trianglestrip);
    
    // Draws all sides, but repeats the initial point to close the polygon.
    for (var i = 0; i < n + 1; i++) {
        var aoff = angle + (i * 360 / n);
        var xcos = dcos(aoff);
        var ysin = -dsin(aoff);
        
        // To support line thickness, we draw outer and inner vertices
        draw_vertex_colour(center.x + outer_r * xcos, center.y + outer_r * ysin, col, alpha);
        draw_vertex_colour(center.x + inner_r * xcos, center.y + inner_r * ysin, col, alpha);
    }
    
    draw_primitive_end();
}

function DrawPolygonOutline(center, points, width, col, alpha=1) {
    var n = array_length(points)
    if n < 3 {
        return;
    }
    
    var hw = width * 0.5;
    var miter_limit = 4; // cap miter length, for sharp corners - multiple of hw
    
    draw_primitive_begin(pr_trianglestrip);
    
    // Draws all sides, but repeats the initial point to close the polygon.
    for (var i = 0; i < n + 1; i++) {
        var p = points[i mod n].Subtract(center);
        var a = points[(i - 1 + n) mod n].Subtract(center);
        var b = points[(i + 1) mod n].Subtract(center);
        
        // Unit directions of the incoming and outgoing edges
        var ua = p.Subtract(a).Unit();        
        var ub = b.Subtract(p).Unit();

        // Edge normals - go along the width of the line
        var na = new Vec2(-ua.y, ua.x)
        var nb = new Vec2(-ub.y, ub.x)

        // Miter direction = normalised sum of the two normals
        var m = na.Add(nb).Unit()

        // Scale so each edge keeps full thickness; clamp for very sharp corners
        var s = hw / max(m.x * na.x + m.y * na.y, 1 / miter_limit);

        var pa = p.Add(center).Add(m.Multiply(s))        
        var pb = p.Add(center).Subtract(m.Multiply(s))
        draw_vertex_colour(pa.x, pa.y, col, alpha);
        draw_vertex_colour(pb.x, pb.y, col, alpha);
    }
    
    draw_primitive_end();
}