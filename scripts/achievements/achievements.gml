#macro Achievements global.__achievements

Achievements = {
    Init: function() {
        var achievement_validate = function(data) {
            return (data == self);
        };
        
        self.first_blood = KestrelSystem.Add(new Kestrel("@ACH_NAME_FIRST_BLOOD",               "@ACH_DESC_FIRST_BLOOD",        spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.bug_stomper = KestrelSystem.Add(new Kestrel("@ACH_NAME_BUG_STOMPER",               "@ACH_DESC_BUG_STOMPER",        spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.first_victory = KestrelSystem.Add(new Kestrel("@ACH_NAME_FIRST_VICTORY",           "@ACH_DESC_FIRST_VICTORY",      spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.perfect_game = KestrelSystem.Add(new Kestrel("@ACH_NAME_PERFECT_GAME",             "@ACH_DESC_PERFECT_GAME",       spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.living_on_the_edge = KestrelSystem.Add(new Kestrel("@ACH_NAME_LIVING_ON_THE_EDGE", "@ACH_DESC_LIVING_ON_THE_EDGE", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.battle_tested = KestrelSystem.Add(new Kestrel("@ACH_NAME_BATTLE_TESTED",           "@ACH_DESC_BATTLE_TESTED",      spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.battle_veteran = KestrelSystem.Add(new Kestrel("@ACH_NAME_BATTLE_VETERAN",         "@ACH_DESC_BATTLE_VETERAN",     spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.getting_an_upgrade = KestrelSystem.Add(new Kestrel("@ACH_NAME_GETTING_AN_UPGRADE", "@ACH_DESC_GETTING_AN_UPGRADE", spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.foul_play = KestrelSystem.Add(new Kestrel("@ACH_NAME_FOUL_PLAY",                   "@ACH_DESC_FOUL_PLAY",          spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.locusts = KestrelSystem.Add(new Kestrel("@ACH_NAME_LOCUST_PLAGUE",                 "@ACH_DESC_LOCUST_PLAGUE",      spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.tower_expert = KestrelSystem.Add(new Kestrel("@ACH_NAME_TOWER_EXPERT",             "@ACH_DESC_TOWER_EXPERT",       spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.tower_master = KestrelSystem.Add(new Kestrel("@ACH_NAME_TOWER_MASTER",             "@ACH_DESC_TOWER_MASTER",       spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.triple_threat = KestrelSystem.Add(new Kestrel("@ACH_NAME_TRIPLE_THREAT",           "@ACH_DESC_TRIPLE_THREAT",      spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.impatience = KestrelSystem.Add(new Kestrel("@ACH_NAME_IMPATIENCE",                 "@ACH_DESC_IMPATIENCE",         spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        self.rookie_squad = KestrelSystem.Add(new Kestrel("@ACH_NAME_ROOKIE_SQUAD",             "@ACH_DESC_ROOKIE_SQUAD",       spr_achievement_lock, spr_achievement_generic, achievement_validate, true));
        
        KestrelSystem.SetUnlockCallback(function(kestrel) {
            array_push(Achievements.badge_queue, {
                kestrel: kestrel,
                t: ACHIEVEMENT_BADGE_DURATION,
                x: -400,
                y: (array_length(Achievements.badge_queue) > 0) ? (Achievements.badge_queue[array_length(Achievements.badge_queue) - 1].y - 96) : window_get_height() - 96,
                w: 400,
                h: 96,
            });
            if (!audio_is_playing(se_achievement))
                audio_play_sound(se_achievement, SOUND_PRIORITY_UI, false);
            Achievements.Save();
        });
        
        self.Reset();
    },
    
    // this is filled in in Reset() when you call Init()
    stats: undefined,
    
    badge_queue: [],
    
    Update: function() {
        for (var i = array_length(self.badge_queue) - 1; i >= 0; i--) {
            var badge = self.badge_queue[i];
            badge.t -= DT;
            badge.x = min(badge.x + badge.w * DT / ACHIEVEMENT_BADGE_TRANSITION_TIME, 0);
            if (badge.y > window_get_height()) {
                array_delete(self.badge_queue, i, 1);
            } else if (badge.t <= ACHIEVEMENT_BADGE_TRANSITION_TIME) {
                if (i == 0) {
                    badge.y += badge.h * DT / ACHIEVEMENT_BADGE_TRANSITION_TIME;
                }
            }
        }
        for (var i = 1, n = array_length(self.badge_queue); i < n; i++) {
            self.badge_queue[i].y = min(window_get_width() - 96, self.badge_queue[i - 1].y - 96);
        }
    },
    
    Render: function() {
        var spr = spr_block_raycast;
        var ww = 400;
        var hh = 96;
        var icon_xx = 16;
        var icon_yy = 16;
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
            var badge = self.badge_queue[i];
            var kestrel = badge.kestrel;
            surf = surface_validate(surf, badge.w, badge.h);
            surface_set_target(surf);
            draw_clear_alpha(c_black, 0);
            gpu_set_blendmode(bm_add);
            draw_sprite_stretched(spr, 0, 0, 0, badge.w, badge.h);
            gpu_set_blendmode(bm_normal);
            if (sprite_exists(kestrel.icon_unlocked)) {
                draw_sprite(kestrel.icon_unlocked, 0, icon_xx, icon_yy);
            }
            draw_text_colour(header_xx, header_yy, L("@ACHIEVEMENT_GET"), c, c, c, c, 1);
            draw_text_colour(name_xx, name_yy, L(kestrel.name), c_black, c_black, c_black, c_black, 1);
            surface_reset_target();
            
            draw_surface(surf, badge.x, badge.y);
        }
        draw_set_halign(halign);
        draw_set_valign(valign);
    },
    
    Reset: function() {
        self.stats = {
            stomp_count: 0,
            tower_records: { },
        };
        KestrelSystem.Reset();
    },
    
    SetTowerRank: function(id, rank) {
        if (!self.stats.tower_records[$ id]) {
            self.stats.tower_records[$ id] = {
                highest_rank: rank,
            };
        } else {
            self.stats.tower_records[$ id].highest_rank = max(self.stats.tower_records[$ id].highest_rank, rank);
        }
        self.Save();
    },
    
    Save: function() {
        static output = buffer_create(1000, buffer_grow, 1);
        buffer_seek(output, buffer_seek_start, 0);
        buffer_write(output, buffer_text, json_stringify({
            stats: self.stats,
            data: KestrelSystem.Save(),
        }));
        buffer_save_ext(output, ACHIEVEMENT_SAVE_FILE, 0, buffer_tell(output));
    },
    
    Load: function() {
        // OGX doesn't like doing this with try-catch for some reason
        if (file_exists(ACHIEVEMENT_SAVE_FILE)) {
            try {
                var data = buffer_load(ACHIEVEMENT_SAVE_FILE);
                var input = json_parse(buffer_read(data, buffer_text));
                KestrelSystem.Load(input.data);
                self.stats = input.stats ?? { };
                self.stats[$ "stomp_count"] ??= 0;
                self.stats[$ "tower_records"] ??= { };
                buffer_delete(data);
            } catch (e) {
                show_debug_message("Failed to load achievement data: " + e.message);
                self.Reset();
            }
        } else {
            self.Reset();
        }
    },
}

#macro ACHIEVEMENT_BUG_STOMPER_THRESHOLD    3000
#macro ACHIEVEMENT_BADGE_DURATION           6
#macro ACHIEVEMENT_BADGE_TRANSITION_TIME    0.4
#macro ACHIEVEMENT_SAVE_FILE                "achieve.ments"