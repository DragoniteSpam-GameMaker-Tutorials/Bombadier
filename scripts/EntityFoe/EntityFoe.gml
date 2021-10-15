function EntityFoe(class, level) : Entity(0, 0, 0) constructor {
    self.class = class;
    self.level = level;
    
    self.hp = class.hp;
    self.hp_max = self.hp;
    self.damage = class.damage;
    self.reward = class.reward;
    self.base_def = class.def;
    self.base_mdef = class.mdef;
    self.base_speed = class.speed;
    self.shield = 0;
    
    self.mod_def = 1;
    self.mod_mdef = 1;
    self.mod_speed = 1;
    
    self.status_burn = 0;
    self.status_poison = 0;
    self.status_slow = 0;
    self.status_immobilize = 0;
    self.has_been_immobilized = false;
    self.whodunnit_burn = undefined;
    self.whodunnit_poison = undefined;
    self.whodunnit_slow = undefined;
    self.whodunnit_immobilize = undefined;
    
    self.lifetime = 0;
    self.previous_position = {
        x: self.position.x,
        y: self.position.y,
        z: self.position.z
    };
    
    Burn = function(duration, whodunnit) {
        if (duration == undefined) duration = BURN_DURATION;
        self.status_burn = duration;
        self.whodunnit_burn = whodunnit;
    };
    
    Poison = function(duration, whodunnit) {
        if (duration == undefined) duration = POISON_DURATION;
        self.status_poison = duration;
        self.whodunnit_poison = whodunnit;
    };
    
    Slow = function(duration, factor, whodunnit) {
        if (duration == undefined) duration = BURN_DURATION;
        if (factor == undefined) factor = SLOW_FACTOR;
        self.status_slow = duration;
        self.SetSpeedMod(factor);
        self.whodunnit_slow = whodunnit;
    };
    
    Immobilize = function(duration, whodunnit) {
        if (duration == undefined) duration = IMMOBILIZE_DURATION;
        if (self.has_been_immobilized) return;
        self.status_immobilize = duration;
        self.has_been_immobilized = true;
        self.whodunnit_immobilize = whodunnit;
    };
    
    SetDefMod = function(value) {
        momod_def_damage = value;
        act_def = CalcDef() * mod_def;
    }
    
    SetMdefMod = function(value) {
        mod_mdef = value;
        act_mdef = CalcMDef() * mod_mdef;
    }
    
    SetSpeedMod = function(value) {
        mod_speed = value;
        act_speed = CalcSpeed() * mod_speed;
    }
    
    CalcDef = function() {
        return base_def * level;
    }
    
    CalcMDef = function() {
        return base_mdef * level;
    }
    
    CalcSpeed = function() {
        return base_speed;
    }
    
    self.act_def = CalcDef() * self.mod_def;
    self.act_mdef = CalcMDef() * self.mod_mdef;
    self.act_speed = CalcSpeed() * self.mod_speed;
    
    self.path = GAME.path_nodes;
    self.path_node = 1;
    self.position = clone(self.path[0].position);
    self.destination = clone(self.path[1].position);
    
    Damage = function(amount) {
        if (self.shield > 0) {
            self.shield--;
            return;
        }
        hp -= max(amount, 0);
        if (hp < 0) {
            Die();
        }
    };
    
    Heal = function(amount) {
        hp = min(hp + max(amount, 0), hp_max);
    };
    
    Die = function() {
        Destroy();
        GAME.player_money += reward;
        GAME.CheckGameOver();
        Particles.BurstFromEmitter(Particles.emitters.hit_effects, Particles.types.death, self.position.x, self.position.y, self.position.z + 8, 12);
        audio_play_sound(se_foe_die, SOUND_PRIORITY_GAMEPLAY_LOW, false);
    };
    
    AddToMap = function() {
        ds_list_add(GAME.all_entities, self);
        ds_list_add(GAME.all_foes, self);
    };
    
    UpdatePreviousPositions = function() {
        self.previous_position.x = self.position.x;
        self.previous_position.y = self.position.y;
        self.previous_position.z = self.position.z;
    };
    
    Update = function() {
        self.lifetime += DT;
        self.UpdatePreviousPositions();
        
        if (self.status_immobilize <= 0) {
            var dt = DT;
            var dir = point_direction(position.x, position.y, destination.x, destination.y);
            position.x = approach(position.x, destination.x, act_speed * abs(dcos(dir)) * dt);
            position.y = approach(position.y, destination.y, act_speed * abs(dsin(dir)) * dt);
            position.z = approach(position.z, destination.z, act_speed * dt);
            if (position.x == destination.x && position.y == destination.y && position.z == destination.z) {
                if (array_length(path) > (path_node + 1) && path[path_node + 1] != undefined) {
                    path_node++;
                    destination = clone(path[path_node].position);
                } else {
                    GAME.PlayerDamage(damage);
                    Destroy();
                }
            }
        }
        
        if (status_immobilize > 0) {
            status_immobilize -= DT;
        }
        
        if (status_burn > 0) {
            self.whodunnit_burn.stats.damage += BURN_DPS * DT;
            Damage(BURN_DPS * DT);
            status_burn -= DT;
            Particles.BurstFromEmitter(Particles.emitters.hit_effects, Particles.types.fire, self.position.x, self.position.y, self.position.z + 8, 1);
        }
        
        if (status_poison > 0) {
            self.whodunnit_poison.stats.damage += POISON_DPS * DT;
            Damage(POISON_DPS * DT);
            status_poison -= DT;
            if (irandom(4) == 1) {
                Particles.BurstFromEmitter(Particles.emitters.hit_effects, Particles.types.poison, self.position.x, self.position.y, self.position.z + 8, 1);
            }
        }
        
        if (status_slow > 0) {
            status_slow -= DT;
            if (status_slow <= 0) {
                SetSpeedMod(1);
            }
            if (irandom(4) == 1) {
                Particles.BurstFromEmitter(Particles.emitters.hit_effects, Particles.types.glue, self.position.x, self.position.y, self.position.z + 8, 1);
            }
        }
    };
    
    Render = function() {
        var bearing = point_direction(self.previous_position.x, self.previous_position.y, self.position.x, self.position.y);
        var transform = matrix_build(0, 0, 0, 0, 0, 0, scale.x, scale.y, scale.z);
        transform = matrix_multiply(transform, matrix_build(0, 0, 0, rotation.x, rotation.y, rotation.z + bearing, 1, 1, 1));
        transform = matrix_multiply(transform, matrix_build(position.x, position.y, position.z, 0, 0, 0, 1, 1, 1));
        matrix_set(matrix_world, transform);
        vertex_submit(class.models[(self.lifetime * 4) % 2].vbuff, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
    };
    
    RenderHealthBar = function() {
        var f = max(hp / hp_max, 0.125);
        if (f < 1 || status_poison || status_burn || status_slow) {
            shader_set(shd_billboard);
            gpu_set_zwriteenable(false);
            
            var transform = matrix_build(position.x, position.y, position.z + 48, 0, 0, 0, 1, 1, 1);
            matrix_set(matrix_world, transform);
            var s = 0.25;
            draw_sprite_ext(spr_healthbar, 0, 0, 0, s, s, 0, c_white, 1);
            var ww = sprite_get_width(spr_healthbar_fill) * s;
            var hh = sprite_get_height(spr_healthbar_fill) * s;
            draw_sprite_stretched(spr_healthbar_fill, 0, -ww / 2, -hh / 2, ww * f, hh);
            var xx = -ww / 2;
            var yoff = -12;
            // if you want to draw something above the health bar, do it here
            
            gpu_set_zwriteenable(true);
            shader_reset();
            matrix_set(matrix_world, matrix_build_identity());
        }
    };
    
    Destroy = function() {
        var current_index = ds_list_find_index(GAME.all_entities, self);
        if (current_index > -1) {
            ds_list_delete(GAME.all_entities, current_index);
        }
        var current_index = ds_list_find_index(GAME.all_foes, self);
        if (current_index > -1) {
            ds_list_delete(GAME.all_foes, current_index);
        }
    };
}

function EntityFoeMidge(class, level) : EntityFoe(class, level) constructor {
    self.shield = 1;
}