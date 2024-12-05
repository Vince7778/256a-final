
public class Chime extends UGen {
    null @=> SndBuf @ _buf;

    fun Chime(int pitch) {
        new SndBuf("audio/sounds/chime" + pitch + ".wav") @=> _buf;
        _buf.pos(_buf.samples());
        _buf.gain(0.3);
        _buf => this;
    }

    fun void play() {
        _buf.pos(0);
    }
}
