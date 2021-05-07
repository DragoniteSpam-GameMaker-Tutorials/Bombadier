function Entity(x, y, z) constructor {
    position = new Vector3(x, y, z);
    rotation = new Vector3(0, 0, 0);
    scale = new Vector3(1, 1, 1);
    
    collision = new BBox(new Vector3(position.x - 16, position.y - 16, position.z), new Vector3(position.x + 16, position.y + 16, position.z + 64));
    
    raycast = coll_ray_aabb;
    solid = true;
    
    BeginUpdate = function() {
        
    };
    
    Update = function() {
        
    };
    
    Render = function() {
        
    };
    
    AddToMap = function() {
        
    };
    
    AddCollision = function() {
        if (solid) {
            var xmin = min(collision.p1.x * scale.x, collision.p2.x * scale.x);
            var ymin = min(collision.p1.y * scale.y, collision.p2.y * scale.y);
            var xmax = max(collision.p1.x * scale.x, collision.p2.x * scale.x);
            var ymax = max(collision.p1.y * scale.y, collision.p2.y * scale.y);
            var cell_xmin = clamp(xmin div GRID_CELL_SIZE, 0, ds_grid_width(GAME.collision_grid) - 1);
            var cell_ymin = clamp(ymin div GRID_CELL_SIZE, 0, ds_grid_height(GAME.collision_grid) - 1);
            var cell_xmax = clamp(ceil(xmax / GRID_CELL_SIZE), 0, ds_grid_width(GAME.collision_grid) - 1);
            var cell_ymax = clamp(ceil(ymax / GRID_CELL_SIZE), 0, ds_grid_height(GAME.collision_grid) - 1);
            for (var i = cell_xmin; i <= cell_xmax; i++) {
                for (var j = cell_ymin; j <= cell_ymax; j++) {
                    GAME.collision_grid[# i, j] = max(GAME.collision_grid[# i, j], GRID_COLLISION_FILLED);
                }
            }
        }
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

function EntityEnv(x, y, z, model, savename) : Entity(x, y, z) constructor {
    self.model = model;
    self.solid = model.solid;
    self.savename = savename;
    
    self.rotation = new Vector3(0, 0, 0);
    self.scale = new Vector3(1, 1, 1);
    
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
    
    Select = function() {
        
    };
    
    Deselect = function() {
        is_moving = false;
    };
    
    AddToMap = function() {
        ds_list_add(GAME.all_entities, self);
        ds_list_add(GAME.all_env_entities, self);
        AddCollision();
    };
    
    is_moving = false;
    
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
                shader_set_uniform_color(shader_get_uniform(shd_selected, "color"), c_env);
            } else if (GAME.editor_hover_entity == self) {
                shader_set_uniform_color(shader_get_uniform(shd_selected, "color"), c_env_hover);
            }
        }
        
        matrix_set(matrix_world, matrix_build(position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, scale.x, scale.y, scale.z));
        vertex_submit(model.vbuff, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
        // reset the shader if you are selected
        if (GAME.selected_entity == self || GAME.editor_hover_entity == self) {
            cluck_apply(SHADER_WORLD);
        }
    };
}