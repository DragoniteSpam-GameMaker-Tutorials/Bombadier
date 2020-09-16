function coll_ray_aabb(aabb, ray) {
    var t1 = (aabb.p1.x - ray.origin.x) / ((ray.direction.x == 0) ? 0.0001 : ray.direction.x);
    var t2 = (aabb.p2.x - ray.origin.x) / ((ray.direction.x == 0) ? 0.0001 : ray.direction.x);
    var t3 = (aabb.p1.y - ray.origin.y) / ((ray.direction.y == 0) ? 0.0001 : ray.direction.y);
    var t4 = (aabb.p2.y - ray.origin.y) / ((ray.direction.y == 0) ? 0.0001 : ray.direction.y);
    var t5 = (aabb.p1.z - ray.origin.z) / ((ray.direction.z == 0) ? 0.0001 : ray.direction.z);
    var t6 = (aabb.p2.z - ray.origin.z) / ((ray.direction.z == 0) ? 0.0001 : ray.direction.z);
    var tmin = max(max(min(t1, t2), min(t3, t4), min(t5, t6)));
    var tmax = min(min(max(t1, t2), max(t3, t4), max(t5, t6)));
    if (tmax < 0) return false;
    if (tmin > tmax) return false;
    return true;
}

function Ray(origin, direction) constructor {
    self.origin = origin;
    self.direction = direction;
}

function BBox(p1, p2) constructor {
    self.p1 = p1;
    self.p2 = p2;
}