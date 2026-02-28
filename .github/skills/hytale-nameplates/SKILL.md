---
name: hytale-nameplates
description: Documents how to set and modify entity nameplates in Hytale plugins. Covers the Nameplate component, system type selection (RefChangeSystem vs RefSystem), CommandBuffer visibility rules, and patterns for building rich NPC nameplates with quality, affixes, and level. Triggers - nameplate, Nameplate, NPC name, entity name, name above head, nameplate system, RefChangeSystem nameplate, display name, nameplate format, nameplate text.
---

# Hytale Nameplates Skill

Use this skill when creating or modifying the text displayed above entities (nameplates). This includes NPC names, quality badges, affix prefixes/suffixes, and level indicators.

> **Related skills:** `hytale-ecs` for ECS fundamentals, `hytale-text-holograms` for world-positioned floating text, `hytale-spawning-entities` for entity creation, `modding-doc-buff-display` for effect display patterns.

---

## Quick Reference

| Concept | Description |
|---------|-------------|
| **Nameplate** | Built-in component that displays text above an entity's head |
| **DisplayNameComponent** | Built-in component storing an entity's localized display name |
| **RefChangeSystem** | System type that fires AFTER a component is committed to the store |
| **RefSystem** | System type that fires during entity-add — components staged by other RefSystems are NOT yet visible |
| **CommandBuffer** | Handles deferred mutations; `getComponent()` reads from committed store only |

---

## Core API

### Nameplate Component

```java
// Package: com.hypixel.hytale.server.core.entity.nameplate.Nameplate
// Implements: Component<EntityStore>

// Get ComponentType (for store access)
ComponentType<EntityStore, Nameplate> nameplateComponentType = Nameplate.getComponentType();

// Create a new nameplate
Nameplate nameplate = new Nameplate("Spider Lv.5");

// Read text
String text = nameplate.getText();

// Set text (marks network state as dirty for client sync)
nameplate.setText("New Text");

// Check if client needs update
boolean dirty = nameplate.consumeNetworkOutdated();
```

The built-in `NameplateSystems.EntityTrackerUpdate` system reads dirty nameplates and sends updates to connected clients automatically.

### DisplayNameComponent

```java
// Package: com.hypixel.hytale.server.core.modules.entity.component.DisplayNameComponent

ComponentType<EntityStore, DisplayNameComponent> displayNameType = DisplayNameComponent.getComponentType();

DisplayNameComponent comp = commandBuffer.getComponent(ref, displayNameType);
if (comp != null) {
    Message displayName = comp.getDisplayName();
    String rawText = displayName.getRawText();
}
```

---

## CRITICAL: CommandBuffer Visibility Rules

This is the most important concept for nameplate systems and a common source of bugs.

### The `putComponent()` / `getComponent()` Asymmetry

```java
// putComponent() is DEFERRED — queued as a lambda, not applied immediately
commandBuffer.putComponent(ref, componentType, component);
// ↳ Internally: this.queue.add(chunk -> chunk.putComponent(...));

// getComponent() reads from the COMMITTED STORE, not the queue
T component = commandBuffer.getComponent(ref, componentType);
// ↳ Internally: return this.store.__internal_getComponent(ref, componentType);
```

**Consequence:** Components staged via `putComponent()` by one system are NOT visible to later systems via `getComponent()` until the CommandBuffer is consumed (flushed).

### When Are Buffers Consumed?

During entity-add, all `RefSystem.onEntityAdded()` calls are processed with the same CommandBuffer. The buffer is consumed **after all RefSystems complete** for that entity-add batch. This means:

- RefSystem A puts MonsterLevelComponent via `commandBuffer.putComponent()`
- RefSystem B (running after A) calls `commandBuffer.getComponent()` for MonsterLevelComponent
- **Result: null** — the component is queued but not yet committed

After the buffer is consumed:
- All queued `putComponent()` operations are applied to the store in FIFO order
- Each component commit triggers `RefChangeSystem` callbacks for that component type
- By this point, components from earlier queue entries are already committed

### System Type Selection Guide

| Use Case | System Type | Why |
|----------|-------------|-----|
| Need to read components staged by other entity-add systems | **RefChangeSystem** | Fires after buffer flush; all prior components are committed |
| Only need components from the entity's Holder (initial construction) | **RefSystem** | Holder components are committed when entity enters the store |
| React to a specific component being added/changed/removed | **RefChangeSystem** | Purpose-built for component lifecycle events |
| Need to run logic when any entity matching a query is added | **RefSystem** | General entity lifecycle |

### The Correct Pattern for Nameplates

**WRONG — RefSystem (components from other systems are invisible):**
```java
// ❌ This fails because MonsterLevelComponent was PUT by another RefSystem
//    but not yet committed to the store
public class NPCNameplateSystem extends RefSystem<EntityStore> {
    @Override
    public void onEntityAdded(Ref<EntityStore> ref, AddReason reason,
            Store<EntityStore> store, CommandBuffer<EntityStore> commandBuffer) {
        // Returns null — not committed yet!
        MonsterLevelComponent level = commandBuffer.getComponent(ref, levelComponentType);
    }
}
```

**CORRECT — RefChangeSystem (fires after buffer consumption):**
```java
// ✅ Triggers when HyforgedNPCQualityComponent is committed to the store.
//    By this point, MonsterLevelComponent (queued earlier) is already committed.
public class NPCNameplateSystem extends RefChangeSystem<EntityStore, HyforgedNPCQualityComponent> {
    
    @Nonnull
    @Override
    public ComponentType<EntityStore, HyforgedNPCQualityComponent> componentType() {
        return qualityComponentType;
    }
    
    @Override
    public void onComponentAdded(Ref<EntityStore> ref,
            HyforgedNPCQualityComponent component,
            Store<EntityStore> store, CommandBuffer<EntityStore> commandBuffer) {
        // Works — MonsterLevelComponent is committed before quality
        MonsterLevelComponent level = commandBuffer.getComponent(ref, levelComponentType);
        // level is non-null ✓
    }
}
```

### Why FIFO Queue Order Matters

Components are committed in the order their `putComponent()` calls were queued. Since RefSystems run in dependency order:

1. `HyforgedMonsterScalingSystem` → queues `putComponent(MonsterLevelComponent)` first
2. `NPCQualitySystem` → queues `putComponent(HyforgedNPCQualityComponent)` later

When the buffer is consumed:
1. MonsterLevelComponent is committed first → triggers its RefChangeSystems
2. HyforgedNPCQualityComponent is committed second → triggers its RefChangeSystems
3. When quality RefChangeSystem fires, level is already in the store ✓

---

## Implementation Patterns

### Pattern 1: Rich NPC Nameplate (Quality + Affixes + Level)

Use a RefChangeSystem on the quality component. When quality is assigned, all other NPC data (level, name) is already committed.

```java
public class NPCNameplateSystem extends RefChangeSystem<EntityStore, HyforgedNPCQualityComponent> {

    private final ComponentType<EntityStore, HyforgedNPCQualityComponent> qualityComponentType;
    private final ComponentType<EntityStore, NPCEntity> npcComponentType;
    private final ComponentType<EntityStore, MonsterLevelComponent> levelComponentType;
    private final ComponentType<EntityStore, Nameplate> nameplateComponentType;
    private final ComponentType<EntityStore, DisplayNameComponent> displayNameComponentType;
    private final Query<EntityStore> query;
    private final Set<Dependency<EntityStore>> dependencies;

    public NPCNameplateSystem() {
        HyforgedPlugin plugin = HyforgedPlugin.getInstance();
        this.qualityComponentType = plugin.getNpcQualityComponentType();
        this.npcComponentType = NPCEntity.getComponentType();
        this.levelComponentType = plugin.getMonsterLevelComponentType();
        this.nameplateComponentType = Nameplate.getComponentType();
        this.displayNameComponentType = DisplayNameComponent.getComponentType();
        this.query = qualityComponentType;
        this.dependencies = Set.of(
                new SystemDependency<>(Order.AFTER, NPCQualityAffixStatSystem.class)
        );
    }

    @Nonnull
    @Override
    public ComponentType<EntityStore, HyforgedNPCQualityComponent> componentType() {
        return qualityComponentType;
    }

    @Override
    public void onComponentAdded(Ref<EntityStore> ref,
            HyforgedNPCQualityComponent component,
            Store<EntityStore> store, CommandBuffer<EntityStore> commandBuffer) {
        updateNameplate(ref, component, commandBuffer);
    }

    @Override
    public void onComponentSet(Ref<EntityStore> ref,
            @Nullable HyforgedNPCQualityComponent previous,
            HyforgedNPCQualityComponent component,
            Store<EntityStore> store, CommandBuffer<EntityStore> commandBuffer) {
        updateNameplate(ref, component, commandBuffer);
    }

    @Override
    public void onComponentRemoved(Ref<EntityStore> ref,
            HyforgedNPCQualityComponent component,
            Store<EntityStore> store, CommandBuffer<EntityStore> commandBuffer) {
        // Reset nameplate to base name + level only
    }

    private void updateNameplate(Ref<EntityStore> ref,
            HyforgedNPCQualityComponent quality,
            CommandBuffer<EntityStore> commandBuffer) {
        NPCEntity npc = commandBuffer.getComponent(ref, npcComponentType);
        if (npc == null) return;

        String baseName = resolveBaseName(npc, ref, commandBuffer);
        MonsterLevelComponent levelComp = commandBuffer.getComponent(ref, levelComponentType);
        int level = (levelComp != null) ? levelComp.getLevel() : 0;

        String qualityId = quality.getQualityId();
        List<RolledAffix> affixes = quality.getAffixes();

        String text = buildNameplateText(qualityId, baseName, affixes, level);
        commandBuffer.putComponent(ref, nameplateComponentType, new Nameplate(text));
    }
}
```

### Pattern 2: Simple Level Nameplate

For entities with level but no quality system (e.g., passive mobs in scaled zones):

```java
public class LevelNameplateSystem extends RefChangeSystem<EntityStore, MonsterLevelComponent> {

    @Nonnull
    @Override
    public ComponentType<EntityStore, MonsterLevelComponent> componentType() {
        return levelComponentType;
    }

    @Override
    public void onComponentAdded(Ref<EntityStore> ref,
            MonsterLevelComponent component,
            Store<EntityStore> store, CommandBuffer<EntityStore> commandBuffer) {
        NPCEntity npc = commandBuffer.getComponent(ref, npcComponentType);
        if (npc == null) return;

        String baseName = formatRoleName(npc.getRoleName());
        int level = component.getLevel();
        String text = baseName + (level > 0 ? " Lv." + level : "");
        commandBuffer.putComponent(ref, nameplateComponentType, new Nameplate(text));
    }
}
```

### Pattern 3: Simple Static Nameplate on Spawn

If you only need a nameplate set once from data available on the Holder (no cross-system dependencies), a RefSystem works:

```java
public class StaticNameplateSystem extends RefSystem<EntityStore> {

    @Override
    public void onEntityAdded(Ref<EntityStore> ref, AddReason reason,
            Store<EntityStore> store, CommandBuffer<EntityStore> commandBuffer) {
        // Only reads NPCEntity — which is on the Holder and already committed
        NPCEntity npc = commandBuffer.getComponent(ref, npcComponentType);
        if (npc == null) return;

        String name = npc.getRoleName().replace('_', ' ');
        commandBuffer.putComponent(ref, nameplateComponentType, new Nameplate(name));
    }
}
```

---

## Nameplate Text Formatting

### Format Convention

```
[Quality] {Prefix} BaseName {Suffix} Lv.X
```

| Part | Example | When Shown |
|------|---------|------------|
| Quality badge | `[Rare]` | Non-Common quality |
| Prefix affixes | `Burning` | Has prefix-type affixes |
| Base name | `Spider` | Always |
| Suffix affixes | `of Thunder` | Has suffix-type affixes |
| Level | `Lv.15` | Level > 0 |

### Full Examples

| Quality | Affixes | Level | Output |
|---------|---------|-------|--------|
| Common | None | 5 | `Spider Lv.5` |
| Rare | None | 15 | `[Rare] Spider Lv.15` |
| Epic | Burning (prefix) | 22 | `[Epic] Burning Spider Lv.22` |
| Legendary | Burning (prefix), of Thunder (suffix) | 30 | `[Legendary] Burning Spider of Thunder Lv.30` |

### Name Resolution Priority

1. `DisplayNameComponent.getDisplayName().getRawText()` — localized display name
2. `NPCEntity.getRoleName()` with underscore-to-space formatting — fallback

Do NOT read the existing `Nameplate` text as a fallback for base name resolution — this creates circular dependency if the nameplate was previously set by your own system.

---

## Registration

Register in `HyforgedPlugin.start()` after the quality and affix systems:

```java
entityStoreRegistry.registerSystem(new NPCNameplateSystem());
```

The system's `getDependencies()` handles ordering (AFTER NPCQualityAffixStatSystem).

---

## Debugging Tips

1. **Nameplate shows only base name (no level/quality):** Your system is likely a RefSystem, not a RefChangeSystem. Components from other systems won't be visible during entity-add.

2. **Level shows as 0:** Check that `HyforgedMonsterScalingSystem` runs before the system that puts the trigger component. Verify the NPC's zone has scaling configured.

3. **Quality is null/empty:** The NPC's role name may not match any `AppliesTo` group in the quality rules. Check `NPCQualityRegistry.resolveRuleForRole()`.

4. **Nameplate doesn't update after quality changes:** Ensure both `onComponentAdded` and `onComponentSet` call the update logic. `onComponentSet` fires when a component is replaced (not just first-time added).

5. **Client doesn't see updated text:** The `Nameplate.setText()` method marks the network state as dirty. The built-in `NameplateSystems.EntityTrackerUpdate` syncs changes. If using `commandBuffer.putComponent()` to replace the entire Nameplate, the new component starts with a dirty flag.
