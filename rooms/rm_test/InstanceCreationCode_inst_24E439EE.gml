OnClick = function() {
    GAME.player_tower_spawn = new EntityTowerGlass(0, 0, 0, GAME.tower_magnify);
};

Update = function() {
    var tower = GAME.tower_magnify;
    self.text_args = [string(tower.cost[0])];
};

OnHover = function() {
    GAME.show_tooltip_tower = true;
    inst_tooltip_tower.text = "@TOWER_TOOLTIP";
    inst_tooltip_tower.text_args = [GAME.tower_magnify.name, GAME.tower_magnify.descriptions[0]];
};