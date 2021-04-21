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
        var upgrade_status = tower.CanBeUpgraded();
        switch (upgrade_status) {
            case ReasonsWhyYouCantUpgradeATower.YES_YOU_CAN:
                enabled = true;
                text = "Upgrade ($" + string(tower.class.cost[tower.level]) + ")";
                break;
            case ReasonsWhyYouCantUpgradeATower.MAX_LEVEL:
                enabled = false;
                text = "(Max Level)";
                break;
            case ReasonsWhyYouCantUpgradeATower.NOT_ENOUGH_MONEY:
                enabled = false;
                text = "Upgrade ($" + string(tower.class.cost[tower.level]) + ")";
                break;
        }
    }
};