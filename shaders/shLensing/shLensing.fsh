varying vec2 v_vTexcoord;
varying vec4 v_vColour;

const int MAX_HOLES = 8;

// Per hole: xy = centre (window pixels), z = shadow radius (pixels). z <= 0 means unused.
uniform vec3 u_holes[MAX_HOLES];

// Size in pixels of the surface being drawn (set from GML).
uniform vec2 u_resolution;

void main()
{
    // Everything in screen heights (geometrized units, c = G = 1), origin at the corner.
    vec2 pos = v_vTexcoord * u_resolution / u_resolution.y;
    //vec2  pos    = gl_FragCoord.xy / u_resolution.y;
    vec2  source = pos;          // where this pixel's ray came from; starts unbent
    float lit    = 1.0;          // 0 inside any shadow
    float edge   = 1.5 / u_resolution.y;  // ~1.5 px soft shadow edge

    for (int i = 0; i < MAX_HOLES; i++) {
        float rCap = u_holes[i].z / u_resolution.y;
        if (rCap > 0.0) {
            vec2  d  = pos - u_holes[i].xy / u_resolution.y;   // from this hole to the pixel
            float r2 = dot(d, d);
            float r  = sqrt(r2);

            // Shadow: union of every hole's capture disc.
            lit *= smoothstep(rCap - edge, rCap + edge, r);

            // Weak-field deflection, summed over holes: each pulls the ray
            // toward itself by 4M/r. Shadow radius = 3*sqrt(3)*M.
            float M = rCap / 5.196152;
            source -= (4.0 * M) * d / max(r2, 1e-8);
        }
    }

    if (lit <= 0.0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0) * v_vColour;
        return;
    }

    // Screen heights -> 0..1 texture coordinates.
    vec2 uv  = source * u_resolution.y / u_resolution;
    vec4 col = texture2D(gm_BaseTexture, uv);

    gl_FragColor = vec4(col.rgb * lit, col.a) * v_vColour;
}
