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

uniform sampler2D samplerCollision;
uniform vec2 samplerCollisionScale;
uniform float samplerCollisionStrength;

varying vec3 v_LightWorldPosition;

void main() {
    vec4 color = v_vColour;
    
    //CommonFog(color);
    
    if (color.a < (alphaRef * alphaTest)) {
        discard;
    }
    
    vec4 colorFromCollision = texture2D(samplerCollision, vec2(v_LightWorldPosition.x, v_LightWorldPosition.y) / samplerCollisionScale);
    
    gl_FragColor = color;
    gl_FragColor.rgb = mix(gl_FragColor.rgb, vec3(0), clamp((1.0 - colorFromCollision.r) * samplerCollisionStrength, 0.0, 1.0));
}