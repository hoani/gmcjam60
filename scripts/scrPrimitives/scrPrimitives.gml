// Shader compatable primitives


function DrawCircleOutline(c, r, width=1, col=c_white, alpha=1) {
    var n = round(min(16 + log2(r*r + 2), 128))
    DrawSymmetricPolygonOutline(c, n, r, width, 0, col, alpha)
}

function DrawLine(a, b, width=1, col=c_white, alpha=1) {
    if a.IsEqual(b) || width <= 0 {
        return
    }
    
    
    draw_primitive_begin(pr_trianglestrip);
    
    
    var n = a.Subtract(b).Unit().Rotate(90).Multiply(width/2)
    
    // To support line thickness, we draw outer and inner vertices
    draw_vertex_colour(a.x + n.x, a.y + n.y, col, alpha);
    draw_vertex_colour(a.x - n.x, a.y - n.y, col, alpha);
    draw_vertex_colour(b.x + n.x, b.y + n.y, col, alpha);
    draw_vertex_colour(b.x - n.x, b.y - n.y, col, alpha);
   
    draw_primitive_end();
}


function DrawPlus(c, r, width=1, col=c_white, alpha=1) {
    DrawLine(c.Add(new Vec2(-r, 0)), c.Add(new Vec2(r, 0)), width, col, alpha)
    DrawLine(c.Add(new Vec2(0, -r)), c.Add(new Vec2(0, r)), width, col, alpha)
}