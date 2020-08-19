/// @param enabled
/// @param color
/// @param strength
/// @param start
/// @param end
function cluck_set_fog() {
    var ax = 0;
    var fog_enabled = argument[ax++];
    var fog_color = argument[ax++];
    var fog_strength = argument[ax++];
    var fog_start = argument[ax++];
    var fog_end = argument[ax++];
    global.__cluck_fog_enabled = fog_enabled;
    global.__cluck_fog_strength = fog_strength;
    global.__cluck_fog_color = fog_color;
    global.__cluck_fog_start = fog_start;
    global.__cluck_fog_end = fog_end;
}