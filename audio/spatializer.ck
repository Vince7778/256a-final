
// single ear source
// no interpolation happens
class MonoSource extends UGen {
    Gain in => JCRev rev => this;
    0.05 => rev.mix;

    fun MonoSource(UGen b) {
        b => in;
    }

    fun _spatialize(float d) {
        // attempt 1 at spatialization: just change both channel gain with distance
        Math.exp(-0.2 * d) => in.gain;
    }
}

public class Source extends UGen_Stereo {
    0.01 => static float INTERP_RATE;

    MonoSource @ _s[2];
    vec3 pos;
    vec3 _cur[2];

    fun Source(UGen b) {
        new MonoSource(b) @=> _s[0] => this.left;
        new MonoSource(b) @=> _s[1] => this.right;
    }

    fun _update(vec3 targetVec, int ear) {
        _cur[ear] + INTERP_RATE * (targetVec - _cur[ear]) => _cur[ear];
        _s[ear]._spatialize(_cur[ear].magnitude());
    }
}

public class Spatializer extends UGen_Stereo {
    0.3 => static float EAR_DIST;

    Source _sources[0];
    vec3 pos; // world position of listener
    vec3 forward; // forward unit vector of listener
    vec3 rightV; // right unit vector of listener
    vec3 up; // you get the idea

    spork ~ _update();

    fun Source register(UGen b) {
        Source src(b) => this;
        _sources << src;
        return src;
    }

    fun _update() {
        while (true) {
            1::samp => now;
            for (Source @ s : _sources) {
                for (int ear; ear <= 1; ear++) {
                    s.pos - pos => vec3 off;
                    if (ear == 0) {
                        -EAR_DIST / 2 * rightV +=> off;
                    } else {
                        EAR_DIST / 2 * rightV +=> off;
                    }
                    @(
                        rightV.dot(off),
                        up.dot(off),
                        forward.dot(off)
                    ) => vec3 rotOff;
                    s._update(rotOff, ear);
                }
            }
        }
    }

    fun moveToGGen(GGen @ g) {
        g.pos() => pos;
        g.forward() => forward;
        g.right() => rightV;
        g.up() => up;
    }
}