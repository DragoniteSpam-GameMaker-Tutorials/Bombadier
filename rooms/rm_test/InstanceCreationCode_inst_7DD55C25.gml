OnClick = function() {
    GAME.player_tower_spawn = new EntityTowerFire(0, 0, 0, GAME.tower_fire);
};

Update = function() {
    var tower = GAME.tower_fire;
    self.text_args = [string(tower.cost[0])];
};

OnHover = function() {
    GAME.show_tooltip_tower = true;
    inst_tooltip_tower.text = "@TOWER_TOOLTIP";
    inst_tooltip_tower.text_args = [GAME.tower_fire.name, GAME.tower_fire.descriptions[0]];
};