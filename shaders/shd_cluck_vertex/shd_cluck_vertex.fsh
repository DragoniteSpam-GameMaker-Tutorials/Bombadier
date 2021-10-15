// not sure why gm_AlphaRefValue does not work so we have to do this ourselves
uniform float alphaRef;
uniform float alphaTest;

uniform float fogStrength;
uniform float fogStart;
uniform float fogEnd;
uniform vec3 fogColor;

varying vec4 v_vColour;
varying vec3 v_FogCameraRelativePosition;

void CommonFog(inout vec4 baseColor);

void CommonFog(inout vec4 baseColor) {
    float dist = length(v_FogCameraRelativePosition);
    float f = clamp((dist - fogStart) / (fogEnd - fogStart) * fogStrength, 0., 1.);
    baseColor.rgb = mix(baseColor.rgb, fogColor, f);
}

void main() {
    vec4 color = v_vColour;
    
    CommonFog(color);
    
    if (color.a < (alphaRef * alphaTest)) {
        discard;
    }
    
    gl_FragColor = color;
}