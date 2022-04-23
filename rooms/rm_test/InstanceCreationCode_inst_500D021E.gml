OnClick = function() {
    GAME.GoToLevel(6);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 5) || !RELEASE_MODE;
};