function Wave(class, number, level) constructor {
    self.class = class;
    self.number = number;
    self.level = level;
    
    self.running = false;
    self.foe_timer = 0;
    self.foes_remaining = number;
    
    Launch = function() {
        running = true;
    };
    
    Update = function() {
        if (running) {
            if (foe_timer <= 0) {
                ds_list_add(GAME.all_entities, new EntityFoe(class, level));
                foe_timer = WAVE_FOE_COUNTDOWN;
                foes_remaining--;
            }
            if (foes_remaining > 0) {
                foe_timer -= DT;
            } else {
                running = false;
            }
        }
    };
}