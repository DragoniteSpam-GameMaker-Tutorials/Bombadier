function Camera() constructor {
    from = new Vector3(640, 720, 100);
    to = new Vector3(640, 0, 0);
    up = new Vector3(0, 0, 1);
    fov = 60;
    znear = 1;
    zfar = 32000;
    
    Update = function() {
        var mspd = 200;
        var dt = delta_time / 1000000;
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
    };
    
    Render = function() {
        gpu_set_ztestenable(true);
        gpu_set_zwriteenable(true);
        
        draw_clear(c_black);
        
        var cam = camera_get_active();
        camera_set_view_mat(cam, matrix_build_lookat(from.x, from.y, from.z, to.x, to.y, to.z, up.x, up.y, up.z));
        camera_set_proj_mat(cam, matrix_build_projection_perspective_fov(-fov, -window_get_width() / window_get_height(), znear, zfar));
        camera_apply(cam);
    };
}