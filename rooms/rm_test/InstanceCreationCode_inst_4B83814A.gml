OnClick = function() {
    GAME.language_index = ++GAME.language_index % array_length(GAME.languages);
    GAME.SaveSettings();
};