OnClick = function() {
    var step_size = 10;
    GAME.volume_master = max(GAME.volume_master - step_size, 0);
    GAME.SaveSettings();
};