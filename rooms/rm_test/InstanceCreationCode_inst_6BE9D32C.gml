OnClick = function() {
    GAME.player_tower_spawn = new EntityTowerBird(0, 0, 0, GAME.tower_bird);
};

Update = function() {
    var tower = GAME.tower_bird;
    text = tower.name + " ($" + string(tower.cost[0]) + ")";
};

OnHover = function() {
    GAME.show_tooltip_tower = true;
    inst_tooltip_tower.text = GAME.tower_bird.name + "\n\n" +
        GAME.tower_bird.descriptions[0];
};