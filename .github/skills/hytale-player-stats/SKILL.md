---
name: hytale-player-stats
description: Documents Hytale's player/entity stat system for reading and modifying stats like health, stamina, mana, oxygen, signature energy, and ammo using EntityStatMap and DefaultEntityStatTypes. Use when healing players, dealing damage, modifying stamina/mana, setting stat values, creating stat-related commands, or working with entity stats. Triggers - player stats, health, stamina, mana, oxygen, ammo, signature energy, EntityStatMap, DefaultEntityStatTypes, stat value, heal, damage, maximizeStatValue, subtractStatValue, addStatValue, setStatValue, resetStatValue, entity stats.
---

# Hytale Player Stats

Use this skill when reading or modifying player/entity stats (health, stamina, mana, etc.) in Hytale plugins. Stats are managed through the `EntityStatMap` component and accessed via `DefaultEntityStatTypes`.

> **Source:** <https://hytalemodding.dev/en/docs/guides/plugin/player-stats>

---

## Quick Reference

| Task | Code |
|------|------|
| Get stat map component | `store.getComponent(playerRef, EntityStatMap.getComponentType())` |
| Set a stat value | `statMap.setStatValue(statIndex, value)` |
| Add to a stat | `statMap.addStatValue(statIndex, amount)` |
| Subtract from a stat | `statMap.subtractStatValue(statIndex, amount)` |
| Maximize a stat (full restore) | `statMap.maximizeStatValue(statIndex)` |
| Reset a stat | `statMap.resetStatValue(statIndex)` |

---

## Available Stats

Hytale provides default stats via `DefaultEntityStatTypes`:

| Stat | Accessor |
|------|----------|
| Health | `DefaultEntityStatTypes.getHealth()` |
| Stamina | `DefaultEntityStatTypes.getStamina()` |
| Mana | `DefaultEntityStatTypes.getMana()` |
| Oxygen | `DefaultEntityStatTypes.getOxygen()` |
| Signature Energy | `DefaultEntityStatTypes.getSignatureEnergy()` |
| Ammo | `DefaultEntityStatTypes.getAmmo()` |

---

## Key Concepts

### EntityStatMap

`EntityStatMap` is an ECS component that holds all stat values for an entity. Retrieve it from the store:

```java
EntityStatMap statMap = (EntityStatMap) store.getComponent(playerRef, EntityStatMap.getComponentType());
```

### World Thread Safety

All stat modifications **must** be performed on the world thread using `world.execute(() -> { ... })` to ensure thread safety.

### Stat Indices

Each stat type (e.g., `DefaultEntityStatTypes.getHealth()`) returns a stat index used by `EntityStatMap` methods. Pass these indices to set/add/subtract/maximize/reset operations.

---

## Required Imports

```java
import com.hypixel.hytale.server.ecs.entity.component.stats.EntityStatMap;
import com.hypixel.hytale.server.ecs.entity.component.stats.DefaultEntityStatTypes;
import com.hypixel.hytale.server.world.World;
import com.hypixel.hytale.server.core.Message;
import com.hypixel.server.ecs.store.EntityStore;
import com.hypixel.server.ecs.store.Ref;
import com.hypixel.server.ecs.store.Store;
```

---

## EntityStatMap Methods

| Method | Description |
|--------|-------------|
| `setStatValue(statIndex, value)` | Sets the stat to an exact value |
| `addStatValue(statIndex, amount)` | Adds to the current stat value |
| `subtractStatValue(statIndex, amount)` | Subtracts from the current stat value |
| `maximizeStatValue(statIndex)` | Restores the stat to its maximum value |
| `resetStatValue(statIndex)` | Resets the stat to its default value |

---

## Access Pattern

The standard pattern for accessing and modifying stats:

```java
// 1. Get the player reference
Ref<EntityStore> playerRef = /* obtain player ref */;

// 2. Get the store and world
Store<EntityStore> store = playerRef.getStore();
EntityStore entityStore = store.getExternalData();
World world = entityStore.getWorld();

// 3. Modify on the world thread
world.execute(() -> {
    EntityStatMap statMap = (EntityStatMap) store.getComponent(playerRef, EntityStatMap.getComponentType());
    if (statMap != null) {
        // Perform stat operations here
    }
});
```

---

## Example: Heal Command

Restores the player's health to its maximum value.

```java
public class HealCommand extends CommandBase {
    public HealCommand() {
        super("heal", "Restores your health to maximum.");
        this.setPermissionGroup(GameMode.Adventure);
    }

    @Override
    protected void executeSync(@Nonnull CommandContext ctx) {
        // 1. Get the player reference
        Ref<EntityStore> playerRef = ctx.senderAsPlayerRef();
        if (playerRef == null) return;

        // 2. Get the store and the world
        Store<EntityStore> store = playerRef.getStore();
        EntityStore entityStore = store.getExternalData();
        World world = entityStore.getWorld();

        // 3. Perform modification on the world thread
        world.execute(() -> {
            EntityStatMap statMap = (EntityStatMap) store.getComponent(playerRef, EntityStatMap.getComponentType());
            if (statMap != null) {
                statMap.maximizeStatValue(DefaultEntityStatTypes.getHealth());
                ctx.sendMessage(Message.raw("Your health has been restored!"));
            }
        });
    }
}
```

---

## Example: Damage Self Command

Removes a specified amount of health from the player.

```java
public class DamageSelfCommand extends CommandBase {
    private final Argument amountArg;

    public DamageSelfCommand() {
        super("damageself", "Damages yourself by a specific amount.");
        this.setPermissionGroup(GameMode.Adventure);
        this.amountArg = this.withRequiredArg("amount", "Amount of damage", ArgTypes.FLOAT);
    }

    @Override
    protected void executeSync(@Nonnull CommandContext ctx) {
        // 1. Get the player reference
        Ref<EntityStore> playerRef = ctx.senderAsPlayerRef();
        if (playerRef == null) return;

        // 2. Get command arg
        Float amount = (Float) this.amountArg.get(ctx);
        if (amount == null) return;

        // 3. Get the store and the world
        Store<EntityStore> store = playerRef.getStore();
        EntityStore entityStore = store.getExternalData();
        World world = entityStore.getWorld();

        // 4. Perform modification on the world thread
        world.execute(() -> {
            EntityStatMap statMap = (EntityStatMap) store.getComponent(playerRef, EntityStatMap.getComponentType());
            if (statMap != null) {
                statMap.subtractStatValue(DefaultEntityStatTypes.getHealth(), amount);
                ctx.sendMessage(Message.raw("Ouch! You took " + amount + " damage."));
            }
        });
    }
}
```

---

## Common Patterns

### Restore All Stats

```java
world.execute(() -> {
    EntityStatMap statMap = (EntityStatMap) store.getComponent(playerRef, EntityStatMap.getComponentType());
    if (statMap != null) {
        statMap.maximizeStatValue(DefaultEntityStatTypes.getHealth());
        statMap.maximizeStatValue(DefaultEntityStatTypes.getStamina());
        statMap.maximizeStatValue(DefaultEntityStatTypes.getMana());
        statMap.maximizeStatValue(DefaultEntityStatTypes.getOxygen());
    }
});
```

### Set Stat to Specific Value

```java
world.execute(() -> {
    EntityStatMap statMap = (EntityStatMap) store.getComponent(playerRef, EntityStatMap.getComponentType());
    if (statMap != null) {
        statMap.setStatValue(DefaultEntityStatTypes.getHealth(), 50.0f);
    }
});
```

### Add to a Stat (Partial Heal)

```java
world.execute(() -> {
    EntityStatMap statMap = (EntityStatMap) store.getComponent(playerRef, EntityStatMap.getComponentType());
    if (statMap != null) {
        statMap.addStatValue(DefaultEntityStatTypes.getHealth(), 20.0f);
    }
});
```

---

## Important Notes

- Always null-check `playerRef` and `statMap` before use.
- Always wrap stat modifications in `world.execute(() -> { ... })` for thread safety.
- `maximizeStatValue` restores to the entity's configured maximum, not a hardcoded value.
- These APIs work on any entity with an `EntityStatMap` component, not just players.
