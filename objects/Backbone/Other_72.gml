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
    
    if (!is_numeric(self.volume_master)) self.volume_master = 100;
    if (!is_numeric(self.screen_size_index)) self.screen_size_index = 1;
    if (!is_numeric(self.current_screen_size.x)) self.current_screen_size.x = room_width;
    if (!is_numeric(self.current_screen_size.y)) self.current_screen_size.y = room_height;
    if (!is_numeric(self.frame_rate_index)) self.frame_rate_index = 1;
    if (!is_numeric(self.resolution_scalar_index)) self.resolution_scalar_index = APP_SURFACE_DEFAULT_SCALE_INDEX;
    if (!is_numeric(self.resolution_scalar)) self.resolution_scalar = self.resolution_scalar_options[self.resolution_scalar_index];
    if (!is_numeric(self.particle_density)) self.particle_density = DEFAULT_PARTICLE_DENSITY;
    
    self.volume_master = clamp(self.volume_master, 0, 100);
    self.screen_size_index = clamp(self.screen_size_index, 0, array_length(self.screen_sizes));
    self.current_screen_size.x = max(self.current_screen_size.x, 10);
    self.current_screen_size.y = max(self.current_screen_size.y, 10);
    self.frame_rate_index = clamp(self.frame_rate_index, 0, array_length(self.frame_rates));
    self.resolution_scalar_index = clamp(self.resolution_scalar_index, 0, array_length(self.resolution_scalar_options));
    self.resolution_scalar = clamp(self.resolution_scalar, 0.05, 1);
    self.particle_density = clamp(self.particle_density, 0, 1);
    
    self.ApplyVolume();
    audio_play_sound(se_ambient, SOUND_PRIORITY_AMBIENT, true);
    self.ApplyScreenSize();
}