function Wave(class, number, level) constructor {
    self.class = class;
    self.number = number;
    self.level = level;
    
    self.status = EWaveStatuses.NOT_STARTED;
    self.foe_timer = 0;
    self.foes_remaining = number;
    
    Launch = function() {
        status = EWaveStatuses.RUNNING;
    };
    
    Update = function() {
        if (status == EWaveStatuses.RUNNING) {
            if (foe_timer <= 0) {
                var foe = new EntityFoe(class, level);
                ds_list_add(GAME.all_entities, foe);
                ds_list_add(GAME.all_foes, foe);
                foe_timer = WAVE_FOE_COUNTDOWN;
                foes_remaining--;
            }
            if (foes_remaining > 0) {
                foe_timer -= DT;
            } else {
                status = EWaveStatuses.FINISHED;
            }
        }
    };
    
    Finished = function() {
        return (status == EWaveStatuses.FINISHED);
    };
}

enum EWaveStatuses {
    NOT_STARTED, RUNNING, FINISHED
}