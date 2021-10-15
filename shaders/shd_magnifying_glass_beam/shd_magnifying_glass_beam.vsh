attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 targetPosition;

void main() {
    vec4 object_space_pos = vec4(in_Position, 1.);
    vec4 world_pos = gm_Matrices[MATRIX_WORLD] * object_space_pos;
    
    vec4 updated_world_pos = vec4(mix(targetPosition, world_pos.xyz, in_Colour.a), world_pos.w);
    
    
    gl_Position = gm_Matrices[MATRIX_PROJECTION] * (gm_Matrices[MATRIX_VIEW] * updated_world_pos);
    
    v_vColour = in_Colour;
}