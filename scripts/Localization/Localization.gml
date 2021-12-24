#macro L global.__localization
L = new (function() constructor {
    static Get = function(key) {
    };
    
    static Load = function(language) {
        try {
            var filename = "lang/" + language + ".csv";
        } catch (e) {
            show_debug_message("could not load the language data: " + language);
        }
    };
})();