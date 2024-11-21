@import "player.ck"

// Orb that emits sound when you place it in the world!
public class SoundOrb extends GGen {
    0.2 => static float DIAMETER;
    5::ms => static dur RAMP_TIME;

    null @=> Osc osc;
    Envelope env(RAMP_TIME) => Pan2 pan;

    GSphere ball --> this;
    ball.sca(@(1, 1, 1) * DIAMETER);

    fun SoundOrb(Osc _osc, float hue, UGen audio) {
        _osc @=> osc;
        osc => env;
        pan => audio;
        env.keyOn();
        ball.color(Color.hsv2rgb(@(hue*360, 1, 1)));
    }

    fun unchuck(UGen audio) {
        env.keyOff();
        RAMP_TIME*2 => now;
        osc =< env;
        pan =< audio;
    }

    fun spatialize(Player @ p) {
        pos() - p.pos() => vec3 diffVec;
        diffVec.magnitude() => float mag;
        Std.clampf(3 / mag, 0, 1) => float newGain;
        env.target(newGain);

        0 => diffVec.y;
        diffVec.normalize();
        p.right() => vec3 rightVec;
        diffVec.x * rightVec.x + diffVec.z * rightVec.z => float newPan;
        Std.clampf(newPan, -0.9, 0.9) => pan.pan;
    }
}
