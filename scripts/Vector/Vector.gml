/// @param x
/// @param y
/// @param z
/// @param a
/// @param b
/// @param c
/// @desc this is not technically a Vector3, kind of
function Vector3() constructor {
    self.x = (argument_count > 0) ? argument[0] : undefined;
    self.y = (argument_count > 1) ? argument[1] : undefined;
    self.z = (argument_count > 2) ? argument[2] : undefined;
    self.a = (argument_count > 3) ? argument[2] : undefined;
    self.b = (argument_count > 4) ? argument[3] : undefined;
    self.c = (argument_count > 5) ? argument[4] : undefined;
    
    static Clone = function() {
        return json_parse(json_stringify(self));
    }
}