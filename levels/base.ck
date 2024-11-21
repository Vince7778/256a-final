// Base class for a game level.
public class Level extends GGen {
    vec2 _spawn;
    Platform _plats[0];

    fun setSpawn(vec2 pos) {
        pos => _spawn;
    }

    fun addPlatform(Platform @ p) {
        p --> this;
        _plats << p;
    }
}
