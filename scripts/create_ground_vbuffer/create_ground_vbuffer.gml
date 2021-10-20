function create_ground_vbuffer(format) {
    var ground = vertex_create_buffer();
    vertex_begin(ground, format);
    
    var padding = 512;
    var tile_size = 64;
    for (var i = -padding; i < room_width + padding; i += tile_size) {
        for (var j = -padding; j < room_height * 1.5; j += tile_size) {
            // 0
            vertex_position_3d(ground, i, j, 0);
            vertex_normal(ground, 0, 0, 1);
            vertex_colour(ground, c_white, 1);
            // 1
            vertex_position_3d(ground, i + tile_size, j, 0);
            vertex_normal(ground, 0, 0, 1);
            vertex_colour(ground, c_white, 1);
            // 2
            vertex_position_3d(ground, i + tile_size, j + tile_size, 0);
            vertex_normal(ground, 0, 0, 1);
            vertex_colour(ground, c_white, 1);
            // 3
            vertex_position_3d(ground, i + tile_size, j + tile_size, 0);
            vertex_normal(ground, 0, 0, 1);
            vertex_colour(ground, c_white, 1);
            // 4
            vertex_position_3d(ground, i, j + tile_size, 0);
            vertex_normal(ground, 0, 0, 1);
            vertex_colour(ground, c_white, 1);
            // 5
            vertex_position_3d(ground, i, j, 0);
            vertex_normal(ground, 0, 0, 1);
            vertex_colour(ground, c_white, 1);
        }
    }
    
    vertex_end(ground);
    
    return ground;
}