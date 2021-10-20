attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;

void main() {
    vec4 object_space_pos = vec4(in_Position.xy, in_Position.z + 1.0, 1);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
}