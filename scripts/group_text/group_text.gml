function L(text, args = undefined) {
    if (text == "") return "";
    // example: "Your score is %0, and your health is %1"
    
    if (variable_struct_exists(Text[GAME.language_index], text) && Text[GAME.language_index][$ text] != "") {
        var translation = Text[GAME.language_index][$ text];
        if (translation != undefined) {
            text = translation;
        }
    } else {
        show_debug_message("Translated string not found: " + text);
        Text[0][$ text] = text;
        Text[GAME.language_index][$ text] = undefined;
        if (SAVE_ON_MISSING_TEXT) save_text_csv("strings.csv");
    }
    
    if (args != undefined) {
        if (!is_array(args)) args = [args];
        for (var i = 0, n = array_length(args); i < n; i++) {
            text = string_replace_all(text, "%" + string(i), string(args[i]));
        }
    }
    
    return text;
}

function save_text_csv(filename) {
    static output = buffer_create(1000, buffer_grow, 1);
    buffer_seek(output, buffer_seek_start, 0);
    
    var keys = variable_struct_get_names(Text[0]);
    array_sort(keys, true);
    
    for (var i = 0, h = array_length(keys); i < h; i++) {
        for (var j = 0, w = array_length(Text); j < w; j++) {
            var translation = Text[j][$ keys[i]];
            buffer_write(output, buffer_text, ((translation != undefined) ? string_replace_all(translation, "\n", "\\n") : "") + ",");
        }
        buffer_write(output, buffer_text, "\r\n");
    }
    
    buffer_save_ext(output, filename, 0, buffer_tell(output));
}

#macro TEXT_FILE "text.csv"
#macro SAVE_ON_MISSING_TEXT true
#macro release:SAVE_ON_MISSING_TEXT false
#macro pi_release:SAVE_ON_MISSING_TEXT false
#macro Text global.__text

function text_initialize() {
    Text = array_create(array_length(GAME.languages));
    for (var i = 0, n = array_length(Text); i < n; i++) {
        Text[i] = { };
    }
    
    var text_grid = -1;
    
    try {
        text_grid = load_csv(TEXT_FILE);
        
        // going to re-initialize text here just in case the languages you get
        // dont match the languages you expect
        Text = array_create(max(ds_grid_width(text_grid), array_length(GAME.languages)));
        for (var i = 0, n = array_length(Text); i < n; i++) {
            Text[i] = { };
        }
        
        for (var i = 0, w = ds_grid_width(text_grid); i < w; i++) {
            for (var j = 0, h = ds_grid_height(text_grid); j < h; j++) {
                Text[i][$ text_grid[# 0, j]] = string_replace_all(text_grid[# i, j], "\\n", "\n");
            }
        }
        
        ds_grid_destroy(text_grid);
    } catch (e) {
        show_debug_message("Couldn't load the language text: " + e.message);
        show_debug_message(e.longMessage);
    } finally {
        if (ds_exists(text_grid, ds_type_grid)) {
            ds_grid_destroy(text_grid);
        }
    }
}