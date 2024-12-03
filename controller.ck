@import { "player.ck", "levels/base.ck", "levels/reader.ck", "orb.ck", "bump.ck" }

// Game controller. Manages the player, level, and sound orbs.
public class Controller extends GGen {
    1 => static int State_Placing;
    2 => static int State_Blind;
    3 => static int State_BlindFall;
    4 => static int State_Win;

    State_Placing => int state;
    Player player;
    Level level;
    Bump bump;
    SoundOrb orbs[3];

    [0.0, 1.0/3, 2.0/3] @=> float orbHues[];
    [new TriOsc(), new TriOsc(), new TriOsc()] @=> Osc orbOscs[];
    Std.mtof(48) => orbOscs[0].freq;
    Std.mtof(55) => orbOscs[1].freq;
    Std.mtof(64) => orbOscs[2].freq;
    0.3 => orbOscs[0].gain;
    0.3 => orbOscs[1].gain;
    0.3 => orbOscs[2].gain;
    Gain orbAudio => dac;

    fun Controller(GScene scene, string levelPath) {
        this --> scene;
        LevelReader.read(levelPath, bump) @=> level;
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

    // returns 1 if should move on to the next level
    fun int frame() {
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
            if (state == State_Blind) {
                State_BlindFall => state;
                player.toggleBlind();
            }
        } else {
            plat.interact(player) => int code;
            if (code == Platform.Inter_EndLevel && state == State_Blind) {
                player.toggleBlind();
                State_Win => state;
            }
        }

        if (state == State_Placing) {
            if (GWindow.keyDown(GWindow.Key_R)) {
                level.start(player);
            } else if (GWindow.keyDown(GWindow.Key_Space)) {
                player.toggleBlind();
                level.start(player);
                State_Blind => state;
            }
        } else if (state == State_Blind) {
            // TODO: make this something more permanent
            player._cam.rotX(-pi/6);
            if (GWindow.keyDown(GWindow.Key_Space)) {
                player.toggleBlind();
                level.start(player);
                State_Placing => state;
            }
        } else if (state == State_BlindFall) {
            if (GWindow.keyDown(GWindow.Key_Space)) {
                level.start(player);
                State_Placing => state;
            }
        } else if (state == State_Win) {
            if (GWindow.keyDown(GWindow.Key_Space)) {
                return true;
            }
        }

        UI.setNextWindowSize(@(400, 100), 1);
        if (UI.begin("info")) {
            if (state == State_Placing) {
                UI.text("Press 1, 2, 3 to place sound orbs");
                UI.text("Press R to respawn");
                UI.text("Press space to play the level, blind!");
                UI.text("(don't worry, this text box is temporary)");
            } else if (state == State_Blind) {
                UI.text("Try and navigate to the finish using your ears!");
            } else if (state == State_BlindFall) {
                UI.text("Uh oh, you fell! Press space to go back to placing orbs.");
            } else if (state == State_Win) {
                UI.text("Good job, you beat the level!");
                UI.text("Press space to go to the next one!");
            } else {
                UI.text("awkward, I forgot to add UI text to this state");
            }
        }
        UI.end();

        return 0;
    }

    fun clearOrbs() {
        for (int i; i < orbs.size(); i++) {
            if (orbs[i] != null) {
                _toggleOrb(i);
            }
        }
    }
}
