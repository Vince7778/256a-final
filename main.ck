@import { "platforms/basic.ck", "levels/base.ck", "levels/reader.ck", "player.ck", "controller.ck" }

GWindow.mouseMode(GWindow.MouseMode_Disabled);
GWindow.mouseDeltaPos();
GG.nextFrame() => now;
// GFlyCamera flyCam --> GG.scene();
// GG.scene().camera(flyCam);

GG.scene().light().rotY(pi/5);

// BasicPlatform testPlat(@(1, 2, 3, 3)) --> GG.scene();
Controller controller(GG.scene(), "levels/1.level");

while (true) {
    GG.nextFrame() => now;
    controller.frame();

    if (GWindow.keyDown(GWindow.Key_R)) {
        controller --< GG.scene();
        new Controller(GG.scene(), "levels/1.level") @=> controller;
    }
}
