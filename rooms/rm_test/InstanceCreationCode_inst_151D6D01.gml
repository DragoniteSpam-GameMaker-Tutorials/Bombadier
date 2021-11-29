OnClick = function() {
    GAME.GoToLevel(8);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 7);
};