OnClick = function() {
    if (file_exists(SAVE_FILE_NAME)) {
        file_delete(SAVE_FILE_NAME);
    }
    GAME.player_save = new SaveData();
    GAME.current_title_screen = "UI_Title_Screen";
};