function Entity(x, y, z) constructor {
    position = new Vector3(x, y, z);
    rotation = new Vector3(0, 0, 0);
    scale = new Vector3(1, 1, 1);
    
    Update = function() {
        
    };
    
    Render = function() {
        
    };
    
    Destroy = function() {
        
    };
}

function EntityTower(x, y, z, class) : Entity(x, y, z) constructor {
    self.class = class;
    
    Update = function() {
        rotation.z++;
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
    
    self.path = pth_test;
    self.path_node = 0;
    self.destination = new Vector3(path_get_point_x(self.path, 0), path_get_point_y(self.path, 0), 0);
    
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
}