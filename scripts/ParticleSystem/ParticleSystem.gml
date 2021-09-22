#macro Particles global.__particles 

Particles = new (function() constructor {
    static init = function() {
        //Create the particle system
        partSystem = new spart_system([256, 600]);

        //Create a particle type
        //Note: All time values are in seconds, not in steps!
        partType = new spart_type();
        with partType
        {
        	setSprite(spr_particle_main, 0, 1);
        	//setSize(100, 140, 0, 0, 0, 200);
        	setLife(1, 1.5);
        	setOrientation(0, 360, 150, 0, true);
        	setSpeed(300, 400, 0, 0);
        	setDirection(0, 0, 1, 45, false);
        	setColour(0x004b96, 1);
        	setGravity(1, 0, 0, -1);
        	//setBlend(true, true);
        }

        //Create a particle emitter
        partEmitter = new spart_emitter(partSystem);
        //partEmitter.stream(partType, 300, -1, false);
        partEmitter.setRegion(matrix_build_identity(), 16, 16, 16, spart_shape_cube, ps_distr_linear, false);
    }
})();