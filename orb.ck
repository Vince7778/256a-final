@import { "audio/spatializer.ck", "audio/chime.ck" }

// Orb that emits sound when you place it in the world!
public class SoundOrb extends Entity {
    5 => static int MAX_ORBS;
    [1.0/3, 0.0, 1.0/6, 2.0/3, 5.0/6] @=> static float ORB_HUES[];
    0.2 => static float DIAMETER;
    0.5::second => static dur PLAY_DELAY;

    GSphere _ball --> this;
    _ball.sca(@(1, 1, 1) * DIAMETER);

    0 => int isPlaced;
    0 => int isPlaying;
    now => time _lastPlay;
    null @=> Chime @ _chime;
    null @=> Source @ _source;

    fun SoundOrb(int pitch, SpatializerEngine @ engine) {
        new Chime(pitch) @=> _chime;
        engine.register(_chime) @=> _source;
        _ball.color(Color.hsv2rgb(@(ORB_HUES[pitch]*360, 1, 1)));
    }

    fun void play() {
        if (now - _lastPlay < PLAY_DELAY) return;
        now => _lastPlay;
        _chime.play();
    }

    fun void setPos(vec3 p) {
        p => _source.pos;
        p => this.pos;
    }

    fun vec4 getAABB() {
        return @(posX()-DIAMETER/2, posZ()-DIAMETER/2, posX()+DIAMETER/2, posZ()+DIAMETER/2);
    }
}
