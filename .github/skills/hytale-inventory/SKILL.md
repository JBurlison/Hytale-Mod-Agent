---
name: hytale-inventory
description: Manages player inventories in Hytale plugins using Inventory, ItemStack, ItemContainer, and PageManager APIs. Use when accessing player inventory, creating items, adding/removing items from slots, opening inventory pages, setting durability, or attaching custom metadata to items. Triggers - inventory, ItemStack, ItemContainer, Inventory, getInventory, addItemStack, removeItemStack, PageManager, Page, getStorage, getHotbar, getArmor, getBackpack, durability, item metadata, BsonDocument, slot, inventory page.
---

# Hytale Inventory Management

Use this skill when managing player inventories, creating items, opening inventory pages, or manipulating item containers in Hytale plugins.

> **Related skills:** For persistent player data, see `hytale-persistent-data`. For notifications with item icons, see `hytale-notifications`. For hotbar key actions, see `hytale-hotbar-actions`. For inventory change events, see `hytale-events`.

---

## Quick Reference

| Task | Approach |
|------|----------|
| Get player inventory | `player.getInventory()` |
| Create an item | `new ItemStack("Stone")` or `new ItemStack("Stone", 64)` |
| Create item with metadata | `new ItemStack("Stone", 64, bsonDocument)` |
| Create item with durability | `new ItemStack(itemId, qty, durability, maxDurability, metadata)` |
| Get storage container | `inventory.getStorage()` |
| Get hotbar container | `inventory.getHotbar()` |
| Get armor container | `inventory.getArmor()` |
| Get backpack container | `inventory.getBackpack()` |
| Get utility container | `inventory.getUtility()` |
| Add item to container | `container.addItemStack(itemStack)` |
| Add item to specific slot | `container.addItemStackToSlot((short) slot, itemStack)` |
| Remove item from container | `container.removeItemStack(itemStack)` |
| Remove item from slot | `container.removeItemStackFromSlot((short) slot)` |
| Open an inventory page | `pageManager.setPage(ref, store, Page.Inventory)` |

---

## Required Imports

```java
import com.hypixel.hytale.server.item.ItemStack;
import com.hypixel.hytale.server.item.ItemContainer;
import com.hypixel.hytale.server.core.entity.entities.player.Inventory;
import com.hypixel.hytale.server.core.entity.entities.player.pages.Page;
import com.hypixel.hytale.server.core.entity.entities.player.pages.PageManager;
import com.hypixel.hytale.server.ecs.entity.EntityStore;
import com.hypixel.hytale.server.ecs.Store;
import org.bson.BsonDocument;
import org.bson.BsonString;
```

---

## Accessing the Player Inventory

Get the `Inventory` object from a `Player` instance:

```java
Inventory inventory = player.getInventory();
```

---

## ItemStack

`ItemStack` represents a stack of items with a material type, quantity, optional metadata, and optional durability.

### Creating an ItemStack

```java
// Basic item (quantity defaults to 1)
ItemStack item = new ItemStack("Stone");

// Item with quantity
ItemStack stack = new ItemStack("Stone", 64);
```

### ItemStack with Custom Metadata

Attach arbitrary BSON metadata to items:

```java
BsonDocument metadata = new BsonDocument();
metadata.append("customData", new BsonString("value"));

ItemStack item = new ItemStack("Stone", 64, metadata);
```

### ItemStack with Durability

Create items that have durability (e.g., tools, weapons):

```java
ItemStack sword = new ItemStack(
    "DiamondSword",  // itemId
    1,               // quantity
    100.0,           // durability
    100.0,           // maxDurability
    metadata         // metadata (optional, can be null)
);
```

| Constructor Parameter | Type | Description |
|----------------------|------|-------------|
| `itemId` | `String` | The item identifier (e.g., `"Stone"`, `"DiamondSword"`) |
| `quantity` | `int` | Number of items in the stack |
| `durability` | `double` | Current durability value |
| `maxDurability` | `double` | Maximum durability value |
| `metadata` | `BsonDocument` | Optional custom metadata (nullable) |

---

## ItemContainer

`ItemContainer` represents a specific section of inventory (storage, hotbar, armor, etc.). All add/remove operations are performed on an `ItemContainer`.

### Getting an ItemContainer

The `Inventory` class provides methods to get individual containers:

| Method | Returns | Description |
|--------|---------|-------------|
| `.getStorage()` | `ItemContainer` | Main storage slots |
| `.getHotbar()` | `ItemContainer` | Hotbar slots |
| `.getArmor()` | `ItemContainer` | Armor equipment slots |
| `.getBackpack()` | `ItemContainer` | Backpack slots |
| `.getUtility()` | `ItemContainer` | Utility slots |

### Combined Containers

For operations that span multiple containers, use combined methods:

| Method | Combines |
|--------|----------|
| `.getCombinedEverything()` | All containers |
| `.getCombinedArmorHotbarStorage()` | Armor + Hotbar + Storage |
| `.getCombinedBackpackStorageHotbar()` | Backpack + Storage + Hotbar |
| `.getCombinedHotbarFirst()` | Hotbar (priority) + others |
| `.getCombinedStorageFirst()` | Storage (priority) + others |
| `.getCombinedArmorHotbarUtilityStorage()` | Armor + Hotbar + Utility + Storage |
| `.getCombinedHotbarUtilityConsumableStorage()` | Hotbar + Utility + Consumable + Storage |

---

## Adding Items

### Add to First Available Slot

```java
Inventory inventory = player.getInventory();
ItemContainer storage = inventory.getStorage();

ItemStack item = new ItemStack("Stone", 64);
storage.addItemStack(item);
```

### Add to Specific Slot

```java
ItemContainer storage = inventory.getStorage();
ItemStack item = new ItemStack("Stone", 32);

storage.addItemStackToSlot((short) 4, item);
```

---

## Removing Items

### Remove by ItemStack

```java
Inventory inventory = player.getInventory();
ItemContainer storage = inventory.getStorage();

storage.removeItemStack(item);
```

### Remove from Specific Slot

```java
ItemContainer storage = inventory.getStorage();
storage.removeItemStackFromSlot((short) 4);
```

---

## Opening Inventory Pages

Use `PageManager` and the `Page` enum to open inventory UI screens for a player.

### Available Pages

| Page | Description |
|------|-------------|
| `Page.None` | Close any open page |
| `Page.Bench` | Crafting bench |
| `Page.Inventory` | Player inventory screen |
| `Page.ToolsSettings` | Tools/settings page |
| `Page.Map` | Map page |
| `Page.MachinimaEditor` | Machinima editor |
| `Page.ContentCreation` | Content creation page |
| `Page.Custom` | Custom page (for plugin UIs) |

### Opening a Page

```java
PageManager pageManager = player.getPageManager();
Store<EntityStore> store = player.getWorld().getEntityStore().getStore();

pageManager.setPage(player.getReference(), store, Page.Inventory);
```

### Closing a Page

```java
PageManager pageManager = player.getPageManager();
Store<EntityStore> store = player.getWorld().getEntityStore().getStore();

pageManager.setPage(player.getReference(), store, Page.None);
```

---

## Common Patterns

### Give Items on Event

```java
public void onPlayerReady(PlayerReadyEvent event) {
    var player = event.getPlayer();
    Inventory inventory = player.getInventory();
    ItemContainer hotbar = inventory.getHotbar();

    hotbar.addItemStackToSlot((short) 0, new ItemStack("Weapon_Sword_Iron", 1));
    hotbar.addItemStackToSlot((short) 1, new ItemStack("Tool_Pickaxe_Iron", 1));
    hotbar.addItemStackToSlot((short) 2, new ItemStack("Food_Apple", 16));
}
```

### Clear Inventory

```java
public void clearPlayerInventory(Player player) {
    Inventory inventory = player.getInventory();
    ItemContainer storage = inventory.getStorage();
    ItemContainer hotbar = inventory.getHotbar();
    ItemContainer armor = inventory.getArmor();

    // Remove items from each slot
    for (short i = 0; i < storage.getSize(); i++) {
        storage.removeItemStackFromSlot(i);
    }
    for (short i = 0; i < hotbar.getSize(); i++) {
        hotbar.removeItemStackFromSlot(i);
    }
    for (short i = 0; i < armor.getSize(); i++) {
        armor.removeItemStackFromSlot(i);
    }
}
```

### Give Item with Metadata

```java
public void giveCustomItem(Player player, String itemId, String customTag, String value) {
    BsonDocument metadata = new BsonDocument();
    metadata.append(customTag, new BsonString(value));

    ItemStack item = new ItemStack(itemId, 1, metadata);
    player.getInventory().getStorage().addItemStack(item);
}
```

### Give Durable Tool

```java
public void giveTool(Player player, String toolId, double maxDurability) {
    ItemStack tool = new ItemStack(
        toolId,
        1,
        maxDurability,
        maxDurability,
        null
    );
    player.getInventory().getHotbar().addItemStack(tool);
}
```

---

## Related Events

| Event | Fires When |
|-------|------------|
| `LivingEntityInventoryChangeEvent` | An entity's inventory changes |
| `ItemContainerChangeEvent` | An item container is modified |

---

## Best Practices

1. **Use the correct container** — Add items to the appropriate container (hotbar for tools, armor for equipment, storage for general items).
2. **Use combined containers for searches** — When checking if a player has an item, use `getCombinedEverything()` or the appropriate combined method.
3. **Cast slot indices to `short`** — Slot methods require `(short)` cast for the index parameter.
4. **Null-check metadata** — The metadata `BsonDocument` parameter is optional and can be `null`.
5. **Use `Page.None` to close** — Always close pages with `Page.None` when done.
6. **Localize item names** — Use translation keys for any user-facing item text.

---

## References

- [Inventory Management Guide](https://hytalemodding.dev/en/docs/guides/plugin/inventory-management)
- [Hotbar Actions Skill](../hytale-hotbar-actions/SKILL.md) — Custom hotbar key handling
- [Notifications Skill](../hytale-notifications/SKILL.md) — Item icons in notifications
- [UI Modding Skill](../hytale-ui-modding/SKILL.md) — Custom pages and UI

```
