OnClick = function() {
    GAME.GoToLevel(4);
    GAME.PlayBGM(bgm_forest);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 3) || !RELEASE_MODE;
};