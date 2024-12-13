@import { "base.ck", "../../utils.ck" }

public class MovingPlatform extends Platform {
    0.5 => static float HEIGHT;

    GCube _cube --> this;
    _cube.color(@(0, 1, 1));

    now => time _lastUpdate;
    float _moveTime;
    float _waitTime;
    vec2 _pos1;
    vec2 _pos2;
    vec2 _size;

    fun MovingPlatform(float inPriority, vec2 size, vec2 pos1, vec2 pos2, float moveTime, float waitTime) {
        inPriority => priority;

        moveTime => _moveTime;
        waitTime => _waitTime;
        pos1 => _pos1;
        pos2 => _pos2;
        size => _size;

        _cube.sca(@(size.x, HEIGHT, size.y));
        _cube.pos(@(pos1.x, -HEIGHT/2, pos1.y));

        upd(now);
    }

    fun vec2 getCyclePos(time t) {
        // 0..moveTime: moving from pos1 to pos2
        // moveTime..(moveTime + waitTime): waiting at pos2
        // (moveTime + waitTime)..(2*moveTime + waitTime): moving from pos2 to pos1
        // (2*moveTime + waitTime)..(2*moveTime + 2*waitTime): waiting at pos1
        t / 1::second => float tsec;
        tsec % (2*_moveTime + 2*_waitTime) => float ct;
        if (ct < _moveTime) {
            return @(
                Std.scalef(ct, 0, _moveTime, _pos1.x, _pos2.x),
                Std.scalef(ct, 0, _moveTime, _pos1.y, _pos2.y)
            );
        } else if (ct < _moveTime + _waitTime) {
            return _pos2;
        } else if (ct < 2*_moveTime + _waitTime) {
            _moveTime + _waitTime -=> ct;
            return @(
                Std.scalef(ct, 0, _moveTime, _pos2.x, _pos1.x),
                Std.scalef(ct, 0, _moveTime, _pos2.y, _pos1.y)
            );
        } else {
            return _pos1;
        }
    }

    fun upd(time t) {
        getCyclePos(t) => vec2 p;
        @(p.x - _size.x/2, p.y - _size.y/2, p.x + _size.x/2, p.y + _size.y/2) => _hitbox;
        _cube.pos(@(p.x, -HEIGHT/2, p.y));
        t => _lastUpdate;
    }

    fun int interact(Entity @ e, time t) {
        if (!e.isFalling) {
            getCyclePos(t) - getCyclePos(_lastUpdate) => vec2 dpos;
            e.getPos() => vec3 oldPos;
            e.setPos(@(oldPos.x + dpos.x, oldPos.y, oldPos.z + dpos.y));
        }
        return Platform.Inter_Floor;
    }
}
