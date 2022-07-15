OnClick = function() {
    GAME.language_index--;
    if (GAME.language_index <= 0) GAME.language_index = array_length(GAME.languages) - 1;
    GAME.SaveSettings();
};