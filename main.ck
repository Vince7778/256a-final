@import { "levels/base.ck", "levels/reader.ck", "player.ck", "controller.ck", "audio/spatializer.ck" }

// GWindow.fullscreen(1920, 1080);
GWindow.mouseMode(GWindow.MouseMode_Disabled);
GWindow.mouseDeltaPos();
GG.nextFrame() => now;
// 0.5::second => now; // give time to transition to fullscreen
// GFlyCamera flyCam --> GG.scene();
// GG.scene().camera(flyCam);

// load the cubemap
Texture.load(
    me.dir() + "./graphics/skybox/posx.png", // right
    me.dir() + "./graphics/skybox/negx.png", // left
    me.dir() + "./graphics/skybox/posy.png", // top
    me.dir() + "./graphics/skybox/negy.png", // bottom
    me.dir() + "./graphics/skybox/posz.png", // back
    me.dir() + "./graphics/skybox/negz.png"  // front
) @=> Texture cubemap;
GG.scene().envMap(cubemap);
GG.scene().backgroundColor(Color.WHITE);
GG.scene().light().rotateY(0.8);
GG.scene().light().rotateX(-pi/5);

[
    "levels/intro.level",
    "levels/basic.level",
    "levels/button.level",
    "levels/moving.level",
    "levels/maze2.level",
    "levels/bus.level"
    // "levels/test.level",
    // "levels/maze.level",
    // "levels/lots.level",
    // "levels/weird.level",
    // "levels/debug.level"
] @=> string levels[];
0 => int curLevel;

Controller controller(GG.scene(), GG.hud(), levels[curLevel]);

while (true) {
    GG.nextFrame() => now;
    if (controller.frame() || GWindow.keyDown(GWindow.Key_Backslash)) {
        1 +=> curLevel;
        levels.size() %=> curLevel;
        controller.cleanup();
        controller --< GG.scene();
        new Controller(GG.scene(), GG.hud(), levels[curLevel]) @=> controller;
    }
}
