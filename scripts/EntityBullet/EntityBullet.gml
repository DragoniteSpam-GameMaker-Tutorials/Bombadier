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
    hits_remaining = 2;
    
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
                if (foe.status_poison <= 0) {
                    hits_remaining--;
                }
                bullet_data.OnHit(foe);
                if (hits_remaining <= 0) {
                    Destroy();
                    return;
                }
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