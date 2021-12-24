global.__cluck_light_ambient = c_white;
global.__cluck_light_color = c_black;
global.__cluck_light_direction = [-1, -1, -1];

// Not currently part of the shader
global.__cluck_fog_enabled = false;
global.__cluck_fog_strength = 1;
global.__cluck_fog_color = c_black;
global.__cluck_fog_start = 256;
global.__cluck_fog_end = 1024;

function cluck_set_light_ambient(color) {
    global.__cluck_light_ambient = color;
}

function cluck_set_fog(fog_enabled, fog_color, fog_strength, fog_start, fog_end) {
    global.__cluck_fog_enabled = fog_enabled;
    global.__cluck_fog_strength = fog_strength;
    global.__cluck_fog_color = fog_color;
    global.__cluck_fog_start = fog_start;
    global.__cluck_fog_end = fog_end;
}

function cluck_set_light_color(color) {
    global.__cluck_light_color = color;
}

function cluck_set_light_direction(dx, dy, dz) {
    var len = -point_distance_3d(0, 0, 0, dx, dy, dz);
    global.__cluck_light_direction = [dx / len, dy / len, dz / len];
}

function cluck_apply(shader) {
    var fog_color = global.__cluck_fog_color;
    var ambient_color = global.__cluck_light_ambient;
    var light_color = global.__cluck_light_color;
    
    shader_set(shader);
    shader_set_uniform_f(shader_get_uniform(shader, "lightAmbientColor"), (ambient_color & 0x0000ff) / 0xff, ((ambient_color & 0x00ff00) >> 8) / 0xff, ((ambient_color & 0xff0000) >> 16) / 0xff);
    shader_set_uniform_f(shader_get_uniform(shader, "lightColor"), (light_color & 0x0000ff) / 0xff, ((light_color & 0x00ff00) >> 8) / 0xff, ((light_color & 0xff0000) >> 16) / 0xff);
    shader_set_uniform_f_array(shader_get_uniform(shader, "lightDirection"), global.__cluck_light_direction);
    
    shader_set_uniform_f(shader_get_uniform(shader, "fogStrength"), global.__cluck_fog_enabled ? global.__cluck_fog_strength : 0);
    shader_set_uniform_f(shader_get_uniform(shader, "fogStart"), global.__cluck_fog_start);
    shader_set_uniform_f(shader_get_uniform(shader, "fogEnd"), global.__cluck_fog_end);
    shader_set_uniform_f(shader_get_uniform(shader, "fogColor"), (fog_color & 0x0000ff) / 0xff, ((fog_color & 0x00ff00) >> 8) / 0xff, ((fog_color & 0xff0000) >> 16) / 0xff);
}