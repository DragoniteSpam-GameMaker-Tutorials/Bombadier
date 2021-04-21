GetText = function() {
    var tower = GAME.selected_entity;
    if (tower != undefined) {
        text = tower.name + " (Lv. " + string(tower.level) + ")";
    }
};