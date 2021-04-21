OnClick = function() {
    GAME.player_tower_spawn = new EntityTowerGlass(0, 0, 0, GAME.tower_magnify);
};

Update = function() {
    var tower = GAME.tower_magnify;
    text = tower.name + " ($" + string(tower.cost[0]) + ")";
};