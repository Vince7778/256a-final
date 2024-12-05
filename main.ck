@import { "levels/base.ck", "levels/reader.ck", "player.ck", "controller.ck", "audio/spatializer.ck" }

// GWindow.fullscreen();
GWindow.mouseMode(GWindow.MouseMode_Disabled);
GWindow.mouseDeltaPos();
GG.nextFrame() => now;
// GFlyCamera flyCam --> GG.scene();
// GG.scene().camera(flyCam);

GG.scene().light().rotY(pi/5);

[
    "levels/button.level",
    "levels/maze.level",
    "levels/basic.level",
    "levels/test.level",
    "levels/debug.level"
] @=> string levels[];
0 => int curLevel;

SpatializerEngine engine => dac;
Controller controller(GG.scene(), GG.hud(), levels[curLevel], engine);

500 => int STAR_COUNT;
GPoints backgroundStars --> GG.scene();
vec3 starPos[0];
for (int i; i < STAR_COUNT; i++) {
    @(
        Utils.sampleNormal(),
        Utils.sampleNormal(),
        Utils.sampleNormal()
    ) => vec3 dir;
    dir.normalize();
    starPos << dir * 100;
}
backgroundStars.positions(starPos);
backgroundStars.size(0.1);

while (true) {
    GG.nextFrame() => now;
    if (controller.frame()) {
        1 +=> curLevel;
        levels.size() %=> curLevel;
        controller.clearOrbs();
        controller --< GG.scene();
        new Controller(GG.scene(), GG.hud(), levels[curLevel], engine) @=> controller;
    }
    // janky hack!
    backgroundStars.pos(controller.player.pos());
}
