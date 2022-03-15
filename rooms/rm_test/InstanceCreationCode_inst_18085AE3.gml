OnClick = function() {
    GAME.GoToLevel(9);
    GAME.PlayBGM(bgm_forest);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 8) || !RELEASE_MODE;
};