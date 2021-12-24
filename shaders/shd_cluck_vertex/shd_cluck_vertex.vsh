attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;                    // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)

uniform vec3 lightAmbientColor;
uniform vec3 lightColor;
uniform vec3 lightDirection;

varying vec4 v_vColour;

varying vec3 v_LightWorldPosition;

void main() {
    vec3 color = in_Colour.rgb;
    vec3 lightAdjustment = vec3(lightAmbientColor);
    float NdotL = max(dot(normalize(gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0)).xyz, lightDirection), 0.0);
    lightAdjustment += lightColor * NdotL;
    color *= clamp(lightAdjustment, vec3(0), vec3(1));
    
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1);
    v_vColour = vec4(color, in_Colour.a);
    v_LightWorldPosition = (gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1)).xyz;
}