function Entity(x, y, z) constructor {
    position = new Vector3(x, y, z);
    rotation = new Vector3(0, 0, 0);
    scale = new Vector3(1, 1, 1);
    
    collision = new BBox(new Vector3(position.x - 16, position.y - 16, position.z), new Vector3(position.x + 16, position.y + 16, position.z + 64));
    
    raycast = coll_ray_aabb;
    
    BeginUpdate = function() {
        
    };
    
    Update = function() {
        
    };
    
    Render = function() {
        
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

function EntityEnv(x, y, z, vbuff, savename) : Entity(x, y, z) constructor {
    self.vbuff = vbuff;
    self.savename = savename;
    
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
                shader_set_uniform_f(shader_get_uniform(shd_selected, "color"), 1, 1, 1, 1);
            } else if (GAME.editor_hover_entity == self) {
                shader_set_uniform_f(shader_get_uniform(shd_selected, "color"), 0, 1, 0, 1);
            }
        }
        matrix_set(matrix_world, matrix_build(position.x, position.y, position.z, 0, 0, 0, 1, 1, 1));
        vertex_submit(vbuff, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
        // reset the shader if you are selected
        if (GAME.selected_entity == self || GAME.editor_hover_entity == self) {
            shader_set(shd_cluck_fragment);
        }
    };
}

function EntityBullet(x, y, z, vx, vy, vz, bullet_data, damage) : Entity(x, y, z) constructor {
    velocity = new Vector3(vx, vy, vz);
    self.bullet_data = bullet_data;
    self.damage = damage;
    time_to_live = 1;
    
    raycast = coll_ray_invalid;
    
    Update = function() {
        position.x += velocity.x;
        position.y += velocity.y;
        position.z += velocity.z;
        
        for (var i = 0; i < ds_list_size(GAME.all_foes); i++) {
            var foe = GAME.all_foes[| i];
            var radius = 18;
            if (point_distance_3d(position.x, position.y, position.z, foe.position.x, foe.position.y, foe.position.z) <= radius) {
                foe.Damage(damage);
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
        vertex_submit(bullet_data.vbuff, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
    };
}

function EntityTower(x, y, z, class) : Entity(x, y, z) constructor {
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
        var bullet = new EntityBullet(position.x, position.y, position.z, 6 * dcos(dir), 6 * -dsin(dir), 0, base_bullet_data, act_damage);
        ds_list_add(GAME.all_entities, bullet);
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
        if (GAME.selected_entity == self) {
            shader_set(shd_selected);
            shader_set_uniform_f(shader_get_uniform(shd_selected, "time"), current_time / 1000);
            shader_set_uniform_f(shader_get_uniform(shd_selected, "color"), 1, 1, 1, 1);
        }
        var transform = matrix_build(0, 0, 0, 0, 0, 0, scale.x, scale.y, scale.z);
        transform = matrix_multiply(transform, matrix_build(0, 0, 0, rotation.x, rotation.y, rotation.z, 1, 1, 1));
        transform = matrix_multiply(transform, matrix_build(position.x, position.y, position.z, 0, 0, 0, 1, 1, 1));
        matrix_set(matrix_world, transform);
        vertex_submit(base_model, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
        // reset the shader if you are selected
        if (GAME.selected_entity == self) {
            shader_set(shd_cluck_fragment);
        }
    };
}

function EntityTowerBuff(x, y, z, class) : EntityTower(x, y, z, class) constructor {
    Update = function() {
        if (shot_cooldown <= 0) {
            var target_friends = GetTarget();
            for (var i = 0; i < ds_list_size(target_friends); i++) {
                Buff(target_friends[| i]);
            }
            ds_list_destroy(target_friends);
        } else {
            shot_cooldown -= DT;
        }
    };
    
    Buff = function(target_friend) {
        target_friend.SetRateMod(4);
        shot_cooldown = 1 / act_rate;
    };
    
    GetTarget = function() {
        var target_friends = ds_list_create();
        for (var i = 0; i < ds_list_size(GAME.all_towers); i++) {
            var friend = GAME.all_towers[| i];
            if (friend == self) continue;
            if (point_distance_3d(position.x, position.y, position.z, friend.position.x, friend.position.y, friend.position.z) < act_range) {
                ds_list_add(target_friends, friend);
            }
        }
        return target_friends;
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
    
    self.path = pth_test;
    self.path_node = 0;
    self.destination = new Vector3(path_get_point_x(self.path, 0), path_get_point_y(self.path, 0), 0);
    
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
    
    Update = function() {
        var dt = DT;
        var dir = point_direction(position.x, position.y, destination.x, destination.y);
        position.x = approach(position.x, destination.x, act_speed * abs(dcos(dir)) * dt);
        position.y = approach(position.y, destination.y, act_speed * abs(dsin(dir)) * dt);
        position.z = approach(position.z, destination.z, act_speed * dt);
        if (position.x == destination.x && position.y == destination.y && position.z == destination.z) {
            if (path_get_number(path) > (path_node + 1)) {
                path_node++;
                destination.x = path_get_point_x(path, path_node);
                destination.y = path_get_point_y(path, path_node);
            } else {
                GAME.PlayerDamage(damage);
                Destroy();
            }
        }
    };
    
    Render = function() {
        var transform = matrix_build(0, 0, 0, 0, 0, 0, scale.x, scale.y, scale.z);
        transform = matrix_multiply(transform, matrix_build(0, 0, 0, rotation.x, rotation.y, rotation.z, 1, 1, 1));
        transform = matrix_multiply(transform, matrix_build(position.x, position.y, position.z, 0, 0, 0, 1, 1, 1));
        matrix_set(matrix_world, transform);
        vertex_submit(class.model, pr_trianglelist, sprite_get_texture(class.sprite, 0));
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