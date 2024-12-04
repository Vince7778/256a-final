@import { "bump.ck" }

// Player controller
public class Player extends GGen {
    0.8 => static float EYE_HEIGHT;
    0.003 => static float ROTATION_SPEED;
    3.0 => static float MOVE_SPEED;
    4.0 => static float GRAVITY;
    0.3 => static float WIDTH;

    GCamera _cam --> this;
    _cam.posY(EYE_HEIGHT);
    _cam.fov(0.3*pi);

    0 => int shouldPreventInput;

    0 => int isFalling;
    @(0, 0, 0) => vec3 _vel;

    0 => int isBlind;

    Bump @ _bump;

    fun Player(Bump @ bump) {
        bump @=> _bump;
        bump.add("player", new BRect(getAABB()));
    }

    fun setSceneCam(GScene @ scene) {
        scene.camera(_cam);
    }

    fun setPos(vec3 p) {
        pos(p);
        _bump.update("player", posX()-WIDTH/2, posZ()-WIDTH/2);
    }

    fun reset() {
        0 => shouldPreventInput;
        0 => isFalling;
        @(0, 0, 0) => _vel;
        _cam.rot(@(0, 0, 0));
        rot(@(0, 0, 0));
    }

    fun update(float dt) {
        if (isFalling) {
            // i don't care enough to make this accurate
            GRAVITY * dt -=> _vel.y;
        }
        translate(_vel * dt);

        GWindow.mouseDeltaPos() => vec2 mouseDelta;
        if (!shouldPreventInput && Math.fabs(mouseDelta.x) < 300 && Math.fabs(mouseDelta.y) < 300) {
            _cam.rotateX(-mouseDelta.y * ROTATION_SPEED);
            Std.clampf(_cam.rotX(), -pi/2, pi/2) => _cam.rotX;
            rotateOnWorldAxis(@(0, 1, 0), -mouseDelta.x * ROTATION_SPEED);

            vec3 curVel;
            right() => vec3 normRight;
            0 => normRight.y;
            normRight.normalize();
            forward() => vec3 normForward;
            0 => normForward.y;
            normForward.normalize();
            if (GWindow.key(GWindow.Key_D) || GWindow.key(GWindow.Key_Right)) {
                normRight * MOVE_SPEED +=> curVel;
            }
            if (GWindow.key(GWindow.Key_A) || GWindow.key(GWindow.Key_Left)) {
                -1 * normRight * MOVE_SPEED +=> curVel;
            }
            if (GWindow.key(GWindow.Key_W) || GWindow.key(GWindow.Key_Up)) {
                normForward * MOVE_SPEED +=> curVel;
            }
            if (GWindow.key(GWindow.Key_S) || GWindow.key(GWindow.Key_Down)) {
                -1 * normForward * MOVE_SPEED +=> curVel;
            }

            posX() - WIDTH/2 + curVel.x * dt => float goalX;
            posZ() - WIDTH/2 + curVel.z * dt => float goalY;
            _bump.move("player", goalX, goalY) @=> MoveResult moveRes;
            posX(moveRes.x + WIDTH/2);
            posZ(moveRes.y + WIDTH/2);
        }
    }

    fun vec4 getAABB() {
        return @(posX()-WIDTH/2, posZ()-WIDTH/2, posX()+WIDTH/2, posZ()+WIDTH/2);
    }

    fun toggleBlind() {
        if (isBlind) {
            _cam.posY(EYE_HEIGHT);
        } else {
            _cam.posY(1000);
        }
        !isBlind => isBlind;
    }
}
