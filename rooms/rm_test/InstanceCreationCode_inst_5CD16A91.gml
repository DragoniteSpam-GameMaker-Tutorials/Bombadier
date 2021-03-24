OnClick = function() {
    GAME.SetGameSpeed(1);
};

Update = function() {
    if (GAME.game_speed == 1) {
        color_tint = c_aqua;
    } else {
        color_tint = c_white;
    }
};