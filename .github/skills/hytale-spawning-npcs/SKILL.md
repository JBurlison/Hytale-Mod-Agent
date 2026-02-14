---
name: hytale-spawning-npcs
description: Spawns NPCs in Hytale plugins using the NPCPlugin helper. Use when spawning NPCs, equipping NPC inventory, setting NPC armor, creating NPC commands, or working with INonPlayerCharacter. Triggers - NPC, spawn NPC, NPCPlugin, INonPlayerCharacter, NPCEntity, NPC inventory, NPC armor, Kweebec, spawnNPC, NPC command.
---

# Hytale Spawning NPCs Skill

Use this skill when spawning Non-Player Characters (NPCs) using the `NPCPlugin` helper. This is the convenient alternative to manually spawning entities with `Holder<EntityStore>`.

> Prerequisite: Familiarity with the Entity Component System (ECS). See the `hytale-ecs` skill.

---

## Quick Reference

| Concept | Description |
|---------|-------------|
| **NPCPlugin** | Helper class that simplifies NPC spawning |
| **INonPlayerCharacter** | Interface providing NPC-specific methods |
| **NPCEntity** | Component for accessing NPC inventory and settings |
| **Ref\<EntityStore\>** | ECS reference to the spawned NPC entity |
| **InventoryHelper** | Hytale API utility for equipping armor |
| **Inventory** | Object for managing NPC hotbar, armor, and items |

---

## Required Imports

```java
import com.example.npc.NPCPlugin; // Adjust import as necessary
import hytale.server.plugin.npc.INonPlayerCharacter;
import hytale.server.plugin.npc.NPCEntity;
import com.hypixel.hytale.server.core.universe.PlayerRef;
import com.hypixel.hytale.server.core.universe.Universe;
import com.hypixel.hytale.server.core.universe.world.World;
import com.hypixel.hytale.server.core.universe.world.storage.EntityStore;
import com.hypixel.hytale.component.Ref;
import com.hypixel.hytale.component.Store;
import com.hypixel.hytale.math.vector.Vector3d;
import com.hypixel.hytale.math.vector.Vector3f;
import com.hypixel.hytale.server.core.inventory.Inventory;
import com.hypixel.hytale.server.core.inventory.InventoryHelper;
import com.hypixel.hytale.server.core.inventory.ItemStack;
import com.hypixel.hytale.server.core.command.system.CommandContext;
import org.apache.commons.lang3.tuple.Pair;
import java.util.Objects;
```

---

## Step-by-Step Process

### 1. Spawn the NPC

Use `NPCPlugin.get().spawnNPC(...)` to create the entity, assign its model, and position it in the world.

```java
Pair<Ref<EntityStore>, INonPlayerCharacter> result = NPCPlugin.get().spawnNPC(
    store,              // The entity store where the NPC will exist
    "Kweebec_Sapling",  // The key/name of the entity model/type
    null,               // Optional configuration (null for defaults)
    position,           // Vec3d position to spawn at
    rotation            // Vec3f facing direction
);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `store` | `Store<EntityStore>` | The entity store where the NPC will exist |
| `entityKey` | `String` | The key/name of the entity model/type (e.g., `"Kweebec_Sapling"`) |
| `config` | `Object` | Optional configuration, pass `null` for defaults |
| `position` | `Vector3d` | World position to spawn the NPC |
| `rotation` | `Vector3f` | Facing direction of the NPC |

### 2. Handle the Result

The method returns a `Pair`. Always check for `null` to confirm the spawn succeeded.

```java
if (result != null) {
    Ref<EntityStore> npcRef = result.first();       // ECS entity reference
    INonPlayerCharacter npc = result.second();       // NPC-specific interface

    // Proceed with customization...
    setupNPCInventory(npcRef, store);
}
```

| Return | Type | Description |
|--------|------|-------------|
| `result.first()` | `Ref<EntityStore>` | ECS reference to add components or modify the entity |
| `result.second()` | `INonPlayerCharacter` | NPC-specific methods interface |

### 3. Access the NPC Inventory

Retrieve the `NPCEntity` component to access inventory settings:

```java
NPCEntity npcComponent = store.getComponent(
    npcRef, 
    Objects.requireNonNull(NPCEntity.getComponentType())
);

// Initialize inventory size (rows, columns, offset)
npcComponent.setInventorySize(3, 9, 0);
```

### 4. Add Items and Armor

Use the `Inventory` object to equip items and armor:

```java
Inventory inventory = npcComponent.getInventory();

// Add a weapon to the first hotbar slot
inventory.getHotbar().addItemStackToSlot((short) 0, new ItemStack("Weapon_Mace_Thorium", 1));

// Equip armor using InventoryHelper (Hytale API utility)
InventoryHelper.useArmor(inventory.getArmor(), "Armor_Thorium_Head");

// Set the active hotbar slot to the weapon
inventory.setActiveHotbarSlot((byte) 0);
```

---

## Complete Example - NPC Spawn Command

```java
import com.example.npc.NPCPlugin;
import hytale.server.plugin.npc.INonPlayerCharacter;
import hytale.server.plugin.npc.NPCEntity;
import com.hypixel.hytale.component.Ref;
import com.hypixel.hytale.component.Store;
import com.hypixel.hytale.math.vector.Vector3d;
import com.hypixel.hytale.math.vector.Vector3f;
import com.hypixel.hytale.server.core.command.system.CommandContext;
import com.hypixel.hytale.server.core.inventory.Inventory;
import com.hypixel.hytale.server.core.inventory.InventoryHelper;
import com.hypixel.hytale.server.core.inventory.ItemStack;
import com.hypixel.hytale.server.core.universe.PlayerRef;
import com.hypixel.hytale.server.core.universe.world.World;
import com.hypixel.hytale.server.core.universe.world.storage.EntityStore;
import org.apache.commons.lang3.tuple.Pair;

import javax.annotation.Nonnull;
import java.util.Objects;

public class SpawnNpcCommand extends AbstractPlayerCommand {

    public SpawnNpcCommand() {
        super("npc", "spawn npc");
    }

    @Override
    protected void execute(
            @Nonnull CommandContext commandContext,
            @Nonnull Store<EntityStore> store,
            @Nonnull Ref<EntityStore> ref,
            @Nonnull PlayerRef playerRef,
            @Nonnull World world) {

        // Get the player's current position
        Vector3d position = playerRef.getTransform().getPosition();

        // Define the initial rotation (facing direction)
        Vector3f rotation = new Vector3f(0, 0, 0);

        // Spawn the NPC using NPCPlugin helper
        Pair<Ref<EntityStore>, INonPlayerCharacter> result = NPCPlugin.get().spawnNPC(
                store, "Kweebec_Sapling", null, position, rotation);

        if (result != null) {
            Ref<EntityStore> npcRef = result.first();
            INonPlayerCharacter npc = result.second();

            // Set up the NPC's inventory and equipment
            setupNPCInventory(npcRef, store);
        }
    }

    /**
     * Configures the inventory for the spawned NPC.
     */
    public void setupNPCInventory(Ref<EntityStore> npcRef, Store<EntityStore> store) {
        NPCEntity npcComponent = store.getComponent(
                npcRef, Objects.requireNonNull(NPCEntity.getComponentType()));

        if (npcComponent == null)
            return;

        // Initialize inventory size (3 rows, 9 columns, 0 offset)
        npcComponent.setInventorySize(3, 9, 0);

        // Add items to the initialized inventory
        addItemsToNPCInventory(npcComponent.getInventory());
    }

    /**
     * Adds specific items and armor to the NPC's inventory.
     */
    public void addItemsToNPCInventory(Inventory inventory) {
        // Add a Thorium Mace to the first hotbar slot
        inventory.getHotbar().addItemStackToSlot((short) 0, new ItemStack("Weapon_Mace_Thorium", 1));

        // Equip a Thorium Helmet
        InventoryHelper.useArmor(inventory.getArmor(), "Armor_Thorium_Head");

        // Set the active hotbar slot to the weapon
        inventory.setActiveHotbarSlot((byte) 0);
    }
}
```

---

## Registering the Command

Register the command in your main plugin class:

```java
public class MyHytaleMod extends JavaPlugin {
    @Override
    protected void setup() {
        this.getCommandRegistry().registerCommand(new SpawnNpcCommand());
    }
}
```

---

## Key Points

1. **NPCPlugin simplifies spawning**: Abstracts Holder boilerplate — creates the entity, attaches the model, and positions it automatically.
2. **Always null-check the result**: `spawnNPC()` can return `null` if spawning fails.
3. **Initialize inventory before adding items**: Call `npcComponent.setInventorySize(rows, cols, offset)` before accessing the inventory.
4. **InventoryHelper for armor**: Use `InventoryHelper.useArmor()` — a Hytale API utility — to equip armor pieces.
5. **Entity key is the model/type name**: Pass the NPC type key (e.g., `"Kweebec_Sapling"`) matching assets in the server data.
6. **ECS reference for further modification**: Use `result.first()` (`Ref<EntityStore>`) to add/remove components on the NPC after spawning.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `spawnNPC()` returns `null` | Verify the entity key (e.g., `"Kweebec_Sapling"`) matches a valid entity type |
| NPC has no items | Ensure `setInventorySize()` is called before adding items |
| NPC not visible | Confirm the spawn position is within a loaded chunk |
| `NPCEntity.getComponentType()` returns `null` | Verify NPCPlugin dependency is loaded and entity module is available |
| NPC facing wrong direction | Adjust the `Vector3f rotation` values |

---

## Related Skills

- `hytale-ecs` — Entity Component System patterns
- `hytale-items` — Item registry and ItemStack usage
- `hytale-commands` — Command creation patterns

---

## Reference

- Source: [Hytale Modding - Spawning NPCs Guide](https://hytalemodding.dev/en/docs/guides/plugin/spawning-npcs)
