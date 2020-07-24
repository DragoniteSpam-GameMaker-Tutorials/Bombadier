function FoeData(name, hp, def, mdef, speed, damage, sprite, model) constructor {
    self.name = name;
    self.hp = hp;
    self.def = def;
    self.mdef = mdef;
    self.speed = speed;
    self.damage = damage;
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
    
    self.shot_type = 0;
}

function BulletData(name, vbuff) constructor {
    self.name = name;
    self.vbuff = vbuff;
}