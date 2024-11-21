public class Utils {
    fun static assert(int v, string info) {
        if (!v) {
            <<< "Assertion failed:", info >>>;
            Machine.crash();
        }
    }

    // takes in (x1, z1, x2, z2) and makes sure that x1 < x2, z1 < z2
    fun static vec4 fixBounds(vec4 bounds) {
        Utils.assert(bounds.x != bounds.z && bounds.y != bounds.w, "Platform bounds are not equal");
        if (bounds.x > bounds.z) {
            @(bounds.z, bounds.y, bounds.x, bounds.w) => bounds;
        }
        if (bounds.y > bounds.w) {
            @(bounds.x, bounds.w, bounds.z, bounds.y) => bounds;
        }
        return bounds;
    }
}
