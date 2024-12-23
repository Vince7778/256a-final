@import { "../../signal.ck", "base.ck", "../../player.ck", "../../audio/spatializer.ck" }

public class Button extends Platform {
    2.0 => static float HEIGHT;
    0.1 => static float UNPRESSED_STEP;

    0 => int _pressed;
    now + 1::eon => time _pressTime;

    GCube _cube --> this;
    _cube.color(@(1, 1, 1) * 0.1);

    Sender sender;

    null @=> Source @ clickSource;
    SndBuf clickSound("audio/sounds/click.wav");

    fun Button(float inPriority, vec4 bounds, vec3 color, Signal @ sig, SpatializerEngine @ engine) {
        inPriority => priority;
        Utils.fixBounds(bounds) => bounds;
        bounds => _hitbox;

        _cube.sca(@(
            bounds.z - bounds.x,
            HEIGHT,
            bounds.w - bounds.y
        ));
        _cube.pos(@(
            (bounds.x + bounds.z) / 2.0,
            -HEIGHT / 2.0 + UNPRESSED_STEP,
            (bounds.y + bounds.w) / 2.0
        ));
        _cube.color(color);

        sig.addSender(sender);

        clickSound.pos(clickSound.samples());
        engine.register(clickSound) @=> clickSource;
        @(
            _cube.posX(),
            0,
            _cube.posZ()
        ) => clickSource.pos;
    }

    fun void upd(time t) {
        if (t >= _pressTime) {
            _cube.posY(-HEIGHT/2.0);
        } else {
            _cube.posY(-HEIGHT / 2.0 + UNPRESSED_STEP);
        }
    }

    fun void activate() {
        sender.setActive(true);
        clickSound.pos(0);
        now => _pressTime;
    }

    fun int interact(Entity @ e, time t) {
        if (e.isPlayer() && !_pressed) {
            1 => _pressed;
            activate();
        }
        return Platform.Inter_Floor;
    }

    fun void reset() {
        _cube.posY(-HEIGHT / 2.0 + UNPRESSED_STEP);
        0 => _pressed;
        now + 1::eon => _pressTime;
        sender.setActive(false);
    }
}
