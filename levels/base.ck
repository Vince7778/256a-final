@import { "../player.ck", "../utils.ck" }

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

    fun _sortPlatforms() {
        // bubble sort since we don't have builtin comparator support :P
        for (int i; i < _plats.size(); i++) {
            for (int j; j < _plats.size()-i-1; j++) {
                if (_plats[j].priority < _plats[j+1].priority) {
                    _plats[j] @=> Platform @ temp;
                    _plats[j+1] @=> _plats[j];
                    temp @=> _plats[j+1];
                }
            }
        }
    }

    // finalizes the level geometry and fixes positions for priority
    fun bake() {
        _sortPlatforms();
        for (int i; i < _plats.size(); i++) {
            _plats[i].posY(_plats[i].priority * 0.0001);
        }
    }

    fun start(Player @ p) {
        p.reset();
        p.pos(@(_spawn.x, 0, _spawn.y));
    }

    // deal with player-level interaction
    fun interact(Player @ p) {
        // see if any platforms are colliding with the player
        0 => int foundCollision;
        Platform.Inter_None => int interCode;
        for (Platform @ plat : _plats) {
            if (plat.collidesWithPlayer(p)) {
                1 => foundCollision;
                plat.interact(p) => interCode;
                break;
            }
        }
        if (!foundCollision) {
            1 => p.isFalling;
            return;
        }

        // TODO: end level if given that interact code
    }
}
