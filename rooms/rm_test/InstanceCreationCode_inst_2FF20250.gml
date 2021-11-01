OnClick = function() {
    GAME.SendInWaveEarly();
}

self.Update = function() {
    self.enabled = (GAME.wave_countdown >= WAVE_COUNTDOWN_THRESHOLD);
};