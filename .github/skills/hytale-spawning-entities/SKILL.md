---
name: hytale-spawning-entities
description: Spawns visible entities with models in Hytale plugins using Holder, ModelAsset, and Store. Use when spawning entities, creating model-based entities, placing entities in the world, or making entities persist across saves. Triggers - spawn entity, entity spawn, ModelAsset, Model, PersistentModel, ModelComponent, BoundingBox, Holder, addEntity, AddReason, SPAWN, createScaledModel, Interactable, Interactions, PropComponent, HolderSystem, visible entity, world.execute, entity model.
---

# Hytale Spawning Entities

Use this skill when spawning visible, model-based entities in the world. Covers getting the World, creating entity Holders, attaching models, adding all required components, spawning, and persisting entities across server saves.

> **Related skills:** For ECS fundamentals (Components, Systems, Queries), see `hytale-ecs`. For invisible text-only entities, see `hytale-text-holograms`. For NPC spawning helpers, see the [Spawning NPCs guide](https://hytalemodding.dev/en/docs/guides/plugin/spawning-npcs).

---

## Quick Reference

| Task | Approach |
|------|----------|
| Get World from player | `player.getWorld()` |
| Get World by UUID | `Universe.get().getWorld("uuid")` |
| Get entity store | `world.getEntityStore().getStore()` |
| Create entity holder | `EntityStore.REGISTRY.newHolder()` |
| Get a model asset | `ModelAsset.getAssetMap().getAsset("EntityName")` |
| Create scaled model | `Model.createScaledModel(modelAsset, scale)` |
| Set entity position | `new TransformComponent(position, rotation)` |
| Get position from player | `store.getComponent(playerRef.getReference(), EntityModule.get().getTransformComponentType())` |
| Add entity to world | `store.addEntity(holder, AddReason.SPAWN)` |
| Run on world thread | `world.execute(() -> { ... })` |

---

## Prerequisites

Familiarize yourself with Hytale's Entity Component System (ECS) before proceeding. See the `hytale-ecs` skill for full reference.

Your plugin `manifest.json` must declare these dependencies:

```json
{
  "dependencies": ["Hytale:EntityModule", "Hytale:BlockModule"]
}
```

---

## Step-by-Step: Spawning an Entity

### 1. Get the World Object

You can retrieve the `World` from a player or by UUID:

```java
// From a Player object
World world = player.getWorld();

// From Universe by world UUID
World world = Universe.get().getWorld("your-world-uuid");
```

### 2. Get the EntityStore

```java
Store<EntityStore> store = world.getEntityStore().getStore();
```

### 3. Execute on World Thread

**All entity mutations must run on the world thread.** Use `world.execute()`:

```java
world.execute(() -> {
    // All entity creation and spawning code goes here
});
```

### 4. Create a Holder

A `Holder` is a staging buffer — you assemble all components on it, then add the complete entity to the store.

```java
Holder<EntityStore> holder = EntityStore.REGISTRY.newHolder();
```

### 5. Get a Model

Look up a model by its asset name (see [entity list](https://hytalemodding.dev/en/docs/server/entities) for available names):

```java
ModelAsset modelAsset = ModelAsset.getAssetMap().getAsset("Minecart");
Model model = Model.createScaledModel(modelAsset, 1.0f);
```

### 6. Create a TransformComponent (Position)

Choose one of these approaches:

**From a player's current position:**

```java
// Get the player's Ref first
Ref<EntityStore> playerRef = /* player's entity ref */;
TransformComponent transform = store.getComponent(
    playerRef.getReference(),
    EntityModule.get().getTransformComponentType()
);
```

**From explicit coordinates:**

```java
Vector3d position = new Vector3d(0, 0, 0);   // world position
Vector3f rotation = new Vector3f(0, 0, 0);   // rotation
TransformComponent transform = new TransformComponent(position, rotation);
```

### 7. Add Components to the Holder

Add the core visual and identity components:

```java
// Position
holder.addComponent(
    TransformComponent.getComponentType(),
    new TransformComponent(position, new Vector3f(0, 0, 0))
);

// Model (visual appearance)
holder.addComponent(
    PersistentModel.getComponentType(),
    new PersistentModel(model.toReference())
);
holder.addComponent(
    ModelComponent.getComponentType(),
    new ModelComponent(model)
);

// Collision bounds
holder.addComponent(
    BoundingBox.getComponentType(),
    new BoundingBox(model.getBoundingBox())
);

// Network sync (required for clients to see the entity)
holder.addComponent(
    NetworkId.getComponentType(),
    new NetworkId(store.getExternalData().takeNextNetworkId())
);

// Interactions (needed if entity should be interactable)
holder.addComponent(
    Interactions.getComponentType(),
    new Interactions()
);
```

### 8. Ensure Required Base Components

Hytale expects certain "default" components on all entities:

```java
holder.ensureComponent(UUIDComponent.getComponentType());
holder.ensureComponent(Interactable.getComponentType()); // if interactable
```

### 9. Spawn the Entity

```java
store.addEntity(holder, AddReason.SPAWN);
```

---

## Complete Example

```java
world.execute(() -> {
    Store<EntityStore> store = world.getEntityStore().getStore();
    Holder<EntityStore> holder = EntityStore.REGISTRY.newHolder();

    // Model
    ModelAsset modelAsset = ModelAsset.getAssetMap().getAsset("Minecart");
    Model model = Model.createScaledModel(modelAsset, 1.0f);

    // Position
    Vector3d position = new Vector3d(100, 65, 200);

    // Add components
    holder.addComponent(
        TransformComponent.getComponentType(),
        new TransformComponent(position, new Vector3f(0, 0, 0))
    );
    holder.addComponent(
        PersistentModel.getComponentType(),
        new PersistentModel(model.toReference())
    );
    holder.addComponent(
        ModelComponent.getComponentType(),
        new ModelComponent(model)
    );
    holder.addComponent(
        BoundingBox.getComponentType(),
        new BoundingBox(model.getBoundingBox())
    );
    holder.addComponent(
        NetworkId.getComponentType(),
        new NetworkId(store.getExternalData().takeNextNetworkId())
    );
    holder.addComponent(
        Interactions.getComponentType(),
        new Interactions()
    );

    // Base components
    holder.ensureComponent(UUIDComponent.getComponentType());
    holder.ensureComponent(Interactable.getComponentType());

    // Spawn
    store.addEntity(holder, AddReason.SPAWN);
});
```

---

## Required Components Summary

| Component | Purpose | Required? |
|-----------|---------|-----------|
| `TransformComponent` | Position and rotation in the world | Yes |
| `PersistentModel` | Model reference for serialization/persistence | Yes |
| `ModelComponent` | Model instance for rendering | Yes |
| `BoundingBox` | Collision bounds derived from model | Yes |
| `NetworkId` | Client synchronization (entity visible to players) | Yes |
| `UUIDComponent` | Unique entity identity | Yes (use `ensureComponent`) |
| `Interactions` | Interaction handler container | If interactable |
| `Interactable` | Marks entity as interactable | If interactable |

---

## Making Entities Persist

Hytale automatically saves all entities, but `NetworkId` (required for clients to see the entity) must be **re-added every time the entity is loaded** from saved data. There are two approaches:

### Option A: HolderSystem (Recommended)

Create a system that re-adds `NetworkId` when entities with your custom component are loaded:

```java
public class AddNetworkIdToMyEntitySystem extends HolderSystem<EntityStore> {

    private final ComponentType<EntityStore, MyEntityComponent> myEntityComponentType =
        MyEntityComponent.getComponentType();
    private final ComponentType<EntityStore, NetworkId> networkIdComponentType =
        NetworkId.getComponentType();
    private final Query<EntityStore> query =
        Query.and(this.myEntityComponentType, Query.not(this.networkIdComponentType));

    @Override
    public void onEntityAdd(
            @NotNull Holder<EntityStore> holder,
            @NotNull AddReason reason,
            @NotNull Store<EntityStore> store) {
        if (!holder.getArchetype().contains(NetworkId.getComponentType())) {
            holder.addComponent(
                NetworkId.getComponentType(),
                new NetworkId(store.getExternalData().takeNextNetworkId())
            );
        }
    }

    @Override
    public void onEntityRemoved(
            @NotNull Holder<EntityStore> holder,
            @NotNull RemoveReason reason,
            @NotNull Store<EntityStore> store) {
        // No-op
    }

    @Override
    public @Nullable Query<EntityStore> getQuery() {
        return query;
    }
}
```

Register the system in your plugin's `setup()`:

```java
this.getEntityStoreRegistry().registerSystem(new AddNetworkIdToMyEntitySystem());
```

### Option B: PropComponent

Add `PropComponent` to your entity. Hytale uses this for entities spawned with the Entity Tool — it automatically gets `NetworkId` and `PrefabCopyableComponent` on load.

```java
holder.addComponent(PropComponent.getComponentType(), new PropComponent());
```

> **Warning:** Hytale may add additional behavior to `PropComponent` in future versions. This could cause unexpected side effects. The HolderSystem approach is safer for custom entities.

---

## Key Points

1. **World Thread Required** — All entity creation/mutation must run inside `world.execute(() -> { ... })`
2. **NetworkId Required** — Without it, clients cannot see the entity
3. **UUIDComponent Required** — Provides unique entity identity; use `ensureComponent` to auto-generate
4. **Model Lookup** — Use `ModelAsset.getAssetMap().getAsset("Name")` to find existing entity models
5. **Persistence** — `NetworkId` must be re-added on every load; use a `HolderSystem` or `PropComponent`
6. **Holder Pattern** — Always stage all components on a `Holder` before calling `store.addEntity()`

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Entity not visible | Ensure `NetworkId` is added with a valid ID from `takeNextNetworkId()` |
| Entity not spawning | Verify code runs inside `world.execute()` |
| Wrong position | Check `TransformComponent` coordinates; Y is vertical |
| Entity disappears on reload | Implement `HolderSystem` to re-add `NetworkId` on load |
| Model not found | Verify asset name in [entity list](https://hytalemodding.dev/en/docs/server/entities); names are case-sensitive |
| Cannot interact with entity | Add both `Interactions` and `Interactable` components |

---

## Reference

- Source: [Hytale Modding — Spawning Entities Guide](https://hytalemodding.dev/en/docs/guides/plugin/spawning-entities)
- Related: [Spawning NPCs](https://hytalemodding.dev/en/docs/guides/plugin/spawning-npcs)
- Related: [Entity List](https://hytalemodding.dev/en/docs/server/entities)
