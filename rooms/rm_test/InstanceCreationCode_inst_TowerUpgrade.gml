OnClick = function() {
    if (GAME.selected_entity != undefined && instanceof(GAME.selected_entity) == "EntityTower") {
        GAME.selected_entity.Upgrade();
    }
};

Update = function() {
    var tower = GAME.selected_entity;
    enabled = false;
    text = "Upgrade";
    if (tower != undefined && instanceof(tower) == "EntityTower") {
        // Yes I know this is the longest way of doing this operation
        if (tower.CanBeUpgraded()) {
            enabled = true;
            text = "Upgrade ($" + string(tower.class.cost[tower.level]) + ")";
        } else {
            enabled = false;
        }
    }
};