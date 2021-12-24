uniform vec3 lightAmbientColor;
uniform vec3 lightColor;
uniform vec3 lightDirection;
uniform float fogStrength;
uniform float fogStart;
uniform float fogEnd;
uniform vec3 fogColor;

varying vec4 v_vColour;
varying vec3 v_LightWorldNormal;
varying vec3 v_LightWorldPosition;

uniform sampler2D samplerCollision;
uniform vec2 samplerCollisionScale;
uniform float samplerCollisionStrength;

void main() {
    vec3 color = v_vColour.rgb;
    
    vec3 lightAdjustment = vec3(lightAmbientColor);
    float NdotL = max(dot(v_LightWorldNormal, lightDirection), 0.0);
    lightAdjustment += lightColor * NdotL;
    color *= clamp(lightAdjustment, vec3(0), vec3(1));
    
    vec4 cc = texture2D(samplerCollision, vec2(v_LightWorldPosition.x, v_LightWorldPosition.y) / samplerCollisionScale);
    gl_FragColor = vec4(mix(color, vec3(0), clamp((1.0 - (cc.r + cc.g + cc.b) / 3.0) * samplerCollisionStrength, 0.0, 1.0)), v_vColour.a);
}