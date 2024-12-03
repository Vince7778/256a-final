@import {
    "base.ck", 
    "../utils.ck", 
    "../things/platforms/base.ck", 
    "../things/platforms/basic.ck", 
    "../things/platforms/finish.ck", 
    "../things/walls/base.ck",
    "../things/walls/basic.ck",
    "../bump.ck"
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
        } else {
            <<< "Error: when reading level file: Unrecognized platform type", platType >>>;
            return null;
        }
    }

    fun static Wall readWall(string wallName, StringTokenizer @ tok, Bump bump) {
        if (!tok.more()) {
            <<< "Error: when reading level file: Missing wall type" >>>;
            return null;
        }

        tok.next() => string wallType;
        if (wallType == "basic") {
            Utils.readVec4(tok) => vec4 bounds;
            return new BasicWall(wallName, bounds, bump);
        } else {
            <<< "Error: when reading level file: Unrecognized wall type", wallType >>>;
            return null;
        }
    }

    fun static Level read(string filepath, Bump bump) {
        FileIO io;
        io.open(filepath, IO.READ);
        if (!io.good()) {
            <<< "Error: Failed to read level file", filepath >>>;
            Machine.crash();
        }

        Level l;
        StringTokenizer tok;
        0 => int wallCounter;

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
                l.addPlatform(readPlatform(tok));
            } else if (lineType == "w") {
                "wall" + wallCounter => string wallName;
                l.addWall(readWall(wallName, tok, bump));
            } else {
                <<< "Error: Unrecognized line type in level", filepath, ":", lineType >>>;
            }
        }

        l.bake();
        return l;
    }
}
