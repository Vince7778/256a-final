@import { "../../utils.ck", "base.ck", "../../signal.ck" }

class GateReceiver extends Receiver {
    // this might cause a memory leak but whatever
    GateWall @ linkedWall;
    fun GateReceiver(GateWall @ w) {
        w @=> linkedWall;
    }

    fun void activate() {
        spork ~ linkedWall.retract();
    }
}

public class GateWall extends Wall {
    3.0 => static float HEIGHT;
    60 => static int RETRACT_FRAMES;

    0 => static int STATE_UP;
    1 => static int STATE_RETRACTING;
    2 => static int STATE_RETRACTED;

    STATE_UP => int retractState;

    GCube _cube --> this;
    _cube.color(@(1, 1, 1) * 0.1);

    Bump @ _bump;
    GateReceiver receiver(this);

    fun GateWall(string name, vec4 bounds, vec3 color, Signal @ sig, Bump @ bump) {
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
        sig.addReceiver(receiver);
    }

    fun retract() {
        if (retractState != STATE_UP) return;
        STATE_RETRACTING => retractState;
        for (int i; i < RETRACT_FRAMES; i++) {
            GG.nextFrame() => now;
            // cancel retracting if reset
            if (retractState != STATE_RETRACTING) return;
            _cube.posY(-HEIGHT / 2.0 + WALL_STEP * (RETRACT_FRAMES - i - 1.0) / RETRACT_FRAMES + 0.0001);
        }
        STATE_RETRACTED => retractState;
        removeFromBump(_bump);
    }

    fun reset() {
        if (retractState != STATE_UP) {
            _cube.posY(-HEIGHT / 2.0 + WALL_STEP);
            if (retractState == STATE_RETRACTED) addToBump(_bump);
            STATE_UP => retractState;
        }
    }
}
