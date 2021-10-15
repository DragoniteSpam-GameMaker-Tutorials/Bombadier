function load_vbuff(filename, format) {
    var buffer = buffer_load(filename);
    var vbuff = vertex_create_buffer_from_buffer(buffer, format);
    buffer_delete(buffer);
    return new ModelData(filename, vbuff);
}