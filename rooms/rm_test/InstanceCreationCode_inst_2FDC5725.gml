OnClick = function() {
    GAME.GoToLevel(4);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 3);
};