function debug_draw_collision(x, y) {
    var old_colour = draw_get_colour();
    draw_set_colour(c_black);
    draw_rectangle(x, y, x + ds_grid_width(GAME.collision_grid), y + ds_grid_height(GAME.collision_grid), false);
    draw_set_colour(c_white);
    for (var i = 0; i < ds_grid_width(GAME.collision_grid); i++) {
        for (var j = 0; j < ds_grid_height(GAME.collision_grid); j++) {
            if (GAME.collision_grid[# i, j] == GRID_COLLISION_FILLED) {
                draw_point(x + i, y + j);
            }
        }
    }
    
    draw_set_colour(old_colour);
}