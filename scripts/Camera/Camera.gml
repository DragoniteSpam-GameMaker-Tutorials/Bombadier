#macro CAMERA_FROM_LEVEL (new Vector3(640, 840, 200))
#macro CAMERA_TO_LEVEL (new Vector3(640, 0, 0))
#macro CAMERA_FROM_TITLE (new Vector3(640, 840, 120))
#macro CAMERA_TO_TITLE (new Vector3(640, 0, 0))

function Camera() constructor {
    from = CAMERA_FROM_TITLE;
    to = CAMERA_TO_TITLE;
    up = new Vector3(0, 0, 1);
    fov = 60;
    znear = 0.3;
    zfar = 32000;
    
    view_mat = undefined;
    proj_mat = undefined;
    mouse_cast = undefined;
    floor_intersect = undefined;
    
    mouse_last = { x: undefined, y: undefined };
    
    Update = function() {
        var mspd = 200;
        var dt = DT;
        var mx = 0;
        var my = 0
        
        if (GAME.gameplay_mode != GameModes.TITLE) {
            if (keyboard_check(ord("A"))) {
                mx -= mspd * dt;
                mx -= mspd * dt;
            }
            if (keyboard_check(ord("D"))) {
                mx += mspd * dt;
                mx += mspd * dt;
            }
            if (keyboard_check(ord("W"))) {
                my -= mspd * dt;
                my -= mspd * dt;
            }
            if (keyboard_check(ord("S"))) {
                my += mspd * dt;
                my += mspd * dt;
            }
        }
        
        if (GAME.gameplay_mode == GameModes.GAMEPLAY) {
            if (self.mouse_last.x != undefined && mouse_check_button(mb_middle)) {
                var mouse_drag_speed = 0.4;
                mx += (window_mouse_get_x() - self.mouse_last.x) * mouse_drag_speed;
                my += (window_mouse_get_y() - self.mouse_last.y) * mouse_drag_speed;
            }
            
            self.mouse_last.x = window_mouse_get_x();
            self.mouse_last.y = window_mouse_get_y();
        }
        
        var camera_x_min = (GAME.gameplay_mode == GameModes.GAMEPLAY) ? 200 : 0;
        var camera_x_max = (GAME.gameplay_mode == GameModes.GAMEPLAY) ? (room_width - 200) : room_width;
        var camera_y_min = (GAME.gameplay_mode == GameModes.GAMEPLAY) ? 0 : 0;
        var camera_y_max = (GAME.gameplay_mode == GameModes.GAMEPLAY) ? 128 : (room_height / 2);
        
        to.x = clamp(to.x + mx, camera_x_min, camera_x_max);
        from.x = clamp(from.x + mx, camera_x_min, camera_x_max);
        
        to.y = clamp(to.y + my, camera_y_min, camera_y_max);
        from.y = to.y + 840;
        
        view_mat = matrix_build_lookat(from.x, from.y, from.z, to.x, to.y, to.z, up.x, up.y, up.z);
        proj_mat = matrix_build_projection_perspective_fov(-fov, -window_get_width() / window_get_height(), znear, zfar);
        
        mouse_cast = screen_to_world(window_mouse_get_x(), window_mouse_get_y(), view_mat, proj_mat);
        
        if (mouse_cast.z < 0) {
            var m = -from.z / mouse_cast.z;
            floor_intersect = new Vector3(from.x + mouse_cast.x * m, from.y + mouse_cast.y * m, 0);
        } else {
            floor_intersect = undefined;
        }
    };
    
    Render = function() {
        gpu_set_alphatestenable(true);
        gpu_set_alphatestref(10);
        
        var cam = camera_get_active();
        
        if (GAME.editor_mode == EditorModes.COLLISION) {
            camera_set_view_mat(cam, matrix_build_lookat(room_width / 2, room_height / 2, 2000, room_width / 2, room_height / 2, 0, 0, 1, 0));
            camera_set_proj_mat(cam, matrix_build_projection_ortho(-room_width, room_height, 1, 3000));
        } else {
            camera_set_view_mat(cam, view_mat);
            camera_set_proj_mat(cam, proj_mat);
        }
        
        camera_apply(cam);
    };
    
    GetFloorIntersect = function() {
        return floor_intersect;
    };
}