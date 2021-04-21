OnClick = function() {
    if (GAME.selected_entity != undefined && instanceof(GAME.selected_entity) == "EntityTower") {
        GAME.selected_entity.Upgrade();
    }
};

Update = function() {
    enabled = false;
    if (GAME.selected_entity != undefined && instanceof(GAME.selected_entity) == "EntityTower") {
        // Yes I know this is the longest way of doing this operation
        if (GAME.selected_entity.CanBeUpgraded()) {
            enabled = true;
        } else {
            enabled = false;
        }
    }
};