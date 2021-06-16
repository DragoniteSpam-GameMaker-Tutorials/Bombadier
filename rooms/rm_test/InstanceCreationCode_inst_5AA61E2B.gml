OnClick = function() {
    GAME.resolution_scalar_index = max(GAME.resolution_scalar_index - 1, 0);
    GAME.resolution_scalar = GAME.resolution_scalar_options[GAME.resolution_scalar_index];
    GAME.ApplyScreenSize();
    GAME.SaveSettings();
};