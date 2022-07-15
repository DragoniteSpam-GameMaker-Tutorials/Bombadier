function EntityTower(x, y, z, class) : Entity(x, y, z) constructor {
    self.name = class.name;
    self.class = class;
    self.level = 1;
    
    self.shot_cooldown = 0;
    
    self.base_rate = class.rate[0];
    self.base_range = class.range[0];
    self.base_damage = class.damage[0];
    self.base_model = class.model;
    self.base_bullet_data = class.bullet_data;
    
    self.mod_rate = 1;
    self.mod_range = 1;
    self.mod_damage = 1;
    
    self.stats = {
        shots: 0,
        damage: 0,
    };
    
    static Reposition = function(x, y, z) {
        position.x = x;
        position.y = y;
        position.z = z;
        collision.p1.x = x - 16;
        collision.p1.y = y - 16;
        collision.p1.z = z;
        collision.p2.x = x + 16;
        collision.p2.y = y + 16;
        collision.p2.z = z + 64;
    };
    
    static SetRateMod = function(value) {
        if (value != undefined) mod_rate = value;
        act_rate = CalcRate() * mod_rate;
    }
    
    static SetRangeMod = function(value) {
        if (value != undefined) mod_range = value;
        act_range = CalcRange() * mod_range;
    }
    
    static SetDamageMod = function(value) {
        if (value != undefined) mod_damage = value;
        act_damage = CalcDamage() * mod_damage;
    }
    
    static CalcRate = function() {
        return base_rate;
    }
    
    static CalcRange = function() {
        return base_range;
    }
    
    static CalcDamage = function() {
        return base_damage;
    }
    
    SetRateMod();
    SetRangeMod();
    SetDamageMod();
    
    static LevelUp = function() {
        level++;
        act_rate = CalcRate() * mod_rate;
        act_range = CalcRange() * mod_range;
        act_damage = CalcDamage() * mod_damage;
    }
    
    static AddCollision = function() {
        var xmin = min(collision.p1.x * scale.x, collision.p2.x * scale.x);
        var ymin = min(collision.p1.y * scale.y, collision.p2.y * scale.y);
        var xmax = max(collision.p1.x * scale.x, collision.p2.x * scale.x);
        var ymax = max(collision.p1.y * scale.y, collision.p2.y * scale.y);
        var cell_xmin = clamp(xmin div GRID_CELL_SIZE, 0, ds_grid_width(GAME.collision_grid) - 1);
        var cell_ymin = clamp(ymin div GRID_CELL_SIZE, 0, ds_grid_height(GAME.collision_grid) - 1);
        var cell_xmax = clamp(ceil(xmax / GRID_CELL_SIZE), 0, ds_grid_width(GAME.collision_grid) - 1);
        var cell_ymax = clamp(ceil(ymax / GRID_CELL_SIZE), 0, ds_grid_height(GAME.collision_grid) - 1);
        for (var i = cell_xmin; i <= cell_xmax; i++) {
            for (var j = cell_ymin; j <= cell_ymax; j++) {
                GAME.collision_grid[# i, j] = max(GAME.collision_grid[# i, j], GRID_COLLISION_FILLED);
            }
        }
    }
    
    static AddToMap = function() {
        ds_list_add(GAME.all_entities, self);
        ds_list_add(GAME.all_towers, self);
        AddCollision();
    };
    
    static Update = function() {
        if (shot_cooldown <= 0) {
            var target_foe = GetTarget();
            if (target_foe) {
                Shoot(target_foe);
            }
        } else {
            shot_cooldown -= DT;
        }
    };
    
    static Shoot = function(target_foe) {
        var dir = point_direction(position.x, position.y, target_foe.position.x, target_foe.position.y);
        var shot_velocity = 16;
        var bullet = new EntityBullet(position.x, position.y, position.z, shot_velocity * dcos(dir), shot_velocity * -dsin(dir), 0, base_bullet_data, act_damage, self);
        bullet.AddToMap();
        shot_cooldown = 1 / act_rate;
        self.stats.shots++;
        audio_play_sound(se_tower_pebble, SOUND_PRIORITY_GAMEPLAY_LOW, false);
    };
    
    // Get the foe in range that's farthest down the track
    static GetTarget = function() {
        var target_foe = undefined;
        for (var i = 0; i < ds_list_size(GAME.all_foes); i++) {
            var foe = GAME.all_foes[| i];
            if (point_distance_3d(position.x, position.y, position.z, foe.position.x, foe.position.y, foe.position.z) < act_range) {
                target_foe = foe;
                break;
            }
        }
        return target_foe;
    };
    
    static Render = function() {
        var transform = matrix_build(0, 0, 0, 0, 0, 0, scale.x, scale.y, scale.z);
        transform = matrix_multiply(transform, matrix_build(0, 0, 0, rotation.x, rotation.y, rotation.z, 1, 1, 1));
        transform = matrix_multiply(transform, matrix_build(position.x, position.y, position.z, 0, 0, 0, 1, 1, 1));
        matrix_set(matrix_world, transform);
        vertex_submit(base_model.vbuff, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
    };
    
    static BaseSell = function() {
        Destroy();
        RemoveCollision();
        ds_list_delete(GAME.all_towers, ds_list_find_index(GAME.all_towers, self));
        GAME.player_money += GetSellValue();
        audio_play_sound(se_sell, SOUND_PRIORITY_GAMEPLAY_HIGH, false);
    };
    
    static Sell = function() {
        self.BaseSell();
    };
    
    static GetSellValue = function() {
        var value = 0;
        for (var i = 0; i < self.level; i++) {
            value += ceil(class.cost[i] * 0.9);
        }
        return value;
    };
    
    static RemoveCollision = function() {
        var xmin = min(collision.p1.x * scale.x, collision.p2.x * scale.x);
        var ymin = min(collision.p1.y * scale.y, collision.p2.y * scale.y);
        var xmax = max(collision.p1.x * scale.x, collision.p2.x * scale.x);
        var ymax = max(collision.p1.y * scale.y, collision.p2.y * scale.y);
        var cell_xmin = clamp(xmin div GRID_CELL_SIZE, 0, ds_grid_width(GAME.collision_grid) - 1);
        var cell_ymin = clamp(ymin div GRID_CELL_SIZE, 0, ds_grid_height(GAME.collision_grid) - 1);
        var cell_xmax = clamp(ceil(xmax / GRID_CELL_SIZE), 0, ds_grid_width(GAME.collision_grid) - 1);
        var cell_ymax = clamp(ceil(ymax / GRID_CELL_SIZE), 0, ds_grid_height(GAME.collision_grid) - 1);
        for (var i = cell_xmin; i <= cell_xmax; i++) {
            for (var j = cell_ymin; j <= cell_ymax; j++) {
                GAME.collision_grid[# i, j] = GRID_COLLISION_FREE;
            }
        }
    };
    
    static Upgrade = function() {
        self.level++;
        self.base_rate = self.class.rate[self.level - 1];
        self.base_range = self.class.range[self.level - 1];
        self.base_damage = self.class.damage[self.level - 1];
        self.SetRateMod();
        self.SetDamageMod();
        self.SetRangeMod();
        GAME.player_money -= self.class.cost[self.level - 1];
        GAME.player_has_upgraded_tower = true;
        audio_play_sound(se_build, SOUND_PRIORITY_GAMEPLAY_HIGH, false);
        KestrelSystem.Update(Achievements.getting_an_upgrade);
        if (self.level == 3) {
            KestrelSystem.Update(Achievements.tower_expert);
        }
        Achievements.SetTowerRank(self.class.id, self.level);
        var inferior_upgrade_found = false;
        for (var i = 0, n = array_length(GAME.all_tower_types); i < n; i++) {
            var tower_record = Achievements.stats.tower_records[$ GAME.all_tower_types[i].id];
            if (!tower_record || tower_record.highest_rank < MAX_TOWER_LEVEL) {
                inferior_upgrade_found = true;
                break;
            }
        }
        if (!inferior_upgrade_found) {
            KestrelSystem.Update(Achievements.tower_master);
        }
    };
    
    static CanBeUpgraded = function() {
        if (self.level >= MAX_TOWER_LEVEL) return ReasonsWhyYouCantUpgradeATower.MAX_LEVEL;
        if (GAME.player_money < self.class.cost[self.level]) return ReasonsWhyYouCantUpgradeATower.NOT_ENOUGH_MONEY;
        return ReasonsWhyYouCantUpgradeATower.YES_YOU_CAN;
    };
    
    enum ReasonsWhyYouCantUpgradeATower {
        MAX_LEVEL,
        NOT_ENOUGH_MONEY,
        YES_YOU_CAN,
    }
    
    static GetSummary = function() {
        return {
            base: "@TOWER_SUMMARY",
            args: [
                L(self.name),
                string(self.level),
                string(self.stats.shots),
                string_format(self.stats.damage, 1, 1)
            ]
        };
    };
    
    static RenderRadius = function() {
        var u_tower_position = shader_get_uniform(shd_tower_radius, "u_TowerPosition");
        var u_tower_radius = shader_get_uniform(shd_tower_radius, "u_TowerRadius");
        var tower_position = self.position;
        var tower_range = self.act_range;
        shader_set(shd_tower_radius);
        shader_set_uniform_f(u_tower_position, tower_position.x, tower_position.y);
        shader_set_uniform_f(u_tower_radius, tower_range);
        matrix_set(matrix_world, matrix_build(tower_position.x, tower_position.y, tower_position.z + 1, 0, 0, 0, tower_range, tower_range, 1));
        draw_sprite(spr_tower_radius, 0, 0, 0);
    }
}

function EntityTowerFire(x, y, z, class) : EntityTower(x, y, z, class) constructor {
    self.baseUpdate = self.Update;
    
    self.Update = function() {
        Particles.BurstFromEmitter(Particles.emitters.tower_effects, Particles.types.tower_fire, self.position.x, self.position.y, self.position.z + 44, 1);
        self.baseUpdate();
    };
}

function EntityTowerGlass(x, y, z, class) : EntityTower(x, y, z, class) constructor {
    self.target_foe = undefined;
    
    self.stats = {
        duration: 0,
        damage: 0,
    };
    
    static Update = function() {
        target_foe = GetTarget();
        var is_burning = false;
        if (target_foe) {
            if (target_foe.shield == 0) {
                target_foe.Damage(self.act_damage * DT);
                self.stats.damage += self.act_damage * DT;
                self.stats.duration += DT;
                if (self.level >= 3) {
                    target_foe.Burn(self, BURN_DURATION);
                }
                Particles.BurstFromEmitter(Particles.emitters.hit_effects, Particles.types.fire, target_foe.position.x, target_foe.position.y, target_foe.position.z + 8, 1);
            }
            rotation.z = point_direction(self.position.x, self.position.y, target_foe.position.x, target_foe.position.y);
            is_burning = true;
        }
        
        if (is_burning) {
            if (!audio_is_playing(se_tower_magnifying_glass)) {
                audio_play_sound(se_tower_magnifying_glass, SOUND_PRIORITY_GAMEPLAY_HIGH, true);
            }
        } else {
            if (audio_is_playing(se_tower_magnifying_glass)) {
                audio_stop_sound(se_tower_magnifying_glass);
            }
        }
    };
    
    static Render = function() {
        var transform = matrix_build(0, 0, 0, 0, 0, 0, scale.x, scale.y, scale.z);
        transform = matrix_multiply(transform, matrix_build(0, 0, 0, rotation.x, rotation.y, rotation.z, 1, 1, 1));
        transform = matrix_multiply(transform, matrix_build(position.x, position.y, position.z, 0, 0, 0, 1, 1, 1));
        matrix_set(matrix_world, transform);
        vertex_submit(base_model.vbuff, pr_trianglelist, -1);
        ds_list_add(GAME.semi_transparent_stuff,
            new TransparentRenderObject(transform, GAME.magnifying_glass_glass,
            shd_passthrough,
            undefined,
        ));
        if (target_foe != undefined) {
            ds_list_add(GAME.semi_transparent_stuff,
                new TransparentRenderObject(transform, GAME.magnifying_glass_beam,
                shd_magnifying_glass_beam,
                {
                    name: "targetPosition",
                    elements: [target_foe.position.x, target_foe.position.y, target_foe.position.z],
                },
            ));
        }
        matrix_set(matrix_world, matrix_build_identity());
    };
    
    static GetSummary = function() {
        return {
            base: "@TOWER_SUMMARY_GLASS",
            args: [
                L(self.name),
                string(self.level),
                string_format(self.stats.duration, 1, 1),
                string_format(self.stats.damage, 1, 1)
            ]
        };
    };
    
    static toString = function() {
        return self.name + " (Lv. " + string(self.level) + ")\n" +
            "Focus duration: " + string_format(self.stats.duration, 1, 1) + " s\n" +
            "Damange dealt: " + string_format(self.stats.damage, 1, 1);
    };
    
    static GameOver = function() {
        audio_stop_sound(se_tower_magnifying_glass);
    };
}

function EntityTowerSpray(x, y, z, class) : EntityTower(x, y, z, class) constructor {
    self.stats = {
        clouds: 0,
        hits: 0,
        damage: 0,
    };
    
    static Update = function() {
        if (shot_cooldown <= 0) {
            SpawnSpray();
        } else {
            shot_cooldown -= DT;
        }
    };
    
    static SpawnSpray = function() {
        self.stats.clouds++;
        shot_cooldown = 1 / act_rate;
        var lifespan = (self.level >= 2) ? 3 : 2;
        var max_hits = (self.level >= 2) ? 3 : 2;
        var cloud = new EntityBulletBugSprayCloud(0, 0, 0, base_bullet_data, lifespan, max_hits, self);
        repeat (15) {
            var dist = random_range(12, act_range);
            var dir = random(360);
            cloud.Reposition(position.x + dist * dcos(dir), position.y - dist * dsin(dir), position.z);
            if (GAME.CollisionIsPath(cloud)) {
                ds_list_add(GAME.all_entities, cloud);
                audio_play_sound(se_tower_bug_spray, SOUND_PRIORITY_GAMEPLAY_LOW, false);
                self.rotation.z = point_direction(self.position.x, self.position.y, cloud.position.x, cloud.position.y);
                return;
            }
        }
    };
    
    static GetSummary = function() {
        return {
            base: "@TOWER_SUMMARY_SPRAY",
            args: [
                L(self.name),
                string(self.level),
                string(self.stats.clouds),
                string(self.stats.hits),
                string_format(self.stats.damage, 1, 1)
            ]
        };
    };
}

function EntityTowerBird(x, y, z, class) : EntityTower(x, y, z, class) constructor {
    birds = [ ];
    bird_limit = 3;
    
    static Update = function() {
        if (self.level >= 3) {
            bird_limit = 4;
        }
        if (shot_cooldown <= 0 && array_length(birds) < bird_limit) {
            HatchBird();
        } else {
            shot_cooldown -= DT;
        }
    };
    
    static HatchBird = function() {
        shot_cooldown = 1 / act_rate;
        var dist = 32 + array_length(birds) * 16;
        var bird = new EntityBulletBird(0, 0, 0, base_bullet_data, self, dist);
        ds_list_add(GAME.all_entities, bird);
        array_push(birds, bird);
        audio_play_sound(choose(se_tower_bird_a, se_tower_bird_b), SOUND_PRIORITY_GAMEPLAY_LOW, false);
    };
    
    self.RemoveBird = function(bird) {
        for (var i = 0; i < array_length(self.birds); i++) {
            if (self.birds[i] == bird) {
                array_delete(self.birds, i, 1);
                break;
            }
        }
    };
    
    static Sell = function() {
        for (var i = array_length(self.birds) - 1; i >=0; i--) {
            self.birds[i].Destroy();
        }
        self.BaseSell();
    };
}

function EntityTowerFlyPaper(x, y, z, class) : EntityTower(x, y, z, class) constructor {
    self.paper_count = 0;
    self.paper_limit = 2;
    
    self.stats = {
        papers: 0,
        hits: 0,
        stuns: 0,
    };
    
    static Update = function() {
        if (shot_cooldown <= 0) {
            Dispense();
        } else {
            shot_cooldown -= DT;
        }
    };
    
    static Dispense = function() {
        if (paper_count >= paper_limit) {
            return;
        }
        self.stats.papers++;
        shot_cooldown = 1 / act_rate;
        var lifespan = 3;
        var paper = new EntityBulletFlyPaper(0, 0, 0, lifespan, base_bullet_data, self);
        repeat (15) {
            var dist = random_range(12, act_range);
            var dir = random(360);
            paper.Reposition(position.x + dist * dcos(dir), position.y - dist * dsin(dir), position.z);
            if (GAME.CollisionIsPath(paper)) {
                ds_list_add(GAME.all_entities, paper);
                paper_count++;
                audio_play_sound(se_tower_flypaper, SOUND_PRIORITY_GAMEPLAY_LOW, false);
                return;
            }
        }
    };
    
    static GetSummary = function() {
        if (self.level >= 3) {
            return {
                base: "@TOWER_SUMMARY_PAPER_ADVANCED",
                args: [
                    L(self.name),
                    string(self.level),
                    string(self.stats.papers),
                    string(self.stats.hits),
                    string(self.stats.stuns)
                ]
            };
        } else {
            return {
                base: "@TOWER_SUMMARY_PAPER",
                args: [
                    self.name,
                    string(self.level),
                    string(self.stats.papers),
                    string(self.stats.hits),
                ]
            };
        }
    };
}