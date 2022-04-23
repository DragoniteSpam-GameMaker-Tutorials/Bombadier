OnClick = function() {
    GAME.GoToLevel(10);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 9) || !RELEASE_MODE;
};