@import { "levels/base.ck", "levels/reader.ck", "player.ck", "controller.ck", "audio/spatializer.ck" }

// GWindow.fullscreen(1920, 1080);
GWindow.mouseMode(GWindow.MouseMode_Disabled);
GWindow.mouseDeltaPos();
GG.nextFrame() => now;
// 0.5::second => now; // give time to transition to fullscreen
// GFlyCamera flyCam --> GG.scene();
// GG.scene().camera(flyCam);

GG.scene().light().rotY(pi/5);

[
    "levels/button.level",
    "levels/maze2.level",
    "levels/maze.level",
    "levels/basic.level",
    "levels/test.level",
    "levels/debug.level"
] @=> string levels[];
0 => int curLevel;

Controller controller(GG.scene(), GG.hud(), levels[curLevel]);

200 => int STAR_COUNT;
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
backgroundStars.size(0.15);

while (true) {
    GG.nextFrame() => now;
    if (controller.frame()) {
        1 +=> curLevel;
        levels.size() %=> curLevel;
        controller.cleanup();
        controller --< GG.scene();
        new Controller(GG.scene(), GG.hud(), levels[curLevel]) @=> controller;
    }
    // janky hack!
    backgroundStars.pos(controller.player.pos());
}
