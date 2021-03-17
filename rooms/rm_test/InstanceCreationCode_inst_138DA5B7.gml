GetText = function() {
    if (GAME.wave_countdown > 0) {
        var wave_time = string(floor(GAME.wave_countdown));
    } else {
        var wave_time = "---";
    }
    if (ds_queue_size(GAME.all_waves) == GAME.wave_total) {
        var wave_text = "-/" + string(GAME.wave_total);
    } else {
        var wave_text = string(GAME.wave_total - ds_queue_size(GAME.all_waves)) + "/" + string(GAME.wave_total);
    }
    text = wave_time + " to next wave\n" +
        "Money: " + string(GAME.player_money) + "\n" +
        "Health: " + string(GAME.player_health) + "\n" +
        "Wave " + wave_text;
        
};