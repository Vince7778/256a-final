@import { "player.ck", "levels/base.ck", "levels/reader.ck", "orb.ck", "bump.ck", "audio/spatializer.ck", "hud.ck" }

// Game controller. Manages the player, level, and sound orbs.
public class Controller extends GGen {
    1 => static int State_Placing;
    2 => static int State_Blind;
    3 => static int State_BlindFall;
    4 => static int State_Win;
    5 => static int State_BlindClosing;

    5 => static int MAX_ORBS;
    [ GWindow.Key_1, 
      GWindow.Key_2,
      GWindow.Key_3,
      GWindow.Key_4,
      GWindow.Key_5 ] @=> static int ORB_KEYS[];

    State_Placing => int state;
    Level level;
    Bump bump;
    null @=> Player @ player;
    
    SpatializerEngine engine => dac;
    SoundOrb orbs[MAX_ORBS];

    Hud hud;

    fun Controller(GScene scene, GScene hudScene, string levelPath) {
        this --> scene;
        hud --> hudScene;
        LevelReader.read(levelPath, bump, engine) @=> level;
        level --> this;
        hud.setOrbLimit(level.maxOrbs);
        new Player(bump) @=> player;
        player --> this;
        player.setSceneCam(scene);
        level.spawn(player);
        for (int i; i < MAX_ORBS; i++) {
            new SoundOrb(i, engine) @=> orbs[i];
        }
    }

    // returns 1 if should move on to the next level
    fun int frame() {
        if (state == State_Placing) {
            for (int i; i < level.maxOrbs; i++) {
                if (GWindow.keyDown(ORB_KEYS[i])) {
                    if (!orbs[i].isPlaced) {
                        orbs[i].setPos(player.getOrbPos());
                        1 => orbs[i].isPlaced;
                        1 => orbs[i].isPlaying;
                        hud.setOrb(i, 1);
                        orbs[i] --> this;
                    } else {
                        0 => orbs[i].isPlaced;
                        0 => orbs[i].isPlaying;
                        hud.setOrb(i, 0);
                        orbs[i] --< this;
                    }
                }
            }
        } else if (state == State_Blind || state == State_Win || state == State_BlindFall) {
            for (int i; i < level.maxOrbs; i++) {
                if (GWindow.keyDown(ORB_KEYS[i])) {
                    !orbs[i].isPlaying => orbs[i].isPlaying;
                    hud.setOrb(i, orbs[i].isPlaying);
                }
            }
        }

        for (int i; i < level.maxOrbs; i++) {
            if (orbs[i].isPlaying) {
                orbs[i].play();
            }
        }

        level.touchingPlatform(player) @=> Platform plat;
        if (plat == null) {
            true => player.isFalling;
            if (state == State_Blind) {
                player._cam.rotX(-pi/6);
                State_BlindFall => state;
                hud.blinker.open(500::ms);
            }
        } else {
            plat.interact(player) => int code;
            if (code == Platform.Inter_EndLevel && state == State_Blind) {
                State_Win => state;
                hud.blinker.open(500::ms);
            }
        }

        level.checkSignals();
        level.upd(now);

        if (state == State_Placing) {
            if (GWindow.keyDown(GWindow.Key_R)) {
                level.reset(player);
            } else if (GWindow.keyDown(GWindow.Key_Space)) {
                level.reset(player);
                silenceOrbs();
                1 => player.shouldPreventInput;
                State_BlindClosing => state;
                hud.blinker.close(1::second);
            }
        } else if (state == State_Blind) {
            if (GWindow.keyDown(GWindow.Key_Space) || GWindow.keyDown(GWindow.Key_R)) {
                silenceOrbs();
                State_Placing => state;
                hud.blinker.open(500::ms);
            }
        } else if (state == State_BlindFall) {
            if (GWindow.keyDown(GWindow.Key_Space) || GWindow.keyDown(GWindow.Key_R)) {
                level.reset(player);
                silenceOrbs();
                State_Placing => state;
            }
        } else if (state == State_Win) {
            if (GWindow.keyDown(GWindow.Key_Space)) {
                return 1;
            }
        } else if (state == State_BlindClosing) {
            if (hud.blinker.eyeState == Blinker.EyeState_Closed) {
                0 => player.shouldPreventInput;
                State_Blind => state;
            }
        }

        engine.setPos(player.pos());
        engine.setDir(player._cam.forward());

        return 0;
    }

    fun void silenceOrbs() {
        for (int i; i < MAX_ORBS; i++) {
            if (orbs[i].isPlaying) {
                0 => orbs[i].isPlaying;
                hud.setOrb(i, 0);
            }
        }
    }

    fun void clearOrbs() {
        for (int i; i < MAX_ORBS; i++) {
            if (orbs[i].isPlaced) {
                orbs[i] --< this;
                0 => orbs[i].isPlaced;
                0 => orbs[i].isPlaying;
                hud.setOrb(i, 0);
            } else if (orbs[i].isPlaying) {
                0 => orbs[i].isPlaying;
                hud.setOrb(i, 0);
            }
        }
    }

    fun void cleanup() {
        clearOrbs();
        engine =< dac;
        hud --< GG.hud();
    }
}
