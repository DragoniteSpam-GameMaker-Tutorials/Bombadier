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