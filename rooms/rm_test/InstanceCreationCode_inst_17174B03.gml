OnClick = function() {
    GAME.GoToLevel(12);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 11) || !RELEASE_MODE;
};