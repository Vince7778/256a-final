@import { "../../signal.ck", "base.ck", "../../player.ck" }

public class Button extends Platform {
    2.0 => static float HEIGHT;
    0.1 => static float UNPRESSED_STEP;

    0 => int _pressed;

    GCube _cube --> this;
    _cube.color(@(1, 1, 1) * 0.1);

    Sender sender;

    fun Button(float inPriority, vec4 bounds, vec3 color, Signal @ sig) {
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
    }

    fun void activate() {
        _cube.posY(-HEIGHT/2.0);
        sender.setActive(true);
    }

    fun int interact(Player @ p) {
        if (!_pressed) {
            1 => _pressed;
            activate();
        }
        return Inter_Floor;
    }

    fun void reset() {
        _cube.posY(-HEIGHT / 2.0 + UNPRESSED_STEP);
        0 => _pressed;
        sender.setActive(false);
    }
}
