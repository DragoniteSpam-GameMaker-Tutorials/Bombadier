OnClick = function() {
    var step_size = 10;
    GAME.volume_master = min(GAME.volume_master + step_size, 100);
    GAME.SaveSettings();
};