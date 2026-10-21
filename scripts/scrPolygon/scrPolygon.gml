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


function DrawPolygonOutline(center, n, r, width, angle, col, alpha=1) {
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