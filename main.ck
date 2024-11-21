@import { "platforms/basic.ck", "levels/base.ck", "levels/reader.ck", "player.ck" }

GWindow.mouseMode(GWindow.MouseMode_Disabled);
GWindow.mouseDeltaPos();
GG.nextFrame() => now;
// GFlyCamera flyCam --> GG.scene();
// GG.scene().camera(flyCam);

// BasicPlatform testPlat(@(1, 2, 3, 3)) --> GG.scene();
LevelReader.read("levels/test.level") @=> Level level;
level --> GG.scene();

Player player --> GG.scene();
player.setSceneCam(GG.scene());
level.start(player);

while (true) {
    GG.nextFrame() => now;
}
