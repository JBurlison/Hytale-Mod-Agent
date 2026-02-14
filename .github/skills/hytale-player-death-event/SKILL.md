---
name: hytale-player-death-event
description: Documents how to detect and react to player death in Hytale plugins using DeathSystems.OnDeathSystem. Use when handling player death, reading death cause/damage, broadcasting death messages, or building respawn logic. Triggers - death, player death, OnDeathSystem, DeathSystems, DeathComponent, death event, death handler, death info, death damage, death cause, respawn, kill feed, death message.
---

# Hytale Player Death Event

Use this skill when reacting to player (or entity) death in a Hytale plugin. Death detection uses the ECS `RefChangeSystem` pattern — specifically `DeathSystems.OnDeathSystem` — which fires when a `DeathComponent` is added to an entity.

> **Source:** <https://hytalemodding.dev/en/docs/guides/plugin/player-death-event>
>
> **Related skills:** `hytale-events` (general event system), `hytale-ecs` (ECS fundamentals), `hytale-entity-effects` (effects/damage pipeline).

---

## Quick Reference

| Task | Approach |
|------|----------|
| Detect player death | Extend `DeathSystems.OnDeathSystem`, query for `Player` |
| Get the player who died | `store.getComponent(ref, Player.getComponentType())` |
| Get death damage info | `component.getDeathInfo()` → `Damage` |
| Get damage amount | `deathInfo.getAmount()` |
| Broadcast a death message | `Universe.get().sendMessage(Message.raw(...))` |
| Register the system | `getEntityStoreRegistry().registerSystem(...)` in `start()` |

---

## How It Works

1. When an entity's health reaches zero, the damage pipeline attaches a `DeathComponent` to the entity.
2. Any system extending `DeathSystems.OnDeathSystem` whose `getQuery()` matches the entity is notified via `onComponentAdded`.
3. The `DeathComponent` carries a `Damage` object with information about the killing blow (amount, source, etc.).

This is a `RefChangeSystem` — it reacts to component lifecycle changes, not tick-based updates.

---

## Required Imports

```java
import com.hypixel.hytale.component.CommandBuffer;
import com.hypixel.hytale.component.Ref;
import com.hypixel.hytale.component.Store;
import com.hypixel.hytale.component.query.Query;
import com.hypixel.hytale.server.core.Message;
import com.hypixel.hytale.server.core.entity.entities.Player;
import com.hypixel.hytale.server.core.modules.entity.damage.Damage;
import com.hypixel.hytale.server.core.modules.entity.damage.DeathComponent;
import com.hypixel.hytale.server.core.modules.entity.damage.DeathSystems;
import com.hypixel.hytale.server.core.universe.Universe;
import com.hypixel.hytale.server.core.universe.world.storage.EntityStore;
import javax.annotation.Nonnull;
```

---

## Step-by-Step

### 1. Create a class extending `DeathSystems.OnDeathSystem`

```java
public class PlayerDeathHandler extends DeathSystems.OnDeathSystem {
```

`OnDeathSystem` is a specialised `RefChangeSystem` that listens for `DeathComponent` additions.

### 2. Define which entities to watch with `getQuery()`

```java
@Nonnull
@Override
public Query<EntityStore> getQuery() {
    return Query.and(Player.getComponentType());
}
```

`Query.and(Player.getComponentType())` ensures only entities that have a `Player` component trigger this system. You can combine multiple component types to narrow the filter further.

### 3. Override `onComponentAdded` to handle the death

```java
@Override
public void onComponentAdded(
        @Nonnull Ref ref,
        @Nonnull DeathComponent component,
        @Nonnull Store store,
        @Nonnull CommandBuffer commandBuffer) {

    Player playerComponent = (Player) store.getComponent(ref, Player.getComponentType());
    assert playerComponent != null;

    // React to the death
    Universe.get().sendMessage(
        Message.raw("Player died: " + playerComponent.getDisplayName()));

    // Access death damage info
    Damage deathInfo = component.getDeathInfo();
    if (deathInfo != null) {
        Universe.get().sendMessage(
            Message.raw("Damage amount: " + deathInfo.getAmount()));
    }
}
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `ref` | `Ref` | Handle to the entity that died |
| `component` | `DeathComponent` | Contains death cause info via `getDeathInfo()` |
| `store` | `Store` | ECS store for looking up other components on the entity |
| `commandBuffer` | `CommandBuffer` | Buffer for queuing entity/component mutations |

### 4. Register the system in your plugin's `start()` method

```java
@Override
protected void start() {
    this.getEntityStoreRegistry().registerSystem(new PlayerDeathHandler());
}
```

Death systems are registered the same way as any other ECS system — via `getEntityStoreRegistry().registerSystem()` in the plugin's `start()` lifecycle method.

---

## Complete Example

```java
package com.example.plugin.systems;

import com.hypixel.hytale.component.CommandBuffer;
import com.hypixel.hytale.component.Ref;
import com.hypixel.hytale.component.Store;
import com.hypixel.hytale.component.query.Query;
import com.hypixel.hytale.server.core.Message;
import com.hypixel.hytale.server.core.entity.entities.Player;
import com.hypixel.hytale.server.core.modules.entity.damage.Damage;
import com.hypixel.hytale.server.core.modules.entity.damage.DeathComponent;
import com.hypixel.hytale.server.core.modules.entity.damage.DeathSystems;
import com.hypixel.hytale.server.core.universe.Universe;
import com.hypixel.hytale.server.core.universe.world.storage.EntityStore;
import javax.annotation.Nonnull;

public class PlayerDeathHandler extends DeathSystems.OnDeathSystem {

    @Nonnull
    @Override
    public Query<EntityStore> getQuery() {
        return Query.and(Player.getComponentType());
    }

    @Override
    public void onComponentAdded(
            @Nonnull Ref ref,
            @Nonnull DeathComponent component,
            @Nonnull Store store,
            @Nonnull CommandBuffer commandBuffer) {

        Player playerComponent = (Player) store.getComponent(ref, Player.getComponentType());
        assert playerComponent != null;

        Universe.get().sendMessage(
            Message.raw("Player died: " + playerComponent.getDisplayName()));

        Damage deathInfo = component.getDeathInfo();
        if (deathInfo != null) {
            Universe.get().sendMessage(
                Message.raw("Damage amount: " + deathInfo.getAmount()));
        }
    }
}
```

---

## Tips

- **Null-check `getDeathInfo()`** — it can be `null` if the entity was removed without going through the damage pipeline (e.g., `/kill` or direct removal).
- **Use `Query.and(...)` with multiple component types** to restrict death handling to specific entity subsets (e.g., players with a certain custom component).
- **Exclude dead entities from other systems** by adding `Query.not(DeathComponent.getComponentType())` to their queries so they stop processing dead entities immediately.
- **Use `CommandBuffer`** (not direct store mutation) if you need to add/remove components in response to a death — this ensures thread safety and proper ordering.
- **Localize death messages** using `Message.translation(...)` instead of `Message.raw(...)` for user-facing text.

---

## Key Classes

| Class | Package | Purpose |
|-------|---------|---------|
| `DeathSystems.OnDeathSystem` | `...modules.entity.damage` | Base class for death-reaction systems |
| `DeathComponent` | `...modules.entity.damage` | Component added on death; carries `Damage` info |
| `Damage` | `...modules.entity.damage` | Death cause data (amount, source) |
| `Player` | `...core.entity.entities` | Player component for identity/display name |
| `Query` | `...component.query` | Entity filter for system targeting |
| `Store` | `...component` | ECS data store for component lookups |
| `CommandBuffer` | `...component` | Thread-safe mutation buffer |
