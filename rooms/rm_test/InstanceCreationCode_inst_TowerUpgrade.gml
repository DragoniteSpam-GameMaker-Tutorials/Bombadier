OnClick = function() {
    if (GAME.selected_entity != undefined) {
        GAME.selected_entity.Upgrade();
    }
};

Update = function() {
    var tower = GAME.selected_entity;
    self.text = "Upgrade ($%0)";
    if (tower != undefined) {
        var upgrade_status = tower.CanBeUpgraded();
        switch (upgrade_status) {
            case ReasonsWhyYouCantUpgradeATower.YES_YOU_CAN:
                self.text_args = [string(tower.class.cost[tower.level])];
                self.enabled = true;
                break;
            case ReasonsWhyYouCantUpgradeATower.MAX_LEVEL:
                self.enabled = false;
                self.text = "@TOWER_MAX_LEVEL";
                break;
            case ReasonsWhyYouCantUpgradeATower.NOT_ENOUGH_MONEY:
                self.text_args = [string(tower.class.cost[tower.level])];
                self.enabled = false;
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
            inst_tooltip_tower.text = "@TOWER_TOOLTIP";
            inst_tooltip_tower.text_args = [tower.class.name, tower.class.descriptions[tower.level]];
        }
    }
};