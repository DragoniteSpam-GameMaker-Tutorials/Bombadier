function FoeData(name, hp, def, mdef, speed, damage, reward, sprite, model, entity_type) constructor {
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
    
    self.entity_type = entity_type;
}

function TowerData(name, rate_arr, range_arr, damage_arr, cost_arr, model, bullet_data) constructor {
    self.name = name;
    self.rate = rate_arr;           // shots per second
    self.range = range_arr;
    self.damage = damage_arr;
    self.cost = cost_arr;
    self.model = model;
    self.bullet_data = bullet_data;
}

function BulletData(name, model, on_hit) constructor {
    self.name = name;
    self.model = model;
    
    self.OnHit = method(self, on_hit);
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