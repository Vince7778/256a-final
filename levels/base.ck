@import {
    "../player.ck", 
    "../utils.ck", 
    "../things/platforms/base.ck",
    "../things/walls/base.ck",
    "../signal.ck"
}

// Base class for a game level.
public class Level extends GGen {
    float _startRot;
    vec2 _spawn;

    Platform _plats[0];
    Wall _walls[0];
    Signal _signals[0];

    fun setSpawn(vec2 pos) {
        pos => _spawn;
    }

    // input is in degrees!!
    fun setStartRot(float val) {
        val / 180 * pi => _startRot;
    }

    fun addPlatform(Platform @ plat) {
        plat --> this;
        _plats << plat;
    }

    fun addWall(Wall @ wall) {
        wall --> this;
        _walls << wall;
    }

    fun addSignal(Signal @ signal) {
        if (_signals.isInMap(signal.name)) {
            <<< "Error: Signal", signal.name, "already added" >>>;
            return;
        }
        signal @=> _signals[signal.name];
    }

    fun Signal getSignal(string name) {
        if (!_signals.isInMap(name)) {
            <<< "Error: Signal", name, "not found" >>>;
            return null;
        }
        return _signals[name];
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

    fun spawn(Player @ p) {
        p.reset();
        p.setPos(@(_spawn.x, 0, _spawn.y));
        p.rotateY(_startRot);
    }

    // soft reset; only moves player + resets buttons
    fun reset(Player @ p) {
        spawn(p);
        for (Platform @ plat : _plats) {
            plat.reset();
        }
        for (Wall @ wall : _walls) {
            wall.reset();
        }

        string signalNames[0];
        _signals.getKeys(signalNames);
        for (string name : signalNames) {
            _signals[name].reset();
        }
    }

    // returns the platform that the player is interacting with
    fun Platform touchingPlatform(Player @ p) {
        for (Platform @ plat : _plats) {
            if (plat.collidesWithPlayer(p)) {
                return plat;
            }
        }
        return null;
    }

    fun update() {
        string signalNames[0];
        _signals.getKeys(signalNames);
        for (string name : signalNames) {
            _signals[name].check();
        }
    }
}
