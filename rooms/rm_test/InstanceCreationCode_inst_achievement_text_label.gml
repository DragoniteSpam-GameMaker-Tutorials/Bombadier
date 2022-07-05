self.GetText = function() {
    self.text = "@ACHIEVEMENT_PROGRESS";
    self.text_args = [floor(KestrelSystem.GetProgress() * 100)];
};