@import { "platforms/basic.ck", "levels/base.ck", "levels/reader.ck" }

GG.nextFrame() => now;
GFlyCamera flyCam --> GG.scene();
GG.scene().camera(flyCam);

// BasicPlatform testPlat(@(1, 2, 3, 3)) --> GG.scene();
LevelReader.read("levels/test.level") @=> Level level;
level --> GG.scene();

while (true) {
    GG.nextFrame() => now;
}
