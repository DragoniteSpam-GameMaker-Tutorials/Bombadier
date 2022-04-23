OnClick = function() {
    GAME.GoToLevel(3);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 2) || !RELEASE_MODE;
};