---
name: hytale-hotbar-actions
description: Customizes hotbar key actions in Hytale plugins using packet filtering. Use when creating custom keybinds, ability triggers, blocking slot switches, or handling hotbar input. Triggers - hotbar, keybind, ability slot, SyncInteractionChains, PlayerPacketFilter, slot switch, custom action, SetActiveSlot, ability trigger.
---

# Hytale Hotbar Actions Skill

Use this skill when implementing custom hotbar keybinds in Hytale plugins. This covers intercepting slot-switch packets, blocking default behavior, and triggering custom abilities.

> **Note:** This pattern only works for hotbar slots. Each custom action consumes one hotbar slot.

---

## Quick Reference

| Concept | Description |
|---------|-------------|
| **SyncInteractionChains** | Packet (ID 290) sent when player performs interactions |
| **PlayerPacketFilter** | Filter interface to block/allow inbound packets |
| **PlayerPacketWatcher** | Watcher interface for observing packets (read-only) |
| **SetActiveSlot** | Packet (ID 177) to force client slot selection |
| **InteractionType.SwapFrom** | Interaction type when leaving a slot |

---

## Part 1: Understanding the Packet System

When a player presses a hotbar key (1-9), the client sends a `SyncInteractionChains` packet containing `SyncInteractionChain` objects.

### SyncInteractionChain Fields

| Field | Description |
|-------|-------------|
| `interactionType` | Type of interaction (SwapFrom, SwapTo, Attack, etc.) |
| `activeHotbarSlot` | The slot the player is currently on |
| `data.targetSlot` | The slot the player wants to switch to |
| `initial` | Whether this is the start of a new interaction chain |

> **Note:** Slot indices are 0-based. Key "9" = slot index 8.

---

## Part 2: Packet Interception

### Watcher vs Filter

| Type | Interface | Can Block | Use Case |
|------|-----------|-----------|----------|
| Watcher | `PlayerPacketWatcher` | No | Logging, analytics, side effects |
| Filter | `PlayerPacketFilter` | Yes | Blocking/modifying behavior |

Use `PlayerPacketFilter` when you need to block the slot switch.

---

## Part 3: Implementation

### Required Imports

```java
import com.hypixel.hytale.protocol.Packet;
import com.hypixel.hytale.protocol.InteractionType;
import com.hypixel.hytale.protocol.packets.interaction.SyncInteractionChain;
import com.hypixel.hytale.protocol.packets.interaction.SyncInteractionChains;
import com.hypixel.hytale.protocol.packets.inventory.SetActiveSlot;
import com.hypixel.hytale.server.core.io.adapter.PlayerPacketFilter;
import com.hypixel.hytale.server.core.io.adapter.PacketAdapters;
import com.hypixel.hytale.server.core.io.adapter.PacketFilter;
import com.hypixel.hytale.server.core.universe.PlayerRef;
import com.hypixel.hytale.server.core.inventory.Inventory;
import com.hypixel.hytale.server.core.universe.Store;
import com.hypixel.hytale.server.core.universe.entity.EntityStore;
import com.hypixel.hytale.server.core.universe.entity.Ref;
import com.hypixel.hytale.server.player.Player;
import com.hypixel.hytale.server.world.World;
import javax.annotation.Nonnull;
import java.util.logging.Level;
```

### Handler Class

```java
public class AbilitySlotHandler implements PlayerPacketFilter {
    private static final int ABILITY_SLOT = 8;  // Slot index 8 = Key "9"
    
    private final MyPlugin plugin;
    
    public AbilitySlotHandler(MyPlugin plugin) {
        this.plugin = plugin;
    }
    
    @Override
    public boolean test(@Nonnull PlayerRef playerRef, @Nonnull Packet packet) {
        // Step 1: Check packet type
        if (!(packet instanceof SyncInteractionChains syncPacket)) {
            return false;
        }
        
        // Step 2: Look for our trigger condition
        for (SyncInteractionChain chain : syncPacket.updates) {
            if (chain.interactionType == InteractionType.SwapFrom
                    && chain.data != null
                    && chain.data.targetSlot == ABILITY_SLOT
                    && chain.initial) {
                
                int originalSlot = chain.activeHotbarSlot;
                
                // Step 3: Trigger ability and fix client state
                handleAbilityTrigger(playerRef, originalSlot);
                
                return true;  // Block the packet
            }
        }
        
        return false;  // Let packet through
    }
    
    private void handleAbilityTrigger(PlayerRef playerRef, int originalSlot) {
        Ref<EntityStore> entityRef = playerRef.getReference();
        if (entityRef == null || !entityRef.isValid()) {
            return;
        }
        
        Store<EntityStore> store = entityRef.getStore();
        World world = store.getExternalData().getWorld();
        
        // Schedule on world thread for thread safety
        world.execute(() -> {
            Player playerComponent = store.getComponent(entityRef, Player.getComponentType());
            if (playerComponent == null) {
                return;
            }
            
            // Fix client desync - restore original slot
            playerComponent.getInventory().setActiveHotbarSlot((byte) originalSlot);
            
            SetActiveSlot setActiveSlotPacket = new SetActiveSlot(
                Inventory.HOTBAR_SECTION_ID,  // -1 indicates the hotbar
                originalSlot                   // The slot index to select
            );
            playerRef.getPacketHandler().write(setActiveSlotPacket);
            
            // Your ability logic here
            triggerAbility(playerRef, playerComponent);
        });
    }
    
    private void triggerAbility(PlayerRef playerRef, Player player) {
        // Example: Run a command as the player
        // CommandManager.get().handleCommand(playerRef, "noon");
        
        // Example: Send notification
        playerRef.sendMessage(Message.raw("Ability triggered!"));
    }
}
```

### Plugin Registration

```java
import com.hypixel.hytale.server.core.io.adapter.PacketAdapters;
import com.hypixel.hytale.server.core.io.adapter.PacketFilter;

public class MyPlugin extends HytaleServerPlugin {
    private PacketFilter inboundFilter;
    
    @Override
    protected void setup() {
        AbilitySlotHandler handler = new AbilitySlotHandler(this);
        inboundFilter = PacketAdapters.registerInbound(handler);
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

## Part 4: The Client Desync Problem

### The Challenge

The client performs slot switches locally before server confirmation:

| Side | State |
|------|-------|
| Server | Player stays on slot 5 (packet blocked) |
| Client | Player is on slot 8 (switched locally) |

### The Solution

Send `SetActiveSlot` packet to force the client to the correct slot:

```java
// Update server-side state
playerComponent.getInventory().setActiveHotbarSlot((byte) originalSlot);

// Send packet to force client to the correct slot
SetActiveSlot setActiveSlotPacket = new SetActiveSlot(
    Inventory.HOTBAR_SECTION_ID,  // -1 indicates the hotbar
    originalSlot                   // The slot index to select
);
playerRef.getPacketHandler().write(setActiveSlotPacket);
```

---

## Part 5: Thread Safety

Packet handlers run on network threads, but entity operations must run on the world thread. Always use `world.execute()`:

```java
Ref<EntityStore> entityRef = playerRef.getReference();
Store<EntityStore> store = entityRef.getStore();
World world = store.getExternalData().getWorld();

world.execute(() -> {
    // Entity operations here are thread-safe
    Player playerComponent = store.getComponent(entityRef, Player.getComponentType());
    // ...
});
```

---

## Part 6: Triggering Abilities

### Running Commands

```java
CommandManager.get().handleCommand(playerRef, "noon");
```

### Spawning Projectiles

```java
ProjectileModule.get().spawnProjectile(/* config */);
// Use TargetUtil.getLook for player's eye position
```

---

## Part 7: Multiple Ability Slots

```java
public class MultiAbilityHandler implements PlayerPacketFilter {
    private static final int ABILITY_SLOT_1 = 6;  // Key "7"
    private static final int ABILITY_SLOT_2 = 7;  // Key "8"
    private static final int ABILITY_SLOT_3 = 8;  // Key "9"
    
    @Override
    public boolean test(@Nonnull PlayerRef playerRef, @Nonnull Packet packet) {
        if (!(packet instanceof SyncInteractionChains syncPacket)) {
            return false;
        }
        
        for (SyncInteractionChain chain : syncPacket.updates) {
            if (chain.interactionType == InteractionType.SwapFrom
                    && chain.data != null
                    && chain.initial) {
                
                int targetSlot = chain.data.targetSlot;
                int originalSlot = chain.activeHotbarSlot;
                
                switch (targetSlot) {
                    case ABILITY_SLOT_1 -> {
                        handleAbility1(playerRef, originalSlot);
                        return true;
                    }
                    case ABILITY_SLOT_2 -> {
                        handleAbility2(playerRef, originalSlot);
                        return true;
                    }
                    case ABILITY_SLOT_3 -> {
                        handleAbility3(playerRef, originalSlot);
                        return true;
                    }
                }
            }
        }
        return false;
    }
}
```

---

## Part 8: Cooldowns

```java
private final Map<UUID, Long> cooldowns = new ConcurrentHashMap<>();
private static final long COOLDOWN_MS = 5000;  // 5 seconds

private boolean isOnCooldown(PlayerRef playerRef) {
    UUID playerId = playerRef.getUUID();
    Long lastUse = cooldowns.get(playerId);
    
    if (lastUse == null) {
        return false;
    }
    
    return System.currentTimeMillis() - lastUse < COOLDOWN_MS;
}

private void startCooldown(PlayerRef playerRef) {
    cooldowns.put(playerRef.getUUID(), System.currentTimeMillis());
}

private void handleAbilityTrigger(PlayerRef playerRef, int originalSlot) {
    if (isOnCooldown(playerRef)) {
        playerRef.sendMessage(Message.raw("Ability on cooldown!").color(Color.RED));
        return;
    }
    
    startCooldown(playerRef);
    // ... rest of ability logic
}
```

---

## Debugging Tips

### Log Packet Data

```java
plugin.getLogger().at(Level.INFO).log(
    "[DEBUG] Packet: %s, type=%s, activeSlot=%d, targetSlot=%d",
    playerRef.getUsername(),
    chain.interactionType,
    chain.activeHotbarSlot,
    chain.data != null ? chain.data.targetSlot : -1
);
```

### Common Issues

| Problem | Solution |
|---------|----------|
| Nothing happens when pressing key | Check filter registration in startup logs |
| Ability fires but wrong slot selected | Verify `SetActiveSlot` is sent correctly |
| Thread/null errors | Use `entityRef.isValid()`, null-check components, use `world.execute()` |

---

## Complete Example

```java
package com.example.abilities;

import com.hypixel.hytale.protocol.Packet;
import com.hypixel.hytale.protocol.InteractionType;
import com.hypixel.hytale.protocol.packets.interaction.SyncInteractionChain;
import com.hypixel.hytale.protocol.packets.interaction.SyncInteractionChains;
import com.hypixel.hytale.protocol.packets.inventory.SetActiveSlot;
import com.hypixel.hytale.server.HytaleServerPlugin;
import com.hypixel.hytale.server.core.Message;
import com.hypixel.hytale.server.core.Color;
import com.hypixel.hytale.server.core.io.adapter.PacketAdapters;
import com.hypixel.hytale.server.core.io.adapter.PacketFilter;
import com.hypixel.hytale.server.core.io.adapter.PlayerPacketFilter;
import com.hypixel.hytale.server.core.inventory.Inventory;
import com.hypixel.hytale.server.core.universe.PlayerRef;
import com.hypixel.hytale.server.core.universe.Store;
import com.hypixel.hytale.server.core.universe.entity.EntityStore;
import com.hypixel.hytale.server.core.universe.entity.Ref;
import com.hypixel.hytale.server.player.Player;
import com.hypixel.hytale.server.world.World;

import javax.annotation.Nonnull;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

public class AbilityPlugin extends HytaleServerPlugin {
    private PacketFilter inboundFilter;
    
    @Override
    protected void setup() {
        AbilitySlotHandler handler = new AbilitySlotHandler(this);
        inboundFilter = PacketAdapters.registerInbound(handler);
        getLogger().info("Ability slot handler registered!");
    }
    
    @Override
    protected void shutdown() {
        if (inboundFilter != null) {
            PacketAdapters.deregisterInbound(inboundFilter);
        }
    }
}

class AbilitySlotHandler implements PlayerPacketFilter {
    private static final int ABILITY_SLOT = 8;
    private static final long COOLDOWN_MS = 3000;
    
    private final AbilityPlugin plugin;
    private final Map<UUID, Long> cooldowns = new ConcurrentHashMap<>();
    
    public AbilitySlotHandler(AbilityPlugin plugin) {
        this.plugin = plugin;
    }
    
    @Override
    public boolean test(@Nonnull PlayerRef playerRef, @Nonnull Packet packet) {
        if (!(packet instanceof SyncInteractionChains syncPacket)) {
            return false;
        }
        
        for (SyncInteractionChain chain : syncPacket.updates) {
            if (chain.interactionType == InteractionType.SwapFrom
                    && chain.data != null
                    && chain.data.targetSlot == ABILITY_SLOT
                    && chain.initial) {
                
                handleAbilityTrigger(playerRef, chain.activeHotbarSlot);
                return true;
            }
        }
        return false;
    }
    
    private void handleAbilityTrigger(PlayerRef playerRef, int originalSlot) {
        // Check cooldown
        UUID playerId = playerRef.getUUID();
        Long lastUse = cooldowns.get(playerId);
        if (lastUse != null && System.currentTimeMillis() - lastUse < COOLDOWN_MS) {
            playerRef.sendMessage(Message.raw("Ability on cooldown!").color(Color.RED));
            fixClientSlot(playerRef, originalSlot);
            return;
        }
        
        Ref<EntityStore> entityRef = playerRef.getReference();
        if (entityRef == null || !entityRef.isValid()) {
            return;
        }
        
        Store<EntityStore> store = entityRef.getStore();
        World world = store.getExternalData().getWorld();
        
        world.execute(() -> {
            Player playerComponent = store.getComponent(entityRef, Player.getComponentType());
            if (playerComponent == null) {
                return;
            }
            
            // Fix client state
            playerComponent.getInventory().setActiveHotbarSlot((byte) originalSlot);
            fixClientSlot(playerRef, originalSlot);
            
            // Start cooldown
            cooldowns.put(playerId, System.currentTimeMillis());
            
            // Trigger ability
            playerRef.sendMessage(Message.raw("⚡ Ability activated!").color(Color.YELLOW));
        });
    }
    
    private void fixClientSlot(PlayerRef playerRef, int slot) {
        SetActiveSlot packet = new SetActiveSlot(Inventory.HOTBAR_SECTION_ID, slot);
        playerRef.getPacketHandler().write(packet);
    }
}
```

---

## References

- [Customizing Hotbar Actions Guide](https://hytalemodding.dev/en/docs/guides/plugin/customizing-hotbar-actions)
- [Listening to Packets Guide](https://hytalemodding.dev/en/docs/guides/plugin/listening-to-packets)
- [Thread Safety: Using world.execute()](https://forum.hytalemodding.dev/d/21-thread-safety-using-worldexecute)
