@import { "utils.ck", "orb.ck", "blinker.ck" }

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
    GText texts[0];

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

                GText text;
                text.posX(circ.posX());
                text.posY(circ.posY());
                text.posZ(0.001);
                text.sca(@(1,1,1)*ORB_SIZE);
                text.text(""+(i+1));
                text --> this;
                texts << text;
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
    Utils.getScreenSize() => vec2 screenSize;

    0 => int orbsShown;
    null @=> HudOrbs @ orbs;
    Blinker blinker --> this;

    GText _titleText --> this;
    _titleText.controlPoints(@(0.5, 1.0));
    _titleText.posY(screenSize.y / 2 - 0.2);
    _titleText.sca(@(1,1,1) * 0.3);
    _titleText.text("");

    fun setOrbsShown(int s) {
        if (!orbsShown && s) {
            1 => orbsShown;
            if (orbs != null) {
                orbs --> this;
            }
        } else if (orbsShown && !s) {
            0 => orbsShown;
            if (orbs != null) {
                orbs --< this;
            }
        }
    }

    fun setOrbLimit(int limit) {
        if (orbs != null && orbsShown) {
            orbs --< this;
        }
        new HudOrbs(limit) @=> orbs;
        orbs.posX(-screenSize.x/2);
        orbs.posY(screenSize.y/2);
        if (orbsShown) {
            orbs --> this;
        }
    }

    fun setOrb(int i, int on) {
        orbs.set(i, on);
    }

    fun setTitleText(string txt) {
        _titleText.text(txt);
    }
}
