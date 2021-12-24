var async_id = async_load[? "id"];
var async_status = async_load[? "status"]

for (var i = 0, n = ds_list_size(global.env_object_list); i < n; i++) {
    var env_name = global.env_object_list[| i];
    var env_data = global.env_objects[? env_name];
    
    if (instanceof(env_data) == undefined && env_data.id == async_id) {
        if (!async_status) {
            show_debug_message("aaaaa! could not load " + env_name);
            return;
        }
        global.env_objects[? env_name] = new ModelData(env_data.name, vertex_create_buffer_from_buffer(env_data.buffer, global.format));
        buffer_delete(env_data.buffer);
        return;
    }
}

if (async_id == global.__async_player_save) {
    if (!async_status) {
        show_debug_message("aaaaa! could not load the player save");
        return;
    }
    self.player_save = new SaveData(json_parse(buffer_read(global.__async_player_save_buffer, buffer_string)));
    buffer_delete(global.__async_player_save_buffer);
    return;
}