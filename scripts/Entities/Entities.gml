function Entity(x, y, z) constructor {
    position = new Vector3(x, y, z);
    rotation = new Vector3(0, 0, 0);
    scale = new Vector3(1, 1, 1);
    
    Update = function() {
        
    };
    
    Render = function() {
        
    };
    
    Destroy = function() {
        var current_index = ds_list_find_index(GAME.all_entities, self);
        if (current_index > -1) {
            ds_list_delete(GAME.all_entities, current_index);
        }
    };
}

function EntityEnv(x, y, z, vbuff) : Entity(x, y, z) constructor {
    self.vbuff = vbuff;
    
    Render = function() {
        matrix_set(matrix_world, matrix_build(position.x, position.y, position.z, 0, 0, 0, 1, 1, 1));
        vertex_submit(vbuff, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
        show_debug_message([position.x, position.y, position.z, vbuff]);
    };
}

function EntityBullet(x, y, z, vx, vy, vz, bullet_data) : Entity(x, y, z) constructor {
    velocity = new Vector3(vx, vy, vz);
    self.bullet_data = bullet_data;
    time_to_live = 1;
    
    Update = function() {
        position.x += velocity.x;
        position.y += velocity.y;
        position.z += velocity.z;
        
        for (var i = 0; i < ds_list_size(GAME.all_foes); i++) {
            var foe = GAME.all_foes[| i];
            var radius = 12;
            if (point_distance_3d(position.x, position.y, position.z, foe.position.x, foe.position.y, foe.position.z) <= radius) {
                foe.Damage(1);
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
    
    self.shot_cooldown = 0;
    
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
        var bullet = new EntityBullet(position.x, position.y, position.z, 6 * dcos(dir), 6 * -dsin(dir), 0, class.bullet_data);
        ds_list_add(GAME.all_entities, bullet);
        shot_cooldown = 1 / class.rate;
    };
    
    GetTarget = function() {
        var target_foe = undefined;
        for (var i = 0; i < ds_list_size(GAME.all_foes); i++) {
            var foe = GAME.all_foes[| i];
            if (point_distance_3d(position.x, position.y, position.z, foe.position.x, foe.position.y, foe.position.z) < class.range) {
                target_foe = foe;
                break;
            }
        }
        return target_foe;
    };
    
    Render = function() {
        var transform = matrix_build(0, 0, 0, 0, 0, 0, scale.x, scale.y, scale.z);
        transform = matrix_multiply(transform, matrix_build(0, 0, 0, rotation.x, rotation.y, rotation.z, 1, 1, 1));
        transform = matrix_multiply(transform, matrix_build(position.x, position.y, position.z, 0, 0, 0, 1, 1, 1));
        matrix_set(matrix_world, transform);
        vertex_submit(class.model, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
    };
}

function EntityFoe(class, level) : Entity(0, 0, 0) constructor {
    self.class = class;
    self.level = level;
    
    self.hp = class.hp;
    self.hp_max = self.hp;
    self.def = class.def;
    self.mdef = class.mdef;
    self.speed = class.speed;
    self.damage = class.damage;
    self.reward = class.reward;
    
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
        position.x = approach(position.x, destination.x, speed * abs(dcos(dir)) * dt);
        position.y = approach(position.y, destination.y, speed * abs(dsin(dir)) * dt);
        position.z = approach(position.z, destination.z, speed * dt);
        if (position.x == destination.x && position.y == destination.y && position.z == destination.z) {
            if (path_get_number(path) > (path_node + 1)) {
                path_node++;
                destination.x = path_get_point_x(path, path_node);
                destination.y = path_get_point_y(path, path_node);
            } else {
                GAME.PlayerDamage(1);
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