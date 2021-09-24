function Wave(class, number, level, frequency) constructor {
    self.class = class;
    self.number = number;
    self.level = level;
    self.frequency = frequency;
    
    self.status = EWaveStatuses.NOT_STARTED;
    self.foe_timer = 0;
    self.foes_remaining = number;
    
    Launch = function() {
        status = EWaveStatuses.RUNNING;
    };
    
    Update = function() {
        if (status == EWaveStatuses.RUNNING) {
            if (foe_timer <= 0) {
                var foe = new class.entity_type(class, level);
                ds_list_add(GAME.all_entities, foe);
                ds_list_add(GAME.all_foes, foe);
                foe_timer = WAVE_FOE_COUNTDOWN / self.frequency;
                foes_remaining--;
            }
            if (foes_remaining > 0) {
                foe_timer -= DT;
            } else {
                status = EWaveStatuses.FINISHED;
            }
        }
    };
    
    Finished = function() {
        return (status == EWaveStatuses.FINISHED);
    };
}

enum EWaveStatuses {
    NOT_STARTED, RUNNING, FINISHED
}

function PathNode(position) constructor {
    self.position = position
    collision = new BBox(new Vector3(position.x - 8, position.y - 8, position.z - 8), new Vector3(position.x + 8, position.y + 8, position.z + 8));
    raycast = coll_ray_aabb;
    
    Render = function() {
        // set the shader if you are selected
        if (GAME.selected_entity == self || GAME.editor_hover_entity == self) {
            shader_set(shd_selected);
            shader_set_uniform_f(shader_get_uniform(shd_selected, "time"), current_time / 1000);
            if (GAME.selected_entity == self) {
                shader_set_uniform_color(shader_get_uniform(shd_selected, "color"), c_path);
            } else if (GAME.editor_hover_entity == self) {
                shader_set_uniform_color(shader_get_uniform(shd_selected, "color"), c_path_hover);
            }
        }
        
        matrix_set(matrix_world, matrix_build(position.x, position.y, position.z, 0, 0, 0, 1, 1, 1));
        vertex_submit(GAME.test_ball, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_build_identity());
        // reset the shader if you are selected
        if (GAME.selected_entity == self || GAME.editor_hover_entity == self) {
            shader_set(shd_cluck_unlit);
        }
    };
}