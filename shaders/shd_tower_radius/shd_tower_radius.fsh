varying vec2 v_vWorldPosition;

uniform vec2 u_TowerPosition;
uniform float u_TowerRadius;

void main() {
    gl_FragColor = vec4(1);
    if (distance(v_vWorldPosition, u_TowerPosition) > u_TowerRadius) {
        discard;
    }
}