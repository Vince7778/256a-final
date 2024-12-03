// from https://github.com/kikito/bump.lua/blob/master/bump.lua
@import { "utils.ck" }

class BUtils {
    1e-10 => static float DELTA;

    fun static float nearest(float x, float a, float b) {
        if (Math.fabs(a-x) < Math.fabs(b-x)) {
            return a;
        } else {
            return b;
        }
    }
}

class CollisionResult {
    1 => int success;
    int overlaps;
    float ti;
    vec2 move;
    vec2 normal;
    vec2 touch;
    BRect itemRect;
    BRect otherRect;
}

class BRect {
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

        if (d.containsPoint(0, 0)) {
            d.getNearestCorner(0, 0) => vec2 p;
            Math.min(w, Math.fabs(p.x)) => float wi;
            Math.min(h, Math.fabs(p.y)) => float hi;
            -wi * hi => ti;
            true => overlaps;
        } else {
            float inters[6];
            if (d.getSegmentIntersectionIndices(0, 0, dx, dy, -Math.INFINITY, Math.INFINITY, inters)) {
                if (inters[0] < 1
                        && Math.fabs(inters[0] - inters[1]) >= BUtils.DELTA
                        && (0 < inters[0] + BUtils.DELTA || (inters[0] == 0 && inters[1] > 0))) {
                    inters[0] => ti;
                    inters[2] => nx;
                    inters[3] => ny;
                    false => overlaps;
                }
            }
        }

        if (ti == 0) {
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
                if (!d.getSegmentIntersectionIndices(0, 0, dx, dy, -Math.INFINITY, 1, inters)) {
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

class Grid {
    float cellSize;

    fun vec2 toWorld(float cx, float cy) {
        return @((cx-1)*cellSize, (cy-1)*cellSize);
    }

    fun vec2 toCell(float x, float y) {
        return @(
            Math.floor(x / cellSize) + 1,
            Math.floor(y / cellSize) + 1
        );
    }

    fun vec3 traverseInitStep(float ct, float t1, float t2) {
        t2 - t1 => float v;
        if (v > 0) {
            return @(1, cellSize/v, ((ct + v) * cellSize - t1) / v);
        } else if (v < 0) {
            return @(-1, -cellSize / v, ((ct + v - 1) * cellSize - t1) / v);
        } else {
            return @(0, Math.INFINITY, Math.INFINITY);
        }
    }

    // puts into out a list of traversed cells
    fun void traverse(float x1, float y1, float x2, float y2, vec2 out[]) {
        toCell(x1, y1) => vec2 c1;
        toCell(x2, y2) => vec2 c2;
        traverseInitStep(c1.x, x1, x2) => vec3 irx;
        irx.x => float stepX; irx.y => float dx; irx.z => float tx;
        traverseInitStep(c1.y, y1, y2) => vec3 iry;
        iry.x => float stepY; iry.y => float dy; iry.z => float ty;

        c1.x => float cx;
        c1.y => float cy;
        out << @(cx, cy);

        while (Math.fabs(cx - c2.x) + Math.fabs(cy - c2.y) > 1) {
            if (tx < ty) {
                dx +=> tx;
                stepX +=> cx;
                out << @(cx, cy);
            } else {
                if (tx == ty) {
                    out << @(cx + stepX, cy);
                }
                dy +=> ty;
                stepY +=> cy;
                out << @(cx, cy);
            }
        }

        if (cx != c2.x || cy != c2.y) {
            out << @(c2.x, c2.y);
        }
    }

    fun vec4 toCellRect(BRect r) {
        toCell(r.x, r.y) => vec2 c;
        Math.ceil((r.x + r.w) / cellSize) => float cr;
        Math.ceil((r.y + r.h) / cellSize) => float cb;
        return @(c.x, c.y, cr - c.x + 1, cb - c.y + 1);
    }
}

class Cell {
    0 => int itemCount;
    int itemSet[0]; // associative array
    string items[0]; // might contain deleted items, always check itemSet
    int x; int y;

    fun Cell(int _x, int _y) {
        _x => x;
        _y => y;
    }

    fun int hasItem(string item) {
        return itemSet[item] == 1;
    }
    fun void addItem(string item) {
        1 => itemSet[item];
        items << item;
    }
    fun void removeItem(string item) {
        if (hasItem(item)) {
            0 => itemSet[item];
        }
    }
}

public class Bump {
    Grid g; 64 => g.cellSize;
    // unlike in the lua one rows can't be garbage collected,
    // could potentially add manual garbage collection
    Cell rows[0];
    int nonEmptyCells[0];

    fun string _cellId(int cx, int cy) {
        return cx + "," + cy;
    }

    fun Cell _getCell(int cx, int cy) {
        _cellId(cx, cy) => string s;
        if (rows[s] == null) {
            new Cell(cx, cy) @=> rows[s];
        }
        return rows[s];
    }

    fun _addItemToCell(string item, int cx, int cy) {
        _getCell(cx, cy) @=> Cell @ cell;
        1 => nonEmptyCells[_cellId(cx, cy)]
    }
}
