OnClick = function() {
    GAME.GoToLevel(2);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 1) || !RELEASE_MODE;
};