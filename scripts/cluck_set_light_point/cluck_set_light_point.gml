/// @param index
/// @param color
/// @param x
/// @param y
/// @param z
/// @param radius
/// @param [radius_inner]
function cluck_set_light_point() {
    var ax = 0;
    var light_index = argument[ax++];
    var light_color = argument[ax++];
    var light_x = argument[ax++];
    var light_y = argument[ax++];
    var light_z = argument[ax++];
    var light_radius = argument[ax++];
    var light_radius_inner = (argument_count == (ax + 1)) ? argument[ax] : 0;
    var position = light_index * __cluck_light_data_size;
    global.__cluck_light_data[position +  0] = light_x;
    global.__cluck_light_data[position +  1] = light_y;
    global.__cluck_light_data[position +  2] = light_z;
    global.__cluck_light_data[position +  3] = CLUCK_LIGHT_POINT;
    // 4 unused
    // 5 unused
    global.__cluck_light_data[position +  6] = light_radius_inner;
    global.__cluck_light_data[position +  7] = light_radius;
    global.__cluck_light_data[position +  8] = (light_color & 0x0000ff) / 0xff;
    global.__cluck_light_data[position +  9] = ((light_color & 0x00ff00) >> 8) / 0xff;
    global.__cluck_light_data[position + 10] = ((light_color & 0xff0000) >> 16) / 0xff;
    // 11 unused
}