function FoeData(name, hp, def, mdef, speed, damage, reward, sprite, model) constructor {
    self.name = name;
    self.hp = hp;
    self.def = def;
    self.mdef = mdef;
    self.speed = speed;
    self.damage = damage;
    self.reward = reward;
    self.sprite = sprite;
    self.model = model;
    
    self.weaknesses = 0;
    self.immunities = 0;
}

function TowerData(name, rate, range, damage, cost, model, bullet_data) constructor {
    self.name = name;
    self.rate = rate;           // shots per second
    self.range = range;
    self.damage = damage;
    self.cost = cost;
    self.model = model;
    self.bullet_data = bullet_data;
    // this isn't used for anything and it probably won't be used later
    self.shot_type = 0;
}

function BulletData(name, model) constructor {
    self.name = name;
    self.model = model;
    
    self.OnHit = function(target) {
        
    };
}

function BulletDataFire(name, model) : BulletData(name, model) constructor {
    self.OnHit = function(target) {
        target.Burn();
    };
}

function ModelData(name, vbuff) constructor {
    self.name = name;
    self.vbuff = vbuff;
    
    var xmin = 100000000;
    var ymin = 100000000;
    var zmin = 100000000;
    var xmax = -100000000;
    var ymax = -100000000;
    var zmax = -100000000;
    
    var data_buffer = buffer_create_from_vertex_buffer(vbuff, buffer_fixed, 1);
    
    for (var i = 0; i < buffer_get_size(data_buffer); i += 36) {
        var vertex_x = buffer_peek(data_buffer, i, buffer_f32);
        var vertex_y = buffer_peek(data_buffer, i + 4, buffer_f32);
        var vertex_z = buffer_peek(data_buffer, i + 8, buffer_f32);
        xmin = min(vertex_x, xmin);
        ymin = min(vertex_y, ymin);
        zmin = min(vertex_z, zmin);
        xmax = max(vertex_x, xmax);
        ymax = max(vertex_y, ymax);
        zmax = max(vertex_z, zmax);
    }
    
    collision = new BBox(new Vector3(xmin, ymin, zmin), new Vector3(xmax, ymax, zmax));
    
    solid = ((xmin - xmax) * (ymin - ymax)) >= 256;
}