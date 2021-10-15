attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;                    // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)

#define MAX_LIGHTS 2
#define LIGHT_DIRECTIONAL 1.
#define LIGHT_POINT 2.
#define LIGHT_SPOT 3.
#define LIGHT_TYPES 4.
#define PI 3.141592653

uniform vec3 lightAmbientColor;
uniform vec4 lightData[MAX_LIGHTS * 3];

varying vec4 v_vColour;

varying vec3 v_FogCameraRelativePosition;

void CommonLightEvaluate(int i, inout vec4 finalColor, in vec3 position, in vec3 normal);
void CommonLight(inout vec4 baseColor, in vec3 position, in vec3 normal);
void CommonFogSetup();

void CommonLight(inout vec4 baseColor, in vec3 position, in vec3 normal) {
    vec4 lightColor = vec4(lightAmbientColor, 1.);
    
    for (int i = 0; i < MAX_LIGHTS; i++) {
        CommonLightEvaluate(i, lightColor, position, normal);
    }
    
    baseColor *= clamp(lightColor, vec4(0.), vec4(1.));
}

void CommonLightEvaluate(int i, inout vec4 finalColor, in vec3 position, in vec3 normal) {
    vec3 lightPosition = lightData[i * 3].xyz;
    float type = mod(lightData[i * 3].w, LIGHT_TYPES);
    vec4 lightExt = lightData[i * 3 + 1];
    vec4 lightColor = lightData[i * 3 + 2];
    
    if (type == LIGHT_DIRECTIONAL) {
        // directional light: [dx, dy, dz, type], [0, 0, 0, 0], [r, g, b, 0]
        vec3 lightIncoming = -normalize(lightPosition);
        float NdotL = max(dot(normal, lightIncoming), 0.);
        finalColor += lightColor * NdotL;
    } else if (type == LIGHT_POINT) {
        // point light: [x, y, z, type], [0, 0, range_inner, range_outer], [r, g, b, 0]
        float rangeInner = lightExt.z;
        float rangeOuter = lightExt.w;
        vec3 lightIncoming = position - lightPosition;
        float dist = length(lightIncoming);
        lightIncoming = normalize(-lightIncoming);
        float att = clamp((rangeOuter - dist) / max(rangeOuter - rangeInner, 0.000001), 0., 1.);
        
        float NdotL = max(dot(normal, lightIncoming), 0.);
        
        finalColor += att * lightColor * NdotL;
    } else if (type == LIGHT_SPOT) {
        // spot light: [x, y, z, type | cutoff_inner], [dx, dy, dz, range], [r, g, b, cutoff_outer]
        float range = lightExt.w;
        vec3 sourceDir = -normalize(lightExt.xyz);
        float cutoff = lightColor.w;
        float innerCutoff = (lightData[i * 3].w - type) / 512.;
        
        vec3 lightIncoming = position - lightPosition;
        float dist = length(lightIncoming);
        lightIncoming = normalize(-lightIncoming);
        float NdotL = max(dot(normal, lightIncoming), 0.);
        
        float lightAngleDifference = max(dot(lightIncoming, sourceDir), 0.);
        
        float f = clamp((lightAngleDifference - cutoff) / max(innerCutoff - cutoff, 0.000001), 0., 1.);
        float att = f * max((range - dist) / range, 0.);
        
        lightColor.a = 1.;
        finalColor += att * lightColor * NdotL;
    }
}

void CommonFogSetup() {
    v_FogCameraRelativePosition = (gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.)).xyz;
}

void main() {
    vec4 worldPosition = gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1.);
    vec4 worldNormal = gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.);
    vec4 finalColor = vec4(in_Colour);
    CommonLight(finalColor, worldPosition.xyz, worldNormal.xyz);
    finalColor.a = in_Colour.a;
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.);
    v_vColour = finalColor;
    
    CommonFogSetup();
}