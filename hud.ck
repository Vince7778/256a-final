@import { "utils.ck", "orb.ck" }

class HudOrbs extends GGen {
    0.4 => static float ORB_SIZE;
    0.1 => static float ORB_SPACING;

    GText zeroText;
    zeroText.text("No sound orbs available!");
    zeroText.controlPoints(@(0.0, 1.0));
    zeroText.posX(ORB_SPACING);
    zeroText.posY(-ORB_SPACING);
    zeroText.sca(@(1,1,1)*0.2);

    GCircle circles[0];

    fun HudOrbs(int limit) {
        if (limit == 0) {
            zeroText --> this;
        } else {
            for (int i; i < limit; i++) {
                GCircle circ;
                circ.color(Color.hsv2rgb(@(360*SoundOrb.ORB_HUES[i], 1, 0.2)));
                circ.posX(ORB_SPACING*(i+1) + ORB_SIZE*(i+0.5));
                circ.posY(-ORB_SPACING - ORB_SIZE/2);
                circ.sca(@(1,1,1)*ORB_SIZE);
                circ --> this;
                circles << circ;
            }
        }
        
    }

    fun set(int i, int on) {
        float v;
        if (on) {
            1 => v;
        } else {
            0.2 => v;
        }
        circles[i].color(Color.hsv2rgb(@(360*SoundOrb.ORB_HUES[i], 1, v)));
    }
}

public class Hud extends GGen {
    0 => static int EyeState_Open;
    1 => static int EyeState_Closing;
    2 => static int EyeState_Closed;
    3 => static int EyeState_Opening;

    Utils.getScreenSize() => vec2 screenSize;

    null @=> HudOrbs @ orbs;

    EyeState_Open => int eyeState;
    screenSize.y/2 => float closeSpeed;

    FlatMaterial lidMat;
    lidMat.color(@(0,0,0));
    PlaneGeometry lidGeo;
    GMesh lid1(lidGeo, lidMat) --> this;
    lid1.scaX(screenSize.x);
    lid1.scaY(screenSize.y/2);
    lid1.posY(screenSize.y*3/4);

    GMesh lid2(lidGeo, lidMat) --> this;
    lid2.scaX(screenSize.x);
    lid2.scaY(screenSize.y/2);
    lid2.posY(-screenSize.y*3/4);

    fun setOrbLimit(int limit) {
        if (orbs != null) {
            orbs --< this;
        }
        new HudOrbs(limit) @=> orbs;
        orbs.posX(-screenSize.x/2);
        orbs.posY(screenSize.y/2);
        orbs --> this;
    }

    fun setOrb(int i, int on) {
        orbs.set(i, on);
    }

    fun toggleBlind() {
        if (eyeState == EyeState_Open || eyeState == EyeState_Opening) {
            EyeState_Closing => eyeState;
        } else if (eyeState == EyeState_Closed || eyeState == EyeState_Closing) {
            EyeState_Opening => eyeState;
        }
    }

    fun update(float dt) {
        if (eyeState == EyeState_Closing) {
            lid1.translateY(-closeSpeed * dt);
            lid2.translateY(closeSpeed * dt);
            if (lid1.posY() <= screenSize.y/4 || lid2.posY() >= -screenSize.y/4) {
                lid1.posY(screenSize.y/4);
                lid2.posY(-screenSize.y/4);
                EyeState_Closed => eyeState;
            }
        } else if (eyeState == EyeState_Opening) {
            lid1.translateY(closeSpeed * dt);
            lid2.translateY(-closeSpeed * dt);
            if (lid1.posY() >= screenSize.y*3/4 || lid2.posY() <= -screenSize.y*3/4) {
                lid1.posY(screenSize.y*3/4);
                lid2.posY(-screenSize.y*3/4);
                EyeState_Open => eyeState;
            }
        }
    }
}
