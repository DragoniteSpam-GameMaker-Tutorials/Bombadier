OnClick = function() {
    GAME.resolution_scalar_index = min(GAME.resolution_scalar_index + 1, array_length(GAME.resolution_scalar_options) - 1);
    GAME.resolution_scalar = GAME.resolution_scalar_options[GAME.resolution_scalar_index];
    GAME.ApplyScreenSize();
    GAME.SaveSettings();
};