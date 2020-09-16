varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float time;
uniform vec4 color;

void main() {
    vec4 base_color = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor = mix(base_color, color, 0.5 + 0.5 * sin(time * 8.));
}