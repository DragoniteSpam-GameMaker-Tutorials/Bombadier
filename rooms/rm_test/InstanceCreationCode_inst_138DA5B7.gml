GetText = function() {
    if (GAME.wave_countdown > 0) {
        var wave_time = string(floor(GAME.wave_countdown));
    } else {
        var wave_time = "---";
    }
    text = wave_time + " to next wave\n" +
        "Money: " + string(GAME.player_money) + "\n" +
        "Health: " + string(GAME.player_health);
};