OnClick = function() {
    GAME.player_tower_spawn = new EntityTowerFire(0, 0, 0, GAME.tower_fire);
};

Update = function() {
    var tower = GAME.tower_fire;
    text = tower.name + " ($" + string(tower.cost[0]) + ")";
};