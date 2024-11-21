@import { "base.ck", "../utils.ck", "../platforms/base.ck", "../platforms/basic.ck", "../platforms/finish.ck" }

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

    fun static Level read(string filepath) {
        FileIO io;
        io.open(filepath, IO.READ);
        if (!io.good()) {
            <<< "Error: Failed to read level file", filepath >>>;
            Machine.crash();
        }

        Level l;
        StringTokenizer tok;

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
            } else {
                <<< "Error: Unrecognized line type in level", filepath, ":", lineType >>>;
            }
        }

        l.bake();
        return l;
    }
}
