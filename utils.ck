public class Utils {
    fun static assert(int v, string info) {
        if (!v) {
            <<< "Assertion failed:", info >>>;
            Machine.crash();
        }
    }

    // takes in (x1, z1, x2, z2)
    fun static vec4 fixBounds(vec4 bounds) {
        if (bounds.x > bounds.z) {
            @(bounds.z, bounds.y, bounds.x, bounds.w) => bounds;
        }
        if (bounds.y > bounds.w) {
            @(bounds.x, bounds.w, bounds.z, bounds.y) => bounds;
        }
        return bounds;
    }

    // extends each bound by v
    fun static vec4 jut(vec4 bounds, float v) {
        return @(bounds.x - v, bounds.y - v, bounds.z + v, bounds.w + v);
    }

    fun static readFloats(StringTokenizer @ tok, int n, float out[]) {
        for (int i; i < n; i++) {
            if (!tok.more()) {
                <<< "Failed to read", n, "tokens; only read", i >>>;
            }
            out << tok.next().toFloat();
        }
    }

    fun static vec2 readVec2(StringTokenizer @ tok) {
        float p[0];
        readFloats(tok, 2, p);
        return @(p[0], p[1]);
    }

    fun static vec3 readVec3(StringTokenizer @ tok) {
        float p[0];
        readFloats(tok, 3, p);
        return @(p[0], p[1], p[2]);
    }

    fun static vec4 readVec4(StringTokenizer @ tok) {
        float p[0];
        readFloats(tok, 4, p);
        return @(p[0], p[1], p[2], p[3]);
    }

    // returns 1 if collision, 0 if not
    fun static int collideAABB(vec4 v, vec4 w) {
        fixBounds(v) => v;
        fixBounds(w) => w;
        if (v.z < w.x || v.x > w.z) return 0;
        if (v.w < w.y || v.y > w.w) return 0;
        return 1;
    }
}
