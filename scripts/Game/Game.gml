function Game() constructor {
    camera = new Camera();
    
    Update = function() {
        camera.Update();
    };
    
    Render = function() {
        camera.Render();
        
        for (var i = 0; i < 16; i++) {
            for (var j = 0; j < 9; j++) {
                draw_sprite(spr_grid, 0, i * 64, j * 64);
            }
        }
    };
}