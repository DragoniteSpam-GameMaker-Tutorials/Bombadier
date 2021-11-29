OnClick = function() {
    GAME.GoToLevel(5);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 4);
};