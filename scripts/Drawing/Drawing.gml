function TransparentRenderObject(matrix, vbuff, shader, shader_uniforms) constructor {
    self.matrix = matrix;
    self.vbuff = vbuff;
    self.shader = shader;
    self.shader_uniforms = shader_uniforms;
};

function surface_validate(original, width, height) {
    if (!surface_exists(original)) {
        return surface_create(width, height);
    }
    
    if (surface_get_width(original) != width || surface_get_height(original) != height) {
        surface_free(original);
        return surface_create(width, height);
    }
    
    return original;
}