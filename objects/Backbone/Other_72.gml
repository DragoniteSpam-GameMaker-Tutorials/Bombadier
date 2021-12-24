for (var i = 0, n = ds_list_size(GAME.env_object_list); i < n; i++) {
    var env_name = GAME.env_object_list[| i];
    var env_data = GAME.env_objects[? env_name];
    
    if (instanceof(env_data) == undefined) {
        if (env_data.buffer == async_load[? "id"]) {
            GAME.env_objects[? env_name] = new ModelData(env_data.name, vertex_create_buffer_from_buffer(env_data.buffer, GAME.format));
            buffer_delete(env_data.buffer);
            return;
        }
    }
}