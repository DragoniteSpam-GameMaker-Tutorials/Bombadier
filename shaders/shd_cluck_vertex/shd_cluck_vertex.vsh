attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;

uniform vec3 lightAmbientColor;
uniform vec3 lightDirection;

varying vec4 v_vColour;
varying vec3 v_LightWorldPosition;

void main() {
    vec4 worldPosition = gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1);
    vec4 worldNormal = gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0);
    
    float NdotL = max(dot(worldNormal.xyz, -normalize(lightDirection)), 0.0);
    v_vColour = vec4(in_Colour.rgb * max(lightAmbientColor, vec3(NdotL)), in_Colour.a);
    
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.);
    v_LightWorldPosition = (gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1)).xyz;
}