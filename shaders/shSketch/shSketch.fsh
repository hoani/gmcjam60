//
// Sketch shader, gives a sketch effect, intended for pre-placement
// 
// u_frame - current game frame

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_frame;


float alphaHash(vec2 p)
{
    p = mod(p, 7.31); //Bring 'p' to a useful range.
    //Generate a pseudo random number from 'p'.
    return fract(sin(p.x*12.9898) * 43758.5453) * 0.5 + fract(sin(p.y*18.233) * 43758.5453) * 0.5;
}

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void main() {
    vec2 px = gl_FragCoord.xy;  // pixel position on the render target

    vec2 offset = vec2(
        noise(px * 0.05 + u_frame * 3.1),
        noise(px * 0.05 + u_frame * 7.7 + 50.0)
    ) - 0.5;
    vec2 uv = v_vTexcoord + offset * 0.003;  // wobble in UV units

    vec4 col = v_vColour * texture2D(gm_BaseTexture, uv);
    col.a *= mix(0.0, 0.8, alphaHash(px * 0.8 + u_frame));

    gl_FragColor = col;
}
