function Vector3(x = 0, y = 0, z = 0) constructor {
    self.x = x;
    self.y = y;
    self.z = z;
}

function clone(what) {
    return new Vector3(what.x, what.y, what.z);
}