@import { "player.ck" }

class ReplayFrame {
    time t;
    vec3 playerPos;
    vec3 playerRot;
    vec3 camRot;

    fun ReplayFrame(Player @ p) {
        now => t;
        p.pos() => playerPos;
        p.rot() => playerRot;
        p._cam.rot() => camRot;
    }

    fun updatePlayer(Player @ p) {
        playerPos => p.pos;
        playerRot => p.rot;
        camRot => p._cam.rot;
        p.fixCamera();
    }
}

public class Replay {
    ReplayFrame _frames[0];
    time startTime;

    0 => int isPlaying;
    0 => int frameIndex;

    fun addFrame(Player @ p) {
        if (empty()) {
            now => startTime;
        }
        _frames << new ReplayFrame(p);
    }

    fun int empty() {
        return _frames.size() == 0;
    }

    fun clear() {
        _frames.clear();
    }

    fun start() {
        1 => isPlaying;
        0 => frameIndex;
    }

    // returns 1 if replay should end
    fun int nextFrame(Player @ p, Level @ l) {
        if (empty() || !isPlaying) {
            return 1;
        }
        if (frameIndex >= _frames.size()) {
            0 => isPlaying;
            return 1;
        }
        _frames[frameIndex].updatePlayer(p);
        l.upd(_frames[frameIndex].t);
        frameIndex++;
        return 0;
    }
}
