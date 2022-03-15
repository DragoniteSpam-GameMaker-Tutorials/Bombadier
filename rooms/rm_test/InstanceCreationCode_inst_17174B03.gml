OnClick = function() {
    GAME.GoToLevel(12);
    GAME.PlayBGM(bgm_forest);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 11) || !RELEASE_MODE;
};