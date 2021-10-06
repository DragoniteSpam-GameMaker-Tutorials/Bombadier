#macro GAME Backbone.game
show_debug_overlay(true);

application_surface_draw_enable(false);

function Game() constructor {
    Particles.init();
    
    camera = new Camera();
    
    #region graphical stuff
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_normal();
    vertex_format_add_texcoord();
    vertex_format_add_color();
    format = vertex_format_end();
    
    ground = vertex_create_buffer();
    vertex_begin(ground, format);
    
    // 0
    vertex_position_3d(ground, 0, 0, 0);
    vertex_normal(ground, 0, 0, 1);
    vertex_texcoord(ground, 0, 0);
    vertex_colour(ground, c_white, 1);
    // 1
    vertex_position_3d(ground, FIELD_WIDTH, 0, 0);
    vertex_normal(ground, 0, 0, 1);
    vertex_texcoord(ground, 1, 0);
    vertex_colour(ground, c_white, 1);
    // 2
    vertex_position_3d(ground, FIELD_WIDTH, FIELD_HEIGHT * 1.5, 0);
    vertex_normal(ground, 0, 0, 1);
    vertex_texcoord(ground, 1, 1);
    vertex_colour(ground, c_white, 1);
    // 3
    vertex_position_3d(ground, FIELD_WIDTH, FIELD_HEIGHT * 1.5, 0);
    vertex_normal(ground, 0, 0, 1);
    vertex_texcoord(ground, 1, 1);
    vertex_colour(ground, c_white, 1);
    // 4
    vertex_position_3d(ground, 0, FIELD_HEIGHT * 1.5, 0);
    vertex_normal(ground, 0, 0, 1);
    vertex_texcoord(ground, 0, 1);
    vertex_colour(ground, c_white, 1);
    // 5
    vertex_position_3d(ground, 0, 0, 0);
    vertex_normal(ground, 0, 0, 1);
    vertex_texcoord(ground, 0, 0);
    vertex_colour(ground, c_white, 1);
    
    vertex_end(ground);
    vertex_freeze(ground);
    #endregion
    
    fused = {
        raw: undefined,
        vbuff: undefined,
        collision: buffer_create((FIELD_WIDTH / GRID_CELL_SIZE) * (FIELD_HEIGHT / GRID_CELL_SIZE), buffer_fixed, 1),
    };
    
    #region environment objects
    env_objects = ds_map_create();
    env_object_list = ds_list_create();
    for (var file = file_find_first("environment/*.vbuff", 0); file != ""; file = file_find_next()) {
        //var vbuff = load_model("environment/" + file, format);
        var buffer = buffer_load("environment/" + file);
        var obj_name = string_replace(file, ".000.vbuff", "");
        env_objects[? obj_name] = new ModelData("environment/" + file, vertex_create_buffer_from_buffer(buffer, format));
        buffer_delete(buffer);
        ds_list_add(env_object_list, obj_name);
    }
    collision_grid = ds_grid_create(10, 10);
    #endregion
    
    test_ball = load_model("testball.d3d", format).vbuff;
    skybox_cube = load_model("skybox.d3d", format).vbuff;
    
    magnifying_glass_beam = load_model("tower-glass-beam.d3d", format).vbuff;
    magnifying_glass_glass = load_model("tower-glass-glass.d3d", format).vbuff;
    
    #region database
    foe_ant =       new FoeData("Ant",               5, 0, 0, 100, 1, 2, spr_foe_ant,           load_model("foe.d3d", format), EntityFoe);
    foe_pillbugs =  new FoeData("Pillbug",          10, 1, 0,  50, 1, 3, spr_foe_pillbug,       load_model("foe.d3d", format), EntityFoe);
    foe_gnat =    new FoeData("Midge",               1, 0, 1, 100, 1, 2, spr_foe_gnat,          load_model("foe.d3d", format), EntityFoeMidge);
    foe_aphid = new FoeData("Aphid",                 3, 0, 0,  50, 1, 1, spr_foe_aphid,         load_model("foe.d3d", format), EntityFoe);
    foe_grasshopper = new FoeData("Grasshopper",    20, 0, 0, 150, 2, 8, spr_foe_grasshopper,   load_model("foe.d3d", format), EntityFoe);
    
    bullet_pebble =     new BulletData("Pebble", load_model("testbullet.d3d", format), function(target) { });
    bullet_fire =       new BulletData("Fire", load_model("bullet-fire.d3d", format), function(target) {
        if (self.parent_tower.level >= 3) {
            target.Burn(BURN_DURATION * 2, self.parent_tower);
        } else {
            target.Burn(BURN_DURATION, self.parent_tower);
        }
    });
    bullet_bug_spray =  new BulletData("Bug Spray", -1, function(target) {
        target.Poison(POISON_DURATION, self.parent_tower);
    });
    bullet_fly_paper =  new BulletData("Fly Paper", load_model("flypaper.d3d", format), function(target) {
        if (self.parent_tower.level >= 3) {
            target.Immobilize(self.parent_tower);
            self.parent_tower.stats.stuns++;
        }
        
        if (self.parent_tower.level >= 2) {
            target.Slow(SLOW_DURATION * 1.5, SLOW_FACTOR * 0.75, self.parent_tower);
        } else {
            target.Slow(SLOW_DURATION, SLOW_FACTOR, self.parent_tower);
        }
    });
    bullet_bird =       new BulletData("Bird", load_model("bullet-bird-down.d3d", format), function(target) { });
    bullet_bird.anim_frames = [
        load_model("bullet-bird-down.d3d", format),
        load_model("bullet-bird-up.d3d", format)
    ];
    
    tower_pebbles =     new TowerData("Pebble Shooter",
                        /* rate  */ [1, 1, 2],
                        /* range */ [3 * 32, 3 * 32, 3 * 32],
                        /* dmg   */ [1, 2, 2],
                        /* cost  */ [10, 40, 50],
                            load_model("tower-pebble.d3d", format), bullet_pebble
                        );
    tower_fire =        new TowerData("Fire Shooter",
                        /* rate  */ [0.5, 0.75, 0.5],
                        /* range */ [3 * 32, 3.5 * 32, 3.5 * 32],
                        /* dmg   */ [1, 1, 1],
                        /* cost  */ [15, 40, 60],
                            load_model("tower-fire.d3d", format), bullet_fire
                        );
    
    tower_magnify =     new TowerData("Magnifying Glass",
                        /* rate  */ [0, 0, 0],
                        /* range */ [2.5 * 32, 3 * 32, 3 * 32],
                        /* dmg   */ [5, 8, 8],
                        /* cost  */ [50, 150, 200],
                            load_model("tower-glass.d3d", format), bullet_pebble
                        );
    tower_spray =       new TowerData("Bug Spray",
                        /* rate  */ [1, 1, 2],
                        /* range */ [4 * 32, 4 * 32, 4 * 32],
                        /* dmg   */ [0, 0, 0],
                        /* cost  */ [40, 60, 80],
                            load_model("tower-spray.d3d", format), bullet_bug_spray
                        );
    tower_flypaper =    new TowerData("Fly Paper Dispenser",
                        /* rate  */ [1, 1, 1],
                        /* range */ [4 * 32, 4 * 32, 4 * 32],
                        /* dmg   */ [0, 0, 0],
                        /* cost  */ [60, 100, 100],
                            load_model("tower-flypaper.d3d", format), bullet_fly_paper
                        );
    tower_bird =        new TowerData("Bird Nest",
                        /* rate  */ [0.5, 1, 1],
                        /* range */ [4 * 32, 4 * 32, 4 * 32],
                        /* dmg   */ [8, 12, 12],
                        /* cost  */ [60, 80, 120],
                            load_model("tower-bird.d3d", format), bullet_bird
                        );
    #endregion
    
    collision_surface = -1;
    path_nodes = array_create(0);
    
    all_entities = ds_list_create();
    all_foes = ds_list_create();
    all_towers = ds_list_create();
    all_env_entities = ds_list_create();
    
    all_waves = ds_queue_create();
    wave_active = ds_list_create();
    
    all_ui_elements = { };
    current_pause_screen = "UI_Game_Pause_Menu";
    current_title_screen = "UI_Title_Screen";
    current_game_over_screen = "UI_Game_Over_Win";
    current_level_index = 0;
    with (ParentUI) {
        var layers = other.all_ui_elements[$ string(depth)];
        if (layers == undefined) {
            layers = {
                elements: ds_list_create(),
                block_raycast: undefined,
                Render: function() {
                    block_raycast.Render();
                    for (var i = 0; i < ds_list_size(elements); i++) {
                        elements[| i].Render();
                    }
                },
            };
            other.all_ui_elements[$ string(depth)] = layers;
        }
        ds_list_add(layers.elements, id);
        visible = false;
    }
    with (UIBlockRaycast) {
        var layers = other.all_ui_elements[$ string(depth)];
        if (layers != undefined) {
            layers.block_raycast = id;
            visible = false;
        } else {
            instance_destroy();
        }
    }
    
    semi_transparent_stuff = ds_list_create();
    
    #region settings stuff
    volume_master = 100;
    screen_sizes = [
        { x: 1280, y: 720 },
        { x: 1366, y: 768 },
        { x: 1600, y: 900 },
        { x: 1920, y: 1080 },
        { x: 2560, y: 1440 },
    ];
    screen_size_index = 1;
    current_screen_size = { x: room_width, y: room_height };
    
    frame_rates = [30, 60, 120, 144];
    frame_rate_index = 1;
    
    resolution_scalar_options = [0.25, 0.33, 0.4, 0.5, 0.66, 0.75, 1];
    resolution_scalar_index = APP_SURFACE_DEFAULT_SCALE_INDEX;
    resolution_scalar = resolution_scalar_options[resolution_scalar_index];
    outline_surface = surface_create(OUTLINE_SURFACE_WIDTH, OUTLINE_SURFACE_HEIGHT);
    
    // don't get rid of this, please
    display_set_gui_maximize();
    game_set_speed(TARGET_FPS, gamespeed_fps);
    
    ApplyScreenSize = function() {
        window_set_size(current_screen_size.x, current_screen_size.y);
        surface_resize(application_surface, current_screen_size.x * resolution_scalar, current_screen_size.y * resolution_scalar);
    };
    
    ApplyVolume = function() {
        audio_set_master_gain(0, self.volume_master / 100);
    };
    
    SaveSettings = function() {
        var json = {
            volume_master: self.volume_master,
            screen_size_index: self.screen_size_index,
            current_screen_size: self.current_screen_size,
            fullscreen: window_get_fullscreen(),
            frame_rate_index: self.frame_rate_index,
            frames_per_second: game_get_speed(gamespeed_fps),
            resolution_scalar_index: self.resolution_scalar_index,
            resolution_scalar: self.resolution_scalar,
        };
        var save_buffer = buffer_create(100, buffer_grow, 1);
        buffer_write(save_buffer, buffer_text, json_stringify(json));
        buffer_save_ext(save_buffer, "settings.json", 0, buffer_tell(save_buffer));
        buffer_delete(save_buffer);
    };
    
    try {
        var load_buffer = buffer_load("settings.json");
        var json = json_parse(buffer_read(load_buffer, buffer_text));
        buffer_delete(load_buffer);
        
        self.volume_master = json.volume_master;
        self.screen_size_index = json.screen_size_index;
        self.current_screen_size.x = json.current_screen_size.x;
        self.current_screen_size.y = json.current_screen_size.y;
        window_set_fullscreen(json.fullscreen);
        self.frame_rate_index = json.frame_rate_index;
        game_set_speed(json.frames_per_second, gamespeed_fps);
        self.resolution_scalar_index = json.resolution_scalar_index;
        self.resolution_scalar = json.resolution_scalar;
        
        if (!is_numeric(self.volume_master)) self.volume_master = 100;
        if (!is_numeric(self.screen_size_index)) self.screen_size_index = 1;
        if (!is_numeric(self.current_screen_size.x)) self.current_screen_size.x = room_width;
        if (!is_numeric(self.current_screen_size.y)) self.current_screen_size.y = room_height;
        if (!is_numeric(self.frame_rate_index)) self.frame_rate_index = 1;
        if (!is_numeric(self.resolution_scalar_index)) self.resolution_scalar_index = APP_SURFACE_DEFAULT_SCALE_INDEX;
        if (!is_numeric(self.resolution_scalar)) self.resolution_scalar = self.resolution_scalar_options[self.resolution_scalar_index];
        
        self.volume_master = clamp(self.volume_master, 0, 100);
        self.screen_size_index = clamp(self.screen_size_index, 0, array_length(self.screen_sizes));
        self.current_screen_size.x = max(self.current_screen_size.x, 10);
        self.current_screen_size.y = max(self.current_screen_size.y, 10);
        self.frame_rate_index = clamp(self.frame_rate_index, 0, array_length(self.frame_rates));
        self.resolution_scalar_index = clamp(self.resolution_scalar_index, 0, array_length(self.resolution_scalar_options));
        self.resolution_scalar = clamp(self.resolution_scalar, 0.05, 1);
        
        self.ApplyVolume();
    } catch (e) {
        show_debug_message("Settings could not be loaded");
    }
    
    audio_play_sound(se_ambient, SOUND_PRIORITY_AMBIENT, true);
    
    self.ApplyScreenSize();
    #endregion
    
    Initialize = function() {
        for (var i = ds_list_size(all_foes) - 1; i >= 0; i--) {
            all_foes[| i].Destroy();
        }
        for (var i = ds_list_size(all_towers) - 1; i >= 0; i--) {
            all_towers[| i].RemoveCollision();
            all_towers[| i].Destroy();
        }
        ds_list_clear(all_towers);
        ds_list_clear(all_foes);
        
        game_speed = 1;
        
        player_money = 75;
        player_health = 10;
        
        player_cursor_over_ui = false;
        player_tower_spawn = undefined;
        
        selected_entity = undefined;
        selected_entity_hover = undefined;
        editor_hover_entity = undefined;
        editor_path_mode = false;
        editor_collision_mode = false;
        editor_model_index = 0;
        
        DefineAllWaves(all_waves);
        ds_list_clear(wave_active);
        wave_total = ds_queue_size(all_waves);
        wave_countdown = WAVE_WARMUP_COUNTDOWN;
        waves_remain = true;
        
        gameplay_mode = GameModes.GAMEPLAY;
    };
    
    GoToLevel = function(level_index) {
        self.current_level_index = level_index;
        self.LoadMap("maps/level" + string(level_index) + ".bug");
        self.Initialize();
        self.camera.from = CAMERA_FROM_LEVEL;
        self.camera.to = CAMERA_TO_LEVEL;
    };
    
    GoToNextLevel = function() {
        if (self.current_level_index < MAX_LEVEL_INDEX) {
            self.current_level_index++;
            self.LoadMap("maps/level" + string(self.current_level_index) + ".bug");
            self.Initialize();
            self.camera.from = CAMERA_FROM_LEVEL;
            self.camera.to = CAMERA_TO_LEVEL;
        }
    };
    
    GoToTitle = function() {
        self.CallEntityGameOver();
        self.LoadMap("maps/title.bug");
        self.gameplay_mode = GameModes.TITLE;
        self.current_title_screen = "UI_Title_Screen";
        self.camera.from = CAMERA_FROM_TITLE;
        self.camera.to = CAMERA_TO_TITLE;
    };
    
    enum GameModes {
        TITLE, GAMEPLAY, EDITOR, PAUSED, GAME_OVER,
    }
    
    gameplay_mode = GameModes.TITLE;
    
    SetGameSpeed = function(speed) {
        self.game_speed = speed;
    };
    
    SendInWave = function() {
        if (ds_queue_empty(all_waves)) {
            waves_remain = false;
            wave_countdown = -1;
        } else {
            wave_countdown = WAVE_COUNTDOWN;
            var wave_current = ds_queue_dequeue(all_waves);
            wave_current.Launch();
            ds_list_add(wave_active, wave_current);
        }
    };
    
    SendInWaveEarly = function() {
        if (!ds_queue_empty(all_waves)) {
            if (wave_countdown > 0) {
                player_money += ceil(wave_countdown);
            } else {
                //player_money += WAVE_COUNTDOWN;
            }
        }
        SendInWave();
    };
    
    PlayerDamage = function(amount) {
        player_health -= max(amount, 0);
        if (player_health <= 0) {
            self.gameplay_mode = GameModes.GAME_OVER;
            self.current_game_over_screen = "UI_Game_Over_Lose";
            self.CallEntityGameOver();
        }
    };
    
    CheckGameOver = function() {
        if (!ds_list_empty(self.wave_active)) return;
        if (!ds_queue_empty(self.all_waves)) return;
        if (!ds_list_empty(self.all_foes)) return;
        self.gameplay_mode = GameModes.GAME_OVER;
        self.current_game_over_screen = "UI_Game_Over_Win";
        self.CallEntityGameOver();
    };
    
    CallEntityGameOver = function() {
        for (var i = ds_list_size(self.all_entities) - 1; i >= 0; i--) {
            self.all_entities[| i].GameOver();
        }
    };
    
    SpawnTower = function() {
        var position = camera.GetFloorIntersect();
        
        if (position) {
            if (player_tower_spawn && player_money >= player_tower_spawn.class.cost[0] && CollisionFree(player_tower_spawn)) {
                player_money -= player_tower_spawn.class.cost[0];
                player_tower_spawn.AddToMap();
                self.selected_entity = player_tower_spawn;
                player_tower_spawn = undefined;
                audio_play_sound(se_build, SOUND_PRIORITY_GAMEPLAY_HIGH, false);
            }
        }
    };
    
    CollisionFree = function(entity) {
        var xmin = min(entity.collision.p1.x * entity.scale.x, entity.collision.p2.x * entity.scale.x);
        var ymin = min(entity.collision.p1.y * entity.scale.y, entity.collision.p2.y * entity.scale.y);
        var xmax = max(entity.collision.p1.x * entity.scale.x, entity.collision.p2.x * entity.scale.x);
        var ymax = max(entity.collision.p1.y * entity.scale.y, entity.collision.p2.y * entity.scale.y);
        var cell_xmin = xmin div GRID_CELL_SIZE;
        var cell_ymin = ymin div GRID_CELL_SIZE;
        var cell_xmax = ceil(xmax / GRID_CELL_SIZE);
        var cell_ymax = ceil(ymax / GRID_CELL_SIZE);
        
        if (xmin < 0 || ymin < 0 || xmax >= FIELD_WIDTH || ymax >= FIELD_WIDTH) {
            return false;
        }
        
        if (ds_grid_get_max(collision_grid, cell_xmin, cell_ymin, cell_xmax, cell_ymax) != GRID_COLLISION_FREE) {
            return false;
        }
        
        for (var i = cell_xmin; i <= cell_xmax; i++) {
            for (var j = cell_ymin; j <= cell_ymax; j++) {
                var addr = (j * ceil(FIELD_WIDTH / GRID_CELL_SIZE)) + i;
                if (!buffer_peek(fused.collision, addr, buffer_u8)) {
                    return false;
                }
            }
        }
        
        return true;
    };
    
    CollisionIsPath = function(entity) {
        var xmin = min(entity.collision.p1.x * entity.scale.x, entity.collision.p2.x * entity.scale.x);
        var ymin = min(entity.collision.p1.y * entity.scale.y, entity.collision.p2.y * entity.scale.y);
        var xmax = max(entity.collision.p1.x * entity.scale.x, entity.collision.p2.x * entity.scale.x);
        var ymax = max(entity.collision.p1.y * entity.scale.y, entity.collision.p2.y * entity.scale.y);
        var cell_xmin = xmin div GRID_CELL_SIZE;
        var cell_ymin = ymin div GRID_CELL_SIZE;
        var cell_xmax = ceil(xmax / GRID_CELL_SIZE);
        var cell_ymax = ceil(ymax / GRID_CELL_SIZE);
        return (ds_grid_get_max(collision_grid, cell_xmin, cell_ymin, cell_xmax, cell_ymax) == GRID_COLLISION_PATH);
    };
    
    GetRaycastBlocked = function() {
        var ui_layer = ActiveGUILayer();
        if (ui_layer != undefined) {
            var mx = window_mouse_get_x();
            var my = window_mouse_get_y();
            var block = ui_layer.block_raycast;
            if (mx > block.bbox_left && mx < block.bbox_right && my > block.bbox_top && my < block.bbox_bottom) {
                return true;
            }
        }
        return false;
    };
    
    GetUnderCursor = function(entity_list) {
        if (GetRaycastBlocked()) {
            return undefined;
        }
        
        var ray = new Ray(camera.from, camera.mouse_cast);
        var thing_selected = undefined;
        var n = is_array(entity_list) ? array_length(entity_list) : ds_list_size(entity_list);
        for (var i = 0; i < n; i++) {
            var tower = is_array(entity_list) ? entity_list[i] : entity_list[| i];
            if (tower != undefined) {
                if (tower.raycast(tower.collision, ray)) {
                    if (!thing_selected) {
                        thing_selected = tower;
                    } else {
                        var this_tower_dist = point_distance_3d(tower.position.x, tower.position.y, tower.position.z, camera.from.x, camera.from.y, camera.from.z);
                        var other_tower_dist = point_distance_3d(thing_selected.position.x, thing_selected.position.y, thing_selected.position.z, camera.from.x, camera.from.y, camera.from.z);
                        if (this_tower_dist < other_tower_dist) {
                            thing_selected = tower;
                        }
                    }
                }
            }
        }
        return thing_selected;
    };
    
    ResetCollisionData = function() {
        ds_grid_clear(collision_grid, GRID_COLLISION_FREE);
    };
    
    FuseMapEntities = function() {
        var vbuff = vertex_create_buffer();
        vertex_begin(vbuff, format);
        
        var cam_x = camera.to.x - camera.from.x;
        var cam_y = camera.to.y - camera.from.y;
        var cam_z = camera.to.z - camera.from.z;
        var cam_magnitude = point_distance_3d(0, 0, 0, cam_x, cam_y, cam_z);
        cam_x /= cam_magnitude;
        cam_y /= cam_magnitude;
        cam_z /= cam_magnitude;
        
        for (var i = 0; i < ds_list_size(all_env_entities); i++) {
            var ent = all_env_entities[| i];
            
            var raw_buffer = buffer_create_from_vertex_buffer(ent.model.vbuff, buffer_fixed, 1);
            var entity_matrix = matrix_build(
                ent.position.x, ent.position.y, ent.position.z,
                ent.rotation.x, ent.rotation.y, ent.rotation.z,
                ent.scale.x, ent.scale.y, ent.scale.z
            );
            var entity_matrix_normals = matrix_build(
                0, 0, 0,
                ent.rotation.x, ent.rotation.y, ent.rotation.z,
                ent.scale.x, ent.scale.y, ent.scale.z
            );
            
            for (var j = 0; j < buffer_get_size(raw_buffer); j += 36 * 3) {
                var xx1 = buffer_peek(raw_buffer, j +  0, buffer_f32);
                var yy1 = buffer_peek(raw_buffer, j +  4, buffer_f32);
                var zz1 = buffer_peek(raw_buffer, j +  8, buffer_f32);
                var nx1 = buffer_peek(raw_buffer, j + 12, buffer_f32);
                var ny1 = buffer_peek(raw_buffer, j + 16, buffer_f32);
                var nz1 = buffer_peek(raw_buffer, j + 20, buffer_f32);
                var xt1 = buffer_peek(raw_buffer, j + 24, buffer_f32);
                var yt1 = buffer_peek(raw_buffer, j + 28, buffer_f32);
                var cc1 = buffer_peek(raw_buffer, j + 32, buffer_u32);
                var xx2 = buffer_peek(raw_buffer, j + 36, buffer_f32);
                var yy2 = buffer_peek(raw_buffer, j + 40, buffer_f32);
                var zz2 = buffer_peek(raw_buffer, j + 44, buffer_f32);
                var nx2 = buffer_peek(raw_buffer, j + 48, buffer_f32);
                var ny2 = buffer_peek(raw_buffer, j + 52, buffer_f32);
                var nz2 = buffer_peek(raw_buffer, j + 56, buffer_f32);
                var xt2 = buffer_peek(raw_buffer, j + 60, buffer_f32);
                var yt2 = buffer_peek(raw_buffer, j + 64, buffer_f32);
                var cc2 = buffer_peek(raw_buffer, j + 68, buffer_u32);
                var xx3 = buffer_peek(raw_buffer, j + 72, buffer_f32);
                var yy3 = buffer_peek(raw_buffer, j + 76, buffer_f32);
                var zz3 = buffer_peek(raw_buffer, j + 80, buffer_f32);
                var nx3 = buffer_peek(raw_buffer, j + 84, buffer_f32);
                var ny3 = buffer_peek(raw_buffer, j + 88, buffer_f32);
                var nz3 = buffer_peek(raw_buffer, j + 92, buffer_f32);
                var xt3 = buffer_peek(raw_buffer, j + 96, buffer_f32);
                var yt3 = buffer_peek(raw_buffer, j + 100, buffer_f32);
                var cc3 = buffer_peek(raw_buffer, j + 104, buffer_u32);
                
                var new_normal = matrix_transform_vertex(entity_matrix_normals, nx1, ny1, nz1);
                var normal_magnitude = point_distance_3d(0, 0, 0, new_normal[0], new_normal[1], new_normal[2]);
                new_normal[0] /= normal_magnitude;
                new_normal[1] /= normal_magnitude;
                new_normal[2] /= normal_magnitude;
                
                var triangle_to_camera = dot_product_3d(new_normal[0], new_normal[1], new_normal[2], cam_x, cam_y, cam_z);
                var triangle_to_ground = dot_product_3d(new_normal[0], new_normal[1], new_normal[2], 0, 0, -1);
                
                if (triangle_to_camera < 0.8 && triangle_to_ground < 0.75) {
                    var new_position_1 = matrix_transform_vertex(entity_matrix, xx1, yy1, zz1);
                    var new_position_2 = matrix_transform_vertex(entity_matrix, xx2, yy2, zz2);
                    var new_position_3 = matrix_transform_vertex(entity_matrix, xx3, yy3, zz3);
                    var new_normal_2 = matrix_transform_vertex(entity_matrix_normals, nx2, ny2, nz2);
                    var new_normal_3 = matrix_transform_vertex(entity_matrix_normals, nx3, ny3, nz3);
                    
                    vertex_position_3d(vbuff, new_position_1[0], new_position_1[1], new_position_1[2]);
                    vertex_normal(vbuff, new_normal[0], new_normal[1], new_normal[2]);
                    vertex_texcoord(vbuff, xt1, yt1);
                    vertex_color(vbuff, cc1 & 0xffffff, (cc1 >> 24) / 255);
                    
                    vertex_position_3d(vbuff, new_position_2[0], new_position_2[1], new_position_2[2]);
                    vertex_normal(vbuff, new_normal_2[0], new_normal_2[1], new_normal_2[2]);
                    vertex_texcoord(vbuff, xt2, yt2);
                    vertex_color(vbuff, cc2 & 0xffffff, (cc2 >> 24) / 255);
                    
                    vertex_position_3d(vbuff, new_position_3[0], new_position_3[1], new_position_3[2]);
                    vertex_normal(vbuff, new_normal_3[0], new_normal_3[1], new_normal_3[2]);
                    vertex_texcoord(vbuff, xt3, yt3);
                    vertex_color(vbuff, cc3 & 0xffffff, (cc3 >> 24) / 255);
                }
            }
            
            buffer_delete(raw_buffer);
            ds_list_delete(all_entities, ds_list_find_index(all_entities, ent));
        }
        
        vertex_end(vbuff);
        ds_list_clear(all_env_entities);
        
        if (fused.raw != undefined) {
            buffer_delete(fused.raw);
        }
        if (fused.vbuff) {
            vertex_delete_buffer(fused.vbuff);
        }
        
        show_message(string(vertex_get_number(vbuff)) + " vertices (" + string(vertex_get_number(vbuff) / 3) + " triangles)");
        
        fused.vbuff = vbuff;
        fused.raw = buffer_create_from_vertex_buffer(vbuff, buffer_fixed, 1);
        vertex_freeze(vbuff);
    };
    
    Update = function() {
        if (keyboard_check_pressed(vk_tab)) {
            gameplay_mode = (gameplay_mode == GameModes.GAMEPLAY) ? GameModes.EDITOR : GameModes.GAMEPLAY;
            selected_entity = undefined;
            if (gameplay_mode == GameModes.GAMEPLAY) {
                ResetCollisionData();
            }
        }
        
        if (gameplay_mode== GameModes.TITLE) {
            camera.Update();
            if (keyboard_check_pressed(vk_escape)) {
                current_title_screen = "UI_Title_Screen";
                return;
            }
        } else if (gameplay_mode == GameModes.GAMEPLAY) {
            camera.Update();
            if (keyboard_check_pressed(vk_escape)) {
                gameplay_mode = GameModes.PAUSED;
                current_pause_screen = "UI_Game_Pause_Menu";
                audio_play_sound(se_menu_pause, SOUND_PRIORITY_UI, false);
                return;
            }
            
            #region Gameplay stuff
            selected_entity_hover = undefined;
            if (!player_cursor_over_ui) {
                var floor_intersect = camera.GetFloorIntersect();
                if (player_tower_spawn && floor_intersect) {
                    player_tower_spawn.Reposition(floor_intersect.x, floor_intersect.y, floor_intersect.z);
                }
                
                if (!GetRaycastBlocked()) {
                    selected_entity_hover = GetUnderCursor(all_towers);
                    if (mouse_check_button_pressed(mb_left)) {
                        selected_entity = selected_entity_hover;
                        if (selected_entity) {
                        
                        } else {
                            SpawnTower();
                        }
                    }
                }
            }
            
            if (mouse_check_button_pressed(mb_right)) {
                selected_entity = undefined;
            }
            
            if (keyboard_check_pressed(vk_space)) {
                SendInWaveEarly();
            }
            
            if (self.player_health > 0) {
                // Speed up the game by running the update tick multiple times per step
                repeat (self.game_speed) {
                    // Check to see if a new wave should be launched
                    if (wave_countdown > 0 && waves_remain) {
                        wave_countdown -= DT;
                        if (wave_countdown <= 0) {
                            SendInWave();
                        }
                    }
                    
                    // Check to see if the currently active wave(s) can still update
                    for (var i = ds_list_size(wave_active) - 1; i >= 0; i--) {
                        wave_active[| i].Update();
                        if (wave_active[| i].Finished()) {
                            ds_list_delete(wave_active, i);
                            if (ds_list_empty(wave_active)) {
                                wave_countdown = WAVE_COUNTDOWN;
                            }
                        }
                    }
                    
                    for (var i = 0; i < ds_list_size(all_entities); i++) {
                        all_entities[| i].BeginUpdate();
                    }
                    
                    for (var i = 0; i < ds_list_size(all_entities); i++) {
                        all_entities[| i].Update();
                    }
                }
            }
            #endregion
        } else if (gameplay_mode == GameModes.PAUSED) {
            if (keyboard_check_pressed(vk_escape)) {
                gameplay_mode = GameModes.GAMEPLAY;
                audio_play_sound(se_menu_back, SOUND_PRIORITY_UI, false);
            }
        } else if (gameplay_mode == GameModes.EDITOR) {
            camera.Update();
            #region Editor stuff
            if (keyboard_check_pressed(vk_f2)) {
                editor_collision_mode = false;
                editor_path_mode = !editor_path_mode;
                selected_entity = undefined;
            }
            
            if (keyboard_check_pressed(vk_f3)) {
                if (show_question("Would you like to fuse all the map things?")) {
                    FuseMapEntities();
                }
            }
            
            if (keyboard_check_pressed(vk_f7)) {
                editor_path_mode = false;
                if (editor_collision_mode) {
                    var surface_buffer = buffer_create(surface_get_width(collision_surface) * surface_get_height(collision_surface) * 4, buffer_fixed, 1);
                    buffer_get_surface(surface_buffer, collision_surface, 0);
                    
                    buffer_seek(surface_buffer, buffer_seek_start, 0);
                    buffer_seek(fused.collision, buffer_seek_start, 0);
                    
                    repeat (buffer_get_size(fused.collision)) {
                        var color = buffer_read(surface_buffer, buffer_u32) & 0xff;
                        buffer_write(fused.collision, buffer_u8, color);
                    }
                    
                    buffer_delete(surface_buffer);
                }
                editor_collision_mode = !editor_collision_mode;
                selected_entity = undefined;
            }
            
            if (editor_path_mode) {
                editor_hover_entity = GetUnderCursor(path_nodes);
                
                if (mouse_check_button_pressed(mb_left)) {
                    if (editor_hover_entity) {
                        selected_entity = editor_hover_entity;
                    } else {
                        // Spawn a path node at the location of the cursor on the floor
                        // (and append it to the end of the list)
                        var position = camera.GetFloorIntersect();
                        for (var i = 0; i < array_length(path_nodes) + 1; i++) {
                            if (i == array_length(path_nodes) || path_nodes[i] == undefined) {
                                path_nodes[@ i] = new PathNode(position);
                                break;
                            }
                        }
                    }
                }
                if (keyboard_check_pressed(vk_delete)) {
                    if (selected_entity) {
                        for (var i = 0; i < array_length(path_nodes); i++) {
                            if (path_nodes[i] == selected_entity) {
                                array_delete(path_nodes, i, 1);
                                break;
                            }
                        }
                        selected_entity = undefined;
                    }
                }
            } else if (editor_collision_mode) {
                
            } else {
                editor_hover_entity = GetUnderCursor(all_env_entities);
                
                if (keyboard_check_pressed(vk_f4)) {
                    editor_model_index = (editor_model_index + ds_list_size(env_object_list) - 1) % ds_list_size(env_object_list);
                }
                
                if (keyboard_check_pressed(vk_f5)) {
                    editor_model_index = (editor_model_index + 1) % ds_list_size(env_object_list);
                }
                
                if (keyboard_check_pressed(vk_f6)) {
                    var seek_name = string_lower(get_string("What model do you want to jump to?", env_object_list[| editor_model_index]));
                    for (var i = 1, n = ds_list_size(env_object_list); i <= n; i++) {
                        var index = (i + editor_model_index) % n;
                        if (string_count(seek_name, string_lower(env_object_list[| index])) > 0) {
                            editor_model_index = index;
                        }
                    }
                }
                
                if (mouse_check_button_pressed(mb_left)) {
                    if (editor_hover_entity) {
                        if (selected_entity) selected_entity.Deselect();
                        selected_entity = editor_hover_entity;
                        editor_hover_entity.Select();
                    } else {
                        var position = camera.GetFloorIntersect();
                        if (position) {
                            var spawn_name = env_object_list[| editor_model_index];
                            var ent = new EntityEnv(position.x, position.y, 0, env_objects[? spawn_name], spawn_name);
                            ent.rotation.z = random(360);
                            ent.scale.x = random_range(1.8, 2.2);
                            ent.scale.y = ent.scale.x;
                            ent.scale.z = ent.scale.x;
                            ent.AddToMap();
                        }
                    }
                } else {
                    if (selected_entity) {
                        if (keyboard_check_pressed(vk_f12)) {
                            selected_entity.is_moving = !selected_entity.is_moving;
                        }
                        if (selected_entity.is_moving) {
                            var pos = camera.GetFloorIntersect();
                            if (pos) {
                                selected_entity.Reposition(pos.x, pos.y, pos.z);
                            }
                        } else {
                            #region position, rotation, scale
                            if (keyboard_check(vk_shift)) {
                                if (keyboard_check(vk_right)) {
                                    selected_entity.rotation.x++;
                                }
                                if (keyboard_check(vk_left)) {
                                    selected_entity.rotation.x--;
                                }
                                if (keyboard_check(vk_up)) {
                                    selected_entity.rotation.y--;
                                }
                                if (keyboard_check(vk_down)) {
                                    selected_entity.rotation.y++;
                                }
                                if (keyboard_check(vk_pageup)) {
                                    selected_entity.rotation.z++;
                                }
                                if (keyboard_check(vk_pagedown)) {
                                    selected_entity.rotation.z--;
                                }
                                if (keyboard_check(vk_backspace)) {
                                    selected_entity.rotation.x = 0;
                                    selected_entity.rotation.y = 0;
                                    selected_entity.rotation.z = 0;
                                }
                            } else if (keyboard_check(vk_control)) {
                                if (keyboard_check(vk_up)) {
                                    selected_entity.scale.x = min(selected_entity.scale.x + 0.01, 4);
                                    selected_entity.scale.y = min(selected_entity.scale.y + 0.01, 4);
                                    selected_entity.scale.z = min(selected_entity.scale.z + 0.01, 4);
                                }
                                if (keyboard_check(vk_down)) {
                                    selected_entity.scale.x = max(selected_entity.scale.x - 0.01, 0.25);
                                    selected_entity.scale.y = max(selected_entity.scale.y - 0.01, 0.25);
                                    selected_entity.scale.z = max(selected_entity.scale.z - 0.01, 0.25);
                                }
                                if (keyboard_check(vk_backspace)) {
                                    selected_entity.scale.x = 1;
                                    selected_entity.scale.y = 1;
                                    selected_entity.scale.z = 1;
                                }
                            } else {
                                if (keyboard_check(vk_right)) {
                                    selected_entity.Reposition(selected_entity.position.x + 1, selected_entity.position.y, selected_entity.position.z);
                                }
                                if (keyboard_check(vk_left)) {
                                    selected_entity.Reposition(selected_entity.position.x - 1, selected_entity.position.y, selected_entity.position.z);
                                }
                                if (keyboard_check(vk_up)) {
                                    selected_entity.Reposition(selected_entity.position.x, selected_entity.position.y - 1, selected_entity.position.z);
                                }
                                if (keyboard_check(vk_down)) {
                                    selected_entity.Reposition(selected_entity.position.x, selected_entity.position.y + 1, selected_entity.position.z);
                                }
                                if (keyboard_check(vk_pageup)) {
                                    selected_entity.Reposition(selected_entity.position.x, selected_entity.position.y, selected_entity.position.z - 1);
                                }
                                if (keyboard_check(vk_pagedown)) {
                                    selected_entity.Reposition(selected_entity.position.x, selected_entity.position.y, selected_entity.position.z + 1);
                                }
                            }
                            #endregion
                            if (keyboard_check_pressed(vk_delete)) {
                                ds_list_delete(all_entities, ds_list_find_index(all_entities, selected_entity));
                                ds_list_delete(all_env_entities, ds_list_find_index(all_env_entities, selected_entity));
                                selected_entity = undefined;
                            }
                        }
                    }
                }
            }
            
            if (keyboard_check_pressed(vk_f1)) {
                SaveMap();
            }
            #endregion
        }
    };
    
    SaveMap = function() {
        var filename = get_save_filename("Bombadier maps|*.bug", "map.bug");
        if (filename == "") return;
        
        var save_json = {
            entities: array_create(ds_list_size(all_env_entities), undefined),
            nodes: path_nodes,
        };
        for (var i = 0; i < ds_list_size(all_env_entities); i++) {
            all_env_entities[| i].Save(save_json, i);
        }
        
        var json_string = json_stringify(save_json);
        var buffer = buffer_create(string_length(json_string), buffer_fixed, 1);
        buffer_poke(buffer, 0, buffer_text, json_string);
        buffer_save(buffer, filename);
        buffer_delete(buffer);
        
        if (fused.raw != undefined) {
            buffer_save(fused.raw, filename_change_ext(filename, ".fused"));
        }
        
        buffer_save(fused.collision, filename_change_ext(filename, ".collision"));
    };
    
    LoadMap = function(filename) {
        if (self.fused.raw != undefined) {
            vertex_delete_buffer(self.fused.vbuff);
            buffer_delete(self.fused.raw);
            self.fused.vbuff = undefined;
            self.fused.raw = undefined;
        }
        
        array_resize(self.path_nodes, 0);
        ds_list_clear(self.all_entities);
        ds_list_clear(self.all_foes);
        ds_list_clear(self.all_towers);
        ds_list_clear(self.all_env_entities);
        
        var buffer = undefined;
        try {
            buffer = buffer_load(filename);
            var json_string = buffer_read(buffer, buffer_text);
            var load_json = json_parse(json_string);
            
            var ww = FIELD_WIDTH div GRID_CELL_SIZE;
            var hh = FIELD_HEIGHT div GRID_CELL_SIZE;
            ds_grid_resize(collision_grid, ww, hh);
            ds_grid_clear(collision_grid, GRID_COLLISION_FREE);
            
            for (var i = 0; i < array_length(load_json.entities); i++) {
                var data = load_json.entities[i];
                if (is_struct(data)) {
                    var ent = new EntityEnv(data.position.x, data.position.y, data.position.z, env_objects[? data.name], data.name);
                    ent.rotation = data.rotation;
                    ent.scale = data.scale;
                    ent.AddToMap();
                }
            }
            path_nodes = array_create(array_length(load_json.nodes));
            for (var i = 0; i < array_length(load_json.nodes); i++) {
                path_nodes[@ i] = new PathNode(load_json.nodes[i].position);
            }
            
            if (file_exists(filename_change_ext(filename, ".fused"))) {
                fused.raw = buffer_load(filename_change_ext(filename, ".fused"));
                fused.vbuff = vertex_create_buffer_from_buffer(fused.raw, format);
                vertex_freeze(fused.vbuff);
            }
            
            if (file_exists(filename_change_ext(filename, ".collision"))) {
                if (buffer_exists(fused.collision)) buffer_delete(fused.collision);
                fused.collision = buffer_load(filename_change_ext(filename, ".collision"));
            }
        } catch (e) {
            show_debug_message("Something bad happened loading the file:");
            show_debug_message(e.message);
            show_debug_message(e.longMessage);
            show_debug_message(e.script);
            show_debug_message(e.stacktrace);
        }
        
        if (buffer != undefined) {
            buffer_delete(buffer);
        }
    };
    
    Render = function() {
        if (!surface_exists(self.outline_surface)) {
            self.outline_surface = surface_create(OUTLINE_SURFACE_WIDTH, OUTLINE_SURFACE_HEIGHT);
        }
        
        surface_set_target(self.outline_surface);
        
        camera.Render();
        
        shader_set(shd_solid_color);
        if (self.selected_entity) self.selected_entity.Render();
        if (self.player_tower_spawn) self.player_tower_spawn.Render();
        if (self.editor_hover_entity) self.editor_hover_entity.Render();
        if (self.selected_entity_hover) self.selected_entity_hover.Render();
        shader_reset();
        surface_reset_target();
        
        camera.Render();
        
        gpu_set_ztestenable(false);
        gpu_set_zwriteenable(false);
        matrix_set(matrix_world, matrix_build(camera.from.x, camera.from.y, camera.from.z, 0, 0, 0, 1, 1, 1));
        vertex_submit(skybox_cube, pr_trianglelist, sprite_get_texture(spr_skybox, 0));
        matrix_set(matrix_world, matrix_build_identity());
        gpu_set_ztestenable(true);
        gpu_set_zwriteenable(true);
        
        ds_list_clear(semi_transparent_stuff);
        
        gpu_set_cullmode(cull_counterclockwise);
        cluck_set_light_ambient(0x202020);
        cluck_set_light_direction(0, c_white, -1, -1, -1);
        cluck_apply(SHADER_WORLD);
        
        vertex_submit(ground, pr_trianglelist, sprite_get_texture(spr_ground, 0));
        
        if (fused.vbuff != undefined) {
            vertex_submit(fused.vbuff, pr_trianglelist, -1);
        }
        
        for (var i = 0; i < ds_list_size(all_entities); i++) {
            all_entities[| i].Render();
        }
        
        for (var i = 0; i < ds_list_size(all_foes); i++) {
            all_foes[| i].RenderHealthBar();
        }
        
        if (player_tower_spawn) player_tower_spawn.Render();
        
        if (gameplay_mode == GameModes.EDITOR) {
            // Draw a debug line so you can see where the bounds of the world is
            var vb_border = vertex_create_buffer();
            vertex_begin(vb_border, format);
            vertex_position_3d(vb_border, 0, FIELD_HEIGHT, 8);
            vertex_normal(vb_border, 0, 0, 1);
            vertex_texcoord(vb_border, 0, 0);
            vertex_colour(vb_border, c_red, 1);
            vertex_position_3d(vb_border, FIELD_WIDTH, FIELD_HEIGHT, 8);
            vertex_normal(vb_border, 0, 0, 1);
            vertex_texcoord(vb_border, 0, 0);
            vertex_colour(vb_border, c_red, 1);
            vertex_end(vb_border);
            vertex_submit(vb_border, pr_linestrip, -1);
            vertex_delete_buffer(vb_border);
            
            if (editor_path_mode) {
                var draw_the_line = array_length(path_nodes) > 1;
                if (draw_the_line) {
                    var vb_path_nodes = vertex_create_buffer();
                    vertex_begin(vb_path_nodes, format);
                    var node_hue = 0;
                    var node_hue_interval = 255 / array_length(path_nodes);
                }
                shader_set(shd_cluck_unlit);
                for (var i = 0; i < array_length(path_nodes); i++) {
                    var node = path_nodes[i];
                    if (node != undefined) {
                        node.Render();
                        if (draw_the_line) {
                            // rainbow path node connections
                            vertex_position_3d(vb_path_nodes, node.position.x, node.position.y, node.position.z + 8);
                            vertex_normal(vb_path_nodes, 0, 0, 1);
                            vertex_texcoord(vb_path_nodes, 0, 0);
                            vertex_colour(vb_path_nodes, make_colour_hsv(node_hue, 255, 255), 1);
                            node_hue += node_hue_interval;
                        }
                    }
                }
                if (draw_the_line) {
                    vertex_end(vb_path_nodes);
                    vertex_submit(vb_path_nodes, pr_linestrip, -1);
                    vertex_delete_buffer(vb_path_nodes);
                }
            }
        }
        
        // semi-transparent stuff gets drawn last because the depth buffer sucks
        for (var i = 0; i < ds_list_size(semi_transparent_stuff); i++) {
            var thing_to_draw = semi_transparent_stuff[| i];
            shader_set(thing_to_draw.shader);
            if (thing_to_draw.shader_uniforms != undefined) {
                shader_set_uniform_f_array(shader_get_uniform(thing_to_draw.shader, thing_to_draw.shader_uniforms.name), thing_to_draw.shader_uniforms.elements);
            }
            matrix_set(matrix_world, thing_to_draw.matrix);
            vertex_submit(thing_to_draw.vbuff, pr_trianglelist, -1);
        }
        
        matrix_set(matrix_world, matrix_build_identity());
        shader_reset();
        
        Particles.Render();
    };
    
    // These are the UI layers that may be turned on or off during gameplay
    ActiveGUILayer = function() {
        if (gameplay_mode == GameModes.EDITOR) {
            return undefined;
        }
        if (selected_entity != undefined) {
            return all_ui_elements[$ layer_get_depth("UI_Tower_Select")];
        }
        return all_ui_elements[$ layer_get_depth("UI_Game")];
    };
    
    GetGUILayer = function(name) {
        return all_ui_elements[$ layer_get_depth(name)];
    };
    
    GUI = function() {
        draw_surface_stretched(application_surface, 0, 0, window_get_width(), window_get_height());
        
        shader_set(shd_outline);
        gpu_set_texfilter(true);
        draw_surface_stretched(self.outline_surface, 0, 0, window_get_width(), window_get_height());
        gpu_set_texfilter(false);
        shader_reset();
        
        if (gameplay_mode == GameModes.TITLE) {
            GetGUILayer(current_title_screen).Render();
        } else if (gameplay_mode == GameModes.GAMEPLAY) {
            GetGUILayer("UI_Game_Overlay").Render();
            ActiveGUILayer().Render();
            
            player_cursor_over_ui = false;
            
            if (mouse_check_button(mb_middle)) {
                draw_sprite(spr_cursor_pan, 0, window_mouse_get_x(), window_mouse_get_y());
                window_set_cursor(cr_none);
            } else {
                window_set_cursor(cr_default);
            }
        } else if (gameplay_mode == GameModes.PAUSED) {
            window_set_cursor(cr_default);
            GetGUILayer(current_pause_screen).Render();
            
            player_cursor_over_ui = false;
        } else if (gameplay_mode == GameModes.GAME_OVER) {
            window_set_cursor(cr_default);
            GetGUILayer(current_game_over_screen).Render();
            
            player_cursor_over_ui = false;
        } else if (gameplay_mode == GameModes.EDITOR) {
            window_set_cursor(cr_default);
            if (editor_path_mode) {
                draw_text(32, 32, "Click to spawn or select a path node");
            } else if (editor_collision_mode) {
                if (!surface_exists(collision_surface)) {
                    collision_surface = surface_create(ceil(FIELD_WIDTH / GRID_CELL_SIZE), ceil(FIELD_HEIGHT / GRID_CELL_SIZE));
                    
                    var surface_buffer = buffer_create(surface_get_width(collision_surface) * surface_get_height(collision_surface) * 4, buffer_fixed, 1);
                    
                    buffer_seek(surface_buffer, buffer_seek_start, 0);
                    buffer_seek(fused.collision, buffer_seek_start, 0);
                    
                    surface_set_target(collision_surface);
                    draw_clear(c_black);
                    surface_reset_target();
                    
                    repeat (buffer_get_size(fused.collision)) {
                        var color = buffer_read(fused.collision, buffer_u8);
                        buffer_write(surface_buffer, buffer_u32, 0xff000000 | make_colour_rgb(color, color, color));
                    }
                    
                    buffer_set_surface(surface_buffer, collision_surface, 0);
                }
                
                surface_set_target(collision_surface);
                var xx = window_mouse_get_x() / window_get_width() * surface_get_width(collision_surface);
                var yy = window_mouse_get_y() / window_get_height() * surface_get_height(collision_surface);
                
                static collision_brush_radius = 4;
                
                if (mouse_wheel_up()) collision_brush_radius = max(2, collision_brush_radius - 1);
                if (mouse_wheel_down()) collision_brush_radius = min(10, collision_brush_radius + 1);
                if (mouse_check_button(mb_left)) draw_circle_color(xx, yy, collision_brush_radius, c_white, c_white, false);
                if (mouse_check_button(mb_right)) draw_circle_color(xx, yy, collision_brush_radius, c_black, c_black, false);
                
                surface_reset_target();
                draw_surface_stretched_ext(collision_surface, 0, 0, window_get_width(), window_get_height(), c_white, 0.5);
                draw_circle_color(window_mouse_get_x(), window_mouse_get_y(), collision_brush_radius * (window_get_width() / surface_get_width(collision_surface)), c_aqua, c_aqua, true);
                draw_text(32, 32, "Left click to paint collision information; right click to clear collision information");
            } else {
                draw_text(32, 32, "Click to spawn a thing (" + env_object_list[| editor_model_index] + ") or select an existing thing; F4 and F5 cycle through models");
                if (selected_entity) {
                    if (keyboard_check(vk_shift)) {
                        draw_text(32, 64, "Left, Right, Up, Down, PageUp and Page Down to rotate the selected thing");
                        draw_text(32, 96, "Backspace to reset the rotation");
                    } else if (keyboard_check(vk_control)) {
                        draw_text(32, 64, "Up and Down to scale the selected thing");
                        draw_text(32, 96, "Backspace to reset the scale");
                    } else {
                        draw_text(32, 64, "Left, Right, Up, Down, PageUp and Page Down to move the selected thing");
                        draw_text(32, 96, "Hold Shift or Control to affect rotation and scale instead");
                    }
                    draw_text(32, 128, "F12 to move a thing to a new location");
                    draw_text(32, 160, "Delete to delete the selected thing");
                    draw_text(32, 192, string(ds_list_size(all_env_entities)) + " total things");
                }
                draw_set_halign(fa_right);
                var n = 0;
                draw_text(window_get_width() - 32, ++n * 32, "F1 to save");
                draw_text(window_get_width() - 32, ++n * 32, "F2 to view/hide path nodes");
                draw_text(window_get_width() - 32, ++n * 32, "F3 to fuse all of the environment entities together");
                draw_text(window_get_width() - 32, ++n * 32, "F6 to search for a model");
                draw_text(window_get_width() - 32, ++n * 32, "F7 to go into collision painting mode");
                draw_set_halign(fa_left);
            }
        }
    };
    
    Initialize();
    
    gameplay_mode = GameModes.TITLE;
}