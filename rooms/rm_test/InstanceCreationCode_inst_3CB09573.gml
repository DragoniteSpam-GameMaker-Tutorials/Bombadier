OnClick = function() {
    var step_size = 10;
    GAME.particle_density = min(GAME.particle_density * 100 + step_size, 100) / 100;
    GAME.SaveSettings();
};