@import { "../../utils.ck", "../../player.ck", "../../entity.ck" }

// base class for all platform types
// should never be moved, rotated, or scaled using the GGen methods
public class Platform extends GGen {
    // interaction codes
    0 => static int Inter_None;
    1 => static int Inter_Floor; // not falling
    2 => static int Inter_EndLevel;

    // function called to manually update platform
    // t is draw time, use this instead of `now` to make replays work
    fun upd(time t) {}

    fun reset() {}

    fun int interact(Entity @ e, time t) {
        return Inter_Floor;
    }

    fun int collidesWith(Entity @ e) {
        return Utils.collideAABB(_hitbox, e.getAABB());
    }

    // player will not fall if they collide with this region
    // player will interact if their center falls within this region
    vec4 _hitbox;
    fun vec4 getHitbox() {
        return _hitbox;
    }

    // priority of platform
    // higher priority means renders on top and gets updates first
    float priority;
}
