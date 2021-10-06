#define MAX_LIGHTS 2
#define LIGHT_DIRECTIONAL 1.
#define LIGHT_POINT 2.
#define LIGHT_SPOT 3.
#define LIGHT_TYPES 4.
#define PI 3.141592653

// not sure why gm_AlphaRefValue does not work so we have to do this ourselves
uniform float alphaRef;
uniform float alphaTest;

uniform vec3 lightAmbientColor;
uniform vec4 lightData[MAX_LIGHTS * 3];
uniform float fogStrength;
uniform float fogStart;
uniform float fogEnd;
uniform vec3 fogColor;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_LightWorldNormal;
varying vec3 v_LightWorldPosition;
varying vec3 v_FogCameraRelativePosition;

void CommonLightEvaluate(int i, inout vec4 finalColor);
void CommonLight(inout vec4 baseColor);
void CommonFog(inout vec4 baseColor);

void CommonLight(inout vec4 baseColor) {
    vec4 lightColor = vec4(lightAmbientColor, 1.);
    
    for (int i = 0; i < MAX_LIGHTS; i++) {
        CommonLightEvaluate(i, lightColor);
    }
    
    baseColor *= clamp(lightColor, vec4(0.), vec4(1.));
}

void CommonLightEvaluate(int i, inout vec4 finalColor) {
    vec3 lightPosition = lightData[i * 3].xyz;
    float type = mod(lightData[i * 3].w, LIGHT_TYPES);
    vec4 lightExt = lightData[i * 3 + 1];
    vec4 lightColor = lightData[i * 3 + 2];
    
    if (type == LIGHT_DIRECTIONAL) {
        // directional light: [dx, dy, dz, type], [0, 0, 0, 0], [r, g, b, 0]
        vec3 lightIncoming = -normalize(lightPosition);
        float NdotL = max(dot(v_LightWorldNormal, lightIncoming), 0.);
        finalColor += lightColor * NdotL;
    } else if (type == LIGHT_POINT) {
        // point light: [x, y, z, type], [0, 0, range_inner, range_outer], [r, g, b, 0]
        float rangeInner = lightExt.z;
        float rangeOuter = lightExt.w;
        vec3 lightIncoming = v_LightWorldPosition - lightPosition;
        float dist = length(lightIncoming);
        lightIncoming = normalize(-lightIncoming);
        float att = clamp((rangeOuter - dist) / max(rangeOuter - rangeInner, 0.000001), 0., 1.);
        
        float NdotL = max(dot(v_LightWorldNormal, lightIncoming), 0.);
        
        finalColor += att * lightColor * NdotL;
    } else if (type == LIGHT_SPOT) {
        // spot light: [x, y, z, type | cutoff_inner], [dx, dy, dz, range], [r, g, b, cutoff_outer]
        float range = lightExt.w;
        vec3 sourceDir = -normalize(lightExt.xyz);
        float cutoff = lightColor.w;
        float innerCutoff = (lightData[i * 3].w - type) / 512.;
        
        vec3 lightIncoming = v_LightWorldPosition - lightPosition;
        float dist = length(lightIncoming);
        lightIncoming = normalize(-lightIncoming);
        float NdotL = max(dot(v_LightWorldNormal, lightIncoming), 0.);
        
        float lightAngleDifference = max(dot(lightIncoming, sourceDir), 0.);
        
        float f = clamp((lightAngleDifference - cutoff) / max(innerCutoff - cutoff, 0.000001), 0., 1.);
        float att = f * max((range - dist) / range, 0.);
        
        lightColor.a = 1.;
        finalColor += att * lightColor * NdotL;
    }
}

void CommonFog(inout vec4 baseColor) {
    float dist = length(v_FogCameraRelativePosition);
    float f = clamp((dist - fogStart) / (fogEnd - fogStart) * fogStrength, 0., 1.);
    baseColor.rgb = mix(baseColor.rgb, fogColor, f);
}

uniform sampler2D samplerCollision;
uniform vec2 samplerCollisionScale;
uniform float samplerCollisionStrength;

void main() {
    vec4 color = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    
    CommonLight(color);
    CommonFog(color);
    
    if (color.a < (alphaRef * alphaTest)) {
        discard;
    }
    
    vec4 colorFromCollision = texture2D(samplerCollision, vec2(v_LightWorldPosition.x, v_LightWorldPosition.y) / samplerCollisionScale);
    gl_FragColor = mix(color, colorFromCollision, samplerCollisionStrength);
}