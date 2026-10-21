//
// Horizontal Dissolve shader. Prioritizes horizontal lines for a retro kill look. 
// 
// amount - The amount to dissolve by, 0 = no dissolve, 1 = completely dissolved
// seed - Varies the random pattern. Keep constant to keep the dissolve consistent, or change over time for static noise effect.

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float amount;
uniform float seed;

float hash(vec2 p)
{
    p = mod(p, 7.31); //Bring 'p' to a useful range.
    //Generate a pseudo random number from 'p'.
    return fract(sin(p.x*12.9898) * 43758.5453) * 0.325 + fract(sin(p.y*78.233) * 43758.5453) * 0.675;
}

//Handle fragments/pixels.
void main()
{
    //Set the output the vertex color multiplied by texture color of each pixel.
    vec4 texCol = texture2D( gm_BaseTexture, v_vTexcoord );
    texCol.a *= (hash(v_vTexcoord*(seed + 1.0))) < amount ? 0.:1.;  
    
    gl_FragColor = v_vColour * texCol;
}
