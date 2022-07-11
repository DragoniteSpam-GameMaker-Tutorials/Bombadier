OnClick = function() {
    GAME.player_tower_spawn = new EntityTower(0, 0, 0, GAME.tower_pebbles);
};

Update = function() {
    var tower = GAME.tower_pebbles;
    self.text_args = [string(tower.cost[0])];
    self.enabled = GAME.player_money >= tower.cost[0];
};

OnHover = function() {
    GAME.show_tooltip_tower = true;
    inst_tooltip_tower.text = "@TOWER_TOOLTIP";
    inst_tooltip_tower.text_args = [GAME.tower_pebbles.name, GAME.tower_pebbles.descriptions[0]];
};