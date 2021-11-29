OnClick = function() {
    if (GAME.selected_entity != undefined) {
        GAME.selected_entity.Upgrade();
    }
};

Update = function() {
    var tower = GAME.selected_entity;
    enabled = false;
    text = "Upgrade";
    if (tower != undefined) {
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

OnHover = function() {
    var tower = GAME.selected_entity;
    if (tower != undefined) {
        var upgrade_status = tower.CanBeUpgraded();
        if (upgrade_status != ReasonsWhyYouCantUpgradeATower.MAX_LEVEL) {
            GAME.show_tooltip_tower = true;
            inst_tooltip_tower.text = tower.class.name + "\n\n" +
                tower.class.descriptions[tower.level];
        }
    }
};