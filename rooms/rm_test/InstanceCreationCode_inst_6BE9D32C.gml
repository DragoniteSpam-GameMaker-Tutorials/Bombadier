OnClick = function() {
    GAME.player_tower_spawn = new EntityTowerBird(0, 0, 0, GAME.tower_bird);
};

Update = function() {
    var tower = GAME.tower_bird;
    self.text_args = [string(tower.cost[0])];
};

OnHover = function() {
    GAME.show_tooltip_tower = true;
    inst_tooltip_tower.text = "@TOWER_TOOLTIP";
    inst_tooltip_tower.text_args = [GAME.tower_bird.name, GAME.tower_bird.descriptions[0]];
};