---
name: hytale-instances
description: Documents Hytale's Instance System for creating, managing, and teleporting players into instanced worlds using InstancesPlugin. Use when spawning instance worlds from templates, teleporting players into active or loading instances, exiting instances with return points, or safely removing instances. Triggers - instance, InstancesPlugin, spawnInstance, teleportPlayerToInstance, teleportPlayerToLoadingInstance, exitInstance, safeRemoveInstance, instance template, instanced world, instance system, dungeon instance, challenge instance, return point.
---

# Hytale Instance System

Use this skill when working with instanced worlds in Hytale plugins. The `InstancesPlugin` provides a complete API for spawning instance worlds from templates, teleporting players in/out, and managing instance lifecycles.

> **Source:** <https://hytalemodding.dev/en/docs/guides/plugin/instances>

---

## Quick Reference

| Task | Method |
|------|--------|
| Get plugin instance | `InstancesPlugin.get()` |
| Spawn a new instance | `InstancesPlugin.get().spawnInstance(name, world, returnPoint)` |
| Teleport to active instance | `InstancesPlugin.teleportPlayerToInstance(playerRef, store, instanceWorld, overrideReturn)` |
| Teleport to loading instance | `InstancesPlugin.teleportPlayerToLoadingInstance(playerRef, store, worldFuture, overrideReturn)` |
| Exit an instance | `InstancesPlugin.exitInstance(playerRef, store)` |
| Remove an instance | `InstancesPlugin.safeRemoveInstance(instanceWorld)` |

---

## Key Concepts

### Instance Templates

Instance templates are located in your asset pack under `Server/Instances/[Name]`. Each template must contain an `instance.bson` configuration file. When `spawnInstance` is called, the template is copied and initialized as a new world in the universe.

### Return Points

A `Transform` that defines where the player should be teleported back to when they exit the instance. This is set during instance creation and can be optionally overridden during teleportation.

### World Execution Context

All instance operations (spawn, teleport, remove) should be executed within the world's execution context using `world.execute(() -> { ... })` to ensure thread safety.

---

## Required Imports

```java
import com.hypixel.hytale.server.core.Message;
import com.hypixel.hytale.server.core.Universe;
import com.hypixel.hytale.server.world.World;
import com.hypixel.hytale.server.world.Transform;
import com.hypixel.hytale.server.world.ISpawnProvider;
import com.hypixel.hytale.server.player.Player;
import com.hypixel.hytale.server.player.PlayerRef;
import com.hypixel.hytale.server.instances.InstancesPlugin;

import java.util.UUID;
import java.util.concurrent.CompletableFuture;
```

---

## Spawning an Instance

Use `spawnInstance` to create a new instanced world from a template. Returns a `CompletableFuture<World>`.

### Method Signature

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `String` | Name of the instance template (matches folder under `Server/Instances/`) |
| `world` | `World` | The current world context |
| `returnPoint` | `Transform` | Where the player should return when exiting the instance |
| **Returns** | `CompletableFuture<World>` | Future that completes with the new instance world |

### Example

```java
InstancesPlugin plugin = InstancesPlugin.get();
World currentWorld = /* current world context */;
Transform returnPoint = /* where players should go when they leave */;

// Spawn an instance named "Challenge_Combat_1"
World instanceWorld = InstancesPlugin.get()
    .spawnInstance("Challenge_Combat_1", currentWorld, returnPoint)
    .join();

Universe.get().sendMessage(Message.raw("Instance spawned: " + instanceWorld.getName()));
```

---

## Teleporting Players to Instances

The `InstancesPlugin` provides two approaches depending on whether the instance world is already loaded or still loading.

### Teleporting to an Active Instance

Use when the `World` object is already available (instance has finished loading).

```java
InstancesPlugin.teleportPlayerToInstance(
    playerRef,             // Ref<EntityStore> — the player's entity reference
    componentAccessor,     // EntityStore — the player's component accessor (store)
    instanceWorld,         // World — the target instance world
    null                   // Transform — optional override for return point (null to use original)
);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `playerRef` | `Ref<EntityStore>` | The player's entity reference |
| `componentAccessor` | `EntityStore` | The store/component accessor for the player |
| `instanceWorld` | `World` | The active instance world to teleport into |
| `overrideReturnPoint` | `Transform` | Optional override for the return point; pass `null` to use the one set during spawn |

### Teleporting to a Loading Instance

Use when you have a `CompletableFuture<World>` from `spawnInstance`. This queues the teleport to happen as soon as the world is ready.

```java
CompletableFuture<World> worldFuture = plugin.spawnInstance("Challenge_Combat_1", currentWorld, returnPoint);

InstancesPlugin.teleportPlayerToLoadingInstance(
    playerRef,             // Ref<EntityStore> — the player's entity reference
    componentAccessor,     // EntityStore — the player's component accessor (store)
    worldFuture,           // CompletableFuture<World> — future from spawnInstance
    null                   // Transform — optional override for return point (null to use original)
);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `playerRef` | `Ref<EntityStore>` | The player's entity reference |
| `componentAccessor` | `EntityStore` | The store/component accessor for the player |
| `worldFuture` | `CompletableFuture<World>` | The future returned by `spawnInstance` |
| `overrideReturnPoint` | `Transform` | Optional override for the return point; pass `null` to use the one set during spawn |

---

## Exiting Instances

Returns the player to their original world using the return point defined when the instance was created.

```java
InstancesPlugin.exitInstance(playerRef, componentAccessor);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `playerRef` | `Ref<EntityStore>` | The player's entity reference |
| `componentAccessor` | `EntityStore` | The store/component accessor for the player |

---

## Managing Instance Removal

Instances can be safely removed when no longer needed (e.g., when empty). Use `safeRemoveInstance` to cleanly shut down an instance world.

```java
InstancesPlugin.safeRemoveInstance(instanceWorld);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `instanceWorld` | `World` | The instance world to remove |

---

## Getting Player Ref and Store

In most contexts you need the player's `Ref<EntityStore>` and the `EntityStore`:

```java
// From a PlayerRef
PlayerRef playerRef = Universe.get().getPlayer(playerUUID);
Ref<EntityStore> ref = playerRef.getReference();
EntityStore store = playerRef.getReference().getStore();

// From a Player object (e.g., in a command)
Player player = (Player) ctx.sender();
Ref<EntityStore> ref = player.getReference();
EntityStore store = player.getReference().getStore();
```

### Getting a Return Point from Spawn Provider

```java
World world = Universe.get().getWorld(playerRef.getWorldUuid());
ISpawnProvider spawnProvider = world.getWorldConfig().getSpawnProvider();
Transform returnPoint = spawnProvider != null
    ? spawnProvider.getSpawnPoint(world, playerRef.getUuid())
    : new Transform();
```

---

## Command Examples

### Spawn Instance Command

```java
public class ExampleSpawnInstanceCommand extends CommandBase {
    private final RequiredArg<String> nameArg;

    public ExampleSpawnInstanceCommand() {
        super("spawninstance", "Spawns a new instance from a template");
        this.nameArg = this.withRequiredArg("name", "The name of the new instance", ArgTypes.STRING);
    }

    @Override
    protected void executeSync(@Nonnull CommandContext ctx) {
        UUID playerUUID = ctx.sender().getUuid();
        PlayerRef playerRef = Universe.get().getPlayer(playerUUID);
        World world = Universe.get().getWorld(playerRef.getWorldUuid());

        ISpawnProvider spawnProvider = world.getWorldConfig().getSpawnProvider();
        Transform returnPoint = spawnProvider != null
            ? spawnProvider.getSpawnPoint(world, playerRef.getUuid())
            : new Transform();

        world.execute(() -> {
            World instanceWorld = InstancesPlugin.get()
                .spawnInstance(this.nameArg.get(ctx), world, returnPoint)
                .join();
            Universe.get().sendMessage(
                Message.raw("Instance spawned: " + instanceWorld.getName())
            );
        });
    }
}
```

### Enter Instance Command

Spawns an instance and immediately teleports the player into it (using `teleportPlayerToLoadingInstance` so it works even before the world finishes loading):

```java
public class ExampleEnterInstanceCommand extends CommandBase {
    private final RequiredArg<String> nameArg;

    public ExampleEnterInstanceCommand() {
        super("enterinstance", "Spawns and enters an instance immediately");
        this.nameArg = this.withRequiredArg("name", "The name of the instance", ArgTypes.STRING);
    }

    @Override
    protected void executeSync(@Nonnull CommandContext ctx) {
        UUID playerUUID = ctx.sender().getUuid();
        PlayerRef playerRef = Universe.get().getPlayer(playerUUID);
        World world = Universe.get().getWorld(playerRef.getWorldUuid());

        ISpawnProvider spawnProvider = world.getWorldConfig().getSpawnProvider();
        Transform returnPoint = spawnProvider != null
            ? spawnProvider.getSpawnPoint(world, playerRef.getUuid())
            : new Transform();

        world.execute(() -> {
            CompletableFuture<World> worldFuture = InstancesPlugin.get()
                .spawnInstance(this.nameArg.get(ctx), world, returnPoint);

            InstancesPlugin.teleportPlayerToLoadingInstance(
                playerRef.getReference(),
                playerRef.getReference().getStore(),
                worldFuture,
                null
            );
        });
    }
}
```

### Exit Instance Command

```java
public class ExampleExitInstanceCommand extends CommandBase {
    public ExampleExitInstanceCommand() {
        super("exitinstance", "Exits the current instance and returns to the previous world");
    }

    @Override
    protected void executeSync(@Nonnull CommandContext ctx) {
        Player player = (Player) ctx.sender();
        World world = player.getWorld();

        world.execute(() -> {
            InstancesPlugin.exitInstance(
                player.getReference(),
                player.getReference().getStore()
            );
        });
    }
}
```

### Remove Instance Command

```java
public class ExampleRemoveInstanceCommand extends CommandBase {
    private final RequiredArg<String> worldArg;

    public ExampleRemoveInstanceCommand() {
        super("removeinstance", "Safely removes an instance");
        this.worldArg = this.withRequiredArg("world", "The world to remove", ArgTypes.STRING);
    }

    @Override
    protected void executeSync(@Nonnull CommandContext ctx) {
        String worldName = ctx.get(this.worldArg);
        World targetWorld = Universe.get().getWorld(worldName);

        if (targetWorld == null) {
            ctx.sendMessage(Message.raw("World not found: " + worldName));
            return;
        }

        targetWorld.execute(() -> {
            InstancesPlugin.safeRemoveInstance(targetWorld);
        });
    }
}
```

---

## Best Practices

1. **Always use `world.execute()`** — Instance operations must run within the world's execution context for thread safety.
2. **Prefer `teleportPlayerToLoadingInstance`** — When spawning and immediately entering, use the loading variant to avoid blocking on `.join()` before teleporting.
3. **Use spawn provider for return points** — Get the world's `ISpawnProvider` to calculate proper return positions rather than hardcoding coordinates.
4. **Clean up instances** — Call `safeRemoveInstance` when an instance is no longer needed to free resources.
5. **Null return point override** — Pass `null` for the override parameter when you want to use the return point set during `spawnInstance`.
6. **Instance templates** — Place templates under `Server/Instances/[Name]` with an `instance.bson` configuration file.
