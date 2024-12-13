@import {
    "base.ck", 
    "../utils.ck", 
    "../things/platforms/base.ck", 
    "../things/platforms/basic.ck", 
    "../things/platforms/finish.ck", 
    "../things/platforms/button.ck",
    "../things/platforms/moving.ck",
    "../things/walls/base.ck",
    "../things/walls/basic.ck",
    "../things/walls/gate.ck",
    "../signal.ck",
    "../bump.ck"
}

class NameGenerator {
    0 => int ind;
    fun string gen(string prefix) {
        1 +=> ind;
        return prefix + "_" + ind;
    }
}

// Class that reads levels from a file.
public class LevelReader {
    fun static Platform readPlatform(StringTokenizer @ tok) {
        if (!tok.more()) {
            <<< "Error: when reading level file: Missing platform type" >>>;
            return null;
        }

        tok.next() => string platType;
        tok.next().toFloat() => float priority;
        if (platType == "basic") {
            Utils.readVec4(tok) => vec4 bounds;
            return new BasicPlatform(priority, bounds);
        } else if (platType == "finish") {
            Utils.readVec4(tok) => vec4 bounds;
            return new FinishPlatform(priority, bounds);
        } else if (platType == "moving") {
            Utils.readVec2(tok) => vec2 size;
            Utils.readVec2(tok) => vec2 pos1;
            Utils.readVec2(tok) => vec2 pos2;
            tok.next().toFloat() => float moveTime;
            tok.next().toFloat() => float waitTime;
            return new MovingPlatform(priority, size, pos1, pos2, moveTime, waitTime);
        } else {
            <<< "Error: when reading level file: Unrecognized platform type", platType >>>;
            return null;
        }
    }

    fun static Wall readWall(Level @ l, NameGenerator @ gen, StringTokenizer @ tok, Bump @ bump, SpatializerEngine @ spat) {
        if (!tok.more()) {
            <<< "Error: when reading level file: Missing wall type" >>>;
            return null;
        }

        tok.next() => string wallType;
        gen.gen("wall_" + wallType) => string wallName;
        if (wallType == "basic") {
            Utils.readVec4(tok) => vec4 bounds;
            return new BasicWall(wallName, bounds, bump);
        } else if (wallType == "gate") {
            Utils.readVec4(tok) => vec4 bounds;
            Utils.readVec3(tok) / 255.0 => vec3 color;
            tok.next() => string signalName;
            l.getSignal(signalName) @=> Signal @ sig;
            return new GateWall(wallName, bounds, color, sig, bump, spat);
        } else {
            <<< "Error: when reading level file: Unrecognized wall type", wallType >>>;
            return null;
        }
    }

    fun static Signal readSignal(StringTokenizer @ tok) {
        if (!tok.more()) {
            <<< "Error: when reading level file: Missing signal name" >>>;
            return null;
        }
        tok.next() => string signalName;
        return new Signal(signalName);
    }

    fun static Button readButton(Level @ l, StringTokenizer @ tok, SpatializerEngine @ spat) {
        tok.next().toFloat() => float priority;
        Utils.readVec4(tok) => vec4 bounds;
        Utils.readVec3(tok) / 255.0 => vec3 color;
        tok.next() => string signalName;
        
        l.getSignal(signalName) @=> Signal @ sig;
        return new Button(priority, bounds, color, sig, spat);
    }

    fun static void attachWalls(string dirs, Level @ l, Platform @ plat, NameGenerator @ gen, Bump @ bump) {
        plat.getHitbox() => vec4 hb;
        for (int i; i < dirs.length(); i++) {
            vec4 bounds;
            if (dirs.charAt(i) == 'n') {
                @(hb.x, hb.y, hb.z, hb.y) => bounds;
            } else if (dirs.charAt(i) == 'e') {
                @(hb.z, hb.y, hb.z, hb.w) => bounds;
            } else if (dirs.charAt(i) == 's') {
                @(hb.x, hb.w, hb.z, hb.w) => bounds;
            } else if (dirs.charAt(i) == 'w') {
                @(hb.x, hb.y, hb.x, hb.w) => bounds;
            } else {
                <<< "Error: when reading level file: Unrecognized attach direction", dirs.substring(i, 1) >>>;
                continue;
            }
            BasicWall wall(gen.gen("attach_wall"), bounds, bump);
            l.addWall(wall);
        }
    }

    fun static Level read(string filepath, Bump @ bump, SpatializerEngine @ spat) {
        FileIO io;
        io.open(filepath, IO.READ);
        if (!io.good()) {
            <<< "Error: Failed to read level file", filepath >>>;
            Machine.crash();
        }

        Level l;
        StringTokenizer tok;
        NameGenerator nameGen;
        Platform @ lastPlatform;

        while (io.more()) {
            io.readLine() => string line;
            tok.set(line);
            if (!tok.more()) continue;

            tok.next() => string lineType;
            if (lineType == "//") continue;
            else if (lineType == "spawn") {
                Utils.readVec2(tok) => vec2 spawnPos;
                l.setSpawn(spawnPos);
                if (tok.more()) {
                    tok.next().toFloat() => float startRot;
                    l.setStartRot(startRot);
                }
            } else if (lineType == "p") {
                readPlatform(tok) @=> lastPlatform;
                l.addPlatform(lastPlatform);
            } else if (lineType == "w") {
                l.addWall(readWall(l, nameGen, tok, bump, spat));
            } else if (lineType == "|") {
                if (lastPlatform == null) {
                    <<< "Error: Cannot attach walls without declaring a platform first" >>>;
                    continue;
                }
                tok.next() => string dirs;
                attachWalls(dirs, l, lastPlatform, nameGen, bump);
            } else if (lineType == "signal") {
                l.addSignal(readSignal(tok));
            } else if (lineType == "button") {
                l.addPlatform(readButton(l, tok, spat));
            } else if (lineType == "orbs") {
                tok.next().toInt() => l.maxOrbs;
            } else if (lineType == "title") {
                line.substring(6) => l.title;
            } else {
                <<< "Error: Unrecognized line type in level", filepath, ":", lineType >>>;
            }
        }

        l.bake();
        return l;
    }
}
