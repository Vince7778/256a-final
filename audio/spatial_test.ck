// spatial audio test file
@import { "chime.ck", "spatializer.ck" }

Chime src(0);
Chime src2(2);

SpatializerEngine spat => dac;
spat.register(src) @=> Source s;
@(0, 0, -3) => s.pos;
spat.register(src2) @=> Source s2;
@(0, 0, 3) => s2.pos;

GWindow.mouseMode(GWindow.MouseMode_Disabled);
GFlyCamera flyCam --> GG.scene();
GG.scene().camera(flyCam);
GG.nextFrame() => now;

GSphere sph --> GG.scene();
sph.posZ(-3);

fun playChime() {
    while (true) {
        1::second => now;
        src.play();
        src2.play();
    }
}
spork ~ playChime();

while (true) {
    GG.nextFrame() => now;
    spat.moveToGGen(flyCam);
}
