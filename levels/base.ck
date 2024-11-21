@import "../player.ck"

// Base class for a game level.
public class Level extends GGen {
    vec2 _spawn;
    Platform _plats[0];

    fun setSpawn(vec2 pos) {
        pos => _spawn;
    }

    fun addPlatform(Platform @ plat) {
        plat --> this;
        _plats << plat;
    }

    fun start(Player @ p) {
        p.pos(@(_spawn.x, 0, _spawn.y));
    }
}
