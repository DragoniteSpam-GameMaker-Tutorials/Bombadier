function shader_set_uniform_color(uniform, color) {
    shader_set_uniform_f(uniform, colour_get_red(color) / 255, colour_get_green(color) / 255, colour_get_blue(color) / 255, 1);
}