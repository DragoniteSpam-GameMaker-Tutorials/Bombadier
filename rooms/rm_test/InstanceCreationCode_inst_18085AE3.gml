OnClick = function() {
    GAME.GoToLevel(9);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 8) || !RELEASE_MODE;
};