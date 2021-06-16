OnClick = function() {
    GAME.frame_rate_index = max(GAME.frame_rate_index - 1, 0);
    game_set_speed(GAME.frame_rates[GAME.frame_rate_index], gamespeed_fps);
    GAME.SaveSettings();
};