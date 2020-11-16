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
        var vbuff = load_model("environment/" + file, format);;
        var obj_name = string_replace(file, ".000.d3d", "");
        env_objects[? obj_name] = vbuff;
        ds_list_add(env_object_list, obj_name);
    }
    collision_grid = ds_grid_create(10, 10);
    #endregion
    
    test_ball = load_model("testball.d3d", format);
    skybox_cube = load_model("skybox.d3d", format);
    
    #region database
    foe_ant =       new FoeData("Ant",          5, 0, 0, 100, 1, 2, spr_ant, load_model("foe.d3d", format));
    foe_pillbugs =  new FoeData("Pillbugs",     10, 1, 0, 50, 1, 3, spr_ant_red, load_model("foe.d3d", format));
    foe_spider =    new FoeData("Spider",       10, 0, 1, 64, 1, 4, spr_ant, load_model("foe.d3d", format));
    foe_millipede = new FoeData("Millipede",    20, 0, 0, 40, 1, 4, spr_ant, load_model("foe.d3d", format));
    
    bullet_pebble = new BulletData("Pebble", load_model("testbullet.d3d", format));
    
    tower_pebbles =     new TowerData("Pebble Shooter",     1, 3 * 32, 1, 10, load_model("tower.d3d", format), bullet_pebble);
    tower_fire =        new TowerData("Fire Shooter",       2, 1.5 * 32, 1, 10, load_model("tower.d3d", format), bullet_pebble);
    tower_buff =     new TowerData("Friendly Tower",        1, 3 * 32, 1, 10, load_model("tower-buff.d3d", format), bullet_pebble);
    #endregion
    
    path_nodes = array_create();
    
    all_entities = ds_list_create();
    all_foes = ds_list_create();
    all_towers = ds_list_create();
    all_env_entities = ds_list_create();
    
    selected_entity = undefined;
    selected_entity_hover = undefined;
    editor_hover_entity = undefined;
    editor_path_mode = false;
    editor_model_index = 0;
    
    all_waves = ds_queue_create();
    ds_queue_enqueue(all_waves,
        new Wave(foe_ant, 8, 1),
        new Wave(foe_pillbugs, 8, 1),
        new Wave(foe_ant, 10, 2),
        new Wave(foe_ant, 10, 3),
        new Wave(foe_pillbugs, 4, 3),
    );
    wave_active = ds_list_create();
    wave_countdown = WAVE_WARMUP_COUNTDOWN;
    wave_finished = false;
    
    player_money = 50;
    player_health = 10;
    
    player_cursor_over_ui = false;
    player_tower_spawn = undefined;
    
    ui_elements_game = ds_list_create();
    with (UIButton) {
        ds_list_add(other.ui_elements_game, id);
        visible = false;
    }
    
    enum GameModes {
        GAMEPLAY, EDITOR,
    }
    
    gameplay_mode = GameModes.GAMEPLAY;
    
    SendInWave = function() {
        if (ds_queue_empty(all_waves)) {
            wave_finished = true;
        } else {
            var wave_current = ds_queue_dequeue(all_waves);
            wave_current.Launch();
            ds_list_add(wave_active, wave_current);
        }
    };
    
    PlayerDamage = function(amount) {
        player_health -= max(amount, 0);
        if (player_health < 0) {
            show_message("aaaaaaaaaaaaaaaaa");
            game_end();
        }
    };
    
    SpawnTower = function() {
        var position = camera.GetFloorIntersect();
        
        if (player_tower_spawn && position && player_money >= player_tower_spawn.cost) {
            player_money -= player_tower_spawn.cost;
            var tower = new EntityTower(position.x, position.y, position.z, player_tower_spawn);
            tower.AddToMap();
            player_tower_spawn = undefined;
        }
    };
    
    GetUnderCursor = function(entity_list) {
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
    
    Update = function() {
        camera.Update();
        
        if (keyboard_check_pressed(vk_tab)) {
            gameplay_mode = (gameplay_mode == GameModes.GAMEPLAY) ? GameModes.EDITOR : GameModes.GAMEPLAY;
            selected_entity = undefined;
        }
        
        if (gameplay_mode == GameModes.GAMEPLAY) {
            #region Gameplay stuff
            selected_entity_hover = undefined;
            if (!player_cursor_over_ui) {
                selected_entity_hover = GetUnderCursor(all_towers);
                if (mouse_check_button_pressed(mb_left)) {
                    selected_entity = selected_entity_hover;
                    if (selected_entity) {
                        
                    } else {
                        SpawnTower();
                    }
                }
            }
            
            if (keyboard_check_pressed(vk_space)) {
                SendInWave();
            }
            
            if (!wave_finished) {
                wave_countdown -= DT;
                if (wave_countdown < 0) {
                    SendInWave();
                    wave_countdown = WAVE_COUNTDOWN;
                }
            }
            
            for (var i = ds_list_size(wave_active) - 1; i >= 0; i--) {
                wave_active[| i].Update();
                if (wave_active[| i].Finished()) {
                    ds_list_delete(wave_active, i);
                }
            }
            
            for (var i = 0; i < ds_list_size(all_entities); i++) {
                all_entities[| i].BeginUpdate();
            }
            
            for (var i = 0; i < ds_list_size(all_entities); i++) {
                all_entities[| i].Update();
            }
            #endregion
        } else {
            #region Editor stuff
            if (keyboard_check_pressed(vk_f2)) {
                editor_path_mode = !editor_path_mode;
                selected_entity = undefined;
            }
            
            if (editor_path_mode) {
                editor_hover_entity = GetUnderCursor(path_nodes);
                
                if (mouse_check_button_pressed(mb_left)) {
                    if (editor_hover_entity) {
                        selected_entity = editor_hover_entity;
                    } else {
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
        
        cluck_set_light_ambient(0x202020);
        cluck_set_light_direction(0, c_white, -1, -1, -1);
        cluck_apply(shd_cluck_fragment);
        
        vertex_submit(ground, pr_trianglelist, sprite_get_texture(spr_ground, 0));
        
        for (var i = 0; i < ds_list_size(all_entities); i++) {
            all_entities[| i].Render();
        }
        
        var floor_intersect = camera.GetFloorIntersect();
        
        if (floor_intersect && player_tower_spawn) {
            shader_set(shd_selected);
            shader_set_uniform_f(shader_get_uniform(shd_selected, "time"), current_time / 1000);
            shader_set_uniform_f(shader_get_uniform(shd_selected, "color"), c_phantom_tower_r, c_phantom_tower_g, c_phantom_tower_b, 1);
            matrix_set(matrix_world, matrix_build(floor_intersect.x, floor_intersect.y, 0, 0, 0, 0, 1, 1, 1));
            vertex_submit(player_tower_spawn.model, pr_trianglelist, -1);
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
        
        shader_reset();
    };
    
    GUI = function() {
        if (gameplay_mode == GameModes.GAMEPLAY) {
            draw_text(32, 32, "Player money: " + string(player_money));
            draw_text(32, 64, "Player health: " + string(player_health));
            
            player_cursor_over_ui = false;
            
            for (var i = 0; i < ds_list_size(ui_elements_game); i++) {
                ui_elements_game[| i].Render();
            }
            
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
                draw_text(window_get_width() - 128, 32, "F1 to save");
            }
        }
    };
}