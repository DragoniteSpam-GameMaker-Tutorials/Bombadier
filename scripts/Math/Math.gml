function approach(value, target, step) {
    return value + clamp(target - value, -step, step);
};

function screen_to_world(x, y, view_mat, proj_mat) {
    /*
    Transforms a 2D coordinate (in window space) to a 3D vector.
    Returns a Vector of the following format:
    [dx, dy, dz, ox, oy, oz]
    where [dx, dy, dz] is the direction vector and [ox, oy, oz] is the origin of the ray.
    Works for both orthographic and perspective projections.
    Script created by TheSnidr
    (slightly modified by @dragonitespam)
    */
    var mx = 2 * (x / window_get_width() - .5) / proj_mat[0];
    var my = 2 * (y / window_get_height() - .5) / proj_mat[5];
    var camX = - (view_mat[12] * view_mat[0] + view_mat[13] * view_mat[1] + view_mat[14] * view_mat[2]);
    var camY = - (view_mat[12] * view_mat[4] + view_mat[13] * view_mat[5] + view_mat[14] * view_mat[6]);
    var camZ = - (view_mat[12] * view_mat[8] + view_mat[13] * view_mat[9] + view_mat[14] * view_mat[10]);
    
    if (proj_mat[15] == 0) {    //This is a perspective projection
        return new Vector3(view_mat[2]  + mx * view_mat[0] + my * view_mat[1], view_mat[6]  + mx * view_mat[4] + my * view_mat[5], view_mat[10] + mx * view_mat[8] + my * view_mat[9], camX, camY, camZ);
    } else {    //This is an ortho projection
        return new Vector3(view_mat[2], view_mat[6], view_mat[10], camX + mx * view_mat[0] + my * view_mat[1], camY + mx * view_mat[4] + my * view_mat[5], camZ + mx * view_mat[8] + my * view_mat[9]);
    }
}

function world_to_screen(x, y, z, view_mat, proj_mat) {
    /*
        Transforms a 3D world-space coordinate to a 2D window-space coordinate. Returns a Vector of the following format:
        [xx, yy]
        Returns [-1, -1] if the 3D point is not in view
   
        Script created by TheSnidr
        www.thesnidr.com
    */
    
    if (proj_mat[15] == 0) {   //This is a perspective projection
        var w = view_mat[2] * x + view_mat[6] * y + view_mat[10] * z + view_mat[14];
        // If you try to convert the camera's "from" position to screen space, you will
        // end up dividing by zero (please don't do that)
        //if (w <= 0) return [-1, -1];
        if (w == 0) return [-1, -1];
        var cx = proj_mat[8] + proj_mat[0] * (view_mat[0] * x + view_mat[4] * y + view_mat[8] * z + view_mat[12]) / w;
        var cy = proj_mat[9] + proj_mat[5] * (view_mat[1] * x + view_mat[5] * y + view_mat[9] * z + view_mat[13]) / w;
    } else {    //This is an ortho projection
        var cx = proj_mat[12] + proj_mat[0] * (view_mat[0] * x + view_mat[4] * y + view_mat[8]  * z + view_mat[12]);
        var cy = proj_mat[13] + proj_mat[5] * (view_mat[1] * x + view_mat[5] * y + view_mat[9]  * z + view_mat[13]);
    }

    return new Vector3((0.5 + 0.5 * cx) * window_get_width(), (0.5 + 0.5 * cy) * window_get_height());
}

function triangle_normal(x1, y1, z1, x2, y2, z2, x3, y3, z3) {
    var v1x = x2 - x1;
    var v1y = y2 - y1;
    var v1z = z2 - z1;
    var v2x = x3 - x1;
    var v2y = y3 - y1;
    var v2z = z3 - z1;
    var cx = v1y * v2z - v1z * v2y;
    var cy = -v1x * v2z + v1z * v2x;
    var cz = v1x * v2y - v1y * v2x;
    
    // if this is zero, the triangle has zero area and won't be visible anyway
    var cpl = point_distance_3d(0, 0, 0, cx, cy, cz);
    
    if (cpl != 0) return new Vector3(cx / cpl, cy / cpl, cz / cpl);
    return new Vector3(0, 0, 1);
}