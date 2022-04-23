OnClick = function() {
    GAME.GoToLevel(11);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 10) || !RELEASE_MODE;
};