switch (anchor_horizontal) {
    case fa_left:
        x = offset_x;
        break;
    case fa_right:
        x = room_width - offset_x;
        break;
    case fa_center:
        x = offset_x + (room_width / 2);
        break;
}

switch (anchor_vertical) {
    case fa_left:
        y = offset_y;
        break;
    case fa_right:
        y = room_height - offset_y;
        break;
    case fa_center:
        y = offset_y + (room_height / 2);
        break;
}