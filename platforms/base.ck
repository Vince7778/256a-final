@import "../utils.ck"

// base class for all platform types
// should never be moved, rotated, or scaled using the GGen methods
public class Platform extends GGen {
    // function called to manually update platform
    // t is draw time, use this instead of `now` to make replays work
    fun upd(time t) {}

    // player will not fall if they collide with this region
    // player will interact if their center falls within this region
    vec4 _hitbox;
}
