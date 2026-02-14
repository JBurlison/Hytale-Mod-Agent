---
name: hytale-text-holograms
description: Creates floating text holograms in Hytale plugins using invisible entities with nameplates. Use when displaying floating text, title holograms, labels above locations, NPC names, or any world-positioned text displays. Triggers - hologram, text hologram, nameplate, floating text, title hologram, Nameplate, world label, entity nameplate, hovering text.
---

# Hytale Text Holograms Skill

Use this skill when creating floating text displays (holograms) in the world. Holograms are invisible entities with a `Nameplate` component that displays text above them.

---

## Quick Reference

| Concept | Description |
|---------|-------------|
| **Nameplate** | Component that displays text above an entity |
| **ProjectileComponent** | Used as an invisible entity shell for the hologram |
| **TransformComponent** | Positions the hologram in the world |
| **NetworkId** | Required for client-side synchronization |
| **UUIDComponent** | Gives the entity a unique identity |
| **Holder** | Used to stage components before spawning |

---

## How It Works

Text holograms work by spawning an invisible entity (using a `ProjectileComponent` as a shell) and attaching a `Nameplate` component to display floating text. The entity is invisible but the nameplate renders as floating text in the world.

---

## Required Imports

```java
import com.hypixel.hytale.component.Holder;
import com.hypixel.hytale.math.vector.Transform;
import com.hypixel.hytale.math.vector.Vec3d;
import com.hypixel.hytale.math.vector.Vec4f;
import com.hypixel.hytale.server.core.entity.UUIDComponent;
import com.hypixel.hytale.server.core.entity.entities.ProjectileComponent;
import com.hypixel.hytale.server.core.entity.nameplate.Nameplate;
import com.hypixel.hytale.server.core.modules.entity.component.TransformComponent;
import com.hypixel.hytale.server.core.modules.entity.tracker.NetworkId;
import com.hypixel.hytale.server.core.universe.PlayerRef;
import com.hypixel.hytale.server.core.universe.Universe;
import com.hypixel.hytale.server.core.universe.world.World;
import com.hypixel.hytale.server.core.universe.world.storage.EntityStore;
```

---

## Step-by-Step Process

### 1. Get World Reference

All entity operations must run on the world thread. First, obtain the world where the hologram will spawn:

```java
// From a player context
UUID playerUUID = ctx.sender().getUuid();
PlayerRef playerRef = Universe.get().getPlayer(playerUUID);
World world = Universe.get().getWorld(playerRef.getWorldUuid());
Transform playerTransform = playerRef.getTransform();
```

### 2. Execute on World Thread

Entity operations must run on the world thread:

```java
world.execute(() -> {
    // All hologram creation code goes here
});
```

### 3. Create Entity Holder

Create a holder to stage components before spawning:

```java
Holder<EntityStore> holder = EntityStore.REGISTRY.newHolder();
```

### 4. Create Projectile Component (Entity Shell)

The projectile provides a valid entity shell. It won't move or behave like a real projectile:

```java
ProjectileComponent projectileComponent = new ProjectileComponent("Projectile");
```

### 5. Add Position and Identity Components

| Component | Purpose |
|-----------|---------|
| `ProjectileComponent` | Provides a valid entity shell |
| `TransformComponent` | Sets the entity's position and rotation |
| `UUIDComponent` | Gives the entity a unique identity |

```java
holder.putComponent(ProjectileComponent.getComponentType(), projectileComponent);
holder.putComponent(
    TransformComponent.getComponentType(), 
    new TransformComponent(
        playerTransform.getPosition().clone(), 
        playerTransform.getRotation().clone()
    )
);
holder.ensureComponent(UUIDComponent.getComponentType());
```

### 6. Initialize the Projectile

Ensure the projectile entity is fully created before proceeding:

```java
if (projectileComponent.getProjectile() == null) {
    projectileComponent.initialize();
    if (projectileComponent.getProjectile() == null) {
        return; // Initialization failed
    }
}
```

### 7. Add Network and Nameplate Components

| Component | Purpose |
|-----------|---------|
| `NetworkId` | Allows the entity to be synced to clients |
| `Nameplate` | The actual hologram text displayed |

```java
holder.addComponent(
    NetworkId.getComponentType(),
    new NetworkId(
        world.getEntityStore()
            .getStore()
            .getExternalData()
            .takeNextNetworkId()
    )
);

holder.addComponent(
    Nameplate.getComponentType(),
    new Nameplate("Your Hologram Text Here")
);
```

### 8. Spawn the Entity

Insert the hologram entity into the world:

```java
world.getEntityStore()
    .getStore()
    .addEntity(holder, com.hypixel.hytale.component.AddReason.SPAWN);
```

---

## Complete Example - Hologram Command

```java
package org.example.plugin;

import com.hypixel.hytale.component.Holder;
import com.hypixel.hytale.math.vector.Transform;
import com.hypixel.hytale.server.core.command.system.CommandContext;
import com.hypixel.hytale.server.core.command.system.basecommands.CommandBase;
import com.hypixel.hytale.server.core.entity.UUIDComponent;
import com.hypixel.hytale.server.core.entity.entities.ProjectileComponent;
import com.hypixel.hytale.server.core.entity.nameplate.Nameplate;
import com.hypixel.hytale.server.core.modules.entity.component.TransformComponent;
import com.hypixel.hytale.server.core.modules.entity.tracker.NetworkId;
import com.hypixel.hytale.server.core.universe.PlayerRef;
import com.hypixel.hytale.server.core.universe.Universe;
import com.hypixel.hytale.server.core.universe.world.World;
import com.hypixel.hytale.server.core.universe.world.storage.EntityStore;

import javax.annotation.Nonnull;
import java.util.UUID;

public class TitleHologramCommand extends CommandBase {

    public TitleHologramCommand() {
        super("TitleHologram", "Create a title hologram.");
    }

    @Override
    protected void executeSync(@Nonnull CommandContext ctx) {
        UUID playerUUID = ctx.sender().getUuid();
        PlayerRef playerRef = Universe.get().getPlayer(playerUUID);
        World world = Universe.get().getWorld(playerRef.getWorldUuid());
        Transform playerTransform = playerRef.getTransform();

        world.execute(() -> {
            Holder<EntityStore> holder = EntityStore.REGISTRY.newHolder();
            ProjectileComponent projectileComponent = new ProjectileComponent("Projectile");

            holder.putComponent(ProjectileComponent.getComponentType(), projectileComponent);
            holder.putComponent(
                TransformComponent.getComponentType(), 
                new TransformComponent(
                    playerTransform.getPosition().clone(), 
                    playerTransform.getRotation().clone()
                )
            );
            holder.ensureComponent(UUIDComponent.getComponentType());

            if (projectileComponent.getProjectile() == null) {
                projectileComponent.initialize();
                if (projectileComponent.getProjectile() == null) {
                    return;
                }
            }

            holder.addComponent(
                NetworkId.getComponentType(),
                new NetworkId(
                    world.getEntityStore()
                        .getStore()
                        .getExternalData()
                        .takeNextNetworkId()
                )
            );
            
            holder.addComponent(
                Nameplate.getComponentType(),
                new Nameplate("Testing Holograms")
            );

            world.getEntityStore()
                .getStore()
                .addEntity(holder, com.hypixel.hytale.component.AddReason.SPAWN);
        });
    }
}
```

---

## Spawning at Custom Position

To spawn a hologram at a specific position instead of the player's location:

```java
Vec3d position = new Vec3d(100.0, 65.0, 200.0);
Vec4f rotation = new Vec4f(0, 0, 0, 1); // Identity quaternion

holder.putComponent(
    TransformComponent.getComponentType(), 
    new TransformComponent(position, rotation)
);
```

---

## Utility Method Example

Create a reusable utility method for spawning holograms:

```java
public static void spawnHologram(World world, Vec3d position, String text) {
    world.execute(() -> {
        Holder<EntityStore> holder = EntityStore.REGISTRY.newHolder();
        ProjectileComponent projectileComponent = new ProjectileComponent("Projectile");

        holder.putComponent(ProjectileComponent.getComponentType(), projectileComponent);
        holder.putComponent(
            TransformComponent.getComponentType(), 
            new TransformComponent(position.clone(), new Vec4f(0, 0, 0, 1))
        );
        holder.ensureComponent(UUIDComponent.getComponentType());

        if (projectileComponent.getProjectile() == null) {
            projectileComponent.initialize();
            if (projectileComponent.getProjectile() == null) {
                return;
            }
        }

        holder.addComponent(
            NetworkId.getComponentType(),
            new NetworkId(
                world.getEntityStore()
                    .getStore()
                    .getExternalData()
                    .takeNextNetworkId()
            )
        );
        
        holder.addComponent(
            Nameplate.getComponentType(),
            new Nameplate(text)
        );

        world.getEntityStore()
            .getStore()
            .addEntity(holder, com.hypixel.hytale.component.AddReason.SPAWN);
    });
}
```

---

## Key Points

1. **World Thread Required**: All entity operations must run inside `world.execute(() -> { ... })`
2. **ProjectileComponent**: Used as an invisible shell - it won't move or behave like a projectile
3. **NetworkId Required**: Without this, the hologram won't sync to clients
4. **UUIDComponent Required**: Provides unique entity identity
5. **Initialize Projectile**: Must call `projectileComponent.initialize()` before spawning
6. **Nameplate Text**: The text passed to `new Nameplate(text)` will be displayed as floating text

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Hologram not visible | Ensure `NetworkId` component is added |
| Entity not spawning | Check that `projectileComponent.initialize()` succeeded |
| Wrong position | Verify `TransformComponent` has correct coordinates |
| Crashes on spawn | Ensure code runs inside `world.execute()` |

---

## Credits

Thanks to Al3xWarrior and Quito on Discord for initially discovering this feature, and Elie for the initial code snippet.

---

## Reference

- Source: [Hytale Modding - Text Hologram Guide](https://hytalemodding.dev/en/docs/guides/plugin/text-hologram)
