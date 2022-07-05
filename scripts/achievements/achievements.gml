#macro Achievements global.__achievements

Achievements = {
    Init: function() {
        var achievement_validate = function(data) {
            return (data == self);
        };
        
        self.first_blood = KestrelSystem.Add(new Kestrel("First Blood", "Kill a foe for the first time", -1, -1, achievement_validate));
        self.bug_stomper = KestrelSystem.Add(new Kestrel("Bug Stomper", "Kill a thousand foes (lifetime)", -1, -1, achievement_validate));
        self.first_victory = KestrelSystem.Add(new Kestrel("First Victory", "Win a map for the first time", -1, -1, achievement_validate));
        self.getting_an_upgrade = KestrelSystem.Add(new Kestrel("Getting an Upgrade", "Upgrade a tower", -1, -1, achievement_validate));
        self.foul_play = KestrelSystem.Add(new Kestrel("Foul Play", "Inflict a status ailment on a foe", -1, -1, achievement_validate));
        self.battle_tested = KestrelSystem.Add(new Kestrel("Battle Tested", "Win six maps", -1, -1, achievement_validate));
        self.perfect_game = KestrelSystem.Add(new Kestrel("Perfect Game", "Win a map without letting any foes reach the end", -1, -1, achievement_validate));
        self.battle_veteran = KestrelSystem.Add(new Kestrel("Battle Veteran", "Win on twelve maps", -1, -1, achievement_validate));
        self.experimentalist = KestrelSystem.Add(new Kestrel("Experimentalist", "Build one of every type of tower in the game (lifetime)", -1, -1, achievement_validate));
        self.tower_master = KestrelSystem.Add(new Kestrel("Tower Master", "Fully upgrade all types of tower in the game (lifetime)", -1, -1, achievement_validate));
        self.triple_threat = KestrelSystem.Add(new Kestrel("Triple Threat", "Inflict three different status ailments on a single foe", -1, -1, achievement_validate));
        self.impatience = KestrelSystem.Add(new Kestrel("Impatience", "Call every wave in a level early", -1, -1, achievement_validate));
        self.rookie_squad = KestrelSystem.Add(new Kestrel("Rookie Squad", "Win a map without upgrading any towers", -1, -1, achievement_validate));
        self.living_on_the_edge = KestrelSystem.Add(new Kestrel("Living on the Edge", "Win a map with only one life remaining", -1, -1, achievement_validate));
    },
    
    stats: {
        stomp_count: 0,
    },
    
    badge_queue: [],
    
    Update: function() {
    },
    
    Render: function() {
    },
    
    Save: function() {
    },
    
    Load: function() {
    },
}

#macro ACHIEVEMENT_BUG_STOMPER_THRESHOLD    1000
#macro ACHIEVEMENT_BADGE_DURATION           5

KestrelSystem.SetUnlockCallback(function(kestrel) {
    array_push(Achievements.badge_queue, { kestrel: kestrel, t: ACHIEVEMENT_BADGE_DURATION });
});