OnClick = function() {
    GAME.player_tower_spawn = new EntityTowerSpray(0, 0, 0, GAME.tower_spray);
};

Update = function() {
    var tower = GAME.tower_spray;
    text = tower.name + " ($" + string(tower.cost[0]) + ")";
};