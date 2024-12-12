@import { "utils.ck" }

public class Blinker extends GGen {
    0 => static int EyeState_Open;
    1 => static int EyeState_Closing;
    2 => static int EyeState_Closed;
    3 => static int EyeState_Opening;

    Utils.getScreenSize() => vec2 screenSize;

    EyeState_Closed => int eyeState;
    screenSize.y/2 => float closeSpeed;

    FlatMaterial lidMat;
    lidMat.color(@(0,0,0));
    PlaneGeometry lidGeo;

    GMesh lid1(lidGeo, lidMat) --> this;
    lid1.scaX(screenSize.x);
    lid1.scaY(screenSize.y/2);
    lid1.posY(screenSize.y/4);

    GMesh lid2(lidGeo, lidMat) --> this;
    lid2.scaX(screenSize.x);
    lid2.scaY(screenSize.y/2);
    lid2.posY(-screenSize.y/4);

    fun open(dur d) {
        if (eyeState != EyeState_Open) {
            (screenSize.y/2) / (d/1::second) => closeSpeed;
            EyeState_Opening => eyeState;
        }
    }

    fun close(dur d) {
        if (eyeState != EyeState_Closed) {
            (screenSize.y/2) / (d/1::second) => closeSpeed;
            EyeState_Closing => eyeState;
        }
    }

    fun update(float dt) {
        if (eyeState == EyeState_Closing) {
            lid1.translateY(-closeSpeed * dt);
            lid2.translateY(closeSpeed * dt);
            if (lid1.posY() <= screenSize.y/4 || lid2.posY() >= -screenSize.y/4) {
                lid1.posY(screenSize.y/4);
                lid2.posY(-screenSize.y/4);
                EyeState_Closed => eyeState;
            }
        } else if (eyeState == EyeState_Opening) {
            lid1.translateY(closeSpeed * dt);
            lid2.translateY(-closeSpeed * dt);
            if (lid1.posY() >= screenSize.y*3/4 || lid2.posY() <= -screenSize.y*3/4) {
                lid1.posY(screenSize.y*3/4);
                lid2.posY(-screenSize.y*3/4);
                EyeState_Open => eyeState;
            }
        }
    }
}