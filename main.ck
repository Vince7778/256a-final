@import { "things/platforms/basic.ck", "levels/base.ck", "levels/reader.ck", "player.ck", "controller.ck" }

// GWindow.fullscreen();
GWindow.mouseMode(GWindow.MouseMode_Disabled);
GWindow.mouseDeltaPos();
GG.nextFrame() => now;
// GFlyCamera flyCam --> GG.scene();
// GG.scene().camera(flyCam);

GG.scene().light().rotY(pi/5);

// BasicPlatform testPlat(@(1, 2, 3, 3)) --> GG.scene();
["levels/test.level", "levels/1.level"] @=> string levels[];
0 => int curLevel;

Controller controller(GG.scene(), levels[curLevel]);

while (true) {
    GG.nextFrame() => now;
    if (controller.frame()) {
        1 +=> curLevel;
        levels.size() %=> curLevel;
        controller.clearOrbs();
        controller --< GG.scene();
        new Controller(GG.scene(), levels[curLevel]) @=> controller;
    }
}
