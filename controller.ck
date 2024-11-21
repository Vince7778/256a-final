// Game controller. Manages the player, level, and sound orbs.
public class Controller extends GGen {
    State_Placing => int state;
    Player player;
    Level level;

    fun Controller(GScene scene, string levelPath) {
        this --> scene;
        LevelReader.read(levelPath) @=> level;
        level --> this;
        player --> this;
        player.setSceneCam(scene);
        level.start(player);
    }

    fun frame() {
        level.interact(player);
    }

    1 => static int State_Placing;
    2 => static int State_Blind;
}
