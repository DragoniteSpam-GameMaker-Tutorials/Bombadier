attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;                    // (x,y,z)
attribute vec2 in_TextureCoord;              // (u,v)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec4 extra;                        // extra data

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

varying vec3 v_LightWorldNormal;
varying vec3 v_LightWorldPosition;
varying vec3 v_FogCameraRelativePosition;

void CommonLightSetup();
void CommonFogSetup();

void CommonLightSetup() {
    v_LightWorldPosition = (gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1.)).xyz;
    v_LightWorldNormal = normalize(gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.)).xyz;
}

void CommonFogSetup() {
    v_FogCameraRelativePosition = (gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.)).xyz;
}

void main() {
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.);
    v_vTexcoord = in_TextureCoord;
    v_vColour = in_Colour;
    
    CommonLightSetup();
    CommonFogSetup();
}