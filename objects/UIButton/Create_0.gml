event_inherited();

self.enabled = true;
self.text = self.source_text;
self.text_args = [];

Render = function() {
    var subimg = 0;
    self.Update();
    
    if (self.enabled) {
        if (point_in_rectangle(window_mouse_get_x(), window_mouse_get_y(), x, y, x + sprite_width, y + sprite_height)) {
            self.OnHover();
            subimg = 1;
            if (mouse_check_button_pressed(mb_left)) {
                if (self.sound_on_click != noone) {
                    audio_play_sound(self.sound_on_click, SOUND_PRIORITY_UI, false)
                }
                self.OnClick();
            }
            GAME.player_cursor_over_ui = true;
        }
    } else {
        subimg = 1;
    }
    
    draw_sprite_stretched_ext(sprite_index, subimg, x, y, sprite_width, sprite_height, self.color_tint, 1);
    if (sprite_exists(self.background_sprite)) {
        if (self.background_sprite_multiply) {
            gpu_set_blendmode_ext(bm_dest_color, bm_inv_src_alpha);
        }
        if (self.background_sprite_stretch) {
            draw_sprite_stretched(self.background_sprite, 0, self.x, self.y, self.sprite_width, self.sprite_height);
        } else {
            draw_sprite(self.background_sprite, 0, self.x + self.sprite_width / 2, self.y + self.sprite_height / 2);
        }
        gpu_set_blendmode(bm_normal);
    }
    draw_set_font(fnt_game_buttons);
    draw_set_colour(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(x + sprite_width / 2, y + sprite_height / 2, L(self.text, self.text_args));
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
};

OnClick = function() {
    
};

Update = function() {
};

OnHover = function() {
    
};