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

if (async_id == global.__async_player_settings) {
    if (!async_status) {
        show_debug_message("aaaaa! could not load the settings data");
        return;
    }
    GAME.LoadSettingsAsyncHandle();
    return;
}

if (async_id == global.__async_map_main) {
    if (!async_status) {
        show_debug_message("aaaaa! could not load the map");
        return;
    }
    GAME.LoadMapAsyncHandle();
    return;
}


if (async_id == global.__async_map_fused) {
    if (!async_status) {
        show_debug_message("aaaaa! could not load the fused map data");
        return;
    }
    
    GAME.fused.raw = global.__async_map_fused_buffer;
    GAME.fused.vbuff = vertex_create_buffer_from_buffer(GAME.fused.raw, global.format);
    vertex_freeze(GAME.fused.vbuff);
    
    if (RELEASE_MODE) {
        buffer_delete(GAME.fused.raw);
        GAME.fused.raw = undefined;
    }
    return;
}
        
if (async_id == global.__async_map_collision) {
    if (!async_status) {
        show_debug_message("aaaaa! could not load the map collision data");
        return;
    }
    
    if (buffer_exists(GAME.fused.collision)) buffer_delete(GAME.fused.collision);
    GAME.fused.collision = global.__async_map_collision_buffer;
    GAME.fused.GenerateCollisionSprite();
    return;
}
        
if (async_id == global.__async_map_ground) {
    if (!async_status) {
        show_debug_message("aaaaa! could not load the map ground data");
        return;
    }
    vertex_delete_buffer(GAME.ground);
    GAME.ground = vertex_create_buffer_from_buffer(global.__async_map_ground_buffer, global.format);
    buffer_delete(global.__async_map_ground_buffer);
    return;
}