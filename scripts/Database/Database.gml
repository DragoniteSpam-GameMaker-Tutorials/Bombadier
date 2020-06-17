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

function TowerData(name, rate, range, damage, cost, model) constructor {
    self.name = name;
    self.rate = rate;
    self.range = range;
    self.damage = damage;
    self.cost = cost;
    self.model = model;
    
    self.shot_type = 0;
}