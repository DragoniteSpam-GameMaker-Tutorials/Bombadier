varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    vec4 color = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    if (color.a < 0.1) discard;
    gl_FragColor = color;
}