// from https://github.com/kikito/bump.lua/blob/master/bump.lua
// this implementation doesn't have cells because those are too hard to translate
// due to lua's very liberal typing
@import { "utils.ck" }

class BUtils {
    1e-10 => static float DELTA;
    1e100 => static float BIG;

    fun static float nearest(float x, float a, float b) {
        if (Math.fabs(a-x) < Math.fabs(b-x)) {
            return a;
        } else {
            return b;
        }
    }

    fun static int cmpCol(CollisionResult a, CollisionResult b) {
        if (a.ti == b.ti) {
            a.itemRect @=> BRect ir;
            a.otherRect @=> BRect ar;
            b.otherRect @=> BRect br;
            ir.getSquareDistance(ar) => float ad;
            ir.getSquareDistance(br) => float bd;
            return ad < bd;
        }
        return a.ti < b.ti;
    }

    // bubble sort :P
    fun static void sortByTiAndDistance(CollisionResult col[]) {
        for (int i; i < col.size()-1; i++) {
            for (i => int j; j < col.size()-1; j++) {
                if (cmpCol(col[j], col[j+1])) {
                    col[j] @=> CollisionResult tmp;
                    col[j+1] @=> col[j];
                    tmp @=> col[j+1];
                }
            }
        }
    }
}

public class CollisionResult {
    1 => int success;
    int overlaps;
    float ti;
    vec2 move;
    vec2 normal;
    vec2 touch;
    vec2 slide;
    string item;
    string other;
    BRect itemRect;
    BRect otherRect;
}

public class BRect {
    float x;
    float y;
    float w;
    float h;

    fun BRect(float _x, float _y, float _w, float _h) {
        _x => x;
        _y => y;
        _w => w;
        _h => h;
    }

    // from x1 y1 x2 y2
    fun BRect(vec4 bounds) {
        bounds.x => x;
        bounds.y => y;
        bounds.z - bounds.x => w;
        bounds.w - bounds.y => h;
    }

    fun vec2 getNearestCorner(float px, float py) {
        return @(BUtils.nearest(px, x, x+w), BUtils.nearest(py, y, y+h));
    }

    // returns 0 if failure, 1 if success
    // out should be size 6
    fun int getSegmentIntersectionIndices(float x1, float y1, float x2, float y2, float out[]) {
        return getSegmentIntersectionIndices(x1, y1, x2, y2, 0, 1, out);
    }
    fun int getSegmentIntersectionIndices(float x1, float y1, float x2, float y2, float ti1, float ti2, float out[]) {
        x2-x1 => float dx;
        y2-y1 => float dy;
        float nx; float ny;
        float nx1; float ny1; float nx2; float ny2;
        float p; float q; float r;
        for (1 => int side; side <= 4; side++) {
            if (side == 1) {
                -1 => nx;
                0 => ny;
                -dx => p;
                x1 - x => q;
            } else if (side == 2) {
                1 => nx;
                0 => ny;
                dx => p;
                x + w - x1 => q;
            } else if (side == 3) {
                0 => nx;
                -1 => ny;
                -dy => p;
                y1 - y => q;
            } else {
                0 => nx;
                1 => ny;
                dy => p;
                y + h - y1 => q;
            }
        }

        if (p == 0) {
            if (q <= 0) {
                return 0;
            }
        } else {
            q / p => r;
            <<< r, ti1, ti2 >>>;
            if (p < 0) {
                if (r > ti2) return 0;
                else if (r > ti1) {
                    r => ti1;
                    nx => nx1;
                    ny => ny1;
                }
            } else {
                if (r < ti1) return 0;
                else if (r < ti2) {
                    r => ti2;
                    nx => nx2;
                    ny => ny2;
                }
            }
        }

        ti1 => out[0];
        ti2 => out[1];
        nx1 => out[2];
        ny1 => out[3];
        nx2 => out[4];
        ny2 => out[5];
        return 1;
    }

    fun BRect getDiff(BRect o) {
        return new BRect(
            o.x - x - w,
            o.y - y - h,
            w + o.w,
            h + o.h
        );
    }

    fun int containsPoint(float px, float py) {
        return px - x > BUtils.DELTA
            && py - y > BUtils.DELTA
            && x + w - px > BUtils.DELTA
            && y + h - py > BUtils.DELTA;
    }

    fun int isIntersecting(BRect o) {
        return x < o.x + o.w
            && o.x < x + w
            && y < o.y + o.h
            && o.y < y + h;
    }

    fun float getSquareDistance(BRect o) {
        x - o.x + (w - o.w)/2.0 => float dx;
        y - o.y + (h - o.h)/2.0 => float dy;
        return dx * dx + dy * dy;
    }

    fun CollisionResult detectCollision(BRect o) { return detectCollision(o, x, y); }
    fun CollisionResult detectCollision(BRect o, float goalX, float goalY) {
        goalX - x => float dx;
        goalY - y => float dy;

        getDiff(o) @=> BRect d;
        int overlaps;
        float ti;
        float nx;
        float ny;
        0 => int setTi;

        if (d.containsPoint(0, 0)) {
            d.getNearestCorner(0, 0) => vec2 p;
            Math.min(w, Math.fabs(p.x)) => float wi;
            Math.min(h, Math.fabs(p.y)) => float hi;
            -wi * hi => ti;
            true => overlaps;
            <<< "overlaps" >>>;
            1 => setTi;
        } else {
            float inters[6];
            if (d.getSegmentIntersectionIndices(0, 0, dx, dy, -BUtils.BIG, BUtils.BIG, inters)) {
                for (int aaa; aaa < 6; aaa++) {
                    <<< aaa, inters[aaa] >>>;
                }
                if (inters[0] < 1
                        && Math.fabs(inters[0] - inters[1]) >= BUtils.DELTA
                        && (0 < inters[0] + BUtils.DELTA || (inters[0] == 0 && inters[1] > 0))) {
                    inters[0] => ti;
                    inters[2] => nx;
                    inters[3] => ny;
                    false => overlaps;
                    1 => setTi;
                }
            }
        }

        if (!setTi) {
            CollisionResult res;
            0 => res.success;
            return res;
        }

        float tx;
        float ty;
        if (overlaps) {
            if (dx == 0 && dy == 0) {
                d.getNearestCorner(0, 0) => vec2 p;
                if (Math.fabs(p.x) < Math.fabs(p.y)) {
                    0 => p.y;
                } else {
                    0 => p.x;
                }
                Math.sgn(p.x) => nx;
                Math.sgn(p.y) => ny;
                x + p.x => tx;
                y + p.y => ty;
            } else {
                float inters[6];
                if (!d.getSegmentIntersectionIndices(0, 0, dx, dy, -BUtils.BIG, 1, inters)) {
                    CollisionResult res;
                    0 => res.success;
                    return res;
                }
                inters[2] => nx;
                inters[3] => ny;
                x + dx * inters[0] => tx;
                y + dy * inters[0] => ty;
            }
        } else {
            x + dx * ti => tx;
            y + dy * ti => ty;
        }

        CollisionResult res;
        overlaps => res.overlaps;
        ti => res.ti;
        @(dx, dy) => res.move;
        @(nx, ny) => res.normal;
        @(tx, ty) => res.touch;
        this @=> res.itemRect;
        o @=> res.otherRect;
        return res;
    }
}

public class MoveResult {
    float x;
    float y; 
    CollisionResult cols[0];

    fun MoveResult(float _x, float _y, CollisionResult _cols[]) {
        _x => x;
        _y => y;
        _cols @=> cols;
    }
}

public class Bump {
    BRect rects[0];

    fun MoveResult slide(CollisionResult col, BRect r, float goalX, float goalY) {
        if (col.move.x != 0 || col.move.y != 0) {
            if (col.normal.x != 0) {
                col.touch.x => goalX;
            } else {
                col.touch.y => goalY;
            }
        }

        @(goalX, goalY) => col.slide;
        CollisionResult cols[0];
        BRect nr(col.touch.x, col.touch.y, r.w, r.h);
        project(col.item, nr, goalX, goalY, cols);
        return new MoveResult(goalX, goalY, cols);
    }
    
    fun project(string item, BRect r, float goalX, float goalY, CollisionResult out[]) {
        string otherItems[0];
        rects.getKeys(otherItems);
        for (string other : otherItems) {
            if (other == item) continue;
            r.detectCollision(rects[other], goalX, goalY) @=> CollisionResult res;
            if (res.success) {
                other => res.other;
                item => res.item;
                out << res;
            }
        }
        BUtils.sortByTiAndDistance(out);
    }

    fun void add(string item, BRect r) {
        if (rects.isInMap(item)) {
            <<< "Rectangle", r, "is already added to world" >>>;
            return;
        }
        r @=> rects[item];
    }

    fun void remove(string item) {
        rects.erase(item);
    }

    fun void update(string item, float x, float y) {
        x => rects[item].x;
        y => rects[item].y;
    }

    fun MoveResult move(string item, float goalX, float goalY) {
        check(item, goalX, goalY) @=> MoveResult res;
        update(item, res.x, res.y);
        return res;
    }

    fun MoveResult check(string item, float goalX, float goalY) {
        CollisionResult cols[0];

        CollisionResult projectedCols[0];
        project(item, rects[item], goalX, goalY, projectedCols);

        int visited[0];
        true => visited[item];

        while (true) {
            CollisionResult @ col;
            for (int i; i < projectedCols.size(); i++) {
                if (!visited[projectedCols[i].other]) {
                    projectedCols[i] @=> col;
                    break;
                }
            }
            if (col == null) break;
            <<< "collided" >>>;

            cols << col;
            true => visited[col.other];
            slide(col, rects[item], goalX, goalY) @=> MoveResult moveRes;
            <<< "moving goal from", goalX, goalY, "to", moveRes.x, moveRes.y >>>;
            moveRes.x => goalX;
            moveRes.y => goalY;
            moveRes.cols @=> projectedCols;
        }
        return new MoveResult(goalX, goalY, cols);
    }
}
