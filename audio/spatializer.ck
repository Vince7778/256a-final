
public class Source extends UGen_Stereo {
    0.01 => static float INTERP_RATE;

    UGen @ _base;
    vec3 pos;

    vec3 _curDir;

    fun Source(UGen b) {
        b @=> _base;
        _base => this.left;
        _base => this.right;
    }

    fun _spatialize(vec3 v) {
        // attempt 1 at spatialization: just change both channel gain with distance
        0.1 / Math.max(v.magnitude(), 0.1) => float gainExp;
        Math.max(0, 1 + Math.log(gainExp)/5) => float gain;
        <<< v.magnitude(), gain >>>;
        gain => this.left.gain;
        gain => this.right.gain;
    }

    fun _update(vec3 targetDir) {
        _curDir + INTERP_RATE * (targetDir - _curDir) => _curDir;
        _spatialize(_curDir);
    }
}

public class Spatializer extends UGen_Stereo {
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
                s.pos - pos => vec3 off;
                @(
                    rightV.dot(off),
                    up.dot(off),
                    forward.dot(off)
                ) => vec3 rotOff;
                s._update(rotOff);
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