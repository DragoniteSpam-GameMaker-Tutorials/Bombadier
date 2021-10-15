function process_vbuff(folder, filename) {
    var buffer = buffer_load(folder + "/" + filename);
    
    var old_vertex_size = 36;
    var new_vertex_size = 28;
    var vertices = buffer_get_size(buffer) / old_vertex_size;
    
    var new_buffer = buffer_create(vertices * new_vertex_size, buffer_fixed, 1);
    
    repeat (vertices) {
        var xx = buffer_read(buffer, buffer_f32);
        var yy = buffer_read(buffer, buffer_f32);
        var zz = buffer_read(buffer, buffer_f32);
        var nx = buffer_read(buffer, buffer_f32);
        var ny = buffer_read(buffer, buffer_f32);
        var nz = buffer_read(buffer, buffer_f32);
        var xt = buffer_read(buffer, buffer_f32);
        var yt = buffer_read(buffer, buffer_f32);
        var cc = buffer_read(buffer, buffer_u32);
        
        buffer_write(new_buffer, buffer_f32, xx);
        buffer_write(new_buffer, buffer_f32, yy);
        buffer_write(new_buffer, buffer_f32, zz);
        buffer_write(new_buffer, buffer_f32, nx);
        buffer_write(new_buffer, buffer_f32, ny);
        buffer_write(new_buffer, buffer_f32, nz);
        buffer_write(new_buffer, buffer_u32, cc);
    }
    
    buffer_save(new_buffer, filename);
    show_debug_message("Saved a buffer: " + filename);
    
    buffer_delete(buffer);
}