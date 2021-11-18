#macro DT                               (delta_time / 1000000)
#macro WAVE_WARMUP_COUNTDOWN            40
#macro WAVE_FOE_COUNTDOWN               1
#macro WAVE_COUNTDOWN                   30
#macro WAVE_COUNTDOWN_THRESHOLD         3

#macro MAX_LEVEL_INDEX                  12

#macro MAX_TOWER_LEVEL                  3

#macro BURN_DURATION                    2
#macro BURN_DPS                         2

#macro POISON_DURATION                  1.5
#macro POISON_DPS                       1.5

#macro SLOW_DURATION                    2
#macro SLOW_FACTOR                      0.5

#macro IMMOBILIZE_DURATION              1

#macro GRID_CELL_SIZE                   4
#macro GRID_COLLISION_FREE              0
#macro GRID_COLLISION_FILLED            1
#macro GRID_COLLISION_PATH              2

#macro PAINT_COLLISION_FILLED           0x00
#macro PAINT_COLLISION_PATH             0x01
#macro PAINT_COLLISION_FREE             0xff

#macro SOUND_PRIORITY_AMBIENT           100
#macro SOUND_PRIORITY_BGM               100
#macro SOUND_PRIORITY_UI                50
#macro SOUND_PRIORITY_GAMEPLAY_HIGH     40
#macro SOUND_PRIORITY_GAMEPLAY_LOW      random_range(1, 25)

#macro FIELD_WIDTH                      1366
#macro FIELD_HEIGHT                     768

#macro FORCE_SQUARE_TEXTURES            true
#macro pi:FORCE_SQUARE_TEXTURES         false
#macro pi_release:FORCE_SQUARE_TEXTURES false

#macro RELEASE_MODE                     false
#macro release:RELEASE_MODE             true
#macro pi_release:RELEASE_MODE          true