function draw_rectangle_9s(sprite, xx, yy, width, height) {
    var sw = sprite_get_width(sprite) / 3;
    var sh = sprite_get_height(sprite) / 3;
    
    draw_sprite_part(sprite, 0, 0, 0, sw, sh, xx, yy);
    draw_sprite_part(sprite, 0, 2 * sw, 0, sw, sh, xx + width - sw, yy);
    draw_sprite_part(sprite, 0, 2 * sw, 2 * sh, sw, sh, xx + width - sw, yy + height - sh);
    draw_sprite_part(sprite, 0, 0, 2 * sh, sw, sh, xx, yy + height - sh);
    
    var hxscale = (width - 2 * sw) / sw;
    var vyscale = (height - 2 * sh) / sh;
    
    draw_sprite_general(sprite, 0, sw, 0, sw, sh, xx + sw, yy, hxscale, 1, 0, c_white, c_white, c_white, c_white, 1);
    draw_sprite_general(sprite, 0, sw, sh*2, sw, sh, xx + sw, yy + height - sh, hxscale, 1, 0, c_white, c_white, c_white, c_white, 1);
    
    draw_sprite_general(sprite, 0, 0, sh, sw, sh, xx, yy + sh, 1, vyscale, 0, c_white, c_white, c_white, c_white, 1);
    draw_sprite_general(sprite, 0, 2 * sw, sh, sw, sh, xx + width - sw, yy + sh, 1, vyscale, 0, c_white, c_white, c_white, c_white, 1);
    
    draw_sprite_general(sprite, 0, sw, sh, sw, sh, xx + sw, yy + sh, hxscale, vyscale, 0, c_white, c_white, c_white, c_white, 1);
}