---
name: hytale-events
description: Documents Hytale's event system for handling game events in plugins. Covers IEvent (global events), IAsyncEvent (async events), and EcsEvent (ECS entity/block events). Use when listening to player join/disconnect, chat, crafting, damage, block break/place, entity death, or any server event. Triggers - event, IEvent, IAsyncEvent, EcsEvent, CancellableEcsEvent, EntityEventSystem, EventRegistry, registerGlobal, registerAsync, PlayerReadyEvent, PlayerDisconnectEvent, PlayerChatEvent, BreakBlockEvent, PlaceBlockEvent, Damage, CraftRecipeEvent, DropItemEvent, DeathSystems, OnDeathSystem, event handler, event listener.
---

# Hytale Events Skill

Use this skill when working with events in Hytale plugins. This covers the three event categories: **IEvent** (global synchronous events), **IAsyncEvent** (asynchronous events), and **EcsEvent** (ECS-based entity/block events).

> **Related skills:** For chat-specific event handling, see `hytale-chat-formatting`. For ECS system fundamentals, see `hytale-ecs`. For entity effects triggered by events, see `hytale-entity-effects`.

---

## Quick Reference

| Task | Approach |
|------|----------|
| Listen to player join | `registerGlobal(PlayerReadyEvent.class, handler)` in `setup()` |
| Listen to player disconnect | `registerGlobal(PlayerDisconnectEvent.class, handler)` in `setup()` |
| Listen to chat messages | `registerAsync(PlayerChatEvent.class, handler)` in `setup()` |
| Cancel block break | Extend `EntityEventSystem<EntityStore, BreakBlockEvent>`, call `setCancelled(true)` |
| Cancel crafting | Extend `EntityEventSystem<EntityStore, CraftRecipeEvent.Pre>` |
| Handle entity damage | Extend `EntityEventSystem<EntityStore, Damage>` |
| Handle player death | Extend `DeathSystems.OnDeathSystem` |
| Handle block placement | Extend `EntityEventSystem<EntityStore, PlaceBlockEvent>` |
| Register global event | `this.getEventRegistry().registerGlobal(EventClass.class, Handler::method)` |
| Register async event | `this.getEventRegistry().registerAsync(EventClass.class, Handler::method)` |
| Register ECS event system | `this.getEntityStoreRegistry().registerSystem(new MyEventSystem())` in `start()` |

---

## Event Categories

Hytale has three distinct event types, each with different registration patterns:

| Category | Interface | Registration | Cancellable | Use Case |
|----------|-----------|--------------|-------------|----------|
| **IEvent** | `IEvent` | `registerGlobal()` | No | Player join, disconnect, world events, plugin lifecycle |
| **IAsyncEvent** | `IAsyncEvent` | `registerAsync()` | Yes (some) | Chat messages, asset loading |
| **EcsEvent** | `EcsEvent` / `CancellableEcsEvent` | `registerSystem()` | Yes (Cancellable) | Block break/place, damage, crafting, item drops |

---

## IEvent — Global Events

Global events are fired for server-wide occurrences. Register them in your plugin's `setup()` method.

### Registration Pattern

```java
@Override
protected void setup() {
    this.getEventRegistry().registerGlobal(PlayerReadyEvent.class, MyEventHandler::onPlayerReady);
    this.getEventRegistry().registerGlobal(PlayerDisconnectEvent.class, MyEventHandler::onPlayerDisconnect);
    this.getEventRegistry().registerGlobal(ShutdownEvent.class, MyEventHandler::onShutdown);
}
```

### Handler Class

```java
public class MyEventHandler {
    public static void onPlayerReady(PlayerReadyEvent event) {
        Player player = event.getPlayer();
        player.sendMessage(Message.raw("Welcome " + player.getDisplayName()));
    }

    public static void onPlayerDisconnect(PlayerDisconnectEvent event) {
        // event.getRef() returns a Ref<EntityStore> for the disconnecting player
    }

    public static void onShutdown(ShutdownEvent event) {
        // Clean up resources on server shutdown
    }
}
```

### Required Imports (IEvent)

```java
import com.hypixel.hytale.server.core.Message;
import com.hypixel.hytale.server.core.entity.entities.Player;
import com.hypixel.hytale.server.event.player.PlayerReadyEvent;
import com.hypixel.hytale.server.event.player.PlayerDisconnectEvent;
import com.hypixel.hytale.server.event.ShutdownEvent;
```

### Available IEvent Types

#### Player Events
| Event | Description | Key Methods |
|-------|-------------|-------------|
| `PlayerReadyEvent` | Player finished joining (fully loaded) | `getPlayer()` |
| `PlayerDisconnectEvent` | Player disconnecting | `getRef()` → `Ref<EntityStore>` |
| `PlayerConnectEvent` | Player beginning connection | - |
| `PlayerSetupConnectEvent` | Player setup phase start | - |
| `PlayerSetupDisconnectEvent` | Player setup phase disconnect | - |
| `PlayerMouseButtonEvent` | Player mouse button input | - |
| `PlayerMouseMotionEvent` | Player mouse motion | - |

#### World Events
| Event | Description |
|-------|-------------|
| `AddWorldEvent` | A world is being added |
| `RemoveWorldEvent` | A world is being removed |
| `StartWorldEvent` | A world is starting |
| `AddPlayerToWorldEvent` | Player added to a world |
| `DrainPlayerFromWorldEvent` | Player removed from a world |
| `AllWorldsLoadedEvent` | All worlds finished loading |

#### Lifecycle Events
| Event | Description |
|-------|-------------|
| `BootEvent` | Server boot |
| `ShutdownEvent` | Server shutting down |
| `PluginSetupEvent` | Plugin setup phase |
| `AllNPCsLoadedEvent` | All NPCs finished loading |
| `LoadedNPCEvent` | Individual NPC loaded |

#### Asset Events
| Event | Description |
|-------|-------------|
| `AssetPackRegisterEvent` | Asset pack registered |
| `AssetPackUnregisterEvent` | Asset pack unregistered |
| `RegisterAssetStoreEvent` | Asset store registered |
| `RemoveAssetStoreEvent` | Asset store removed |
| `GenerateAssetsEvent` | Assets being generated |
| `LoadedAssetsEvent` | Assets finished loading |
| `RemovedAssetsEvent` | Assets removed |
| `LoadAssetEvent` | Individual asset loading |

#### Other Events
| Event | Description |
|-------|-------------|
| `EntityRemoveEvent` | Entity removed from world |
| `LivingEntityInventoryChangeEvent` | Entity inventory changed |
| `ItemContainerChangeEvent` | Item container changed |
| `GenerateDefaultLanguageEvent` | Default language generation |
| `GenerateSchemaEvent` | Schema generation |
| `GenerateServerStateEvent` | Server state generation |
| `ChunkPreLoadProcessEvent` | Chunk pre-load processing |
| `TreasureChestOpeningEvent` | Treasure chest opened |
| `WindowCloseEvent` | Window closed |
| `WorldPathChangedEvent` | World path changed |
| `MessagesUpdated` | Messages updated |

---

## IAsyncEvent — Asynchronous Events

Async events run off the main tick thread. Register in `setup()` using `registerAsync()`.

### Registration Pattern

```java
@Override
protected void setup() {
    this.getEventRegistry().registerAsync(PlayerChatEvent.class, MyEventHandler::onPlayerChat);
}
```

### Handler Example

```java
public static void onPlayerChat(PlayerChatEvent event) {
    PlayerRef sender = event.getSender();
    String content = event.getContent();

    // Cancel the message
    if (content.contains("badword")) {
        event.setCancelled(true);
        sender.sendMessage(Message.raw("That word is not allowed!"));
        return;
    }

    // Modify content
    event.setContent(content.toUpperCase());

    // Set custom formatter
    event.setFormatter((playerRef, message) ->
        Message.join(
            Message.raw("[Server] ").color(Color.GOLD),
            Message.raw(sender.getUsername()).color(Color.WHITE),
            Message.raw(": " + message).color(Color.GRAY)
        ));
}
```

### Available IAsyncEvent Types

| Event | Description | Cancellable |
|-------|-------------|-------------|
| `PlayerChatEvent` | Player sends a chat message | Yes |
| `SendCommonAssetsEvent` | Common assets being sent | No |
| `AssetEditorFetchAutoCompleteDataEvent` | Editor autocomplete data | No |
| `AssetEditorRequestDataSetEvent` | Editor data set request | No |

---

## EcsEvent — ECS Entity/Block Events

ECS events are fired within the ECS tick loop and operate on entities matching a query. They use `EntityEventSystem` and are registered as systems.

### Key Difference from IEvent

- **IEvent**: Simple handler function, registered in `setup()`
- **EcsEvent**: Full ECS system class extending `EntityEventSystem`, registered in `start()` via `registerSystem()`
- **EcsEvent** receives `Store`, `CommandBuffer`, and `ArchetypeChunk` — giving full ECS access

### EntityEventSystem Pattern

```java
import com.hypixel.hytale.component.ArchetypeChunk;
import com.hypixel.hytale.component.CommandBuffer;
import com.hypixel.hytale.component.Store;
import com.hypixel.hytale.component.query.Archetype;
import com.hypixel.hytale.component.query.Query;
import com.hypixel.hytale.server.core.universe.world.storage.EntityStore;
import com.hypixel.hytale.server.ecs.system.EntityEventSystem;
import javax.annotation.Nonnull;

class MyCraftHandler extends EntityEventSystem<EntityStore, CraftRecipeEvent.Pre> {

    public MyCraftHandler() {
        super(CraftRecipeEvent.Pre.class);
    }

    @Override
    public void handle(int index,
                       @Nonnull ArchetypeChunk<EntityStore> archetypeChunk,
                       @Nonnull Store<EntityStore> store,
                       @Nonnull CommandBuffer<EntityStore> commandBuffer,
                       @Nonnull CraftRecipeEvent.Pre event) {
        // Access entity ref
        var ref = archetypeChunk.getReferenceTo(index);

        // Access event data
        CraftingRecipe recipe = event.getCraftedRecipe();

        // Cancel if needed (CancellableEcsEvent only)
        event.setCancelled(true);
    }

    @Override
    public Query<EntityStore> getQuery() {
        // Return which entities this system processes
        // Archetype.empty() = all entities that receive this event
        return Archetype.empty();
    }
}
```

### Registration

```java
@Override
protected void start() {
    this.getEntityStoreRegistry().registerSystem(new MyCraftHandler());
}
```

### Required Imports (EcsEvent)

```java
import com.hypixel.hytale.component.ArchetypeChunk;
import com.hypixel.hytale.component.CommandBuffer;
import com.hypixel.hytale.component.Ref;
import com.hypixel.hytale.component.Store;
import com.hypixel.hytale.component.query.Archetype;
import com.hypixel.hytale.component.query.Query;
import com.hypixel.hytale.server.core.universe.world.storage.EntityStore;
import com.hypixel.hytale.server.ecs.system.EntityEventSystem;
import javax.annotation.Nonnull;
```

### CancellableEcsEvent Types

These events extend `CancellableEcsEvent` and support `setCancelled(true)`:

| Event | Sub-Events | Description |
|-------|------------|-------------|
| `BreakBlockEvent` | — | Player breaking a block |
| `PlaceBlockEvent` | — | Player placing a block |
| `ChangeGameModeEvent` | — | Game mode change |
| `ChunkSaveEvent` | — | Chunk saving |
| `ChunkUnloadEvent` | — | Chunk unloading |
| `CraftRecipeEvent` | `.Pre`, `.Post` | Recipe crafted (Pre = before, Post = after) |
| `Damage` | — | Entity taking damage |
| `DamageBlockEvent` | — | Block being damaged |
| `DropItemEvent` | `.Drop`, `.PlayerRequest` | Item dropped |
| `InteractivelyPickupItemEvent` | — | Player picking up an item |
| `PrefabPasteEvent` | — | Prefab being pasted |
| `SwitchActiveSlotEvent` | — | Active hotbar slot switch |

### Non-Cancellable EcsEvent Types

| Event | Sub-Events | Description |
|-------|------------|-------------|
| `DiscoverInstanceEvent` | `.Display` | Instance discovered |
| `DiscoverZoneEvent` | `.Display` | Zone discovered |
| `MoonPhaseChangeEvent` | — | Moon phase changed |
| `UseBlockEvent` | `.Pre`, `.Post` | Block used (Pre = before, Post = after) |

---

## Special Pattern: Death Events

Player/entity death uses a specialized system extending `DeathSystems.OnDeathSystem` (a `RefChangeSystem` under the hood).

### Death System Example

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

public class PlayerDeathHandler extends DeathSystems.OnDeathSystem {

    @Nonnull
    @Override
    public Query<EntityStore> getQuery() {
        // Only process player deaths
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

        // Access death damage info
        Damage deathInfo = component.getDeathInfo();
        if (deathInfo != null) {
            Universe.get().sendMessage(
                Message.raw("Damage amount: " + deathInfo.getAmount()));
        }
    }
}
```

### Death System Registration

```java
@Override
protected void start() {
    this.getEntityStoreRegistry().registerSystem(new PlayerDeathHandler());
}
```

---

## Complete Plugin Example

A full plugin demonstrating all three event categories:

```java
import com.hypixel.hytale.server.plugin.JavaPlugin;
import com.hypixel.hytale.server.plugin.JavaPluginInit;
import com.hypixel.hytale.server.event.player.PlayerReadyEvent;
import com.hypixel.hytale.server.event.player.PlayerDisconnectEvent;
import com.hypixel.hytale.server.event.PlayerChatEvent;
import javax.annotation.Nonnull;

public class MyPlugin extends JavaPlugin {

    public MyPlugin(@Nonnull JavaPluginInit init) {
        super(init);
    }

    @Override
    protected void setup() {
        // IEvent — global events
        this.getEventRegistry().registerGlobal(PlayerReadyEvent.class,
            EventHandlers::onPlayerReady);
        this.getEventRegistry().registerGlobal(PlayerDisconnectEvent.class,
            EventHandlers::onPlayerDisconnect);

        // IAsyncEvent — async events
        this.getEventRegistry().registerAsync(PlayerChatEvent.class,
            EventHandlers::onPlayerChat);
    }

    @Override
    protected void start() {
        // EcsEvent — ECS event systems
        this.getEntityStoreRegistry().registerSystem(new CraftBlocker());
        this.getEntityStoreRegistry().registerSystem(new PlayerDeathHandler());
    }
}
```

---

## Common Patterns

### Cancel an Event Conditionally

```java
// CancellableEcsEvent pattern
@Override
public void handle(int index,
                   @Nonnull ArchetypeChunk<EntityStore> archetypeChunk,
                   @Nonnull Store<EntityStore> store,
                   @Nonnull CommandBuffer<EntityStore> commandBuffer,
                   @Nonnull BreakBlockEvent event) {
    // Check condition, then cancel
    if (shouldPreventBreak(event)) {
        event.setCancelled(true);
    }
}
```

### Block Crafting by Ingredient

```java
class BlockFibreCrafting extends EntityEventSystem<EntityStore, CraftRecipeEvent.Pre> {

    public BlockFibreCrafting() {
        super(CraftRecipeEvent.Pre.class);
    }

    @Override
    public void handle(int index,
                       @Nonnull ArchetypeChunk<EntityStore> archetypeChunk,
                       @Nonnull Store<EntityStore> store,
                       @Nonnull CommandBuffer<EntityStore> commandBuffer,
                       @Nonnull CraftRecipeEvent.Pre event) {
        CraftingRecipe recipe = event.getCraftedRecipe();
        if (recipe.getInput() != null) {
            for (MaterialQuantity mq : recipe.getInput()) {
                if (Objects.equals(mq.getItemId(), "Ingredient_Fibre")) {
                    event.setCancelled(true);
                    break;
                }
            }
        }
    }

    @Override
    public Query<EntityStore> getQuery() {
        return Archetype.empty();
    }
}
```

### Filter Events by Entity Type

```java
@Override
public Query<EntityStore> getQuery() {
    // Only process for entities with the Player component
    return Query.and(Player.getComponentType());
}
```

### Access Entity Ref from EcsEvent

```java
@Override
public void handle(int index,
                   @Nonnull ArchetypeChunk<EntityStore> archetypeChunk,
                   @Nonnull Store<EntityStore> store,
                   @Nonnull CommandBuffer<EntityStore> commandBuffer,
                   @Nonnull Damage damageEvent) {
    Ref<EntityStore> ref = archetypeChunk.getReferenceTo(index);
    // Use ref with store to access components
    Player player = (Player) store.getComponent(ref, Player.getComponentType());
}
```

---

## Choosing the Right Event Type

| Need | Event Category | Registration |
|------|---------------|--------------|
| Player joins / leaves | IEvent | `registerGlobal()` in `setup()` |
| Chat messages | IAsyncEvent | `registerAsync()` in `setup()` |
| Block break / place | EcsEvent | `registerSystem()` in `start()` |
| Damage / combat | EcsEvent | `registerSystem()` in `start()` |
| Crafting | EcsEvent | `registerSystem()` in `start()` |
| Item drops / pickups | EcsEvent | `registerSystem()` in `start()` |
| Entity death | Special (DeathSystems) | `registerSystem()` in `start()` |
| Server shutdown | IEvent | `registerGlobal()` in `setup()` |
| World lifecycle | IEvent | `registerGlobal()` in `setup()` |

---

## Best Practices

1. **Register IEvent/IAsyncEvent in `setup()`** and EcsEvent systems in `start()`
2. **Use method references** for cleaner registration: `EventHandler::onPlayerReady`
3. **Keep event handler classes separate** from the main plugin class for organization
4. **Use `Archetype.empty()`** for the query when you want to process all entities receiving the event
5. **Use `Query.and()`** to filter which entities your EcsEvent system processes
6. **Check `setCancelled()`** only on `CancellableEcsEvent` subclasses — non-cancellable events will not have this method
7. **Use Pre/Post sub-events** when available (e.g., `CraftRecipeEvent.Pre` vs `.Post`) to choose timing
8. **Access entity data via `Store` and `Ref`** in EcsEvent handlers — never cache entity references
9. **Use `CommandBuffer`** for mutations inside EcsEvent handlers (add/remove components)
10. **Death handling** uses `DeathSystems.OnDeathSystem` (a `RefChangeSystem`), not `EntityEventSystem`

---

## Resources

- [Creating Events Guide](https://hytalemodding.dev/en/docs/guides/plugin/creating-events)
- [Events List](https://hytalemodding.dev/en/docs/server/events)
- [Player Death Event Guide](https://hytalemodding.dev/en/docs/guides/plugin/player-death-event)
- [ECS Systems Guide](https://hytalemodding.dev/en/docs/guides/ecs/systems)
