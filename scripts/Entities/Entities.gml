function Entity(x, y, z) constructor {
    position = new Vector3(x, y, z);
    rotation = new Vector3(0, 0, 0);
    scale = new Vector3(1, 1, 1);
    
    collision = new BBox(new Vector3(position.x - 16, position.y - 16, position.z), new Vector3(position.x + 16, position.y + 16, position.z + 64));
    
    raycast = coll_ray_aabb;
    solid = true;
    
    BeginUpdate = function() {
        
    };
    
    Update = function() {
        
    };
    
    Render = function() {
        
    };
    
    AddToMap = function() {
        
    };
    
    AddCollision = function() {
        if (solid) {
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
    };
    
    Save = function(save_json, i) {
        save_json.entities[i] = 0;
    };
    
    Destroy = function() {
        var current_index = ds_list_find_index(GAME.all_entities, self);
        if (current_index > -1) {
            ds_list_delete(GAME.all_entities, current_index);
        }
    };
}

function EntityEnv(x, y, z, model, savename) : Entity(x, y, z) constructor {
    self.model = model;
    self.solid = model.solid;
    self.savename = savename;
    
    self.rotation = new Vector3(0, 0, 0);
    self.scale = new Vector3(1, 1, 1);
    
    collision = new BBox(new Vector3(position.x - 8, position.y - 8, position.z), new Vector3(position.x + 8, position.y + 8, position.z + 16));
    
    Reposition = function(x, y, z) {
        position.x = x;
        position.y = y;
        position.z = z;
        collision.p1.x = x - 8;
        collision.p1.y = y - 8;
        collision.p1.z = z;
        collision.p2.x = x + 8;
        collision.p2.y = y + 8;
        collision.p2.z = z + 16;
    };
    
    Select = function() {
        
    };
    
    Deselect = function() {
        is_moving = false;
    };
    
    AddToMap = function() {
        ds_list_add(GAME.all_entities, self);
        ds_list_add(GAME.all_env_entities, self);
        AddCollision();
    };
    
    is_moving = false;
    
    Save = function(save_json, i) {
        save_json.entities[i] = {
            position: position,
            rotation: rotation,
            scale: scale,
            name: savename,
        };
    };
    
    Render = function() {
        // set the shader if you are selected
        if (GAME.selected_entity == self || GAME.editor_hover_entity == self) {
            shader_set(shd_selected);
            shader_set_uniform_f(shader_get_uniform(shd_selected, "time"), current_time / 1000);
            if (GAME.selected_entity == self) {
                shader_set_uniform_color(shader_get_uniform(shd_selected, "color"), c_env);
            } else if (GAME.editor_hover_entity == self) {
                shader_set_uniform_color(shader_get_uniform(shd_selected, "color"), c_env_hover);
            }
        }
        
        matrix_set(matrix_world, matrix_build(position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, scale.x, scale.y, scale.z));
        vertex_submit(model.vbuff, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
        // reset the shader if you are selected
        if (GAME.selected_entity == self || GAME.editor_hover_entity == self) {
            cluck_apply(shd_cluck_fragment);
        }
    };
}

function EntityBullet(x, y, z, vx, vy, vz, bullet_data, damage) : Entity(x, y, z) constructor {
    velocity = new Vector3(vx, vy, vz);
    self.bullet_data = bullet_data;
    self.damage = damage;
    self.solid = false;
    time_to_live = 1;
    
    raycast = coll_ray_invalid;
    
    AddToMap = function() {
        ds_list_add(GAME.all_entities, self);
    };
    
    AddCollision = function() {
        
    };
    
    Update = function() {
        position.x += velocity.x;
        position.y += velocity.y;
        position.z += velocity.z;
        
        for (var i = 0; i < ds_list_size(GAME.all_foes); i++) {
            var foe = GAME.all_foes[| i];
            var radius = 18;
            if (point_distance_3d(position.x, position.y, position.z, foe.position.x, foe.position.y, foe.position.z) <= radius) {
                foe.Damage(damage);
                bullet_data.OnHit(foe);
                Destroy();
                return;
            }
        }
        
        time_to_live -= DT;
        
        if (time_to_live <= 0) {
            Destroy();
        }
    };
    
    Render = function() {
        matrix_set(matrix_world, matrix_build(position.x, position.y, position.z, 0, 0, 0, 1, 1, 1));
        vertex_submit(bullet_data.model.vbuff, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
    };
}

function EntityBulletBugSprayCloud(x, y, z, bullet_data) : EntityBullet(x, y, z, 0, 0, 0, bullet_data, 0) constructor {
    lifetime = 2;
    radius = 40;
    
    Reposition = function(x, y, z) {
        position.x = x;
        position.y = y;
        position.z = z;
        collision.p1.x = x - 16;
        collision.p1.y = y - 16;
        collision.p1.z = z;
        collision.p2.x = x + 16;
        collision.p2.y = y + 16;
        collision.p2.z = z + 32;
    };
    
    Update = function() {
        for (var i = 0; i < ds_list_size(GAME.all_foes); i++) {
            var foe = GAME.all_foes[| i];
            if (point_distance_3d(position.x, position.y, position.z, foe.position.x, foe.position.y, foe.position.z) < radius) {
                bullet_data.OnHit(foe);
            }
        }
        
        lifetime -= DT;
        if (lifetime <= 0) {
            Destroy();
        }
    };
};

function EntityBulletBird(x, y, z, bullet_data, nest, nest_radius) : EntityBullet(x, y, z, 0, 0, 0, bullet_data, 0) constructor {
    lifetime = 2;
    attack_radius = 32;
    self.nest = nest;
    self.nest_radius = nest_radius;
    self.nest_angle = 270;
    damage_cooldown = 1 / nest.act_rate;
    anim_frame = 0;
    
    Reposition = function(x, y, z) {
        position.x = x;
        position.y = y;
        position.z = z;
    };
    
    Update = function() {
        if (damage_cooldown <= 0) {
            for (var i = 0; i < ds_list_size(GAME.all_foes); i++) {
                var foe = GAME.all_foes[| i];
                if (point_distance_3d(position.x, position.y, position.z, foe.position.x, foe.position.y, foe.position.z) < attack_radius) {
                    foe.Damage(nest.act_damage);
                    bullet_data.OnHit(foe);
                    damage_cooldown = 1 / nest.act_rate;
                    break;
                }
            }
        }
        
        damage_cooldown -= DT;
        
        var linear_velocity = 160;
        
        Reposition(nest.position.x + nest_radius * dcos(nest_angle), nest.position.y - nest_radius * dsin(nest_angle), nest.position.z + 16);
        nest_angle += linear_velocity / nest_radius;
        
        var anim_speed = 4;
        anim_frame += anim_speed * DT;
    };
    
    Render = function() {
        matrix_set(matrix_world, matrix_build(position.x, position.y, position.z, 0, 0, nest_angle + 180, 1, 1, 1));
        vertex_submit(bullet_data.anim_frames[floor(anim_frame) % array_length(bullet_data.anim_frames)].vbuff, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
    };
};

function EntityBulletFlyPaper(x, y, z, bullet_data, parent_tower) : EntityBullet(x, y, z, 0, 0, 0, bullet_data, 0) constructor {
    radius = 40;
    hits_remaining = 2;
    parent = parent_tower;
    
    Reposition = function(x, y, z) {
        position.x = x;
        position.y = y;
        position.z = z;
        collision.p1.x = x - 16;
        collision.p1.y = y - 16;
        collision.p1.z = z;
        collision.p2.x = x + 16;
        collision.p2.y = y + 16;
        collision.p2.z = z + 32;
    };
    
    Update = function() {
        for (var i = 0; i < ds_list_size(GAME.all_foes); i++) {
            var foe = GAME.all_foes[| i];
            if (point_distance_3d(position.x, position.y, position.z, foe.position.x, foe.position.y, foe.position.z) < radius) {
                if (foe.status_slow <= 0) {
                    hits_remaining--;
                }
                bullet_data.OnHit(foe);
                if (hits_remaining <= 0) {
                    Destroy();
                    parent.paper_count--;
                    return;
                }
            }
        }
    };
};

function EntityTower(x, y, z, class) : Entity(x, y, z) constructor {
    self.name = class.name;
    self.class = class;
    self.level = 1;
    
    self.shot_cooldown = 0;
    
    self.base_rate = class.rate;
    self.base_range = class.range;
    self.base_damage = class.damage;
    self.base_model = class.model;
    self.base_bullet_data = class.bullet_data;
    
    self.mod_rate = 1;
    self.mod_range = 1;
    self.mod_damage = 1;
    
    Reposition = function(x, y, z) {
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
    
    SetRateMod = function(value) {
        mod_rate = value;
        act_rate = CalcRate() * mod_rate;
    }
    
    SetRangeMod = function(value) {
        mod_range = value;
        act_range = CalcRange() * mod_range;
    }
    
    SetDamageMod = function(value) {
        mod_damage = value;
        act_damage = CalcDamage() * mod_damage;
    }
    
    CalcRate = function() {
        return base_rate * level;
    }
    
    CalcRange = function() {
        return base_range * level;
    }
    
    CalcDamage = function() {
        return base_damage * level;
    }
    
    self.act_rate = CalcRate() * self.mod_rate;
    self.act_range = CalcRange() * self.mod_range;
    self.act_damage = CalcDamage() * self.mod_damage;
    
    LevelUp = function() {
        level++;
        act_rate = CalcRate() * mod_rate;
        act_range = CalcRange() * mod_range;
        act_damage = CalcDamage() * mod_damage;
    }
    
    AddToMap = function() {
        ds_list_add(GAME.all_entities, self);
        ds_list_add(GAME.all_towers, self);
        AddCollision();
    };
    
    Update = function() {
        if (shot_cooldown <= 0) {
            var target_foe = GetTarget();
            if (target_foe) {
                Shoot(target_foe);
            }
        } else {
            shot_cooldown -= DT;
        }
    };
    
    Shoot = function(target_foe) {
        var dir = point_direction(position.x, position.y, target_foe.position.x, target_foe.position.y);
        var shot_velocity = 10;
        var bullet = new EntityBullet(position.x, position.y, position.z, shot_velocity * dcos(dir), shot_velocity * -dsin(dir), 0, base_bullet_data, act_damage);
        bullet.AddToMap();
        shot_cooldown = 1 / act_rate;
    };
    
    GetTarget = function() {
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
    
    Render = function() {
        // set the shader if you are selected
        if (GAME.selected_entity == self || GAME.selected_entity_hover == self) {
            shader_set(shd_selected);
            shader_set_uniform_f(shader_get_uniform(shd_selected, "time"), current_time / 1000);
            if (GAME.selected_entity == self) {
                shader_set_uniform_color(shader_get_uniform(shd_selected, "color"), c_tower);
            } else if (GAME.selected_entity_hover == self) {
                shader_set_uniform_color(shader_get_uniform(shd_selected, "color"), c_tower_hover);
            }
        }
        var transform = matrix_build(0, 0, 0, 0, 0, 0, scale.x, scale.y, scale.z);
        transform = matrix_multiply(transform, matrix_build(0, 0, 0, rotation.x, rotation.y, rotation.z, 1, 1, 1));
        transform = matrix_multiply(transform, matrix_build(position.x, position.y, position.z, 0, 0, 0, 1, 1, 1));
        matrix_set(matrix_world, transform);
        vertex_submit(base_model.vbuff, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
        // reset the shader if you are selected
        if (GAME.selected_entity == self || GAME.selected_entity_hover == self) {
            cluck_apply(shd_cluck_fragment);
        }
    };
    
    Sell = function() {
        Destroy();
        RemoveCollision();
        ds_list_add(GAME.all_towers, self);
        GAME.player_money += class.cost;
    };
    
    RemoveCollision = function() {
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
}

function EntityTowerGlass(x, y, z, class) : EntityTower(x, y, z, class) constructor {
    Update = function() {
        var target_foe = GetTarget();
        if (target_foe) {
            target_foe.Damage(self.act_damage * DT);
            rotation.z = point_direction(self.position.x, self.position.y, target_foe.position.x, target_foe.position.y);
        }
    };
    
    Shoot = function(target_foe) {
        
    };
    
    Render = function() {
        // set the shader if you are selected
        if (GAME.selected_entity == self || GAME.selected_entity_hover == self) {
            shader_set(shd_selected);
            shader_set_uniform_f(shader_get_uniform(shd_selected, "time"), current_time / 1000);
            if (GAME.selected_entity == self) {
                shader_set_uniform_color(shader_get_uniform(shd_selected, "color"), c_tower);
            } else if (GAME.selected_entity_hover == self) {
                shader_set_uniform_color(shader_get_uniform(shd_selected, "color"), c_tower_hover);
            }
        }
        var transform = matrix_build(0, 0, 0, 0, 0, 0, scale.x, scale.y, scale.z);
        transform = matrix_multiply(transform, matrix_build(0, 0, 0, rotation.x, rotation.y, rotation.z, 1, 1, 1));
        transform = matrix_multiply(transform, matrix_build(position.x, position.y, position.z, 0, 0, 0, 1, 1, 1));
        matrix_set(matrix_world, transform);
        vertex_submit(base_model.vbuff, pr_trianglelist, -1);
        vertex_submit(GAME.magnifying_glass_beam, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
        // reset the shader if you are selected
        if (GAME.selected_entity == self || GAME.selected_entity_hover == self) {
            cluck_apply(shd_cluck_fragment);
        }
    };
}

function EntityTowerSpray(x, y, z, class) : EntityTower(x, y, z, class) constructor {
    Update = function() {
        if (shot_cooldown <= 0) {
            SpawnSpray();
        } else {
            shot_cooldown -= DT;
        }
    };
    
    SpawnSpray = function() {
        shot_cooldown = 1 / act_rate;
        var cloud = new EntityBulletBugSprayCloud(0, 0, 0, base_bullet_data);
        repeat (15) {
            var dist = random_range(12, act_range);
            var dir = random(360);
            cloud.Reposition(position.x + dist * dcos(dir), position.y - dist * dsin(dir), position.z);
            if (GAME.CollisionIsPath(cloud)) {
                ds_list_add(GAME.all_entities, cloud);
                return;
            }
        }
    };
}

function EntityTowerBird(x, y, z, class) : EntityTower(x, y, z, class) constructor {
    birds = [ ];
    bird_limit = 3;
    
    Update = function() {
        if (shot_cooldown <= 0 && array_length(birds) < bird_limit) {
            HatchBird();
        } else {
            shot_cooldown -= DT;
        }
    };
    
    HatchBird = function() {
        shot_cooldown = 1 / act_rate;
        var dist = 32 + array_length(birds) * 16;
        var bird = new EntityBulletBird(0, 0, 0, base_bullet_data, self, dist);
        ds_list_add(GAME.all_entities, bird);
        array_push(birds, bird);
    };
}

function EntityTowerFlyPaper(x, y, z, class) : EntityTower(x, y, z, class) constructor {
    self.paper_count = 0;
    self.paper_limit = 2;
    
    Update = function() {
        if (shot_cooldown <= 0) {
            Dispense();
        } else {
            shot_cooldown -= DT;
        }
    };
    
    Dispense = function() {
        if (paper_count >= paper_limit) {
            return;
        }
        
        shot_cooldown = 1 / act_rate;
        var paper = new EntityBulletFlyPaper(0, 0, 0, base_bullet_data, self);
        repeat (15) {
            var dist = random_range(12, act_range);
            var dir = random(360);
            paper.Reposition(position.x + dist * dcos(dir), position.y - dist * dsin(dir), position.z);
            if (GAME.CollisionIsPath(paper)) {
                ds_list_add(GAME.all_entities, paper);
                paper_count++;
                return;
            }
        }
    };
}

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
    
    self.mod_def = 1;
    self.mod_mdef = 1;
    self.mod_speed = 1;
    
    self.status_burn = 0;
    self.status_poison = 0;
    self.status_slow = 0;
    
    Burn = function() {
        status_burn = BURN_DURATION;
    };
    
    Poison = function() {
        status_poison = POISON_DURATION;
    };
    
    Slow = function() {
        status_slow = SLOW_DURATION;
        SetSpeedMod(SLOW_FACTOR);
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
        hp -= max(amount, 0);
        if (hp < 0) {
            Die();
        }
    };
    
    Heal = function(amount) {
        hp = min(hp + max(amount, 0), hp_max);
    };
    
    Die = function() {
        GAME.player_money += reward;
        Destroy();
    };
    
    AddToMap = function() {
        ds_list_add(GAME.all_entities, self);
        ds_list_add(GAME.all_foes, self);
    };
    
    Update = function() {
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
        
        if (status_burn > 0) {
            Damage(BURN_DPS * DT);
            status_burn -= DT;
        }
        
        if (status_poison > 0) {
            Damage(POISON_DPS * DT);
            status_poison -= DT;
        }
        
        if (status_slow > 0) {
            status_slow -= DT;
            if (status_slow <= 0) {
                SetSpeedMod(1);
            }
        }
    };
    
    Render = function() {
        var transform = matrix_build(0, 0, 0, 0, 0, 0, scale.x, scale.y, scale.z);
        transform = matrix_multiply(transform, matrix_build(0, 0, 0, rotation.x, rotation.y, rotation.z, 1, 1, 1));
        transform = matrix_multiply(transform, matrix_build(position.x, position.y, position.z, 0, 0, 0, 1, 1, 1));
        matrix_set(matrix_world, transform);
        vertex_submit(class.model.vbuff, pr_trianglelist, sprite_get_texture(class.sprite, 0));
        matrix_set(matrix_world, matrix_build_identity());
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