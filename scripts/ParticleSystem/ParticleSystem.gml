#macro Particles global.__particles 

Particles = new (function() constructor {
    static init = function() {
        //Create the particle system
        part_system_hit_effects = new spart_system([256, 600]);
        
        //Create a particle type
        //Note: All time values are in seconds, not in steps!
        part_type_stone_debris = new spart_type();
        with (part_type_stone_debris) {
            setSize(3, 5, 0, 0, 0, 200);
        	setSprite(spr_particle_main, 0, 1);
        	setLife(0.2, 0.3);
        	setOrientation(0, 360, 150, 0, true);
        	setSpeed(120, 160, 0, 0);
        	setDirection(0, 0, 1, 75, false);
        	setColour(0x004b96, 1, 0x004b96, 1, 0x004b96, 0);
        	setGravity(1, 0, 0, -1);
        }

        //Create a particle emitter
        part_emitter_stone_debris = new spart_emitter(part_system_hit_effects);
    };
    
    static Render = function() {
        part_system_hit_effects.draw(game_get_speed(gamespeed_microseconds) / 1000000);
    };
})();