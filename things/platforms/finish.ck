@import { "base.ck", "../../utils.ck" }

// platform that wins the level upon touch
public class FinishPlatform extends Platform {
    3.0 => static float HEIGHT;

    GCube _cube --> this;
    _cube.color(@(0, 1, 0));

    fun FinishPlatform(float inPriority, vec4 bounds) {
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
            -HEIGHT / 2.0,
            (bounds.y + bounds.w) / 2.0
        ));
    }

    fun int interact(Player @ p) {
        return Platform.Inter_EndLevel;
    }
}
