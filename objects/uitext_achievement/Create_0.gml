event_inherited();

text_args = [];

Render = function() {
    var subimg = 0;
    
    self.GetText();
    var achievement = KestrelSystem.Get(self.achievement_index);
    var unlocked = achievement.GetComplete();
    
    draw_sprite_stretched(unlocked ? achievement.icon_unlocked : achievement.icon_locked, subimg, x, y, sprite_width, sprite_height);
    draw_set_font(fnt_game_buttons);
    draw_set_colour(c_black);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_text(x + sprite_width + 16, y + sprite_height / 2, L(achievement.GetName()));
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    if (unlocked && point_in_rectangle(window_mouse_get_x(), window_mouse_get_y(), x, y, x + sprite_width, y + sprite_height)) {
        GAME.show_tooltip_floating.x = x;
        GAME.show_tooltip_floating.y = y + sprite_height + 32;
        GAME.show_tooltip_floating.w = 320;
        GAME.show_tooltip_floating.enabled = true;
        GAME.show_tooltip_floating.text = achievement.description;
    }
}