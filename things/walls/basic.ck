@import { "../../utils.ck", "base.ck" }

public class BasicWall extends Wall {
    3.0 => static float HEIGHT;

    GCube _cube --> this;
    _cube.color(@(1, 1, 1) * 0.4);

    fun BasicWall(string name, vec4 bounds, Bump @ bump) {
        Utils.fixBounds(bounds) => bounds;
        Utils.jut(bounds, THICKNESS) => bounds;
        new BRect(bounds) @=> _hitbox;
        name => _name;

        _cube.sca(@(
            bounds.z - bounds.x,
            HEIGHT + WALL_STEP,
            bounds.w - bounds.y
        ));
        _cube.pos(@(
            (bounds.x + bounds.z) / 2.0,
            -(HEIGHT - WALL_STEP) / 2.0,
            (bounds.y + bounds.w) / 2.0
        ));

        addToBump(bump);
    }
}
