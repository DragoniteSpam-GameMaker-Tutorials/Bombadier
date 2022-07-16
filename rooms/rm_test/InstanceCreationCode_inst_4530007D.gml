OnClick = function() {
    GAME.frame_rate_index = min(GAME.frame_rate_index + 1, array_length(GAME.frame_rates) - 1);
    game_set_speed(GAME.frame_rates[GAME.frame_rate_index], gamespeed_fps);
    GAME.SaveSettings();
};

Update = function() {
    self.enabled = !IS_OGX;
};