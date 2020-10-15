function load_model(filename, format) {
    var model = vertex_create_buffer();
    vertex_begin(model, format);
    
    var file = file_text_open_read(filename);
    var version = file_text_read_real(file);
    var n = file_text_read_real(file);
    file_text_readln(file);

    var line = array_create(10, 0);

    for (var i = 0; i < n; i++) {
        var str = file_text_read_string(file);
        file_text_readln(file);
        
        var sstr = "";
        var index = 0;
        for (var j = 1; j <= string_length(str); j++) {
            var c = string_char_at(str, j);
            if (c == " ") {
                line[index++] = sstr;
                sstr = "";
            } else {
                sstr += c;
            }
        }
        if (sstr != "") line[index++] = sstr;
        
        if (line[0] == 9) {
            vertex_position_3d(model, line[1], line[2], line[3]);
            vertex_normal(model, line[4], line[5], line[6]);
            vertex_texcoord(model, line[7], line[8]);
            vertex_colour(model, line[9], line[10]);
        }
    }
    
    file_text_close(file);
    vertex_end(model);
    
    return model;
}