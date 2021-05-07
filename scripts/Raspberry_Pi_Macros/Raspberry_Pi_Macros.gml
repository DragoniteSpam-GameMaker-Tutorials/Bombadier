#macro SHADER_WORLD shd_cluck_fragment
#macro pi:SHADER_WORLD shd_cluck_vertex

#macro APP_SURFACE_DEFAULT_WIDTH window_get_width()
#macro APP_SURFACE_DEFAULT_HEIGHT window_get_height()
#macro pi:APP_SURFACE_DEFAULT_WIDTH (window_get_width() / 2)
#macro pi:APP_SURFACE_DEFAULT_HEIGHT (window_get_height() / 2)