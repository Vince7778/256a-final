// Heavily inspired by miniaudio's spatializer:
// https://raw.githubusercontent.com/mackron/miniaudio/master/miniaudio.h

class SpatializerConfig {
    0 => float minGain;
    1 => float maxGain;
    1 => float minDistance;
    Math.FLOAT_MAX => float maxDistance;
    1 => float rolloff;
    Math.TWO_PI => float coneInnerAngle;
    Math.TWO_PI => float coneOuterAngle;
    0 => float coneOuterGain;
    1 => float directionalAttenuationFactor;
    0.2 => float minSpatializationChannelGain;
    360::samp => dur smoothTime;
    @(0, 1, 0) => vec3 worldUp;
}

class AudioUtils {
    fun static float attenuationInverse(float distance, SpatializerConfig cfg) {
        if (cfg.minDistance >= cfg.maxDistance) return 1;
        Std.clampf(distance, cfg.minDistance, cfg.maxDistance) - cfg.minDistance => float fromMin;
        return cfg.minDistance / (cfg.minDistance + cfg.rolloff * fromMin);
    }

    fun static float angularGain(vec3 dirA, vec3 dirB, SpatializerConfig cfg) {
        if (cfg.coneInnerAngle >= Math.TWO_PI) {
            return 1;
        }

        Math.cos(cfg.coneInnerAngle * 0.5) => float cutoffInner;
        Math.cos(cfg.coneOuterAngle * 0.5) => float cutoffOuter;
        dirA.dot(dirB) => float d;

        if (d > cutoffInner) return 1;
        if (d <= cutoffOuter) return cfg.coneOuterGain;
        (d - cutoffOuter) / (cutoffInner - cutoffOuter) => float ratio;
        return cfg.coneOuterGain + ratio * (1 - cfg.coneOuterGain);
    }

    fun static vec3 channelDir(int ch) {
        if (ch == 0) return @(-1, 0, 0);
        if (ch == 1) return @(1, 0, 0);
        // invalid channel, return forwards
        return @(0, 0, -1);
    }
}

public class Source extends UGen_Stereo {
    vec3 pos;
    SpatializerConfig cfg;

    // linear gain interpolation
    [0.0, 0.0] @=> float startGain[];
    [1.0, 1.0] @=> float endGain[];
    [now, now] @=> time startTime[];

    startGain[0] => this.left.gain;
    startGain[1] => this.right.gain;

    fun Source(UGen b) {
        b => this.left;
        b => this.right;
    }

    fun interpGains() {
        for (int ch; ch < 2; ch++) {
            (now - startTime[ch]) / cfg.smoothTime => float prog;
            Std.clampf(prog, 0, 1) => prog;
            startGain[ch] + prog * (endGain[ch] - startGain[ch]) => float interpGain;
            interpGain => this.chan(ch).gain;
        }
    }

    fun updateGains(float newGain[]) {
        for (int ch; ch < 2; ch++) {
            if (newGain[ch] != endGain[ch]) {
                this.chan(ch).gain() => startGain[ch];
                newGain[ch] => endGain[ch];
                now => startTime[ch];
            }
        }
        interpGains();
    }
}

class Listener {
    @(0, 0, 0) => vec3 pos;
    @(0, 0, -1) => vec3 dir;

    // some listener defaults better for first person
    SpatializerConfig cfg;
    pi*4/3 => cfg.coneInnerAngle;
    0.5 => cfg.coneOuterGain;

    fun vec3 getRelativePos(Source s) {
        dir => vec3 axisZ; axisZ.normalize();
        axisZ.cross(s.cfg.worldUp) => vec3 axisX; axisX.normalize();
        if (axisX.magnitude() == 0) {
            @(1, 0, 0) => axisX;
        }
        axisX.cross(axisZ) => vec3 axisY;

        // lookat matrix
        float m[4][4];
        axisX.x => m[0][0]; axisX.y => m[1][0]; axisX.z => m[2][0]; -axisX.dot(pos) => m[3][0];
        axisY.x => m[0][1]; axisY.y => m[1][1]; axisY.z => m[2][1]; -axisY.dot(pos) => m[3][1];
        -axisZ.x => m[0][2]; -axisZ.y => m[1][2]; -axisZ.z => m[2][2]; -axisZ.dot(-1*pos) => m[3][2];
        0 => m[0][3]; 0 => m[1][3]; 0 => m[2][3]; 1 => m[3][3];

        vec3 res;
        m[0][0] * s.pos.x + m[1][0] * s.pos.y + m[2][0] * s.pos.z + m[3][0] => res.x;
        m[0][1] * s.pos.x + m[1][1] * s.pos.y + m[2][1] * s.pos.z + m[3][1] => res.y;
        m[0][2] * s.pos.x + m[1][2] * s.pos.y + m[2][2] * s.pos.z + m[3][2] => res.z;
        return res;
    }

    fun process(Source s) {
        getRelativePos(s) => vec3 relativePos;
        relativePos.magnitude() => float distance;

        AudioUtils.attenuationInverse(distance, s.cfg) => float gain;

        // normalize position (with clamping at low values)
        @(0, 0, 0) => vec3 unitPos;
        if (distance > 0.001) {
            relativePos * (1 / distance) => unitPos;
        } else {
            0 => distance;
        }

        // angular attenuation
        // unlike with miniaudio, we only attenuate the listener
        if (distance > 0) {
            @(0, 0, -1) => vec3 listenerDirection;
            AudioUtils.angularGain(listenerDirection, unitPos, cfg) *=> gain;
        }

        Std.clampf(gain, cfg.minGain, cfg.maxGain) => gain;

        [gain, gain] @=> float channelGains[];

        // panning
        if (distance > 0) {
            for (int iChannel; iChannel < 2; iChannel++) {
                unitPos.dot(AudioUtils.channelDir(iChannel)) => float dirDot;
                1 + s.cfg.directionalAttenuationFactor * (dirDot - 1) => float d;
                s.cfg.minSpatializationChannelGain => float dMin;
                (d + 1) * 0.5 => d;
                Math.max(d, dMin) => d;
                d *=> channelGains[iChannel];
            }
        }

        s.updateGains(channelGains);
    }
}

public class SpatializerEngine extends UGen_Stereo {
    Source _sources[0];
    Listener list;

    spork ~ _interp();
    spork ~ _update();

    fun Source register(UGen b) {
        Source src(b) => this;
        _sources << src;
        return src;
    }

    fun _interp() {
        while (true) {
            1::samp => now;
            for (Source @ s : _sources) {
                s.interpGains();
            }
        }
    }

    fun _update() {
        while (true) {
            10::ms => now;
            for (Source @ s : _sources) {
                list.process(s);
            }
        }
    }

    fun setPos(vec3 pos) {
        pos => list.pos;
    }

    fun setDir(vec3 dir) {
        dir => list.dir;
    }

    fun moveToGGen(GGen @ g) {
        setPos(g.pos());
        setDir(g.forward());
    }
}
