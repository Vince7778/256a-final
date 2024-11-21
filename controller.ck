@import { "player.ck", "levels/base.ck", "levels/reader.ck", "orb.ck" }

// Game controller. Manages the player, level, and sound orbs.
public class Controller extends GGen {
    1 => static int State_Placing;
    2 => static int State_Blind;

    State_Placing => int state;
    Player player;
    Level level;
    SoundOrb orbs[3];

    [0.0, 1.0/3, 2.0/3] @=> float orbHues[];
    [new TriOsc(), new TriOsc(), new TriOsc()] @=> Osc orbOscs[];
    Std.mtof(48) => orbOscs[0].freq;
    Std.mtof(52) => orbOscs[1].freq;
    Std.mtof(55) => orbOscs[2].freq;
    0.3 => orbOscs[0].gain;
    0.3 => orbOscs[1].gain;
    0.3 => orbOscs[2].gain;
    Gain orbAudio => dac;

    fun Controller(GScene scene, string levelPath) {
        this --> scene;
        LevelReader.read(levelPath) @=> level;
        level --> this;
        player --> this;
        [null, null, null] @=> orbs;
        player.setSceneCam(scene);
        level.start(player);
    }

    fun _toggleOrb(int id) {
        if (orbs[id] == null) {
            new SoundOrb(orbOscs[id], orbHues[id], dac) @=> orbs[id];
            orbs[id] --> this;
            player.pos() => vec3 orbPos;
            player.EYE_HEIGHT/2 +=> orbPos.y;
            orbs[id].pos(orbPos);
        } else {
            orbs[id] --< this;
            spork ~ orbs[id].unchuck(dac);
            null @=> orbs[id];
        }
    }

    fun frame() {
        if (state == State_Placing) {
            if (GWindow.keyDown(GWindow.Key_1)) {
                _toggleOrb(0);
            }
            if (GWindow.keyDown(GWindow.Key_2)) {
                _toggleOrb(1);
            }
            if (GWindow.keyDown(GWindow.Key_3)) {
                _toggleOrb(2);
            }
        }

        for (int i; i < orbs.size(); i++) {
            if (orbs[i] != null) {
                orbs[i].spatialize(player);
            }
        }

        level.touchingPlatform(player) @=> Platform plat;
        if (plat == null) {
            true => player.isFalling;
        } else {
            plat.interact(player) => int code;
        }
    }

    fun clear() {
        for (int i; i < orbs.size(); i++) {
            if (orbs[i] != null) {
                _toggleOrb(i);
            }
        }
    }
}
