#macro Particles global.__particles 

Particles = new (function() constructor {
    static init = function() {
        //Create the particle system
        systems = {
            hit_effects: new spart_system([400, 640, 1600, 2000]),
        };
        
        //Create a particle type
        //Note: All time values are in seconds, not in steps!
        types = {
            stone_debris: new spart_type(),
            death: new spart_type(),
            fire: new spart_type(),
            tower_fire: new spart_type(),
            poison: new spart_type(),
            glue: new spart_type(),
        };
        
        with (types.stone_debris) {
            setSize(4, 8, 0, 0, 0, 200);
        	setSprite(spr_particle_main, 0, 1);
        	setLife(0.2, 0.3);
        	setOrientation(0, 360, 150, 0, true);
        	setSpeed(120, 160, 0, 0);
        	setDirection(0, 0, 1, 75, false);
        	setColour(0x004b96, 1, 0x004b96, 1, 0x004b96, 0);
        	setGravity(1, 0, 0, -1);
        }
        
        with (types.death) {
            setSize(4, 8, 0, 0, 0, 200);
        	setSprite(spr_particle_main, 0, 1);
        	setLife(0.2, 0.3);
        	setOrientation(0, 360, 150, 0, true);
        	setSpeed(120, 160, 0, 0);
        	setDirection(0, 0, 1, 75, false);
        	setColour(c_maroon, 1, c_maroon, 1, c_maroon, 0);
        	setGravity(1, 0, 0, -1);
        }
        
        with (types.fire) {
        	setSprite(spr_particle_main, 0, 1);
        	setSize(4, 10, 0, 0, 0, 200);
        	setLife(0.25, 0.4);
        	setOrientation(0, 360, 150, 0, true);
        	setSpeed(120, 160, 0, 0);
        	setDirection(0, 0, 1, 30, false);
        	setColour(c_orange, 1, c_orange, 1, c_orange, 0.6, c_orange, 0);
        	setBlend(true, true);
        }
        
        with (types.tower_fire) {
        	setSprite(spr_particle_main, 0, 1);
        	setSize(4, 10, 0, 0, 0, 200);
        	setLife(0.3, 0.5);
        	setOrientation(0, 360, 150, 0, true);
        	setSpeed(60, 100, 0, 0);
        	setDirection(0, 0, 1, 30, false);
        	setColour(c_yellow, 1, c_orange, 1, c_red, 0.6, c_red, 0);
        	setBlend(true, false);
        }
        
        with (types.poison) {
        	setSprite(spr_particle_bubble, 0, 1);
        	setLife(1, 1.5);
        	setSpeed(12, 20, 0, 0);
        	setDirection(0, 0, 1, 30, false);
        	setColour(0xff6699, 1, 0xff6699, 1, 0xff6699, 0);
        }
        
        with (types.glue) {
        	setSprite(spr_particle_bubble, 0, 1);
            setSize(1.5, 4, 0, 0, 0, 200);
        	setLife(1, 2);
        	setSpeed(6, 10, 0, 0);
        	setDirection(0, 0, -1, 60, false);
        	setColour(c_yellow, 1, c_yellow, 1, c_yellow, 0);
            setGravity(1, 0, 0, -1);
        }
        
        //Create a particle emitter
        emitters = {
            hit_effects: new spart_emitter(systems.hit_effects),
            tower_effects: new spart_emitter(systems.hit_effects),
        };
    };
    
    static BurstFromEmitter = function(emitter, type, x, y, z, amount) {
        emitter.setRegion(matrix_build(x, y, z, 0, 0, 0, 1, 1, 1), 1, 1, 1, spart_shape_cube, spart_distr_linear, false);
        var n = amount * GAME.particle_density;
        if (n < 1) {
            if (random(1) < n) {
                emitter.burst(type, n, true);
            }
        } else {
            emitter.burst(type, n, true);
        }
    };
    
    static BurstFromEmitterRadius = function(emitter, type, x, y, z, radius, amount) {
        emitter.setRegion(matrix_build(x, y, z, 0, 0, 0, 1, 1, 1), radius, radius, radius, spart_shape_sphere, spart_distr_linear, false);
        var n = amount * GAME.particle_density;
        if (n < 1) {
            if (random(1) < n) {
                emitter.burst(type, n, true);
            }
        } else {
            emitter.burst(type, n, true);
        }
    };
    
    static Render = function() {
        systems.hit_effects.draw(game_get_speed(gamespeed_microseconds) / 1000000 * GAME.game_speed);
    };
})();