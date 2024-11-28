// spatial audio test file
@import "spatializer.ck"

Blit src;
.5 => src.gain;
Std.mtof(60) => src.freq;
3 => src.harmonics;

SpatializerEngine spat => dac;
spat.register(src) @=> Source s;
@(0, 0, -3) => s.pos;

GWindow.mouseMode(GWindow.MouseMode_Disabled);
GFlyCamera flyCam --> GG.scene();
GG.scene().camera(flyCam);
GG.nextFrame() => now;

GSphere sph --> GG.scene();
sph.posZ(-3);

while (true) {
    GG.nextFrame() => now;
    spat.moveToGGen(flyCam);
}
