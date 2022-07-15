OnClick = function() {
    GAME.player_tower_spawn = new EntityTowerFlyPaper(0, 0, 0, GAME.tower_flypaper);
};

Update = function() {
    var tower = GAME.tower_flypaper;
    self.text_args = [string(tower.cost[0])];
    self.enabled = GAME.player_money >= tower.cost[0];
};

OnHover = function() {
    GAME.show_tooltip_tower = true;
    inst_tooltip_tower.text = "@TOWER_TOOLTIP";
    inst_tooltip_tower.text_args = [L(GAME.tower_flypaper.name), L(GAME.tower_flypaper.descriptions[0])];
};