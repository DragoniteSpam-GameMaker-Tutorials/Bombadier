#macro GAME Backbone.game
show_debug_overlay(true);

function Game() constructor {
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
    var sw = 64;
    for (var i = 0; i < 20; i++) {
        for (var j = 0; j < 12; j++) {
            // 0
            vertex_position_3d(ground, i * 64, j * 64, 0);
            vertex_normal(ground, 0, 0, 1);
            vertex_texcoord(ground, 0, 0);
            vertex_colour(ground, c_white, 1);
            // 1
            vertex_position_3d(ground, (i + 1) * 64, j * 64, 0);
            vertex_normal(ground, 0, 0, 1);
            vertex_texcoord(ground, 1, 0);
            vertex_colour(ground, c_white, 1);
            // 2
            vertex_position_3d(ground, (i + 1) * 64, (j + 1) * 64, 0);
            vertex_normal(ground, 0, 0, 1);
            vertex_texcoord(ground, 1, 1);
            vertex_colour(ground, c_white, 1);
            // 3
            vertex_position_3d(ground, (i + 1) * 64, (j + 1) * 64, 0);
            vertex_normal(ground, 0, 0, 1);
            vertex_texcoord(ground, 1, 1);
            vertex_colour(ground, c_white, 1);
            // 4
            vertex_position_3d(ground, i * 64, (j + 1) * 64, 0);
            vertex_normal(ground, 0, 0, 1);
            vertex_texcoord(ground, 0, 1);
            vertex_colour(ground, c_white, 1);
            // 5
            vertex_position_3d(ground, i * 64, j * 64, 0);
            vertex_normal(ground, 0, 0, 1);
            vertex_texcoord(ground, 0, 0);
            vertex_colour(ground, c_white, 1);
        }
    }
    vertex_end(ground);
    vertex_freeze(ground);
    #endregion
    
    #region environment objects
    env_objects = ds_map_create();
    env_object_list = ds_list_create();
    for (var file = file_find_first("environment/*.d3d", 0); file != ""; file = file_find_next()) {
        var vbuff = load_model("environment/" + file, format);
        var obj_name = string_replace(file, ".000.d3d", "");
        env_objects[? obj_name] = vbuff;
        ds_list_add(env_object_list, obj_name);
    }
    collision_grid = ds_grid_create(10, 10);
    collision_grid_fused = ds_grid_create(10, 10);
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
    bullet_bug_spray =  new BulletData("Bug Spray", load_model("bugspray.d3d", format), function(target) {
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
    
    path_nodes = array_create(0);
    
    all_entities = ds_list_create();
    all_foes = ds_list_create();
    all_towers = ds_list_create();
    all_env_entities = ds_list_create();
    all_fused_environment_stuff = undefined;
    
    selected_entity = undefined;
    selected_entity_hover = undefined;
    editor_hover_entity = undefined;
    editor_path_mode = false;
    editor_model_index = 0;
    
    all_waves = ds_queue_create();
    ds_queue_enqueue(all_waves,
        new Wave(foe_ant,            8, 1, 1),
        new Wave(foe_pillbugs,       8, 1, 1),
        new Wave(foe_aphid,         40, 1, 4),
        new Wave(foe_ant,           10, 3, 1),
        new Wave(foe_grasshopper,    4, 3, 0.5),
        new Wave(foe_gnat,          60, 3, 2),
        new Wave(foe_aphid,         60, 6, 4),
        new Wave(foe_grasshopper,    4, 5, 0.5),
    );
    wave_total = ds_queue_size(all_waves);
    wave_active = ds_list_create();
    wave_countdown = WAVE_WARMUP_COUNTDOWN;
    waves_remain = true;
    
    game_speed = 1;
    
    player_money = 75;
    player_health = 10;
    
    player_cursor_over_ui = false;
    player_tower_spawn = undefined;
    
    all_ui_elements = { };
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
    
    enum GameModes {
        GAMEPLAY, EDITOR,
    }
    
    gameplay_mode = GameModes.GAMEPLAY;
    
    SetGameSpeed = function(speed) {
        self.game_speed = speed;
    };
    
    SendInWave = function() {
        if (ds_queue_empty(all_waves)) {
            waves_remain = false;
        } else {
            wave_countdown = -1;
            var wave_current = ds_queue_dequeue(all_waves);
            wave_current.Launch();
            ds_list_add(wave_active, wave_current);
        }
    };
    
    SendInWaveEarly = function() {
        if (wave_countdown > 0) {
            player_money += ceil(wave_countdown);
        } else {
            player_money += WAVE_COUNTDOWN;
        }
        SendInWave();
    };
    
    PlayerDamage = function(amount) {
        player_health -= max(amount, 0);
        if (player_health <= 0) {
            show_message("aaaaaaaaaaaaaaaaa");
            game_end();
        }
    };
    
    SpawnTower = function() {
        var position = camera.GetFloorIntersect();
        
        if (position) {
            if (player_tower_spawn && player_money >= player_tower_spawn.class.cost[0] && CollisionFree(player_tower_spawn)) {
                player_money -= player_tower_spawn.class.cost[0];
                player_tower_spawn.AddToMap();
                player_tower_spawn = undefined;
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
        
        var collision_grid_state = ds_grid_get_max(collision_grid, cell_xmin, cell_ymin, cell_xmax, cell_ymax) == GRID_COLLISION_FREE;
        var collision_grid_fused_state = ds_grid_get_max(collision_grid_fused, cell_xmin, cell_ymin, cell_xmax, cell_ymax) == GRID_COLLISION_FREE;
        return (collision_grid_state && collision_grid_fused_state);
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
        for (var i = 0; i < ds_list_size(all_entities); i++) {
            all_entities[| i].AddCollision();
        }
        for (var i = 0; i < array_length(path_nodes); i++) {
            if (path_nodes[i]) {
                path_nodes[i].AddCollision();
            }
        }
    };
    
    FuseMapEntities = function() {
        var vbuff = vertex_create_buffer();
        vertex_begin(vbuff, format);
        ds_grid_clear(collision_grid_fused, GRID_COLLISION_FREE);
        
        var actual_collision_grid = collision_grid;
        collision_grid = collision_grid_fused;
        
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
            
            for (var j = 0; j < buffer_get_size(raw_buffer); j += 36) {
                var xx = buffer_peek(raw_buffer, j +  0, buffer_f32);
                var yy = buffer_peek(raw_buffer, j +  4, buffer_f32);
                var zz = buffer_peek(raw_buffer, j +  8, buffer_f32);
                var nx = buffer_peek(raw_buffer, j + 12, buffer_f32);
                var ny = buffer_peek(raw_buffer, j + 16, buffer_f32);
                var nz = buffer_peek(raw_buffer, j + 20, buffer_f32);
                var xt = buffer_peek(raw_buffer, j + 24, buffer_f32);
                var yt = buffer_peek(raw_buffer, j + 28, buffer_f32);
                var cc = buffer_peek(raw_buffer, j + 32, buffer_u32);
                
                var new_position = matrix_transform_vertex(entity_matrix, xx, yy, zz);
                var new_normal = matrix_transform_vertex(entity_matrix_normals, nx, ny, nz);
                var normal_magnitude = point_distance_3d(0, 0, 0, new_normal[0], new_normal[1], new_normal[2]);
                new_normal[0] /= normal_magnitude;
                new_normal[1] /= normal_magnitude;
                new_normal[2] /= normal_magnitude;
                
                vertex_position_3d(vbuff, new_position[0], new_position[1], new_position[2]);
                vertex_normal(vbuff, new_normal[0], new_normal[1], new_normal[2]);
                vertex_texcoord(vbuff, xt, yt);
                vertex_color(vbuff, cc & 0xffffff, (cc >> 24) / 255);
            }
            
            buffer_delete(raw_buffer);
            ds_list_delete(all_entities, ds_list_find_index(all_entities, ent));
            
            ent.AddCollision();
        }
        
        vertex_end(vbuff);
        ds_list_clear(all_env_entities);
        
        all_fused_environment_stuff = vbuff;
        
        collision_grid = actual_collision_grid;
    };
    
    Update = function() {
        camera.Update();
        
        if (keyboard_check_pressed(vk_tab)) {
            gameplay_mode = (gameplay_mode == GameModes.GAMEPLAY) ? GameModes.EDITOR : GameModes.GAMEPLAY;
            selected_entity = undefined;
            if (gameplay_mode == GameModes.GAMEPLAY) {
                ResetCollisionData();
            }
        }
        
        if (gameplay_mode == GameModes.GAMEPLAY) {
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
            #endregion
        } else {
            #region Editor stuff
            if (keyboard_check_pressed(vk_f2)) {
                editor_path_mode = !editor_path_mode;
                selected_entity = undefined;
            }
            
            if (keyboard_check_pressed(vk_f3)) {
                FuseMapEntities();
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
                                for (var j = i; j < array_length(path_nodes) - 1; j++) {
                                    path_nodes[j] = path_nodes[j + 1];
                                }
                                path_nodes[array_length(path_nodes) - 1] = undefined;
                                break;
                            }
                        }
                    }
                }
            } else {
                editor_hover_entity = GetUnderCursor(all_env_entities);
                
                if (keyboard_check_pressed(vk_f4)) {
                    editor_model_index = (editor_model_index + ds_list_size(env_object_list) - 1) % ds_list_size(env_object_list);
                }
                
                if (keyboard_check_pressed(vk_f5)) {
                    editor_model_index = (editor_model_index + 1) % ds_list_size(env_object_list);
                }
                
                if (mouse_check_button_pressed(mb_left)) {
                    if (editor_hover_entity) {
                        if (selected_entity) selected_entity.Deselect();
                        selected_entity = editor_hover_entity;
                        editor_hover_entity.Select();
                    } else {
                        var position = camera.GetFloorIntersect();
                        var spawn_name = env_object_list[| editor_model_index];
                        var ent = new EntityEnv(position.x, position.y, 0, env_objects[? spawn_name], spawn_name);
                        ent.rotation.z = random(360);
                        ent.scale.x = random_range(0.9, 1.1);
                        ent.scale.y = ent.scale.x;
                        ent.scale.z = ent.scale.x;
                        ent.AddToMap();
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
        
        for (var node_count = array_length(path_nodes) - 1; node_count >= 0; node_count--) {
            if (path_nodes[node_count] != undefined) break;
        }
        
        var save_json = {
            entities: array_create(ds_list_size(all_env_entities), undefined),
            nodes: array_create(node_count),
            fused_collision: ds_grid_write(collision_grid_fused),
        };
        for (var i = 0; i < ds_list_size(all_env_entities); i++) {
            all_env_entities[| i].Save(save_json, i);
        }
        for (var i = 0; i < node_count; i++) {
            save_json.nodes[@ i] = path_nodes[i];
        }
        
        var json_string = json_stringify(save_json);
        var buffer = buffer_create(string_length(json_string), buffer_fixed, 1);
        buffer_poke(buffer, 0, buffer_text, json_string);
        buffer_save(buffer, filename);
        buffer_delete(buffer);
        
        var fused_buffer = buffer_create_from_vertex_buffer(all_fused_environment_stuff, buffer_fixed, 1);
        buffer_save(fused_buffer, filename_change_ext(filename, ".fused"));
        buffer_delete(fused_buffer);
    };
    
    LoadMap = function(filename) {
        var buffer = undefined;
        try {
            buffer = buffer_load(filename);
            var json_string = buffer_read(buffer, buffer_text);
            var load_json = json_parse(json_string);
            
            var ww = room_width div GRID_CELL_SIZE;
            var hh = room_height div GRID_CELL_SIZE;
            ds_grid_resize(collision_grid, ww, hh);
            ds_grid_clear(collision_grid, GRID_COLLISION_FREE);
            ds_grid_resize(collision_grid_fused, ww, hh);
            ds_grid_clear(collision_grid_fused, GRID_COLLISION_FREE);
            
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
        camera.Render();
        
        gpu_set_ztestenable(false);
        gpu_set_zwriteenable(false);
        matrix_set(matrix_world, matrix_build(camera.from.x, camera.from.y, camera.from.z, 0, 0, 0, 1, 1, 1));
        vertex_submit(skybox_cube, pr_trianglelist, sprite_get_texture(spr_skybox, 0));
        matrix_set(matrix_world, matrix_build_identity());
        gpu_set_ztestenable(true);
        gpu_set_zwriteenable(true);
        
        ds_list_clear(semi_transparent_stuff);
        
        gpu_set_cullmode(cull_noculling);
        cluck_set_light_ambient(0x202020);
        cluck_set_light_direction(0, c_white, -1, -1, -1);
        cluck_apply(shd_cluck_fragment);
        
        vertex_submit(ground, pr_trianglelist, sprite_get_texture(spr_ground, 0));
        
        if (all_fused_environment_stuff != undefined) {
            vertex_submit(all_fused_environment_stuff, pr_trianglelist, -1);
        }
        
        for (var i = 0; i < ds_list_size(all_entities); i++) {
            all_entities[| i].Render();
        }
        
        for (var i = 0; i < ds_list_size(all_foes); i++) {
            all_foes[| i].RenderHealthBar();
        }
        
        if (player_tower_spawn) {
            var can_build = CollisionFree(player_tower_spawn);
            shader_set(shd_selected);
            shader_set_uniform_f(shader_get_uniform(shd_selected, "time"), current_time / 1000);
            shader_set_uniform_color(shader_get_uniform(shd_selected, "color"), can_build ? c_phantom_tower : c_phantom_tower_unavailable);
            matrix_set(matrix_world, matrix_build(player_tower_spawn.position.x, player_tower_spawn.position.y, 0, 0, 0, 0, 1, 1, 1));
            vertex_submit(player_tower_spawn.class.model.vbuff, pr_trianglelist, -1);
            matrix_set(matrix_world, matrix_build_identity());
            cluck_apply(shd_cluck_fragment);
        }
        
        if (gameplay_mode == GameModes.EDITOR) {
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
        if (gameplay_mode == GameModes.GAMEPLAY) {
            draw_text(32, 32, "Player money: " + string(player_money));
            draw_text(32, 64, "Player health: " + string(player_health));
            
            GetGUILayer("UI_Game_Overlay").Render();
            ActiveGUILayer().Render();
            
            player_cursor_over_ui = false;
        } else {
            if (editor_path_mode) {
                draw_text(32, 32, "Click to spawn or select a path node");
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
                draw_text(window_get_width() - 32, 32, "F1 to save");
                draw_text(window_get_width() - 32, 64, "F2 to view/hide path nodes");
                draw_text(window_get_width() - 32, 96, "F3 to fuse all of the environment entities together");
                draw_set_halign(fa_left);
            }
        }
        if (keyboard_check(vk_f11)) {
            debug_draw_collision(32, 32);
        }
    };
}