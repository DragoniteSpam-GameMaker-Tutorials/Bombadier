/// @param shader
function cluck_apply(shader) {
    var fog_color = global.__cluck_fog_color;
    var ambient_color = global.__cluck_light_ambient;
    
    shader_set(shader);
    shader_set_uniform_f(shader_get_uniform(shader, "alphaRef"), global.__cluck_alpha_ref);
    shader_set_uniform_f(shader_get_uniform(shader, "alphaTest"), global.__cluck_alpha_test);
    
    shader_set_uniform_f(shader_get_uniform(shader, "lightAmbientColor"), (ambient_color & 0x0000ff) / 0xff, ((ambient_color & 0x00ff00) >> 8) / 0xff, ((ambient_color & 0xff0000) >> 16) / 0xff);
    shader_set_uniform_f_array(shader_get_uniform(shader, "lightData"), global.__cluck_light_data);
    
    shader_set_uniform_f(shader_get_uniform(shader, "fogStrength"), global.__cluck_fog_enabled ? global.__cluck_fog_strength : 0);
    shader_set_uniform_f(shader_get_uniform(shader, "fogStart"), global.__cluck_fog_start);
    shader_set_uniform_f(shader_get_uniform(shader, "fogEnd"), global.__cluck_fog_end);
    shader_set_uniform_f(shader_get_uniform(shader, "fogColor"), (fog_color & 0x0000ff) / 0xff, ((fog_color & 0x00ff00) >> 8) / 0xff, ((fog_color & 0xff0000) >> 16) / 0xff);
}