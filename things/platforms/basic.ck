@import { "base.ck", "../../utils.ck" }

// just your regular old gray platform
public class BasicPlatform extends Platform {
    3.0 => static float HEIGHT;

    GCube _cube --> this;
    _cube.color(@(1, 1, 1) * 0.1);

    fun BasicPlatform(float inPriority, vec4 bounds) {
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
}
