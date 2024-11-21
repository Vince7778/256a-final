// Player controller
public class Player extends GGen {
    0.5 => static float EYE_HEIGHT;
    0.002 => static float ROTATION_SPEED;
    2.0 => static float MOVE_SPEED;
    4.0 => static float GRAVITY;

    GCamera _cam --> this;
    _cam.posY(EYE_HEIGHT);

    0 => int shouldPreventInput;

    0 => int isFalling;
    0 => float velY;

    fun setSceneCam(GScene @ scene) {
        scene.camera(_cam);
    }

    fun update(float dt) {
        GWindow.mouseDeltaPos() => vec2 mouseDelta;
        if (!shouldPreventInput && Math.fabs(mouseDelta.x) < 300 && Math.fabs(mouseDelta.y) < 300) {
            _cam.rotateX(-mouseDelta.y * ROTATION_SPEED);
            Std.clampf(_cam.rotX(), -pi/2, pi/2) => _cam.rotX;
            rotateOnWorldAxis(@(0, 1, 0), -mouseDelta.x * ROTATION_SPEED);

            right() => vec3 normRight;
            0 => normRight.y;
            normRight.normalize();
            forward() => vec3 normForward;
            0 => normForward.y;
            normForward.normalize();
            if (GWindow.key(GWindow.Key_D) || GWindow.key(GWindow.Key_Right)) {
                translate(normRight * MOVE_SPEED * dt);
            }
            if (GWindow.key(GWindow.Key_A) || GWindow.key(GWindow.Key_Left)) {
                translate(-1 * normRight * MOVE_SPEED * dt);
            }
            if (GWindow.key(GWindow.Key_W) || GWindow.key(GWindow.Key_Up)) {
                translate(normForward * MOVE_SPEED * dt);
            }
            if (GWindow.key(GWindow.Key_S) || GWindow.key(GWindow.Key_Down)) {
                translate(-1 * normForward * MOVE_SPEED * dt);
            }
            if (isFalling) {
                // i don't care enough to make this accurate
                GRAVITY * dt -=> velY;
                translateY(velY * dt);
            }
        }
    }
}
