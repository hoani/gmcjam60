#define MAX_SCREENS 8
uniform vec2 u_points[MAX_SCREENS * 2]; // corner A, corner B for each screen
uniform vec3 u_color[MAX_SCREENS];
uniform int u_count;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 col = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    vec2 pos = gl_FragCoord.xy;


    for (int i = 0; i < MAX_SCREENS; i++) {
        if (i >= u_count) {
            break;
        }
        
        vec2 a = u_points[i * 2];
        vec2 b = u_points[i * 2 + 1];
        vec2 lo = min(a, b);
        vec2 hi = max(a, b);

        if (all(greaterThanEqual(pos, lo)) && all(lessThan(pos, hi))) {
            col.rgb = u_color[i];
            break; // First screens are prioritized
        }
    }

    gl_FragColor = col;
}