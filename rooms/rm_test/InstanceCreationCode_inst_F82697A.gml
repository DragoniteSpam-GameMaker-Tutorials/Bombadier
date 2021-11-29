OnClick = function() {
    GAME.GoToLevel(7);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 6);
};