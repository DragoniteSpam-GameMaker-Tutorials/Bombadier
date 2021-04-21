OnClick = function() {
    if (GAME.selected_entity != undefined && instanceof(GAME.selected_entity) == "EntityTower") {
        GAME.selected_entity.Sell();
        GAME.selected_entity = undefined;
    }
};