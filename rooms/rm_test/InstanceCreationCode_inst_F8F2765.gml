OnClick = function() {
    GAME.player_tower_spawn = new EntityTowerFlyPaper(0, 0, 0, GAME.tower_flypaper);
};

Update = function() {
    var tower = GAME.tower_flypaper;
    text = tower.name + " ($" + string(tower.cost[0]) + ")";
};