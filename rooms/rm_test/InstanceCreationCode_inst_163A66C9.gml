OnClick = function() {
    var step_size = 10;
    GAME.particle_density = max(GAME.particle_density * 100 - step_size, 0) / 100;
    GAME.SaveSettings();
};