@import "platforms/basic.ck"

GG.nextFrame() => now;
GFlyCamera flyCam --> GG.scene();
GG.scene().camera(flyCam);

BasicPlatform testPlat(@(1, 2, 3, 3)) --> GG.scene();

while (true) {
    GG.nextFrame() => now;
}
