Render = function() {
    draw_rectangle_9s(sprite_index, 0, x, y, sprite_width, sprite_height);
    draw_set_font(fnt_game_buttons);
    draw_set_colour(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(x + sprite_width / 2, y + sprite_height / 2, text);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}