---
name: hytale-items
description: Documents Hytale's item system including the Item Registry API, custom item JSON definitions, crafting recipes, custom interactions (SimpleInstantInteraction), interaction chaining (Condition, Charging, Serial, Replace), and linking interactions to items. Use when creating custom items, querying the item registry, defining crafting recipes, building item interactions, or working with ItemStack. Triggers - item, custom item, item registry, Item.getAssetMap, DefaultAssetMap, ItemStack, item JSON, item definition, crafting recipe, interaction, SimpleInstantInteraction, InteractionContext, InteractionType, item interaction, Charging, Condition, Serial, Replace, item properties, MaxStack, Categories, item ID.
---

# Hytale Items & Interactions

Comprehensive reference for creating custom items, querying the item registry, defining crafting recipes, and building custom interactions in Hytale plugins.

> **Related skills:** For persistent data/Codec patterns, see `hytale-persistent-data`. For ECS fundamentals, see `hytale-ecs`. For inventory management, see the Hytale inventory APIs. For entity effects applied by items, see `hytale-entity-effects`.

## Quick Reference

| Task | Approach |
|------|----------|
| Get item registry | `Item.getAssetMap()` returns `DefaultAssetMap<String, Item>` |
| Check if item exists | `assetMap.getAsset(id)` — check for `null` and `Item.UNKNOWN` |
| Get item properties | `item.getId()`, `item.getMaxStack()`, `item.hasBlockType()`, `item.isConsumable()` |
| List all items | `Item.getAssetMap().getAssetMap().entrySet()` |
| Define custom item | JSON in `Server/Item/Items/<name>.json` |
| Define crafting recipe | `"Recipe"` block inside item JSON |
| Create custom interaction | Extend `SimpleInstantInteraction`, add `BuilderCodec`, register in `setup()` |
| Link interaction to item | `"Interactions"` block in item JSON with interaction type ID |
| Chain interactions | Nest `Condition`, `Charging`, `Serial`, `Replace` in JSON |

---

## Item Registry API

### Required Imports

```java
import com.hypixel.hytale.assetstore.map.DefaultAssetMap;
import com.hypixel.hytale.server.core.asset.type.item.config.Item;
```

### Getting the Registry

```java
DefaultAssetMap<String, Item> itemMap = Item.getAssetMap();
```

### Listing All Items

```java
DefaultAssetMap<String, Item> itemMap = Item.getAssetMap();
var map = itemMap.getAssetMap();

for (var entry : map.entrySet()) {
    String itemId = String.valueOf(entry.getKey());
    Item item = entry.getValue();
    LOGGER.atInfo().log("Item ID: " + itemId);
}

int totalItems = map.size();
```

### Checking if an Item Exists

```java
public boolean itemExists(String itemId) {
    var assetMap = Item.getAssetMap();
    if (assetMap != null) {
        Item item = assetMap.getAsset(itemId);
        return item != null && item != Item.UNKNOWN;
    }
    return false;
}
```

> **Important:** `Item.UNKNOWN` represents an invalid or unrecognized item. Always check for both `null` and `Item.UNKNOWN` when validating items.

### Accessing Item Properties

```java
var assetMap = Item.getAssetMap();
Item item = assetMap.getAsset("Soil_Grass");

if (item != null && item != Item.UNKNOWN) {
    String id = item.getId();              // "Soil_Grass"
    int maxStack = item.getMaxStack();     // 100
    boolean isBlock = item.hasBlockType(); // true
    boolean isConsumable = item.isConsumable(); // false
}
```

---

## Custom Item Definition

### Folder Structure

Enable asset packs in `manifest.json` by setting `IncludesAssetPack` to `true`, then create:

```
resources/
├── Server/
│   └── Item/
│       └── Items/
│           └── my_new_item.json          # Item definition
└── Common/
    ├── Icons/
    │   └── ItemsGenerated/
    │       └── my_new_item_icon.png      # Inventory icon
    └── Items/
        └── my_new_item/
            ├── model.blockymodel         # 3D model
            └── model_texture.png         # Model texture
```

| File | Location | Purpose |
|------|----------|---------|
| `my_new_item.json` | `Server/Item/Items` | Defines item properties and behavior |
| `my_new_item_icon.png` | `Common/Icons/ItemsGenerated` | Icon for the item in inventory |
| `model.blockymodel` | `Common/Items/my_new_item` | 3D model of the item |
| `model_texture.png` | `Common/Items/my_new_item` | Texture for the item model |

### Item JSON Schema

```json
{
  "TranslationProperties": {
    "Name": "My New Item",
    "Description": "My New Item Description"
  },
  "Id": "My_New_Item",
  "Icon": "Icons/ItemsGenerated/my_new_item_icon.png",
  "Model": "Items/my_new_item/model.blockymodel",
  "Texture": "Items/my_new_item/model_texture.png",
  "Quality": "Common",
  "MaxStack": 1,
  "Categories": [
    "Items.Example"
  ]
}
```

### Key Item Properties

| Property | Type | Description |
|----------|------|-------------|
| `Id` | `String` | Unique identifier for the item (used in registry lookups) |
| `TranslationProperties.Name` | `String` | Display name (or localization key) |
| `TranslationProperties.Description` | `String` | Item description (or localization key) |
| `Icon` | `String` | Path to inventory icon (relative to `Common/`) |
| `Model` | `String` | Path to 3D model file (relative to `Common/`) |
| `Texture` | `String` | Path to model texture (relative to `Common/`) |
| `Quality` | `String` | Item quality/rarity tier (e.g., `"Common"`) |
| `MaxStack` | `int` | Maximum stack size |
| `Categories` | `String[]` | Tags/categories for the item |

---

## Crafting Recipes

Add a `"Recipe"` block to the item JSON to make it craftable:

```json
{
  "TranslationProperties": { "Name": "My New Item" },
  "Id": "My_New_Item",
  "Icon": "Icons/ItemsGenerated/my_new_item_icon.png",
  "Model": "Items/my_new_item/model.blockymodel",
  "Texture": "Items/my_new_item/model_texture.png",
  "Quality": "Common",
  "MaxStack": 1,
  "Categories": ["Items.Example"],

  "Recipe": {
    "TimeSeconds": 3.5,
    "Input": [
      { "ItemId": "Ingredient_1", "Quantity": 15 },
      { "ItemId": "Ingredient_2", "Quantity": 15 },
      { "ItemId": "Ingredient_3", "Quantity": 15 }
    ],
    "BenchRequirement": [
      {
        "Id": "Workbench",
        "Type": "Crafting",
        "Categories": ["Workbench_Survival"]
      }
    ]
  }
}
```

### Recipe Properties

| Property | Type | Description |
|----------|------|-------------|
| `TimeSeconds` | `float` | Time in seconds to craft the item |
| `Input` | `Array` | List of ingredient items with `ItemId` and `Quantity` |
| `BenchRequirement` | `Array` | Required crafting station(s) |
| `BenchRequirement[].Id` | `String` | Bench identifier |
| `BenchRequirement[].Type` | `String` | Bench type (e.g., `"Crafting"`) |
| `BenchRequirement[].Categories` | `String[]` | Which bench tab/category |

---

## Custom Interactions

Custom interactions define what happens when a player uses an item. They are implemented in Java and linked via JSON.

### Step 1: Create the Interaction Class

Extend `SimpleInstantInteraction` and override `firstRun`:

```java
import com.hypixel.hytale.server.core.asset.type.item.interaction.SimpleInstantInteraction;
import com.hypixel.hytale.server.core.asset.type.item.interaction.InteractionType;
import com.hypixel.hytale.server.core.asset.type.item.interaction.InteractionContext;
import com.hypixel.hytale.server.core.asset.type.item.interaction.CooldownHandler;
import com.hypixel.hytale.server.core.asset.type.item.interaction.Interaction;
import com.hypixel.hytale.codec.BuilderCodec;

import javax.annotation.Nonnull;

public class MyCustomInteraction extends SimpleInstantInteraction {

    public static final BuilderCodec<MyCustomInteraction> CODEC = BuilderCodec.builder(
            MyCustomInteraction.class, MyCustomInteraction::new, SimpleInstantInteraction.CODEC
    ).build();

    @Override
    protected void firstRun(
            @Nonnull InteractionType interactionType,
            @Nonnull InteractionContext interactionContext,
            @Nonnull CooldownHandler cooldownHandler) {
        // Custom behavior when the item is used
    }
}
```

### Step 2: Register the Interaction

Register in your plugin's `setup()` method:

```java
public class MyPlugin extends JavaPlugin {

    public MyPlugin(@Nonnull JavaPluginInit init) {
        super(init);
    }

    @Override
    protected void setup() {
        this.getCodecRegistry(Interaction.CODEC)
            .register("my_custom_interaction_id", MyCustomInteraction.class, MyCustomInteraction.CODEC);
    }
}
```

### Step 3: Link Interaction to Item JSON

Add the `"Interactions"` block to the item definition:

```json
{
  "Id": "My_New_Item",
  "Interactions": {
    "Secondary": {
      "Interactions": [
        {
          "Type": "my_custom_interaction_id"
        }
      ]
    }
  }
}
```

The interaction type key (`"Secondary"`, `"Primary"`, etc.) determines which player action triggers it.

---

## Full Interaction Example

A complete interaction that sends a message with the item ID to the player:

```java
import com.hypixel.hytale.server.core.asset.type.item.interaction.SimpleInstantInteraction;
import com.hypixel.hytale.server.core.asset.type.item.interaction.InteractionType;
import com.hypixel.hytale.server.core.asset.type.item.interaction.InteractionContext;
import com.hypixel.hytale.server.core.asset.type.item.interaction.InteractionState;
import com.hypixel.hytale.server.core.asset.type.item.interaction.CooldownHandler;
import com.hypixel.hytale.server.ecs.store.EntityStore;
import com.hypixel.hytale.server.ecs.ref.Ref;
import com.hypixel.hytale.server.ecs.store.Store;
import com.hypixel.hytale.server.ecs.CommandBuffer;
import com.hypixel.hytale.server.player.Player;
import com.hypixel.hytale.server.item.ItemStack;
import com.hypixel.hytale.server.world.World;
import com.hypixel.hytale.codec.BuilderCodec;
import com.hypixel.hytale.server.logging.HytaleLogger;
import com.hypixel.hytale.server.text.Message;

import javax.annotation.Nonnull;

public class SendMessageInteraction extends SimpleInstantInteraction {

    public static final BuilderCodec<SendMessageInteraction> CODEC = BuilderCodec.builder(
            SendMessageInteraction.class, SendMessageInteraction::new, SimpleInstantInteraction.CODEC
    ).build();

    public static final HytaleLogger LOGGER = HytaleLogger.forEnclosingClass();

    @Override
    protected void firstRun(
            @Nonnull InteractionType interactionType,
            @Nonnull InteractionContext interactionContext,
            @Nonnull CooldownHandler cooldownHandler) {

        CommandBuffer<EntityStore> commandBuffer = interactionContext.getCommandBuffer();
        if (commandBuffer == null) {
            interactionContext.getState().state = InteractionState.Failed;
            LOGGER.atInfo().log("CommandBuffer is null");
            return;
        }

        World world = commandBuffer.getExternalData().getWorld();
        Store<EntityStore> store = commandBuffer.getExternalData().getStore();
        Ref<EntityStore> ref = interactionContext.getEntity();

        Player player = commandBuffer.getComponent(ref, Player.getComponentType());
        if (player == null) {
            interactionContext.getState().state = InteractionState.Failed;
            LOGGER.atInfo().log("Player is null");
            return;
        }

        ItemStack itemStack = interactionContext.getHeldItem();
        if (itemStack == null) {
            interactionContext.getState().state = InteractionState.Failed;
            LOGGER.atInfo().log("ItemStack is null");
            return;
        }

        player.sendMessage(Message.raw("You have used the custom item +" + itemStack.getItemId()));
    }
}
```

### Key InteractionContext Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getCommandBuffer()` | `CommandBuffer<EntityStore>` | Access the command buffer for entity/component changes |
| `getEntity()` | `Ref<EntityStore>` | Reference to the entity using the item |
| `getHeldItem()` | `ItemStack` | The item being used |
| `getState()` | `InteractionStateHolder` | Get/set the interaction state (`Failed`, etc.) |

### Key CommandBuffer Methods (from InteractionContext)

| Method | Description |
|--------|-------------|
| `commandBuffer.getExternalData().getWorld()` | Get the current `World` |
| `commandBuffer.getExternalData().getStore()` | Get the entity `Store` |
| `commandBuffer.getComponent(ref, Type)` | Read a component from an entity |

---

## Advanced Interaction Chaining

Interactions are nestable — combine them to create complex behaviors triggered by a single item use.

### Condition

Check conditions before allowing the interaction to proceed:

```json
{
  "Type": "Condition",
  "Crouching": true,
  "Failed": "Block_Secondary",
  "Next": {
    // interaction to run if condition is met
  }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `Crouching` | `boolean` | Only proceed if player is crouching |
| `Failed` | `String` | Interaction type to run if condition fails |
| `Next` | `Object` | Interaction to run if condition passes |

### Charging

Require the player to hold the interaction for a duration before it activates:

```json
{
  "Type": "Charging",
  "FailsOnDamage": true,
  "HorizontalSpeedMultiplier": 0.4,
  "Next": {
    "2.5": {
      // interaction after 2.5 seconds of charging
    }
  },
  "Failed": {
    // interaction to run if charging fails/cancelled
  }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `FailsOnDamage` | `boolean` | Cancel charge if player takes damage |
| `HorizontalSpeedMultiplier` | `float` | Movement speed multiplier while charging |
| `Next` | `Object` | Map of duration (seconds) → interaction |
| `Failed` | `Object` | Interaction if charging is interrupted |

### Serial

Execute a sequence of interactions in order:

```json
{
  "Type": "Serial",
  "Interactions": [
    { /* first interaction */ },
    { /* second interaction */ }
  ]
}
```

### Replace

Replace the default interaction behavior (e.g., inherited from parent):

```json
{
  "Type": "Replace",
  "Var": "Item_Default_Interaction",
  "DefaultValue": {
    "Interactions": [
      { /* replacement interaction */ }
    ]
  }
}
```

### Simple

A basic interaction that performs a single action:

```json
{
  "Type": "Simple"
}
```

---

## Advanced Interaction Example

Require crouching + 2.5-second charge before executing a custom interaction:

```json
{
  "Interactions": {
    "Secondary": {
      "Interactions": [
        {
          "Type": "Condition",
          "Crouching": true,
          "Failed": "Block_Secondary",
          "Next": {
            "Type": "Charging",
            "FailsOnDamage": true,
            "HorizontalSpeedMultiplier": 0.5,
            "Next": {
              "2.5": {
                "Type": "my_custom_interaction_id"
              }
            },
            "Failed": {
              "Type": "Simple"
            }
          }
        }
      ]
    }
  }
}
```

---

## Interaction Codec with Custom Fields

If your interaction needs serialized fields, add them to the `BuilderCodec`:

```java
public class MyParameterizedInteraction extends SimpleInstantInteraction {

    private float radius;
    private String effectId;

    public static final BuilderCodec<MyParameterizedInteraction> CODEC = BuilderCodec.builder(
            MyParameterizedInteraction.class, MyParameterizedInteraction::new, SimpleInstantInteraction.CODEC
    )
    .add("Radius", KeyedCodec.FLOAT, i -> i.radius, (i, v) -> i.radius = v)
    .add("EffectId", KeyedCodec.STRING, i -> i.effectId, (i, v) -> i.effectId = v)
    .build();

    @Override
    protected void firstRun(
            @Nonnull InteractionType interactionType,
            @Nonnull InteractionContext interactionContext,
            @Nonnull CooldownHandler cooldownHandler) {
        // Use this.radius and this.effectId from JSON
    }
}
```

These fields can then be set from the item JSON:

```json
{
  "Interactions": {
    "Secondary": {
      "Interactions": [
        {
          "Type": "my_parameterized_interaction",
          "Radius": 5.0,
          "EffectId": "Burn"
        }
      ]
    }
  }
}
```

> **See also:** `hytale-persistent-data` skill for full Codec/BuilderCodec/KeyedCodec reference.

---

## Common Patterns

### Defensive Null Checks in Interactions

Always validate `CommandBuffer`, `Player`, and `ItemStack` before using them:

```java
@Override
protected void firstRun(@Nonnull InteractionType type,
                         @Nonnull InteractionContext ctx,
                         @Nonnull CooldownHandler cooldown) {
    CommandBuffer<EntityStore> cb = ctx.getCommandBuffer();
    if (cb == null) {
        ctx.getState().state = InteractionState.Failed;
        return;
    }

    Player player = cb.getComponent(ctx.getEntity(), Player.getComponentType());
    if (player == null) {
        ctx.getState().state = InteractionState.Failed;
        return;
    }

    ItemStack held = ctx.getHeldItem();
    if (held == null) {
        ctx.getState().state = InteractionState.Failed;
        return;
    }

    // Safe to proceed
}
```

### Looking Up Items at Runtime

```java
// Validate an item ID string at runtime
public Item resolveItem(String itemId) {
    var assetMap = Item.getAssetMap();
    if (assetMap == null) return null;
    Item item = assetMap.getAsset(itemId);
    if (item == null || item == Item.UNKNOWN) return null;
    return item;
}
```

---

## Checklist: Creating a Custom Item

1. [ ] Set `IncludesAssetPack: true` in `manifest.json`
2. [ ] Create item JSON in `Server/Item/Items/<name>.json`
3. [ ] Create inventory icon in `Common/Icons/ItemsGenerated/`
4. [ ] Create 3D model in `Common/Items/<name>/model.blockymodel`
5. [ ] Create model texture in `Common/Items/<name>/model_texture.png`
6. [ ] (Optional) Add `"Recipe"` block for crafting
7. [ ] (Optional) Create interaction class extending `SimpleInstantInteraction`
8. [ ] (Optional) Register interaction in plugin `setup()` via `getCodecRegistry(Interaction.CODEC).register(...)`
9. [ ] (Optional) Link interaction in item JSON via `"Interactions"` block
