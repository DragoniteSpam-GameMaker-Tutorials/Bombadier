OnClick = function() {
    GAME.player_tower_spawn = new EntityTower(0, 0, 0, GAME.tower_pebbles);
};

Update = function() {
    var tower = GAME.tower_pebbles;
    text = tower.name + " ($" + string(tower.cost[0]) + ")";
};

OnHover = function() {
    GAME.show_tooltip_tower = true;
};