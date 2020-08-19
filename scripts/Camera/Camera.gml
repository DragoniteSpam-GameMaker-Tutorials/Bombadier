function Camera() constructor {
    from = new Vector3(640, 720, 160);
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
        if (keyboard_check(vk_left) || keyboard_check(ord("A"))) {
            from.x -= mspd * dt;
            to.x -= mspd * dt;
        }
        if (keyboard_check(vk_right) || keyboard_check(ord("D"))) {
            from.x += mspd * dt;
            to.x += mspd * dt;
        }
        if (keyboard_check(vk_up) || keyboard_check(ord("W"))) {
            from.y -= mspd * dt;
            to.y -= mspd * dt;
        }
        if (keyboard_check(vk_down) || keyboard_check(ord("S"))) {
            from.y += mspd * dt;
            to.y += mspd * dt;
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
        
        gpu_set_ztestenable(false);
        gpu_set_zwriteenable(false);
        matrix_set(matrix_world, matrix_build(from.x, from.y, from.z, 0, 0, 0, 1, 1, 1));
        vertex_submit(GAME.skybox_cube, pr_trianglelist, sprite_get_texture(spr_skybox, 0));
        matrix_set(matrix_world, matrix_build_identity());
        gpu_set_ztestenable(true);
        gpu_set_zwriteenable(true);
        
        if (floor_intersect) {
            matrix_set(matrix_world, matrix_build(floor_intersect.x, floor_intersect.y, floor_intersect.z, 0, 0, 0, 1, 1, 1));
            vertex_submit(GAME.test_ball, pr_trianglelist, -1);
            matrix_set(matrix_world, matrix_build_identity());
        }
    };
    
    GetFloorIntersect = function() {
        return floor_intersect;
    };
}