@import { "player.ck", "orb.ck" }

class ReplayFrame {
    time t;
    vec3 playerPos;
    vec3 playerRot;
    vec3 camRot;
    vec3 orbPos[SoundOrb.MAX_ORBS];

    fun ReplayFrame(Player @ p, SoundOrb @ orbs[]) {
        now => t;
        p.getPos() => playerPos;
        p.rot() => playerRot;
        p._cam.rot() => camRot;
        for (int i; i < orbs.size(); i++) {
            orbs[i].getPos() => orbPos[i];
        }
    }

    fun updateStuff(Player @ p, SoundOrb @ orbs[]) {
        playerPos => p.pos;
        playerRot => p.rot;
        camRot => p._cam.rot;
        p.fixCamera();
        for (int i; i < orbs.size(); i++) {
            if (orbs[i].isPlaced) {
                orbs[i].setPos(orbPos[i]);
            }
        }
    }
}

public class Replay {
    ReplayFrame _frames[0];
    time startTime;

    0 => int isPlaying;
    0 => int frameIndex;

    fun addFrame(Player @ p, SoundOrb @ orbs[]) {
        if (empty()) {
            now => startTime;
        }
        _frames << new ReplayFrame(p, orbs);
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
    fun int nextFrame(Player @ p, SoundOrb @ orbs[], Level @ l) {
        if (empty() || !isPlaying) {
            return 1;
        }
        if (frameIndex >= _frames.size()) {
            0 => isPlaying;
            return 1;
        }
        _frames[frameIndex].updateStuff(p, orbs);
        l.upd(_frames[frameIndex].t);
        frameIndex++;
        return 0;
    }
}
