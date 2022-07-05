#macro Achievements global.__achievements

Achievements = {
    Init: function() {
        var achievement_validate = function(data) {
            return (data == self);
        };
        
        self.first_blood = KestrelSystem.Add(new Kestrel("First Blood", "Kill a foe for the first time", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.bug_stomper = KestrelSystem.Add(new Kestrel("Bug Stomper", "Kill a thousand foes (lifetime)", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.first_victory = KestrelSystem.Add(new Kestrel("First Victory", "Win a map for the first time", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.perfect_game = KestrelSystem.Add(new Kestrel("Perfect Game", "Win a map without letting any foes reach the end", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.living_on_the_edge = KestrelSystem.Add(new Kestrel("Living on the Edge", "Win a map with only one life remaining", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.battle_tested = KestrelSystem.Add(new Kestrel("Battle Tested", "Win six maps", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.battle_veteran = KestrelSystem.Add(new Kestrel("Battle Veteran", "Win on twelve maps", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.getting_an_upgrade = KestrelSystem.Add(new Kestrel("Getting an Upgrade", "Upgrade a tower", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.foul_play = KestrelSystem.Add(new Kestrel("Foul Play", "Inflict a status ailment on a foe", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.experimentalist = KestrelSystem.Add(new Kestrel("Experimentalist", "Build one of every type of tower in the game (lifetime)", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.tower_expert = KestrelSystem.Add(new Kestrel("Tower Export", "Upgrade a tower to Level 3", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.tower_master = KestrelSystem.Add(new Kestrel("Tower Master", "Fully upgrade all types of tower in the game (lifetime)", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.triple_threat = KestrelSystem.Add(new Kestrel("Triple Threat", "Inflict three different status ailments on a single foe", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.impatience = KestrelSystem.Add(new Kestrel("Impatience", "Call every wave in a level early", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.rookie_squad = KestrelSystem.Add(new Kestrel("Rookie Squad", "Win a map without upgrading any towers", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        
        KestrelSystem.SetUnlockCallback(function(kestrel) {
            array_push(Achievements.badge_queue, { kestrel: kestrel, t: ACHIEVEMENT_BADGE_DURATION });
        });
    },
    
    stats: {
        stomp_count: 0,
    },
    
    badge_queue: [],
    
    Update: function() {
        for (var i = array_length(self.badge_queue) - 1; i >= 0; i--) {
            self.badge_queue[i].t -= DT;
            if (self.badge_queue[i].t <= 0) {
                array_delete(self.badge_queue, i, 1);
            }
        }
    },
    
    Render: function() {
        var ww = 400;
        var hh = 96;
        var xx = 0;
        var yy = window_get_height() - hh;
        var spr = spr_block_raycast;
        var icon_xx = 40;
        var icon_yy = hh / 2;
        var header_xx = 240;
        var header_yy = hh / 3;
        var name_xx = 240;
        var name_yy = hh * 2 / 3;
        var c = c_blue;
        var halign = draw_get_halign();
        var valign = draw_get_valign();
        draw_set_halign(fa_middle);
        draw_set_valign(fa_center);
        static surf = -1;
        for (var i = 0, n = array_length(self.badge_queue); i < n; i++) {
            var kestrel = self.badge_queue[i].kestrel;
            surf = surface_validate(surf, ww, hh);
            surface_set_target(surf);
            draw_clear_alpha(c_black, 0);
            gpu_set_blendmode(bm_add);
            draw_sprite_stretched(spr, 0, 0, 0, ww, hh);
            gpu_set_blendmode(bm_normal);
            if (sprite_exists(kestrel.icon_unlocked)) {
                draw_sprite(kestrel.icon_unlocked, 0, icon_xx, icon_yy);
            }
            draw_text_colour(header_xx, header_yy, L("Achievement get!"), c, c, c, c, 1);
            draw_text_colour(name_xx, name_yy, L(kestrel.name), c_black, c_black, c_black, c_black, 1);
            surface_reset_target();
            
            draw_surface_ext(surf, xx, yy, 1, 1, 0, c_white, min(1, self.badge_queue[i].t));
            
            yy -= hh;
        }
        draw_set_halign(halign);
        draw_set_valign(valign);
    },
    
    Save: function() {
    },
    
    Load: function() {
    },
}

#macro ACHIEVEMENT_BUG_STOMPER_THRESHOLD    1000
#macro ACHIEVEMENT_BADGE_DURATION           5