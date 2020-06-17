#macro GAME Help.game

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
    
    foe_ant =       new FoeData("Ant",          5, 0, 0, 2, 1, 0);
    foe_pillbugs =  new FoeData("Pillbugs",     10, 1, 0, 2, 1, 0);
    foe_spider =    new FoeData("Spider",       10, 0, 1, 2, 1, 0);
    foe_millipede = new FoeData("Millipede",    20, 0, 0, 1, 1, 0);
    
    tower_pebbles =     new TowerData("Pebble Shooter",     1, 3, 1, 10, 0);
    tower_fire =        new TowerData("Fire Shooter",       2, 1.5, 1, 10, 0);
    
    Update = function() {
        camera.Update();
    };
    
    Render = function() {
        camera.Render();
        
        vertex_submit(ground, pr_trianglelist, sprite_get_texture(spr_grid, 0));
    };
}