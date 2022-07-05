function Kestrel(name, description, icon_locked, icon_unlocked, callback, hidden = false) constructor {
    self.name = name;
    self.description = description;
    self.icon_locked = icon_locked;
    self.icon_unlocked = icon_unlocked;
    self.callback = method(self, callback);
    self.hidden = hidden;
    
    self.progress = 0;
    self.complete = false;
    
    self.Check = function(data = undefined) {
        self.complete = self.callback(data);
        return self.complete;
    };
    
    self.Complete = function() {
        self.complete = true;
        self.progress = 1;
        return self;
    };
    
    self.Reset = function() {
        self.complete = false;
        return self;
    };
    
    self.GetName = function() {
        if (self.hidden && !self.complete && !KESTREL_SHOW_HIDDEN_NAMES) return KESTREL_HIDDEN_NAME_TEXT;
        return self.name;
    };
    
    self.GetDescription = function() {
        if (self.hidden && !self.complete && !KESTREL_SHOW_HIDDEN_DESCRIPTIONS) return KESTREL_HIDDEN_DESCRIPTION_TEXT;
        return self.description;
    };
    
    self.GetIcon = function() {
        return self.complete ? self.icon_unlocked : self.icon_locked;
    };
    
    self.GetProgress = function() {
        return self.progress;
    };
    
    self.GetComplete = function() {
        return self.complete;
    };
    
    self.save = function() {
        return {
            progress: self.progress,
            complete: self.complete,
        };
    };
    
    self.load = function(json) {
        self.progress = json.progress;
        self.complete = json.complete;
        
        try {
            var test_progress = power(2, self.progress);
            var test_completion = !!self.complete;
        } catch (e) {
            throw { message : "Stored some bad data", longMessage: json_stringify(json) + " in " + self.name };
        }
    };
}

#macro KestrelSystem global.__kestrel__

KestrelSystem = {
    _: ds_list_create(),
    
    Add: function(kestrel) {
        if (instanceof(kestrel) != "Kestrel") return;
        ds_list_add(self._, kestrel);
        return kestrel;
    },
    
    Update: function(data = undefined) {
        for (var i = 0, n = ds_list_size(self._); i < n; i++) {
            if (!self._[| i].complete) {
                self._[| i].Check(data);
            }
        }
    },
    
    Count: function() {
        return ds_list_size(self._);
    },
    
    Get: function(index) {
        return self._[| clamp(index, 0, ds_list_size(self._) - 1)];
    },
    
    Reset: function() {
        for (var i = 0, n = ds_list_size(self._); i < n; i++) {
            self._[| i].Reset();
        }
    },
    
    Save: function() {
        var json = {
            version: 1,
            items: array_create(ds_list_size(self._))
        };
        for (var i = 0, n = ds_list_size(self._); i < n; i++) {
            json.items[i] = self._[| i].save();
        }
        return  base64_encode(json_stringify(json));
    },
    
    Load: function(blob) {
        try {
            var json = json_decode(base64_decode(blob));
            var version = json.version;
            for (var i = 0, n = min(ds_list_size(self._), array_length(blob.items)); i < n; i++) {
                self._[| i].load(blob.items[i]);
            }
        } catch (e) {
            show_debug_message("Failed to load achievement settings: " + e.message + "(" + e.longMessage + ")");
        }
    },
};