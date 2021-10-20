attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec4 in_Colour;

varying vec4 v_color;
uniform float radius;
uniform vec2 mouse_position;

void main() {
    vec4 object_space_pos = vec4(in_Position.xy, in_Position.z + 1.0, 1);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    if (distance(mouse_position, in_Position.xy) < radius) {
        v_color = vec4(1, 0, 0, 1);
    } else {
        v_color = vec4(0, 0, 0, 1);
    }
}