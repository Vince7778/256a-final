
public class Entity extends GGen {
    fun vec3 getPos() {
        return pos();
    }

    fun void setPos(vec3 p) {
        pos(p);
    }

    fun int isPlayer() {
        return false;
    }

    fun vec4 getAABB() {
        return @(0, 0, 0, 0);
    }
}