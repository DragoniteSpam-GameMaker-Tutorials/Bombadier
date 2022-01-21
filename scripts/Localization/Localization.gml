#macro L global.__localization
L = new (function() constructor {
    static Get = function(key) {
    };
    
    static Load = function(language) {
        var filename = "lang/" + language + ".csv";
        
        try {
            
        } catch (e) {
            show_debug_message("could not load the language data: " + language);
        }
    };
})();