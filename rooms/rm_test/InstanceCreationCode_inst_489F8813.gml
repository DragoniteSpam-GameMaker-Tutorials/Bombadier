GetText = function() {
    var tower = GAME.selected_entity;
    if (tower != undefined) {
        var summary = tower.GetSummary();
        self.text = summary.base;
        self.text_args = summary.args;
    }
};