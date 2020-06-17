function load_model(filename, format) {
    var model = vertex_create_buffer();
    vertex_begin(model, format);
    
    var file = file_text_open_read(filename);
    var version = file_text_read_real(file);
    var n = file_text_read_real(file);
    file_text_readln(file);

    var line = array_create(10, 0);

    for (var i = 0; i < n; i++){
    	for (var j = 0; j < 11; j++){
    		line[j] = file_text_read_real(file);
    	}
        
        if (line[0] == 9) {
            vertex_position_3d(model, line[1], line[2], line[3]);
            vertex_normal(model, line[4], line[5], line[6]);
            vertex_texcoord(model, line[7], line[8]);
            vertex_color(model, line[9], line[10]);
        }
    }
    
    file_text_close(file);
    vertex_end(model);
    
    return model;
}