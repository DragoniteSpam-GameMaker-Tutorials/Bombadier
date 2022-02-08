uniform float fogStrength;
uniform float fogStart;
uniform float fogEnd;
uniform vec3 fogColor;

varying vec4 v_vColour;

uniform sampler2D samplerCollision;
uniform vec2 samplerCollisionScale;
uniform float samplerCollisionStrength;

varying vec3 v_LightWorldPosition;

void main() {
    vec4 cc = texture2D(samplerCollision, v_LightWorldPosition.xy / samplerCollisionScale);
    gl_FragColor = vec4(mix(v_vColour.rgb, vec3(0), clamp((1.0 - (cc.r + cc.g + cc.b) / 3.0) * samplerCollisionStrength, 0.0, 1.0)), v_vColour.a);
}