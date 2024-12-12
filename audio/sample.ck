
public class SoundSample extends UGen {
    null @=> SndBuf @ _buf;

    fun SoundSample(string name) {
        new SndBuf("audio/sounds/" + name + ".wav") @=> _buf;
        _buf.pos(_buf.samples());
        _buf => this;
    }

    fun void play() {
        _buf.pos(0);
    }
}

public class SoundSample2 extends UGen_Stereo {
    null @=> SndBuf2 @ _buf;

    fun SoundSample2(string name) {
        new SndBuf2() @=> _buf;
        _buf.read("audio/sounds/" + name + ".wav");
        _buf.pos(_buf.samples());
        _buf => this;
    }

    fun void play() {
        _buf.pos(0);
    }
}
