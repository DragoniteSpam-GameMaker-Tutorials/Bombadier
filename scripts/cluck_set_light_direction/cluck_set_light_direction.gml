/// @param index
/// @param color
/// @param dx
/// @param dy
/// @param dz
function cluck_set_light_direction() {
    var ax = 0;
    var light_index = argument[ax++];
    var light_color = argument[ax++];
    var light_dx = argument[ax++];
    var light_dy = argument[ax++];
    var light_dz = argument[ax++];
    var position = light_index * __cluck_light_data_size;
    global.__cluck_light_data[position +  0] = light_dx;
    global.__cluck_light_data[position +  1] = light_dy;
    global.__cluck_light_data[position +  2] = light_dz;
    global.__cluck_light_data[position +  3] = CLUCK_LIGHT_DIRECTIONAL;
    // 4 unused
    // 5 unused
    // 6 unused
    // 7 unused
    global.__cluck_light_data[position +  8] = (light_color & 0x0000ff) / 0xff;
    global.__cluck_light_data[position +  9] = ((light_color & 0x00ff00) >> 8) / 0xff;
    global.__cluck_light_data[position + 10] = ((light_color & 0xff0000) >> 16) / 0xff;
    // 11 unused
}