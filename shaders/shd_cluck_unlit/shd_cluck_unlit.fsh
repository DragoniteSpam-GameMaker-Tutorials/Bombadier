varying vec4 v_vColour;

void main() {
    if (v_vColour.a < 0.1) discard;
    gl_FragColor = v_vColour;
}