function Camera() constructor {
    from = new Vector3(640, 840, 120);
    to = new Vector3(640, 0, 0);
    up = new Vector3(0, 0, 1);
    fov = 60;
    znear = 0.3;
    zfar = 32000;
    
    view_mat = undefined;
    proj_mat = undefined;
    mouse_cast = undefined;
    floor_intersect = undefined;
    
    Update = function() {
        var mspd = 200;
        var dt = DT;
        
        if (GAME.gameplay_mode != GameModes.TITLE) {
            if (/*keyboard_check(vk_left) || */keyboard_check(ord("A"))) {
                from.x -= mspd * dt;
                to.x -= mspd * dt;
            }
            if (/*keyboard_check(vk_right) || */keyboard_check(ord("D"))) {
                from.x += mspd * dt;
                to.x += mspd * dt;
            }
            if (/*keyboard_check(vk_up) || */keyboard_check(ord("W"))) {
                from.y -= mspd * dt;
                to.y -= mspd * dt;
            }
            if (/*keyboard_check(vk_down) || */keyboard_check(ord("S"))) {
                from.y += mspd * dt;
                to.y += mspd * dt;
            }
        }
        
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
        
        draw_clear(c_black);
        
        var cam = camera_get_active();
        camera_set_view_mat(cam, view_mat);
        camera_set_proj_mat(cam, proj_mat);
        camera_apply(cam);
    };
    
    GetFloorIntersect = function() {
        return floor_intersect;
    };
}