OnClick = function() {
    GAME.player_tower_spawn = new EntityTowerBird(0, 0, 0, GAME.tower_bird);
};

Update = function() {
    var tower = GAME.tower_bird;
    text = tower.name + " ($" + string(tower.cost[0]) + ")";
};