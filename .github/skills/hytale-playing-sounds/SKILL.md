---
name: hytale-playing-sounds
description: Plays sounds to players in Hytale plugins using SoundUtil and SoundEvent. Use when playing sound effects, music, ambient audio, UI sounds, or any positional 3D audio to players. Triggers - sound, play sound, SoundUtil, SoundEvent, SoundCategory, audio, SFX, music, ambient, playSoundEvent3dToPlayer, sound index, 3D sound.
---

# Hytale Playing Sounds Skill

Use this skill when playing sounds to players in Hytale plugins. Sounds are played using `SoundUtil` with a positional `TransformComponent` and a sound index resolved from the `SoundEvent` asset map.

---

## Quick Reference

| Concept | Description |
|---------|-------------|
| **SoundEvent** | Asset map for resolving sound IDs to numeric indexes |
| **SoundUtil** | Utility class for playing sounds to players |
| **SoundCategory** | Classifies sound type (`SFX`, `UI`, `Music`, `Ambient`) |
| **TransformComponent** | Provides the 3D position where the sound plays |
| **World.execute()** | Required thread-safe execution context for sound playback |

---

## Sound Playback Flow

1. **Resolve the sound index** from `SoundEvent.getAssetMap()`
2. **Get the player reference** (`Ref<EntityStore>`)
3. **Get the world** and entity store
4. **Execute on the world thread** via `world.execute()`
5. **Get the TransformComponent** for the sound position
6. **Play the sound** via `SoundUtil.playSoundEvent3dToPlayer()`

---

## Required Imports

```java
import com.hypixel.hytale.server.core.modules.entity.component.TransformComponent;
import com.hypixel.hytale.server.core.modules.entity.EntityModule;
import com.hypixel.hytale.server.core.universe.world.World;
import com.hypixel.hytale.server.core.universe.world.storage.EntityStore;
import com.hypixel.hytale.server.sound.SoundCategory;
import com.hypixel.hytale.server.sound.SoundEvent;
import com.hypixel.hytale.server.util.SoundUtil;
import com.hypixel.hytale.store.Ref;
```

---

## Sound Indexes

Sounds are referenced by numeric index, resolved from the `SoundEvent` asset map using the sound's string key:

```java
int index = SoundEvent.getAssetMap().getIndex("SFX_Cactus_Large_Hit");
```

See the [full list of available sounds](https://hytalemodding.dev/en/docs/server/sounds) for valid sound keys.

---

## Sound Categories

`SoundCategory` classifies the type of sound being played:

| Category | Use Case |
|----------|----------|
| `SoundCategory.SFX` | Sound effects (combat, interactions, impacts) |
| `SoundCategory.UI` | User interface sounds (clicks, notifications) |
| `SoundCategory.Music` | Background music |
| `SoundCategory.Ambient` | Environmental/ambient audio |

---

## Getting the TransformComponent

The `TransformComponent` determines the 3D position of the sound. Two approaches:

### From the Player (Recommended)

Plays the sound at the player's current position:

```java
TransformComponent transform = store.getStore().getComponent(
    playerRef,
    EntityModule.get().getTransformComponentType()
);
```

### From a Custom Position

Plays the sound at an arbitrary world position (player must be close enough to hear):

```java
Vector3d position = new Vector3d(100, 64, 200);
Vector3f rotation = new Vector3f(0, 0, 0);
TransformComponent transform = new TransformComponent(position, rotation);
```

---

## Basic Example

Play a sound to a player at their current position:

```java
public void playSound(Player player) {
    int index = SoundEvent.getAssetMap().getIndex("SFX_Cactus_Large_Hit");
    World world = player.getWorld();
    EntityStore store = world.getEntityStore();
    Ref<EntityStore> playerRef = player.getReference();

    world.execute(() -> {
        TransformComponent transform = store.getStore().getComponent(
            playerRef,
            EntityModule.get().getTransformComponentType()
        );

        SoundUtil.playSoundEvent3dToPlayer(
            playerRef,
            index,
            SoundCategory.UI,
            transform.getPosition(),
            store.getStore()
        );
    });
}
```

---

## Common Use Cases

### Play a UI Sound on Event

```java
public void onPlayerAction(Player player) {
    int soundIndex = SoundEvent.getAssetMap().getIndex("SFX_UI_Click");
    World world = player.getWorld();
    EntityStore store = world.getEntityStore();
    Ref<EntityStore> playerRef = player.getReference();

    world.execute(() -> {
        TransformComponent transform = store.getStore().getComponent(
            playerRef,
            EntityModule.get().getTransformComponentType()
        );

        SoundUtil.playSoundEvent3dToPlayer(
            playerRef,
            soundIndex,
            SoundCategory.UI,
            transform.getPosition(),
            store.getStore()
        );
    });
}
```

### Play a Sound at a Specific Location

```java
public void playSoundAtPosition(Player player, double x, double y, double z, String soundKey) {
    int soundIndex = SoundEvent.getAssetMap().getIndex(soundKey);
    World world = player.getWorld();
    EntityStore store = world.getEntityStore();
    Ref<EntityStore> playerRef = player.getReference();

    world.execute(() -> {
        Vector3d position = new Vector3d(x, y, z);
        Vector3f rotation = new Vector3f(0, 0, 0);
        TransformComponent transform = new TransformComponent(position, rotation);

        SoundUtil.playSoundEvent3dToPlayer(
            playerRef,
            soundIndex,
            SoundCategory.SFX,
            transform.getPosition(),
            store.getStore()
        );
    });
}
```

### Play a Combat SFX

```java
public void playCombatSound(Player player, String soundKey) {
    int soundIndex = SoundEvent.getAssetMap().getIndex(soundKey);
    World world = player.getWorld();
    EntityStore store = world.getEntityStore();
    Ref<EntityStore> playerRef = player.getReference();

    world.execute(() -> {
        TransformComponent transform = store.getStore().getComponent(
            playerRef,
            EntityModule.get().getTransformComponentType()
        );

        SoundUtil.playSoundEvent3dToPlayer(
            playerRef,
            soundIndex,
            SoundCategory.SFX,
            transform.getPosition(),
            store.getStore()
        );
    });
}
```

---

## Utility Wrapper Class

Consider creating a utility wrapper for consistent sound playback:

```java
public class Sounds {

    public static void playToPlayer(Player player, String soundKey, SoundCategory category) {
        int index = SoundEvent.getAssetMap().getIndex(soundKey);
        World world = player.getWorld();
        EntityStore store = world.getEntityStore();
        Ref<EntityStore> playerRef = player.getReference();

        world.execute(() -> {
            TransformComponent transform = store.getStore().getComponent(
                playerRef,
                EntityModule.get().getTransformComponentType()
            );

            SoundUtil.playSoundEvent3dToPlayer(
                playerRef,
                index,
                category,
                transform.getPosition(),
                store.getStore()
            );
        });
    }

    public static void playAtPosition(Player player, String soundKey, SoundCategory category,
                                      double x, double y, double z) {
        int index = SoundEvent.getAssetMap().getIndex(soundKey);
        World world = player.getWorld();
        EntityStore store = world.getEntityStore();
        Ref<EntityStore> playerRef = player.getReference();

        world.execute(() -> {
            Vector3d position = new Vector3d(x, y, z);
            Vector3f rotation = new Vector3f(0, 0, 0);
            TransformComponent transform = new TransformComponent(position, rotation);

            SoundUtil.playSoundEvent3dToPlayer(
                playerRef,
                index,
                category,
                transform.getPosition(),
                store.getStore()
            );
        });
    }

    public static void playSfx(Player player, String soundKey) {
        playToPlayer(player, soundKey, SoundCategory.SFX);
    }

    public static void playUi(Player player, String soundKey) {
        playToPlayer(player, soundKey, SoundCategory.UI);
    }
}
```

---

## Best Practices

1. **Always use `world.execute()`**: Sound playback must run on the world thread for thread safety
2. **Prefer player transform**: Getting the transform from the player ensures they hear the sound; custom positions risk being out of audible range
3. **Choose the correct SoundCategory**: This affects volume mixing and player audio settings
4. **Cache sound indexes**: If playing the same sound frequently, resolve the index once and reuse it
5. **Validate sound keys**: Ensure the sound key exists in the `SoundEvent` asset map before playing
6. **Don't spam sounds**: Avoid playing many sounds in rapid succession as it can overwhelm the client audio

---

## playSoundEvent3dToPlayer Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `playerRef` | `Ref<EntityStore>` | The target player reference |
| `soundIndex` | `int` | Numeric index from `SoundEvent.getAssetMap()` |
| `category` | `SoundCategory` | Sound classification (`SFX`, `UI`, `Music`, `Ambient`) |
| `position` | `Vector3d` | 3D world position of the sound source |
| `store` | `Store<EntityStore>` | The entity store instance |

---

## Related APIs

- [Notifications](../hytale-notifications/SKILL.md) - For visual notifications with sounds
- [Text Holograms](../hytale-text-holograms/SKILL.md) - For visual world elements
- [ECS](../hytale-ecs/SKILL.md) - Entity Component System patterns

---

## References

- [Official Documentation](https://hytalemodding.dev/en/docs/guides/plugin/playing-sounds)
- [Available Sounds List](https://hytalemodding.dev/en/docs/server/sounds)
```
