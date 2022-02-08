OnClick = function() {
    if (GAME.selected_entity != undefined) {
        GAME.selected_entity.Sell();
        GAME.selected_entity = undefined;
    }
};

Update = function() {
    var tower = GAME.selected_entity;
    enabled = false;
    if (tower != undefined) {
        enabled = true;
        text_args = [string(tower.GetSellValue())];
    }
};