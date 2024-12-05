
public class Chime extends UGen {
    null => SndBuf @ _buf;

    fun Chime(int pitch) {
        pitch => _pitch;
        new SndBuf("sounds/chime" + pitch + ".wav") @=> _buf;
        _buf => this;
    }

    fun void play() {
        _buf.pos(0);
    }
}
