@import { "../../bump.ck" }

public class Wall extends GGen {
    // how high a wall extends above the floor
    0.4 => static float WALL_STEP;
    // how far beyond its initial line a wall juts
    0.1 => static float THICKNESS;

    string _name; // each wall needs a name for bump
    BRect _hitbox;

    fun void addToBump(Bump @ bump) {
        bump.add(_name, _hitbox);
    }

    fun void removeFromBump(Bump @ bump) {
        bump.remove(_name);
    }

    fun void reset() {}
}
