attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;                    // (x,y,z)
attribute vec2 in_TextureCoord;              // (u,v)
attribute vec4 in_Colour;                    // (r,g,b,a)

uniform vec3 lightAmbientColor;
uniform vec3 lightNormal;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    vec3 worldNormal = (gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.)).xyz;
    vec4 finalColor = vec4(in_Colour);
    
    vec4 color = vec4(lightAmbientColor, 1.);
    finalColor *= (color + vec4(max(dot(worldNormal, -normalize(lightNormal)), 0.)));
    
    finalColor.a = in_Colour.a;
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.);
    v_vTexcoord = in_TextureCoord;
    v_vColour = finalColor;
}