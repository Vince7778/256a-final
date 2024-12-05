@import { "player.ck", "levels/base.ck", "levels/reader.ck", "orb.ck", "bump.ck", "audio/spatializer.ck", "hud.ck" }

// Game controller. Manages the player, level, and sound orbs.
public class Controller extends GGen {
    1 => static int State_Placing;
    2 => static int State_Blind;
    3 => static int State_BlindFall;
    4 => static int State_Win;
    5 => static int State_BlindClosing;
    6 => static int State_BlindFallOpening;
    7 => static int State_PlacingOpening;
    8 => static int State_WinOpening;

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
    
    null @=> SpatializerEngine @ engine;
    SoundOrb orbs[MAX_ORBS];

    Hud hud;

    fun Controller(GScene scene, GScene hudScene, string levelPath, SpatializerEngine @ _engine) {
        _engine @=> engine;
        this --> scene;
        hud --> hudScene;
        LevelReader.read(levelPath, bump, _engine) @=> level;
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
        } else if (state == State_Blind || state == State_Win || state == State_BlindFall ||
                   state == State_BlindFallOpening || state == State_WinOpening) {
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
                State_BlindFallOpening => state;
                hud.toggleBlind();
            }
        } else {
            plat.interact(player) => int code;
            if (code == Platform.Inter_EndLevel && state == State_Blind) {
                hud.toggleBlind();
                State_WinOpening => state;
            }
        }
        level.update();

        if (state == State_Placing) {
            if (GWindow.keyDown(GWindow.Key_R)) {
                level.reset(player);
            } else if (GWindow.keyDown(GWindow.Key_Space)) {
                hud.toggleBlind();
                level.reset(player);
                silenceOrbs();
                1 => player.shouldPreventInput;
                State_BlindClosing => state;
            }
        } else if (state == State_Blind) {
            // TODO: make this something more permanent
            player._cam.rotX(-pi/6);
            if (GWindow.keyDown(GWindow.Key_Space) || GWindow.keyDown(GWindow.Key_R)) {
                hud.toggleBlind();
                level.reset(player);
                silenceOrbs();
                State_PlacingOpening => state;
            }
        } else if (state == State_BlindFall) {
            if (GWindow.keyDown(GWindow.Key_Space) || GWindow.keyDown(GWindow.Key_R)) {
                level.reset(player);
                silenceOrbs();
                State_Placing => state;
            }
        } else if (state == State_Win) {
            if (GWindow.keyDown(GWindow.Key_Space)) {
                return true;
            }
        } else if (state == State_BlindClosing) {
            if (hud.eyeState == Hud.EyeState_Closed) {
                0 => player.shouldPreventInput;
                State_Blind => state;
            }
        } else if (state == State_BlindFallOpening) {
            if (hud.eyeState == Hud.EyeState_Open) {
                State_BlindFall => state;
            }
        } else if (state == State_PlacingOpening) {
            if (hud.eyeState == Hud.EyeState_Open) {
                State_Placing => state;
            }
        } else if (state == State_WinOpening) {
            if (hud.eyeState == Hud.EyeState_Open) {
                State_Win => state;
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
            } else if (orbs[i].isPlaying) {
                0 => orbs[i].isPlaying;
            }
            hud.setOrb(i, 0);
        }
    }
}
