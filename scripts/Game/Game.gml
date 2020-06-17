#macro GAME Backbone.game

function Game() constructor {
    camera = new Camera();
    
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
    
    foe_ant =       new FoeData("Ant",          5, 0, 0, 64, 1, spr_ant, load_model("foe.d3d", format));
    foe_pillbugs =  new FoeData("Pillbugs",     10, 1, 0, 64, 1, spr_ant, load_model("foe.d3d", format));
    foe_spider =    new FoeData("Spider",       10, 0, 1, 64, 1, spr_ant, load_model("foe.d3d", format));
    foe_millipede = new FoeData("Millipede",    20, 0, 0, 40, 1, spr_ant, load_model("foe.d3d", format));
    
    tower_pebbles =     new TowerData("Pebble Shooter",     1, 3, 1, 10, load_model("tower.d3d", format));
    tower_fire =        new TowerData("Fire Shooter",       2, 1.5, 1, 10, load_model("tower.d3d", format));
    
    all_entities = ds_list_create();
    ds_list_add(all_entities, new EntityTower(640, 360, 0, tower_pebbles));
    ds_list_add(all_entities, new EntityTower(760, 240, 0, tower_fire));
    
    ds_list_add(all_entities, new EntityFoe(foe_ant, 1));
    /*ds_list_add(all_entities, new EntityFoe(foe_ant, 1));
    ds_list_add(all_entities, new EntityFoe(foe_ant, 1));
    ds_list_add(all_entities, new EntityFoe(foe_ant, 1));
    ds_list_add(all_entities, new EntityFoe(foe_ant, 1));*/
    
    Update = function() {
        camera.Update();
        
        for (var i = 0; i < ds_list_size(all_entities); i++) {
            all_entities[| i].Update();
        }
    };
    
    Render = function() {
        camera.Render();
        
        vertex_submit(ground, pr_trianglelist, sprite_get_texture(spr_grid, 0));
        
        for (var i = 0; i < ds_list_size(all_entities); i++) {
            all_entities[| i].Render();
        }
    };
}