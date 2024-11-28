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
    360 => int smoothTime;
    @(0, 1, 0) => vec3 worldUp;
}

public class Source extends UGen_Stereo {
    vec3 pos;
    float gains[2];
    SpatializerConfig cfg;

    fun Source(UGen b) {
        b => this.left;
        b => this.right;
    }

    fun updateGains(float newGains[]) {
        // TODO: interpolation
    }
}

class Listener {
    vec3 pos;
    vec3 dir;
    SpatializerConfig cfg;

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

        1 => float gain;

        // TODO: attenuation

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
            // TODO: calculate angular gain
        }

        Std.clampf(gain, cfg.minGain, cfg.maxGain) => gain;

        [gain, gain] @=> float channelGains[];

        // panning
        if (distance > 0) {
            for (int iChannel; iChannel <= 1; iChannel++) {
                1 => float d; // TODO: get directional attenuation factor
                s.cfg.minSpatializationChannelGain => float dMin;
                (d + 1) * 0.5 => d;
                Math.max(d, dMin) => d;
                d *=> channelGains[iChannel];
            }
        }

        // TODO: run through gainer on source
    }
}

public class SpatializerEngine extends UGen_Stereo {
    Source _sources[0];
    Listener list;

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
