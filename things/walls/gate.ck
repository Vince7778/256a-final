@import { "../../utils.ck", "base.ck", "../../signal.ck" }

class GateReceiver extends Receiver {
    // this might cause a memory leak but whatever
    GateWall @ linkedWall;
    fun GateReceiver(GateWall @ w) {
        w @=> linkedWall;
    }

    fun void activate() {
        now => linkedWall.retractTime;
        linkedWall.gateSound.pos(0);
    }
}

public class GateWall extends Wall {
    3.0 => static float HEIGHT;
    1::second => static dur RETRACT_DUR;

    0 => static int STATE_UP;
    1 => static int STATE_RETRACTING;
    2 => static int STATE_RETRACTED;

    now + 1::eon => time retractTime;

    GCube _cube --> this;
    _cube.color(@(1, 1, 1) * 0.1);

    Bump @ _bump;
    0 => int isInBump;
    GateReceiver receiver(this);

    null @=> Source @ gateSource;
    SndBuf gateSound("audio/sounds/gate_wind.wav");
    gateSound.gain(2.0);

    fun GateWall(string name, vec4 bounds, vec3 color, Signal @ sig, Bump @ bump, SpatializerEngine @ spat) {
        Utils.fixBounds(bounds) => bounds;
        Utils.jut(bounds, THICKNESS) => bounds;
        new BRect(bounds) @=> _hitbox;
        name => _name;
        bump @=> _bump;

        _cube.sca(@(
            bounds.z - bounds.x,
            HEIGHT,
            bounds.w - bounds.y
        ));
        _cube.pos(@(
            (bounds.x + bounds.z) / 2.0,
            -HEIGHT / 2.0 + WALL_STEP,
            (bounds.y + bounds.w) / 2.0
        ));
        _cube.color(color);

        addToBump(_bump);
        1 => isInBump;
        sig.addReceiver(receiver);
        
        gateSound.pos(gateSound.samples());
        spat.register(gateSound) @=> gateSource;
        @(
            _cube.posX(),
            0,
            _cube.posZ()
        ) => gateSource.pos;
    }

    fun upd(time t) {
        Std.clampf((t - retractTime) / RETRACT_DUR, 0.0, 1.0) => float retractProgress;
        _cube.posY(-HEIGHT/2.0 + WALL_STEP * (1.0 - retractProgress) + 0.0001);
        if (retractProgress >= 1.0 && isInBump) {
            removeFromBump(_bump);
            0 => isInBump;
        } else if (retractProgress <= 0.0 && !isInBump) {
            addToBump(_bump);
            1 => isInBump;
        }
    }

    fun reset() {
        now + 1::eon => retractTime;
        upd(now);
    }
}
