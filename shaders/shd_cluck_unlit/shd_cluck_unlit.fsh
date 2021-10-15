varying vec4 v_vColour;

void main() {
    vec4 color = v_vColour;
    if (color.a < 0.1) discard;
    gl_FragColor = color;
}