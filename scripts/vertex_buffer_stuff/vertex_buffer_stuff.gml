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

function create_water_vbuffer(format) {
    var water = vertex_create_buffer();
    vertex_begin(water, format);
    
    var padding = 512;
    var x1 = -padding;
    var y1 = -padding;
    var x2 = room_width + padding;
    var y2 = room_height + padding;
    var z = -4;
    var c = c_blue;
    var a = 1;
    
    // 0
    vertex_position_3d(water, x1, y1, z);
    vertex_normal(water, 0, 0, 1);
    vertex_colour(water, c, a);
    // 1
    vertex_position_3d(water, x2, y1, z);
    vertex_normal(water, 0, 0, 1);
    vertex_colour(water, c, a);
    // 2
    vertex_position_3d(water, x2, y2, z);
    vertex_normal(water, 0, 0, 1);
    vertex_colour(water, c, a);
    // 3
    vertex_position_3d(water, x2, y2, z);
    vertex_normal(water, 0, 0, 1);
    vertex_colour(water, c, a);
    // 4
    vertex_position_3d(water, x1, y2, z);
    vertex_normal(water, 0, 0, 1);
    vertex_colour(water, c, a);
    // 5
    vertex_position_3d(water, x1, y1, z);
    vertex_normal(water, 0, 0, 1);
    vertex_colour(water, c, a);
    
    vertex_end(water);
    
    return water;
}

function edit_ground_height(source, floor_intersect, edit_direction, format) {
    var ground_buffer = buffer_create_from_vertex_buffer(source, buffer_fixed, 1);
    
    var edit_radius = 100;
    var edit_rate = 0.25;
    
    for (var i = 0, n = buffer_get_size(ground_buffer); i < n; i += 28) {
        var xx = buffer_peek(ground_buffer, i + 00, buffer_f32);
        var yy = buffer_peek(ground_buffer, i + 04, buffer_f32);
        var zz = buffer_peek(ground_buffer, i + 08, buffer_f32);
        
        if (point_distance(floor_intersect.x, floor_intersect.y, xx, yy) < edit_radius) {
            buffer_poke(ground_buffer, i + 08, buffer_f32, zz + edit_direction);
            
            var base_index = (i div 84) * 84;
            var x1 = buffer_peek(ground_buffer, base_index + 00, buffer_f32);
            var y1 = buffer_peek(ground_buffer, base_index + 04, buffer_f32);
            var z1 = buffer_peek(ground_buffer, base_index + 08, buffer_f32);
            var x2 = buffer_peek(ground_buffer, base_index + 28, buffer_f32);
            var y2 = buffer_peek(ground_buffer, base_index + 32, buffer_f32);
            var z2 = buffer_peek(ground_buffer, base_index + 36, buffer_f32);
            var x3 = buffer_peek(ground_buffer, base_index + 56, buffer_f32);
            var y3 = buffer_peek(ground_buffer, base_index + 60, buffer_f32);
            var z3 = buffer_peek(ground_buffer, base_index + 64, buffer_f32);
            var normals = triangle_normal(x1, y1, z1, x2, y2, z2, x3, y3, z3);
            buffer_poke(ground_buffer, base_index + 12, buffer_f32, normals.x);
            buffer_poke(ground_buffer, base_index + 16, buffer_f32, normals.y);
            buffer_poke(ground_buffer, base_index + 20, buffer_f32, normals.z);
            buffer_poke(ground_buffer, base_index + 40, buffer_f32, normals.x);
            buffer_poke(ground_buffer, base_index + 44, buffer_f32, normals.y);
            buffer_poke(ground_buffer, base_index + 48, buffer_f32, normals.z);
            buffer_poke(ground_buffer, base_index + 68, buffer_f32, normals.x);
            buffer_poke(ground_buffer, base_index + 72, buffer_f32, normals.y);
            buffer_poke(ground_buffer, base_index + 76, buffer_f32, normals.z);
        }
    }
    
    vertex_delete_buffer(source);
    var new_vertex_buffer = vertex_create_buffer_from_buffer(ground_buffer, format);
    buffer_delete(ground_buffer);
    return new_vertex_buffer;
}

function edit_ground_reset_height(source, format) {
    var ground_buffer = buffer_create_from_vertex_buffer(source, buffer_fixed, 1);
    
    for (var i = 0, n = buffer_get_size(ground_buffer); i < n; i += 28) {
        var zz = buffer_peek(ground_buffer, i + 08, buffer_f32);
        var nx = buffer_peek(ground_buffer, i + 12, buffer_f32);
        var ny = buffer_peek(ground_buffer, i + 16, buffer_f32);
        var nz = buffer_peek(ground_buffer, i + 20, buffer_f32);
        
        buffer_poke(ground_buffer, i + 08, buffer_f32, 0);
        buffer_poke(ground_buffer, i + 12, buffer_f32, 0);
        buffer_poke(ground_buffer, i + 16, buffer_f32, 0);
        buffer_poke(ground_buffer, i + 20, buffer_f32, 1);
    }
    
    vertex_delete_buffer(source);
    var new_vertex_buffer = vertex_create_buffer_from_buffer(ground_buffer, format);
    buffer_delete(ground_buffer);
    return new_vertex_buffer;
}

function edit_ground_color(source, color, format) {
    var ground_buffer = buffer_create_from_vertex_buffer(source, buffer_fixed, 1);
    
    var edit_radius = 100;
    
    for (var i = 0, n = buffer_get_size(ground_buffer); i < n; i += 28) {
        var cc = buffer_peek(ground_buffer, i + 24, buffer_u32);
        var aa = cc & 0xff000000;
        cc = color | aa;
        buffer_poke(ground_buffer, i + 24, buffer_u32, cc);
    }
    
    vertex_delete_buffer(source);
    var new_vertex_buffer = vertex_create_buffer_from_buffer(ground_buffer, format);
    buffer_delete(ground_buffer);
    return new_vertex_buffer;
}