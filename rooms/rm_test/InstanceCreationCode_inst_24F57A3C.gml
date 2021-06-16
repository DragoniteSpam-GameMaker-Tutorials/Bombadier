OnClick = function() {
    if (GAME.gameplay_mode == GameModes.TITLE) {
        GAME.current_title_screen = "UI_Title_Screen";
    } else {
        GAME.current_pause_screen = "UI_Game_Pause_Menu";
    }
};