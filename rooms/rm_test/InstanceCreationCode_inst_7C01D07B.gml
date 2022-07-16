Update = function() {
    self.text = "Fullscreen: " + (window_get_fullscreen() ? "On" : "Off");
}

OnClick = function() {
    window_set_fullscreen(!window_get_fullscreen());
    GAME.SaveSettings();
};

Update = function() {
    self.enabled = !IS_OGX;
};