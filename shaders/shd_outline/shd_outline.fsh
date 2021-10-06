#extension GL_OES_standard_derivatives: require

varying vec2 v_vTexcoord;

void main() {
    vec4 baseColor = texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor = vec4(1, 1, 1, ceil(max(abs(dFdx(baseColor.r)), abs(dFdy(baseColor.r)))));
}