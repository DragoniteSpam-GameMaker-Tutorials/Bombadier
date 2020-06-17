function Game() constructor {
    camera = new Camera();
    
    Update = function() {
        
    };
    
    Render = function() {
        camera.Render();
        
        for (var i = 0; i < 10; i++) {
            for (var j = 0; j < 10; j++) {
                draw_sprite(spr_grid, 0, i * 64, j * 64);
            }
        }
    };
}