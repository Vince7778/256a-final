@import { "player.ck", "levels/base.ck", "levels/reader.ck", "orb.ck", "bump.ck", "audio/spatializer.ck" }

// Game controller. Manages the player, level, and sound orbs.
public class Controller extends GGen {
    1 => static int State_Placing;
    2 => static int State_Blind;
    3 => static int State_BlindFall;
    4 => static int State_Win;

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

    fun Controller(GScene scene, string levelPath, SpatializerEngine @ _engine) {
        _engine @=> engine;
        this --> scene;
        LevelReader.read(levelPath, bump, _engine) @=> level;
        level --> this;
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
                        orbs[i].setPos(@(
                            player.posX(),
                            player.posY() + Player.EYE_HEIGHT / 2.0,
                            player.posZ()
                        ));
                        1 => orbs[i].isPlaced;
                        1 => orbs[i].isPlaying;
                        orbs[i] --> this;
                    } else {
                        0 => orbs[i].isPlaced;
                        0 => orbs[i].isPlaying;
                        orbs[i] --< this;
                    }
                }
            }
        } else {
            for (int i; i < level.maxOrbs; i++) {
                if (GWindow.keyDown(ORB_KEYS[i])) {
                    !orbs[i].isPlaying => orbs[i].isPlaying;
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
        level.update();

        if (state == State_Placing) {
            if (GWindow.keyDown(GWindow.Key_R)) {
                level.reset(player);
            } else if (GWindow.keyDown(GWindow.Key_Space)) {
                player.toggleBlind();
                level.reset(player);
                silenceOrbs();
                State_Blind => state;
            }
        } else if (state == State_Blind) {
            // TODO: make this something more permanent
            player._cam.rotX(-pi/6);
            if (GWindow.keyDown(GWindow.Key_Space)) {
                player.toggleBlind();
                level.reset(player);
                silenceOrbs();
                State_Placing => state;
            }
        } else if (state == State_BlindFall) {
            if (GWindow.keyDown(GWindow.Key_Space)) {
                level.reset(player);
                silenceOrbs();
                State_Placing => state;
            }
        } else if (state == State_Win) {
            if (GWindow.keyDown(GWindow.Key_Space)) {
                return true;
            }
        }

        engine.setPos(player.pos());
        engine.setDir(player._cam.forward());

        UI.setNextWindowSize(@(400, 120), 1);
        if (UI.begin("info")) {
            if (state == State_Placing) {
                UI.text("Press the number keys to place sound orbs");
                UI.text("Press R to respawn");
                UI.text("Press space to play the level, blind!");
                UI.text("(don't worry, this text box is temporary)");
                UI.text("(I swear I'll remove it by the final)");
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

    fun void silenceOrbs() {
        for (int i; i < MAX_ORBS; i++) {
            if (orbs[i].isPlaying) {
                0 => orbs[i].isPlaying;
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
        }
    }
}
