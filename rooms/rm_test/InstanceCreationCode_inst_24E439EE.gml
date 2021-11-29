OnClick = function() {
    GAME.player_tower_spawn = new EntityTowerGlass(0, 0, 0, GAME.tower_magnify);
};

Update = function() {
    var tower = GAME.tower_magnify;
    text = tower.name + " ($" + string(tower.cost[0]) + ")";
};

OnHover = function() {
    GAME.show_tooltip_tower = true;
    inst_tooltip_tower.text = GAME.tower_magnify.name + "\n\n" +
        GAME.tower_magnify.descriptions[0];
};