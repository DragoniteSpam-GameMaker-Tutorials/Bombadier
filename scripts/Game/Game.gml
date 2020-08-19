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
        var obj_name = string_replace(file, "000.d3d", "");
        env_objects[? obj_name] = vbuff;
        ds_list_add(env_object_list, obj_name);
    }
    #endregion
    
    test_ball = load_model("testball.d3d", format);
    
    skybox_cube = load_model("skybox.d3d", format);
    
    #region database
    foe_ant =       new FoeData("Ant",          5, 0, 0, 100, 1, 2, spr_ant, load_model("foe.d3d", format));
    foe_pillbugs =  new FoeData("Pillbugs",     10, 1, 0, 100, 1, 3, spr_ant_red, load_model("foe.d3d", format));
    foe_spider =    new FoeData("Spider",       10, 0, 1, 64, 1, 4, spr_ant, load_model("foe.d3d", format));
    foe_millipede = new FoeData("Millipede",    20, 0, 0, 40, 1, 4, spr_ant, load_model("foe.d3d", format));
    
    bullet_pebble = new BulletData("Pebble", load_model("testbullet.d3d", format));
    
    tower_pebbles =     new TowerData("Pebble Shooter",     1, 3 * 32, 1, 10, load_model("tower.d3d", format), bullet_pebble);
    tower_fire =        new TowerData("Fire Shooter",       2, 1.5 * 32, 1, 10, load_model("tower.d3d", format), bullet_pebble);
    #endregion
    
    all_entities = ds_list_create();
    all_foes = ds_list_create();
    all_towers = ds_list_create();
    
    all_waves = ds_queue_create();
    ds_queue_enqueue(all_waves,
        new Wave(foe_ant, 8, 1),
        new Wave(foe_pillbugs, 8, 1),
    );
    wave_current = undefined;
    wave_countdown = WAVE_WARMUP_COUNTDOWN;
    wave_finished = false;
    
    player_money = 50;
    player_health = 10;
    
    enum GameModes {
        GAMEPLAY, EDITOR,
    }
    
    gameplay_mode = GameModes.GAMEPLAY;
    
    SendInWave = function() {
        if (ds_queue_empty(all_waves)) {
            wave_finished = true;
        } else {
            wave_current = ds_queue_dequeue(all_waves);
            wave_current.Launch();
        }
    };
    
    PlayerDamage = function(amount) {
        player_health -= max(amount, 0);
        if (player_health < 0) {
            show_message("aaaaaaaaaaaaaaaaa");
            game_end();
        }
    };
    
    Update = function() {
        camera.Update();
        
        if (keyboard_check_pressed(vk_tab)) {
            gameplay_mode = (gameplay_mode == GameModes.GAMEPLAY) ? GameModes.EDITOR : GameModes.GAMEPLAY;
        }
        
        if (gameplay_mode == GameModes.GAMEPLAY) {
            #region Gameplay stuff
            if (mouse_check_button_pressed(mb_left)) {
                var position = camera.GetFloorIntersect();
                var tower_type = tower_pebbles;
                if (position && player_money >= tower_type.cost) {
                    player_money -= tower_type.cost;
                    var tower = new EntityTower(position.x, position.y, position.z, tower_type);
                    ds_list_add(all_entities, tower);
                    ds_list_add(all_towers, tower);
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
            
            if (wave_current) {
                wave_current.Update();
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
            if (mouse_check_button_pressed(mb_left)) {
                var position = camera.GetFloorIntersect();
                var spawn_name = env_object_list[| irandom(ds_list_size(env_object_list) - 1)];
                var ent = new EntityEnv(position.x, position.y, 0, env_objects[? spawn_name], spawn_name);
                ds_list_add(all_entities, ent);
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
            entities: array_create(ds_list_size(all_entities), undefined),
        };
        for (var i = 0; i < ds_list_size(all_entities); i++) {
            all_entities[| i].Save(save_json, i);
        }
        
        var json_string = snap_to_json(save_json);
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
            var load_json = snap_from_json(json_string);
            for (var i = 0; i < array_length(load_json.entities); i++) {
                var data = load_json.entities[i];
                if (is_struct(data)) {
                    var ent = new EntityEnv(data.position.x, data.position.y, 0, env_objects[? data.name], data.name);
                    ds_list_add(all_entities, ent);
                }
            }
        } catch (e) {
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
        
        vertex_submit(ground, pr_trianglelist, sprite_get_texture(spr_grid, 0));
        
        for (var i = 0; i < ds_list_size(all_entities); i++) {
            all_entities[| i].Render();
        }
        shader_reset();
    };
    
    GUI = function() {
        if (gameplay_mode == GameModes.GAMEPLAY) {
            draw_text(32, 32, "Player money: " + string(player_money));
            draw_text(32, 64, "Player health: " + string(player_health));
        } else {
            draw_text(32, 32, "Click to spawn a thing");
            draw_text(32, 64, "F1 to save");
        }
    };
    
    LoadMap("maps\\map1.bug");
}