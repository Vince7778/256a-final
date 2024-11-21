@import { "../utils.ck", "../player.ck" }

// base class for all platform types
// should never be moved, rotated, or scaled using the GGen methods
public class Platform extends GGen {
    // function called to manually update platform
    // t is draw time, use this instead of `now` to make replays work
    fun upd(time t) {}

    fun int interact(Player @ p) {
        return Inter_None;
    }

    fun int collidesWithPlayer(Player @ p) {
        return Utils.collideAABB(_hitbox, p.getAABB());
    }

    // player will not fall if they collide with this region
    // player will interact if their center falls within this region
    vec4 _hitbox;

    // priority of platform
    // higher priority means renders on top and gets updates first
    float priority;

    // interaction codes
    0 => static int Inter_None;
    1 => static int Inter_EndLevel;
}
