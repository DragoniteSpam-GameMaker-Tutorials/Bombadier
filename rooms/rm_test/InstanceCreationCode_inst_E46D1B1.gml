OnClick = function() {
    GAME.screen_size_index = min(GAME.screen_size_index + 1, array_length(GAME.screen_sizes) - 1);
    var size = GAME.screen_sizes[GAME.screen_size_index];
    GAME.current_screen_size.x = size.x;
    GAME.current_screen_size.y = size.y;
    GAME.ApplyScreenSize();
    GAME.SaveSettings();
};

Update = function() {
    self.enabled = !window_get_fullscreen();
};