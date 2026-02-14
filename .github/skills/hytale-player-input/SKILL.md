---
name: hytale-player-input
description: Documents Hytale's player input system including packet interception (PacketAdapters, PacketWatcher, PacketFilter), SyncInteractionChains, InteractionTypes, client-to-server packet reference, and custom camera controls. Use when handling player input, intercepting packets, creating custom interactions, modifying camera behavior, or working with mouse/keyboard input. Triggers - player input, packet, PacketAdapters, PacketWatcher, PacketFilter, PlayerPacketWatcher, PlayerPacketFilter, SyncInteractionChains, InteractionType, MouseInteraction, ClientMovement, camera, SetServerCamera, ServerCameraSettings, camera controls, top-down, isometric, side-scroller, inbound packet, outbound packet, packet listener, input handling.
---

# Hytale Player Input Skill

Use this skill when working with player input handling in Hytale plugins. This covers how the client communicates input to the server via packets, how to intercept and filter those packets, all InteractionTypes, the complete client-to-server packet reference, and custom camera controls.

> **Related skills:** For hotbar-specific slot customization (ability slots), see `hytale-hotbar-actions`. For game events (PlayerReady, chat, damage, etc.), see `hytale-events`. For UI-based input, see `hytale-ui-modding`.

---

## Quick Reference

| Task | Approach |
|------|----------|
| Listen to all inbound packets | `PacketAdapters.registerInbound((PacketWatcher) ...)` |
| Listen to player-specific inbound packets | `PacketAdapters.registerInbound((PlayerPacketWatcher) ...)` |
| Block/cancel inbound packets | `PacketAdapters.registerInbound((PlayerPacketFilter) ...)` — return `true` to cancel |
| Listen to outbound packets | `PacketAdapters.registerOutbound((PacketWatcher) ...)` |
| Detect player interactions (left/right click, F key) | Intercept `SyncInteractionChains` (packet ID 290) |
| Detect mouse input | Intercept `MouseInteraction` (packet ID 111) |
| Detect player movement | Intercept `ClientMovement` (packet ID 108) |
| Customize camera | Send `SetServerCamera` packet with `ServerCameraSettings` |
| Reset camera to default | Send `SetServerCamera(ClientCameraView.Custom, false, null)` |
| Deregister a listener | `PacketAdapters.deregisterInbound(filter)` or `deregisterOutbound(watcher)` |

---

## Part 1: How Player Input Works

Hytale servers **do not receive raw keyboard input**. The client interprets keypresses and sends **packets** describing what action the player wants to perform. To create custom input behavior, you intercept these packets server-side.

Key concepts:
- **Inbound packets** = Client → Server (player actions)
- **Outbound packets** = Server → Client (state updates, camera, etc.)
- Packets are defined in `com.hypixel.hytale.protocol` and organized by category in `com.hypixel.hytale.protocol.packets`
- Base class is `Packet`; the low-level Netty handler is `PlayerChannelHandler` which delegates to `PacketAdapters`

---

## Part 2: PacketAdapters System

The `PacketAdapters` class provides the injection point for packet interception. You do **not** need to hook into Netty manually.

### Registration Methods

| Method | Interface Type | Can Block | Player-Specific |
|--------|---------------|-----------|-----------------|
| `registerInbound(PacketWatcher)` | `PacketWatcher` | No | No |
| `registerInbound(PacketFilter)` | `PacketFilter` | Yes | No |
| `registerInbound(PlayerPacketWatcher)` | `PlayerPacketWatcher` | No | Yes |
| `registerInbound(PlayerPacketFilter)` | `PlayerPacketFilter` | Yes | Yes |
| `registerOutbound(PacketWatcher)` | `PacketWatcher` | No | No |
| `registerOutbound(PacketFilter)` | `PacketFilter` | Yes | No |

### Interfaces

```java
// Read-only observer — cannot block packets
public interface PacketWatcher {
    void accept(PacketHandler packetHandler, Packet packet);
}

// Can block packets — return true to cancel, false to allow
public interface PacketFilter {
    boolean test(PacketHandler packetHandler, Packet packet);
}

// Player-specific read-only observer
public interface PlayerPacketWatcher {
    void accept(@Nonnull PlayerRef playerRef, @Nonnull Packet packet);
}

// Player-specific filter — return true to cancel, false to allow
public interface PlayerPacketFilter {
    boolean test(@Nonnull PlayerRef playerRef, @Nonnull Packet packet);
}
```

### Imports

```java
import com.hypixel.hytale.protocol.Packet;
import com.hypixel.hytale.server.core.io.adapter.PacketAdapters;
import com.hypixel.hytale.server.core.io.adapter.PacketFilter;
import com.hypixel.hytale.server.core.io.adapter.PacketWatcher;
import com.hypixel.hytale.server.core.io.adapter.PlayerPacketFilter;
import com.hypixel.hytale.server.core.io.adapter.PlayerPacketWatcher;
import com.hypixel.hytale.server.core.io.adapter.PacketHandler;
import com.hypixel.hytale.server.core.io.adapter.GamePacketHandler;
import com.hypixel.hytale.server.core.universe.PlayerRef;
```

---

## Part 3: Intercepting Interactions (SyncInteractionChains)

When a player performs interactions (left click, right click, F key, etc.), the client sends a `SyncInteractionChains` packet (ID 290) containing `SyncInteractionChain` objects.

### SyncInteractionChain Fields

| Field | Description |
|-------|-------------|
| `interactionType` | The `InteractionType` enum value |
| `activeHotbarSlot` | The slot the player is currently on |
| `data.targetSlot` | The slot the player wants to switch to (for swap types) |
| `initial` | Whether this is the start of a new interaction chain |

### Example: Listening for Use Interaction (F Key)

```java
public class PacketListener implements PacketWatcher {
    @Override
    public void accept(PacketHandler packetHandler, Packet packet) {
        if (packet.getId() != 290) {
            return;
        }
        SyncInteractionChains interactionChains = (SyncInteractionChains) packet;
        SyncInteractionChain[] updates = interactionChains.updates;

        for (SyncInteractionChain item : updates) {
            PlayerAuthentication playerAuthentication = packetHandler.getAuth();
            String uuid = playerAuthentication.getUuid().toString();
            InteractionType interactionType = item.interactionType;
            if (interactionType == InteractionType.Use) {
                // Handle "F" key interaction
            }
        }
    }
}
```

### Example: Filtering Interactions (Cancel Specific Actions)

```java
public class InteractionFilter implements PlayerPacketFilter {
    @Override
    public boolean test(@Nonnull PlayerRef playerRef, @Nonnull Packet packet) {
        if (!(packet instanceof SyncInteractionChains syncPacket)) {
            return false;
        }

        for (SyncInteractionChain chain : syncPacket.updates) {
            if (chain.interactionType == InteractionType.Primary) {
                // Block left-click interactions
                return true;
            }
        }

        return false; // Allow all other packets
    }
}
```

### Interaction Imports

```java
import com.hypixel.hytale.protocol.InteractionType;
import com.hypixel.hytale.protocol.packets.interaction.SyncInteractionChain;
import com.hypixel.hytale.protocol.packets.interaction.SyncInteractionChains;
import com.hypixel.hytale.server.core.auth.PlayerAuthentication;
```

---

## Part 4: InteractionType Reference

All interaction types from `InteractionType` enum:

| Name | Ordinal | Description |
|------|---------|-------------|
| `Primary` | 0 | Left click |
| `Secondary` | 1 | Right click |
| `Ability1` | 2 | Ability slot 1 |
| `Ability2` | 3 | Ability slot 2 |
| `Ability3` | 4 | Ability slot 3 |
| `Use` | 5 | Use key (F) |
| `Pick` | 6 | Pick action |
| `Pickup` | 7 | Pickup action |
| `CollisionEnter` | 8 | Entity collision start |
| `CollisionLeave` | 9 | Entity collision end |
| `Collision` | 10 | Ongoing collision |
| `EntityStatEffect` | 11 | Stat effect applied |
| `SwapTo` | 12 | Switching to a slot |
| `SwapFrom` | 13 | Switching from a slot |
| `Death` | 14 | Entity death |
| `Wielding` | 15 | Wielding an item |
| `ProjectileSpawn` | 16 | Projectile created |
| `ProjectileHit` | 17 | Projectile hits target |
| `ProjectileMiss` | 18 | Projectile misses |
| `ProjectileBounce` | 19 | Projectile bounces |
| `Held` | 20 | Item held in main hand |
| `HeldOffhand` | 21 | Item held in offhand |
| `Equipped` | 22 | Item equipped |
| `Dodge` | 23 | Dodge action |
| `GameModeSwap` | 24 | Game mode changed |

> **Common input triggers:** `Primary` (left click), `Secondary` (right click), `Use` (F key). For hotbar slot-based ability triggers, see the `hytale-hotbar-actions` skill.

---

## Part 5: Modifying & Observing Packets

### Observing Outbound Packets (Server → Client)

```java
PacketAdapters.registerOutbound((PacketHandler handler, Packet packet) -> {
    var handlerName = handler.getClass().getSimpleName();
    var packetName = packet.getClass().getSimpleName();
    // Exclude noisy packets
    if (!"EntityUpdates".equals(packetName) && !"CachedPacket".equals(packetName)) {
        logger.at(Level.INFO)
              .log("[" + handlerName + "] Sent packet id=" + packet.getId() + ": " + packetName);
    }
});
```

### Modifying Inbound Packets

```java
PacketAdapters.registerInbound((PacketHandler handler, Packet packet) -> {
    if (packet instanceof PlayerOptions skinPacket) {
        skinPacket.skin = null; // Remove skin data
    }
});
```

### Blocking Player Packets (PlayerPacketFilter)

```java
PacketAdapters.registerInbound((PlayerPacketFilter) (player, packet) -> {
    if (packet instanceof ClientMovement movementPacket) {
        // Block movement — return true to cancel
        return true;
    }
    return false;
});
```

> **Warning:** While you can cancel packets, client-side prediction still occurs. The player's client will still show movement locally. Preventing specific player actions requires additional work beyond just cancelling packets.

### Packet Tracker Utility

Track all packets sent to/from players for debugging:

```java
public class PlayerPacketTracker {
    private static final HytaleLogger LOGGER = HytaleLogger.forEnclosingClass();

    private static class PlayerStats {
        final Map<String, AtomicInteger> sent = new ConcurrentHashMap<>();
        final Map<String, AtomicInteger> received = new ConcurrentHashMap<>();
    }

    private static final Map<String, PlayerStats> stats = new ConcurrentHashMap<>();

    private static String getPlayerName(PacketHandler handler) {
        if (handler instanceof GamePacketHandler gpHandler) {
            return gpHandler.getPlayerRef().getUsername();
        }
        return null;
    }

    public static void registerPacketCounters() {
        PacketAdapters.registerInbound((PacketHandler handler, Packet packet) -> {
            String playerName = getPlayerName(handler);
            if (playerName != null) {
                stats.computeIfAbsent(playerName, k -> new PlayerStats())
                     .received.computeIfAbsent(packet.getClass().getSimpleName(),
                         k -> new AtomicInteger(0))
                     .incrementAndGet();
            }
        });

        PacketAdapters.registerOutbound((PacketHandler handler, Packet packet) -> {
            String playerName = getPlayerName(handler);
            if (playerName != null) {
                stats.computeIfAbsent(playerName, k -> new PlayerStats())
                     .sent.computeIfAbsent(packet.getClass().getSimpleName(),
                         k -> new AtomicInteger(0))
                     .incrementAndGet();
            }
        });

        // Log every 3 seconds
        HytaleServer.SCHEDULED_EXECUTOR.scheduleAtFixedRate(() -> {
            if (stats.isEmpty()) return;
            for (Map.Entry<String, PlayerStats> entry : stats.entrySet()) {
                String player = entry.getKey();
                PlayerStats pStats = entry.getValue();
                StringBuilder sb = new StringBuilder();

                List<String> sentLogs = new ArrayList<>();
                pStats.sent.forEach((type, atomic) -> {
                    int count = atomic.getAndSet(0);
                    if (count > 0) sentLogs.add(type + " x" + count);
                });
                if (!sentLogs.isEmpty()) {
                    sb.append("Sent ").append(String.join(", ", sentLogs));
                }

                List<String> recvLogs = new ArrayList<>();
                pStats.received.forEach((type, atomic) -> {
                    int count = atomic.getAndSet(0);
                    if (count > 0) recvLogs.add(type + " x" + count);
                });
                if (!recvLogs.isEmpty()) {
                    if (!sb.isEmpty()) sb.append("\n");
                    sb.append("Received ").append(String.join(", ", recvLogs));
                }

                if (!sb.isEmpty()) {
                    LOGGER.atInfo().log("To " + player + ":\n" + sb);
                }
            }
        }, 3, 3, TimeUnit.SECONDS);
    }
}
```

Call `PlayerPacketTracker.registerPacketCounters()` in your plugin's `setup()` method.

---

## Part 6: Plugin Registration & Cleanup

Always store references to registered filters/watchers and deregister them on shutdown:

```java
public class MyPlugin extends HytaleServerPlugin {
    private PacketFilter inboundFilter;

    @Override
    protected void setup() {
        inboundFilter = PacketAdapters.registerInbound(
            (PlayerPacketFilter) (player, packet) -> {
                // Your filter logic
                return false;
            }
        );
    }

    @Override
    protected void shutdown() {
        if (inboundFilter != null) {
            PacketAdapters.deregisterInbound(inboundFilter);
        }
    }
}
```

---

## Part 7: Client-to-Server Packet Reference

Packets are found in: `com.hypixel.hytale.protocol.packets`

### Player Packets

| Packet | ID | Key Fields |
|--------|----|------------|
| `SetClientId` | 100 | `clientId` |
| `SetGameMode` | 101 | `gameMode` |
| `SetMovementStates` | 102 | `movementStates` |
| `SetBlockPlacementOverride` | 103 | `enabled` |
| `JoinWorld` | 104 | `clearWorld`, `fadeInOut`, `worldUuid` |
| `ClientReady` | 105 | `readyForChunks`, `readyForGameplay` |
| `LoadHotbar` | 106 | `inventoryRow` |
| `SaveHotbar` | 107 | `inventoryRow` |
| `ClientMovement` | 108 | `movementStates`, `relativePosition`, `absolutePosition`, `bodyOrientation`, `lookOrientation`, `teleportAck`, `wishMovement`, `velocity`, `mountedTo`, `riderMovementStates` |
| `ClientTeleport` | 109 | `teleportId`, `modelTransform`, `resetVelocity` |
| `UpdateMovementSettings` | 110 | `movementSettings` |
| `MouseInteraction` | 111 | `clientTimestamp`, `activeSlot`, `itemInHandId`, `screenPoint`, `mouseButton`, `mouseMotion`, `worldInteraction` |
| `DamageInfo` | 112 | `damageSourcePosition`, `damageAmount`, `damageCause` |
| `ReticleEvent` | 113 | `eventIndex` |
| `DisplayDebug` | 114 | `shape`, `matrix`, `color`, `time`, `fade`, `frustumProjection` |
| `ClearDebugShapes` | 115 | (none) |
| `SyncPlayerPreferences` | 116 | `showEntityMarkers`, `armorItemsPreferredPickupLocation`, `weaponAndToolItemsPreferredPickupLocation`, `usableItemsItemsPreferredPickupLocation`, `solidBlockItemsPreferredPickupLocation`, `miscItemsPreferredPickupLocation`, `allowNPCDetection`, `respondToHit` |
| `ClientPlaceBlock` | 117 | `position`, `rotation`, `placedBlockId` |
| `UpdateMemoriesFeatureStatus` | 118 | `isFeatureUnlocked` |
| `RemoveMapMarker` | 119 | `markerId` |

### Inventory Packets

| Packet | ID | Key Fields |
|--------|----|------------|
| `UpdatePlayerInventory` | 170 | `storage`, `armor`, `hotbar`, `utility`, `builderMaterial`, `tools`, `backpack`, `sortType` |
| `SetCreativeItem` | 171 | `inventorySectionId`, `slotId`, `item`, `override` |
| `DropCreativeItem` | 172 | `item` |
| `SmartGiveCreativeItem` | 173 | `item`, `moveType` |
| `DropItemStack` | 174 | `inventorySectionId`, `slotId`, `quantity` |
| `MoveItemStack` | 175 | `fromSectionId`, `fromSlotId`, `quantity`, `toSectionId`, `toSlotId` |
| `SmartMoveItemStack` | 176 | `fromSectionId`, `fromSlotId`, `quantity`, `moveType` |
| `SetActiveSlot` | 177 | `inventorySectionId`, `activeSlot` |
| `SwitchHotbarBlockSet` | 178 | `itemId` |
| `InventoryAction` | 179 | `inventorySectionId`, `inventoryActionType`, `actionData` |

### Window Packets

| Packet | ID | Key Fields |
|--------|----|------------|
| `OpenWindow` | 200 | `id`, `windowType`, `windowData`, `inventory`, `extraResources` |
| `UpdateWindow` | 201 | `id`, `windowData`, `inventory`, `extraResources` |
| `CloseWindow` | 202 | `id` |
| `SendWindowAction` | 203 | `id`, `action` |
| `ClientOpenWindow` | 204 | `type` |

### Other Client Packets

| Packet | ID | Key Fields |
|--------|----|------------|
| `ClientReferral` | 18 | `hostTo`, `data` |
| `SetUpdateRate` | 29 | `updatesPerSecond` |
| `SetTimeDilation` | 30 | `timeDilation` |
| `SetChunk` | 131 | `x`, `y`, `z`, `localLight`, `globalLight`, `data` |
| `SetChunkHeightmap` | 132 | `x`, `z`, `heightmap` |
| `SetChunkTintmap` | 133 | `x`, `z`, `tintmap` |
| `SetChunkEnvironments` | 134 | `x`, `z`, `environments` |
| `SetFluids` | 136 | `x`, `y`, `z`, `data` |
| `SetPaused` | 158 | `paused` |
| `SetEntitySeed` | 160 | `entitySeed` |
| `SetPage` | 216 | `page`, `canCloseThroughInteraction` |
| `SetServerAccess` | 252 | `access`, `password` |
| `SetMachinimaActorModel` | 261 | `model`, `sceneName`, `actorName` |
| `SetServerCamera` | 280 | `clientCameraView`, `isLocked`, `cameraSettings` |
| `SetFlyCameraMode` | 283 | `entering` |
| `SyncInteractionChains` | 290 | `updates` |

### Packet Handlers (Server-Side)

Packet handlers determine which packets are accepted at each phase of the connection lifecycle:

| Handler | Packets Accepted |
|---------|-----------------|
| **InitialPacketHandler** | Connect (0), Disconnect (1) |
| **HandshakeHandler** | Disconnect (1), AuthToken (12) |
| **PasswordPacketHandler** | Disconnect (1), PasswordResponse (15) |
| **SetupPacketHandler** | Disconnect (1), RequestAssets (23), ViewRadius (32), PlayerOptions (33) |
| **GamePacketHandler** | Disconnect (1), Pong (3), ClientMovement (108), ChatMessage (211), RequestAssets (23), CustomPageEvent (219), ViewRadius (32), UpdateLanguage (232), MouseInteraction (111), SendWindowAction (203), CloseWindow (202), ClientReady (105), SyncInteractionChains (290), SetPaused (158), and more |

**GamePacketHandler sub-handlers:**

| Sub-Handler | Packets |
|-------------|---------|
| **InventoryPacketHandler** | SetCreativeItem (171), DropCreativeItem (172), SmartGiveCreativeItem (173), DropItemStack (174), MoveItemStack (175), SmartMoveItemStack (176), SetActiveSlot (177), SwitchHotbarBlockSet (178), InventoryAction (179) |
| **BuilderToolsPacketHandler** | LoadHotbar (106), SaveHotbar (107), BuilderToolArgUpdate (400), BuilderToolEntityAction (401), and more |
| **MountGamePacketHandler** | DismountNPC (294) |

> If a packet arrives during the wrong connection phase, the handler disconnects the sender.

---

## Part 8: Custom Camera Controls

Camera is controlled by sending a `SetServerCamera` packet with `ServerCameraSettings` to the player.

### Camera Imports

```java
import com.hypixel.hytale.protocol.ClientCameraView;
import com.hypixel.hytale.protocol.Direction;
import com.hypixel.hytale.protocol.MouseInputType;
import com.hypixel.hytale.protocol.MovementForceRotationType;
import com.hypixel.hytale.protocol.PositionDistanceOffsetType;
import com.hypixel.hytale.protocol.RotationType;
import com.hypixel.hytale.protocol.ServerCameraSettings;
import com.hypixel.hytale.protocol.Vector3f;
import com.hypixel.hytale.protocol.packets.camera.SetServerCamera;
```

### Basic Camera Setup

```java
ServerCameraSettings settings = new ServerCameraSettings();
settings.distance = 10.0f;           // Zoom distance from player
settings.isFirstPerson = false;      // Third-person mode
settings.positionLerpSpeed = 0.2f;   // Smooth camera follow

playerRef.getPacketHandler().writeNoCache(
    new SetServerCamera(ClientCameraView.Custom, true, settings)
);
```

### Reset Camera to Default

```java
playerRef.getPacketHandler().writeNoCache(
    new SetServerCamera(ClientCameraView.Custom, false, null)
);
```

### Camera Presets

#### Top-Down (RTS/ARPG Style)

Source: `com.hypixel.hytale.server.core.command.commands.player.camera.PlayerCameraTopdownCommand`

```java
ServerCameraSettings settings = new ServerCameraSettings();
settings.positionLerpSpeed = 0.2f;
settings.rotationLerpSpeed = 0.2f;
settings.distance = 20.0f;
settings.displayCursor = true;
settings.isFirstPerson = false;
settings.movementForceRotationType = MovementForceRotationType.Custom;
// Align movement with camera yaw (horizontal rotation only)
settings.movementForceRotation = new Direction(-0.7853981634f, 0.0f, 0.0f); // 45° right
settings.eyeOffset = true;
settings.positionDistanceOffsetType = PositionDistanceOffsetType.DistanceOffset;
settings.rotationType = RotationType.Custom;
settings.rotation = new Direction(0.0f, -1.5707964f, 0.0f); // Look straight down
settings.mouseInputType = MouseInputType.LookAtPlane;
settings.planeNormal = new Vector3f(0.0f, 1.0f, 0.0f); // Ground plane

playerRef.getPacketHandler().writeNoCache(
    new SetServerCamera(ClientCameraView.Custom, true, settings)
);
```

#### Side-Scroller (2D Platformer Style)

Source: `com.hypixel.hytale.server.core.command.commands.player.camera.PlayerCameraSideScrollerCommand`

```java
ServerCameraSettings settings = new ServerCameraSettings();
settings.positionLerpSpeed = 0.2f;
settings.rotationLerpSpeed = 0.2f;
settings.distance = 15.0f;
settings.displayCursor = true;
settings.isFirstPerson = false;
settings.movementForceRotationType = MovementForceRotationType.Custom;
settings.movementMultiplier = new Vector3f(1.0f, 1.0f, 0.0f); // Lock Z-axis
settings.eyeOffset = true;
settings.positionDistanceOffsetType = PositionDistanceOffsetType.DistanceOffset;
settings.rotationType = RotationType.Custom;
settings.mouseInputType = MouseInputType.LookAtPlane;
settings.planeNormal = new Vector3f(0.0f, 0.0f, 1.0f); // Side plane

playerRef.getPacketHandler().writeNoCache(
    new SetServerCamera(ClientCameraView.Custom, true, settings)
);
```

#### Isometric (Diablo Style)

```java
ServerCameraSettings settings = new ServerCameraSettings();
settings.positionLerpSpeed = 0.2f;
settings.rotationLerpSpeed = 0.2f;
settings.isFirstPerson = false;
settings.distance = 6f;
settings.allowPitchControls = false;
settings.displayCursor = true;
// Force the camera's rotation to be set by the server
settings.applyLookType = ApplyLookType.Rotation;
settings.rotationType = RotationType.Custom;

// Set the typical isometric rotation
Direction direction = new Direction(
    (float) Math.toRadians(45f),   // yaw
    (float) Math.toRadians(-35f),  // pitch
    0f                              // roll
);
settings.rotation = direction;
settings.movementForceRotation = direction;

playerRef.getPacketHandler().writeNoCache(
    new SetServerCamera(ClientCameraView.Custom, true, settings)
);
```

### ServerCameraSettings Reference

#### Position & Rotation

| Setting | Description |
|---------|-------------|
| `positionLerpSpeed` (0.0-1.0) | How smoothly camera follows player. Lower = smoother but slower |
| `rotationLerpSpeed` (0.0-1.0) | How smoothly camera rotates. Lower = smoother but slower |
| `distance` | Camera distance from player. Higher = zoomed out |
| `rotation` | Camera angle as `Direction(yaw, pitch, roll)` in **radians** |
| `rotationType` | How rotation is calculated. `RotationType.Custom` uses your `rotation` value |

#### Movement Alignment

| Setting | Description |
|---------|-------------|
| `movementForceRotationType` | `AttachedToHead` = follows player look; `Custom` = use `movementForceRotation` |
| `movementForceRotation` | Direction for W/S movement when using `Custom`. Match yaw with camera, keep pitch at 0 |
| `movementMultiplier` | Scale movement per axis. `(1,1,0)` = lock Z-axis for 2D |

#### Input & Display

| Setting | Description |
|---------|-------------|
| `displayCursor` | Show/hide mouse cursor |
| `mouseInputType` | `LookAtPlane` = cursor on plane (top-down); `LookAtTarget` = rotates camera |
| `planeNormal` | For `LookAtPlane`, defines the plane. `(0,1,0)` = ground, `(0,0,1)` = side |

#### Advanced

| Setting | Description |
|---------|-------------|
| `positionDistanceOffsetType` | `DistanceOffset` = simple; `DistanceOffsetRaycast` = prevents wall clipping |
| `eyeOffset` | Offset camera from player's eye position |
| `isFirstPerson` | First-person vs third-person mode |
| `allowPitchControls` | Allow player to control pitch |
| `isLocked` (packet parameter) | Set `true` in `SetServerCamera` to prevent player camera changes |

### Camera Tips

- **Zoom:** Adjust `distance` (higher = further out)
- **Smoothness:** `positionLerpSpeed` and `rotationLerpSpeed` control camera response speed
- **Wall clipping:** Use `PositionDistanceOffsetType.DistanceOffsetRaycast`
- **Lock camera:** Set `isLocked = true` in the `SetServerCamera` packet
- **2D movement:** Set `movementMultiplier` to zero out an axis
- **Isometric cameras:** Always set `movementForceRotation` to match camera yaw
- **Angle math:** Use `Math.toRadians(degrees)` to convert degrees to radians

---

## Key Warnings

1. **Client-side prediction:** Cancelling packets does not prevent client-side visual effects. The player will still see movement/actions locally even if the server blocks the packet.
2. **Thread safety:** When accessing ECS components from packet handlers, schedule work on the world thread via `world.execute(() -> { ... })`.
3. **Packet IDs may change:** Always use `instanceof` checks or class references rather than hardcoded packet IDs when possible. The ID-based approach (`packet.getId() != 290`) is brittle across server versions.
4. **Deregister on shutdown:** Always store filter/watcher references and deregister them in your plugin's `shutdown()` method.
