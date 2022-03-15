OnClick = function() {
    GAME.GoToLevel(7);
    GAME.PlayBGM(bgm_forest);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 6) || !RELEASE_MODE;
};