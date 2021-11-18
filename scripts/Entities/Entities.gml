function Entity(x, y, z) constructor {
    self.persist = false;
    position = new Vector3(x, y, z);
    rotation = new Vector3(0, 0, 0);
    scale = new Vector3(1, 1, 1);
    
    collision = new BBox(new Vector3(position.x - 16, position.y - 16, position.z), new Vector3(position.x + 16, position.y + 16, position.z + 64));
    
    raycast = coll_ray_aabb;
    
    static BeginUpdate = function() {
        
    };
    
    static Update = function() {
        
    };
    
    static Render = function() {
        
    };
    
    static AddToMap = function() {
        
    };
    
    static AddCollision = function() {
        
    };
    
    static Save = function(save_json, i) {
        save_json.entities[i] = 0;
    };
    
    static Destroy = function() {
        var current_index = ds_list_find_index(GAME.all_entities, self);
        if (current_index > -1) {
            ds_list_delete(GAME.all_entities, current_index);
        }
    };
    
    static GameOver = function() {
        
    };
    
    static RenderRadius = function() {
        
    };
}

function EntityEnv(x, y, z, model, savename) : Entity(x, y, z) constructor {
    self.persist = true;
    self.model = model;
    self.savename = savename;
    
    self.rotation = new Vector3(0, 0, 0);
    self.scale = new Vector3(1, 1, 1);
    
    collision = new BBox(new Vector3(position.x - 8, position.y - 8, position.z), new Vector3(position.x + 8, position.y + 8, position.z + 16));
    
    static Reposition = function(x, y, z) {
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
    
    static Select = function() {
        
    };
    
    static Deselect = function() {
        is_moving = false;
    };
    
    static AddToMap = function() {
        ds_list_add(GAME.all_entities, self);
        ds_list_add(GAME.all_env_entities, self);
    };
    
    is_moving = false;
    
    static Save = function(save_json, i) {
        save_json.entities[i] = {
            position: position,
            rotation: rotation,
            scale: scale,
            name: savename,
        };
    };
    
    static Render = function() {
        matrix_set(matrix_world, matrix_build(position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, scale.x, scale.y, scale.z));
        vertex_submit(model.vbuff, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
    };
}