OnClick = function() {
    GAME.GoToLevel(3);
    GAME.PlayBGM(bgm_forest);
};

Update = function() {
    self.enabled = (GAME.player_save.highest_level >= 2);
};