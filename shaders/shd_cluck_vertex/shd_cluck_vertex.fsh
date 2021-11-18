// not sure why gm_AlphaRefValue does not work so we have to do this ourselves
uniform float alphaRef;
uniform float alphaTest;

uniform float fogStrength;
uniform float fogStart;
uniform float fogEnd;
uniform vec3 fogColor;

varying vec4 v_vColour;

void main() {
    vec4 color = v_vColour;
    
    gl_FragColor = color;
}