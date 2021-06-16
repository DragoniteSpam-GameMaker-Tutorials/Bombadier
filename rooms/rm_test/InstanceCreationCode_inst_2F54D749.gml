OnClick = function() {
    GAME.screen_size_index = max(GAME.screen_size_index - 1, 0);
    var size = GAME.screen_sizes[GAME.screen_size_index];
    GAME.current_screen_size.x = size.x;
    GAME.current_screen_size.y = size.y;
    GAME.ApplyScreenSize();
};