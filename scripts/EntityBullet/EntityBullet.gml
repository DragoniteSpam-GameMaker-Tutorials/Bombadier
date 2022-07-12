function EntityBullet(x, y, z, vx, vy, vz, bullet_data, damage, parent_tower) : Entity(x, y, z) constructor {
    self.velocity = new Vector3(vx, vy, vz);
    self.bullet_data = bullet_data;
    self.damage = damage;
    self.time_to_live = 1;
    self.parent_tower = parent_tower;
    
    raycast = coll_ray_invalid;
    
    static AddToMap = function() {
        ds_list_add(GAME.all_entities, self);
    };
    
    OnHit = method(self, method_get_index(bullet_data.OnHit));
    
    static Update = function() {
        position.x += velocity.x;
        position.y += velocity.y;
        position.z += velocity.z;
        
        for (var i = 0; i < ds_list_size(GAME.all_foes); i++) {
            var foe = GAME.all_foes[| i];
            var radius = 18;
            if (point_distance_3d(position.x, position.y, position.z, foe.position.x, foe.position.y, foe.position.z) <= radius) {
                foe.Damage(damage);
                self.parent_tower.stats.damage += damage;
                OnHit(foe);
                Destroy();
                Particles.BurstFromEmitter(Particles.emitters.hit_effects, Particles.types.stone_debris, foe.position.x, foe.position.y, foe.position.z + 8, 32);
                return;
            }
        }
        
        time_to_live -= DT;
        
        if (time_to_live <= 0) {
            Destroy();
        }
    };
    
    static Render = function() {
        matrix_set(matrix_world, matrix_build(position.x, position.y, position.z, 0, 0, 0, 1, 1, 1));
        vertex_submit(bullet_data.model.vbuff, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
    };
    
    static GameOver = function() {
        self.Destroy();
    };
}

// Clouds last for (x) seconds or (y) hits on the foe
function EntityBulletBugSprayCloud(x, y, z, bullet_data, lifetime, max_hits, parent_tower) : EntityBullet(x, y, z, 0, 0, 0, bullet_data, 0, parent_tower) constructor {
    self.lifetime = lifetime;
    self.radius = 40;
    self.hits_remaining = max_hits;
    
    static Reposition = function(x, y, z) {
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
    
    static Update = function() {
        for (var i = 0; i < ds_list_size(GAME.all_foes); i++) {
            var foe = GAME.all_foes[| i];
            if (point_distance_3d(position.x, position.y, position.z, foe.position.x, foe.position.y, foe.position.z) < radius) {
                if (foe.status_poison <= 0) {
                    self.hits_remaining--;
                    self.parent_tower.stats.hits++;
                }
                OnHit(foe);
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
    
    static Render = function() {
        if (irandom(4) == 1) {
            Particles.BurstFromEmitterRadius(Particles.emitters.hit_effects, Particles.types.poison, self.position.x, self.position.y, self.position.z + 8, 16, 1);
        }
    };
};

function EntityBulletBird(x, y, z, bullet_data, parent_tower, nest_radius) : EntityBullet(x, y, z, 0, 0, 0, bullet_data, 0, parent_tower) constructor {
    self.lifetime = 2;
    self.attack_radius = 32;
    self.nest_radius = nest_radius;
    self.nest_angle = 270;
    self.anim_frame = 0;
    
    static Reposition = function(x, y, z) {
        position.x = x;
        position.y = y;
        position.z = z;
    };
    
    static Update = function() {
        for (var i = 0; i < ds_list_size(GAME.all_foes); i++) {
            var foe = GAME.all_foes[| i];
            if (point_distance_3d(position.x, position.y, position.z, foe.position.x, foe.position.y, foe.position.z) < attack_radius) {
                foe.Damage(parent_tower.act_damage);
                OnHit(foe);
                Particles.BurstFromEmitter(Particles.emitters.hit_effects, Particles.types.stone_debris, foe.position.x, foe.position.y, foe.position.z + 8, 12);
                self.parent_tower.RemoveBird(self);
                self.Destroy();
                break;
            }
        }
        
        var linear_velocity = 160;
        
        Reposition(parent_tower.position.x + nest_radius * dcos(nest_angle), parent_tower.position.y - nest_radius * dsin(nest_angle), parent_tower.position.z + 16);
        nest_angle += linear_velocity / nest_radius;
        
        var anim_speed = 4;
        anim_frame += anim_speed * DT;
    };
    
    static Render = function() {
        matrix_set(matrix_world, matrix_build(position.x, position.y, position.z, 0, 0, nest_angle + 180, 1, 1, 1));
        vertex_submit(bullet_data.anim_frames[floor(anim_frame) % array_length(bullet_data.anim_frames)].vbuff, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
    };
};

function EntityBulletFlyPaper(x, y, z, lifetime, bullet_data, parent_tower) : EntityBullet(x, y, z, 0, 0, 0, bullet_data, 0, parent_tower) constructor {
    self.lifetime = lifetime;
    self.radius = 60;
    self.hits_remaining = 2;
    
    static Reposition = function(x, y, z) {
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
    
    static Update = function() {
        for (var i = 0; i < ds_list_size(GAME.all_foes); i++) {
            var foe = GAME.all_foes[| i];
            if (point_distance_3d(position.x, position.y, position.z, foe.position.x, foe.position.y, foe.position.z) < radius) {
                if (foe.status_slow <= 0) {
                    self.hits_remaining--;
                    self.parent_tower.stats.hits++;
                    Particles.BurstFromEmitter(Particles.emitters.hit_effects, Particles.types.glue, foe.position.x, foe.position.y, foe.position.z + 8, 12);
                }
                OnHit(foe);
                if (hits_remaining <= 0) {
                    Destroy();
                    parent_tower.paper_count--;
                    return;
                }
            }
        }
        
        self.lifetime -= DT;
        if (self.lifetime <= 0) {
            self.Destroy();
            self.parent_tower.paper_count--;
        }
    };
};