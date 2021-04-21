OnClick = function() {
    if (GAME.selected_entity != undefined && instanceof(GAME.selected_entity) == "EntityTower") {
        GAME.selected_entity.Sell();
        GAME.selected_entity = undefined;
    }
};

Update = function() {
    var tower = GAME.selected_entity;
    enabled = false;
    text = "Sell";
    if (tower != undefined) {
        enabled = true;
        text = "Sell ($" + string(tower.GetSellValue()) + ")";
    }
};