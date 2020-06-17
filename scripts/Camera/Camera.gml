function Camera() constructor {
    from = new Vector3(0, 0, 100);
    to = new Vector3(1280, 720, 0);
    up = new Vector3(0, 0, 1);
    fov = 60;
    znear = 1;
    zfar = 32000;
    
    Render = function() {
        gpu_set_ztestenable(true);
        gpu_set_zwriteenable(true);
        
        var cam = camera_get_active();
        camera_set_view_mat(cam, matrix_build_lookat(from.x, from.y, from.z, to.x, to.y, to.z, up.x, up.y, up.z));
        camera_set_proj_mat(cam, matrix_build_projection_perspective_fov(-fov, -window_get_width() / window_get_height(), znear, zfar));
        camera_apply(cam);
    };
}