OnClick = function() {
    GAME.player_tower_spawn = new EntityTowerFire(0, 0, 0, GAME.tower_fire);
};

Update = function() {
    var tower = GAME.tower_fire;
    text = tower.name + " ($" + string(tower.cost[0]) + ")";
};

OnHover = function() {
    GAME.show_tooltip_tower = true;
    inst_tooltip_tower.text = GAME.tower_fire.name + "\n\n" +
        GAME.tower_fire.descriptions[0];
};