OnClick = function() {
    GAME.language_index++;
    if (GAME.language_index >= array_length(GAME.languages)) {
        GAME.language_index = 1;
    }
    GAME.SaveSettings();
};