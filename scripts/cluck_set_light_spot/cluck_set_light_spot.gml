/// @param index 
/// @param color 
/// @param x
/// @param y
/// @param z
/// @param dx
/// @param dy
/// @param dz
/// @param range
/// @param cutoff
/// @param [cutoff_inner]
function cluck_set_light_spot() {
    var ax = 0;
    var light_index = argument[ax++];
    var light_color = argument[ax++];
    var light_x = argument[ax++];
    var light_y = argument[ax++];
    var light_z = argument[ax++];
    var light_dx = argument[ax++];
    var light_dy = argument[ax++];
    var light_dz = argument[ax++];
    var light_range = argument[ax++];
    var light_cutoff = argument[ax++];
    var light_cutoff_inner = (argument_count == (ax + 1)) ? argument[ax] : 0;
    var position = light_index * __cluck_light_data_size;
    global.__cluck_light_data[position +  0] = light_x;
    global.__cluck_light_data[position +  1] = light_y;
    global.__cluck_light_data[position +  2] = light_z;
    global.__cluck_light_data[position +  3] = CLUCK_LIGHT_SPOT | floor(dcos(light_cutoff_inner) * 128) * 4;
    global.__cluck_light_data[position +  4] = light_dx;
    global.__cluck_light_data[position +  5] = light_dy;
    global.__cluck_light_data[position +  6] = light_dz;
    global.__cluck_light_data[position +  7] = light_range;
    global.__cluck_light_data[position +  8] = (light_color & 0x0000ff) / 0xff;
    global.__cluck_light_data[position +  9] = ((light_color & 0x00ff00) >> 8) / 0xff;
    global.__cluck_light_data[position + 10] = ((light_color & 0xff0000) >> 16) / 0xff;
    global.__cluck_light_data[position + 11] = dcos(light_cutoff);
}