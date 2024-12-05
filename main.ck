@import { "levels/base.ck", "levels/reader.ck", "player.ck", "controller.ck", "audio/spatializer.ck" }

// GWindow.fullscreen();
GWindow.mouseMode(GWindow.MouseMode_Disabled);
GWindow.mouseDeltaPos();
GG.nextFrame() => now;
// GFlyCamera flyCam --> GG.scene();
// GG.scene().camera(flyCam);

GG.scene().light().rotY(pi/5);

// BasicPlatform testPlat(@(1, 2, 3, 3)) --> GG.scene();
[
    "levels/button.level",
    "levels/maze.level",
    "levels/basic.level",
    "levels/test.level",
    "levels/debug.level"
] @=> string levels[];
0 => int curLevel;

SpatializerEngine engine => dac;
Controller controller(GG.scene(), levels[curLevel], engine);

while (true) {
    GG.nextFrame() => now;
    if (controller.frame()) {
        1 +=> curLevel;
        levels.size() %=> curLevel;
        controller.clearOrbs();
        controller --< GG.scene();
        new Controller(GG.scene(), levels[curLevel], engine) @=> controller;
    }
}
