#macro SHADER_WORLD shd_cluck_fragment
#macro pi:SHADER_WORLD shd_cluck_vertex
#macro pi_release:SHADER_WORLD shd_cluck_vertex

#macro APP_SURFACE_DEFAULT_SCALE_INDEX 6
#macro pi:APP_SURFACE_DEFAULT_SCALE_INDEX 3
#macro pi_release:APP_SURFACE_DEFAULT_SCALE_INDEX 3

#macro TARGET_FPS 60
#macro pi:TARGET_FPS 30
#macro pi_release:TARGET_FPS 30

#macro OUTLINE_SURFACE_WIDTH 640
#macro OUTLINE_SURFACE_HEIGHT 360
#macro pi:OUTLINE_SURFACE_WIDTH 426
#macro pi:OUTLINE_SURFACE_HEIGHT 240
#macro pi_release:OUTLINE_SURFACE_WIDTH 426
#macro pi_release:OUTLINE_SURFACE_HEIGHT 240

#macro DEFAULT_PARTICLE_DENSITY 1
#macro pi:DEFAULT_PARTICLE_DENSITY 0.75
#macro pi_release:DEFAULT_PARTICLE_DENSITY 0.75

#macro IS_OGX (os_type == os_operagx)