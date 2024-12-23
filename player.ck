@import { "bump.ck", "audio/spatializer.ck", "entity.ck" }

// Player controller
public class Player extends Entity {
    0.8 => static float EYE_HEIGHT;
    0.003 => static float ROTATION_SPEED;
    3.0 => static float MOVE_SPEED;
    4.0 => static float GRAVITY;
    0.3 => static float WIDTH;
    1.2 => static float STEP_DISTANCE;

    // for some reason camera needs to be grucked to scene
    // otherwise lighting gets messed up
    // so i make a new ggen which camera gets moved to each frame
    GCamera _camReal --> GG.scene();
    _camReal.fov(0.3*pi);
    GGen _cam --> this;
    _cam.posY(EYE_HEIGHT);

    0 => int shouldPreventInput;
    0 => int shouldSkipUpdate;

    @(0, 0, 0) => vec3 _vel;

    0 => int isBlind;

    Bump @ _bump;

    SndBuf stepBuf1("audio/sounds/step.wav") => dac;
    0.1 => stepBuf1.gain;
    stepBuf1.pos(stepBuf1.samples());
    SndBuf stepBuf2("audio/sounds/step2.wav") => dac;
    0.1 => stepBuf2.gain;
    stepBuf2.pos(stepBuf2.samples());
    @(0, 0, 0) => vec3 lastStep;
    1 => int lastStepBuf;

    fun Player(Bump @ bump) {
        bump @=> _bump;
        bump.add("player", new BRect(getAABB()));
    }

    fun int isPlayer() {
        return true;
    }

    fun setSceneCam(GScene @ scene) {
        scene.camera(_camReal);
    }

    // resolves collisions
    // use setPosForce to skip collision step
    fun setPos(vec3 p) {
        _bump.move("player", p.x - WIDTH/2, p.z - WIDTH/2) @=> MoveResult moveRes;
        posX(moveRes.x + WIDTH/2);
        posY(p.y);
        posZ(moveRes.y + WIDTH/2);
    }

    fun setPosForce(vec3 p) {
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

    fun fixCamera() {
        _camReal.pos(_cam.posWorld());
        _camReal.rot(rot() + _cam.rot());
    }

    fun update(float dt) {
        if (shouldSkipUpdate) {
            return;
        }

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
                normRight +=> curVel;
            }
            if (GWindow.key(GWindow.Key_A) || GWindow.key(GWindow.Key_Left)) {
                -1 * normRight +=> curVel;
            }
            if (GWindow.key(GWindow.Key_W) || GWindow.key(GWindow.Key_Up)) {
                normForward +=> curVel;
            }
            if (GWindow.key(GWindow.Key_S) || GWindow.key(GWindow.Key_Down)) {
                -1 * normForward +=> curVel;
            }
            curVel.normalize();

            setPos(@(posX() + curVel.x * MOVE_SPEED * dt, posY(), posZ() + curVel.z * MOVE_SPEED * dt));

            // only play step sounds if player actually inputted a move
            // helps account for moving platforms
            if (curVel.magnitude() > 0) {
                pos() => vec3 stepPos;
                0 => stepPos.y;
                stepPos - lastStep => vec3 stepDiff;
                if (stepDiff.magnitude() >= STEP_DISTANCE && !isFalling) {
                    if (lastStepBuf == 1) {
                        stepBuf2.pos(0);
                        2 => lastStepBuf;
                    } else {
                        stepBuf1.pos(0);
                        1 => lastStepBuf;
                    }
                    stepPos => lastStep;
                }
            }
        }

        fixCamera();
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

    fun vec3 getOrbPos() {
        pos() + _cam.forward()*0.7 => vec3 res;
        EYE_HEIGHT/2 => res.y;
        return res;
    }
}
