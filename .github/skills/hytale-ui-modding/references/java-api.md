# Java UI API Reference

This project uses the native Hytale UI Java API. This reference covers the core classes and patterns for building custom UIs.

> **Important**: This project uses native Hytale UI only. Do not use HyUI library.

---

## Class Overview

| Class | Purpose |
|-------|---------|
| `CustomUIHud` | Persistent overlay elements (always visible) |
| `MultipleHUD` | Library enabling multiple simultaneous HUDs per player |
| `CustomUIPage` | Static full-screen modal pages |
| `InteractiveCustomUIPage<T>` | Interactive pages with event handling |
| `UICommandBuilder` | Java API for building/modifying UI |
| `UIEventBuilder` | Java API for binding events |

---

## CustomUIHud

CustomUIHud is used for persistent overlay elements that remain visible while the player plays.

**Important:** Hytale only supports one CustomUIHud per player by default. Use MultipleHUD when you need more than one HUD.

### Basic HUD Implementation

```java
import com.hypixel.hytale.server.core.entity.entities.player.hud.CustomUIHud;
import com.hypixel.hytale.server.core.ui.builder.UICommandBuilder;
import com.hypixel.hytale.server.core.universe.PlayerRef;

public class MyHud extends CustomUIHud {
    
    public MyHud(PlayerRef playerRef) {
        super(playerRef);
    }

    @Override
    protected void build(UICommandBuilder commandBuilder) {
        // Append a .ui file
        commandBuilder.append("Hud/MyHud.ui");
        
        // Or use inline UI:
        commandBuilder.appendInline(null, "Label #Status { Text: \"Hello\"; }");
    }
}
```

### Showing a HUD

```java
MyHud hud = new MyHud(playerRef);
hud.show();
```

### Updating a HUD

```java
// After building, you can send updates
UICommandBuilder commands = new UICommandBuilder();
commands.set("#Status.Text", "Updated text");
hud.sendUpdate(commands);
```

---

## MultipleHUD (MHUD)

By default, Hytale only allows **one** CustomUIHud per player. The MultipleHUD library (by Buuz135) provides a wrapper that allows multiple HUD elements simultaneously.

**Dependency:** Already included in project via CurseForge Maven (`com.buuz135:MultipleHUD:1.0.2`)

### Basic Usage

```java
import com.buuz135.mhud.MultipleHUD;
import com.hypixel.hytale.server.core.entity.entities.Player;
import com.hypixel.hytale.server.core.entity.entities.player.hud.CustomUIHud;
import com.hypixel.hytale.server.core.universe.PlayerRef;

// Add/replace a HUD with a unique identifier
MultipleHUD.getInstance().setCustomHud(player, playerRef, "MyHudId", new MyCustomHud(playerRef));

// Add multiple HUDs
MultipleHUD.getInstance().setCustomHud(player, playerRef, "HealthBar", new HealthBarHud(playerRef));
MultipleHUD.getInstance().setCustomHud(player, playerRef, "Buffs", new BuffDisplayHud(playerRef));
MultipleHUD.getInstance().setCustomHud(player, playerRef, "Minimap", new MinimapHud(playerRef));

// Remove a specific HUD by identifier
MultipleHUD.getInstance().hideCustomHud(player, playerRef, "MyHudId");

// Replace a HUD (same identifier replaces existing)
MultipleHUD.getInstance().setCustomHud(player, playerRef, "HealthBar", new NewHealthBarHud(playerRef));
```

### MHUD API Reference

| Method | Description |
|--------|-------------|
| `MultipleHUD.getInstance()` | Get the singleton instance |
| `setCustomHud(player, playerRef, id, hud)` | Add or replace a HUD by identifier |
| `hideCustomHud(player, playerRef, id)` | Remove a HUD by identifier |

### How MultipleHUD Works

MHUD creates a wrapper `MultipleCustomUIHud` that contains a root group `#MultipleHUD`. Each individual HUD is added as a child group with ID `#<normalizedId>`. The library automatically:

- Converts HUD identifiers to valid element IDs (strips non-alphanumeric chars)
- Prefixes all selectors in your HUD with the container path
- Handles build/update lifecycle for each HUD independently

### Empty HUD Placeholder

Use `EmptyHUD` as a placeholder when you need a HUD slot but no content:

```java
import com.buuz135.mhud.EmptyHUD;

// Create an empty placeholder
MultipleHUD.getInstance().setCustomHud(player, playerRef, "Placeholder", new EmptyHUD(playerRef));
```

### Recommended ECS Pattern for HUD Systems

When creating HUD systems for Hyforged, follow this pattern (used by `CurrencyHudSystem`, `ResourceStatsHudSystem`, `CombatLogHudSystem`):

```java
public class MyHudSystem extends DelayedEntitySystem<EntityStore> {
    
    /** Check for MHUD availability at class load */
    private static final boolean MULTIPLE_HUD_AVAILABLE;
    static {
        boolean available = false;
        try {
            Class.forName("com.buuz135.mhud.MultipleHUD");
            available = true;
        } catch (ClassNotFoundException e) {
            LOGGER.warning("MultipleHUD not available - HUD disabled");
        }
        MULTIPLE_HUD_AVAILABLE = available;
    }
    
    /** Unique namespaced ID for this HUD */
    public static final String HUD_ID = "hyforged:my_hud";
    
    /** Track HUD instances per player */
    private static final Map<UUID, MyHud> playerHuds = new ConcurrentHashMap<>();
    
    @Override
    public void tick(...) {
        if (!MULTIPLE_HUD_AVAILABLE) return;
        
        UUID playerUuid = uuidComponent.getUuid();
        boolean shouldShowHud = /* your logic */;
        
        com.buuz135.mhud.MultipleHUD multipleHUD = com.buuz135.mhud.MultipleHUD.getInstance();
        MyHud existingHud = playerHuds.get(playerUuid);
        
        if (!shouldShowHud) {
            if (existingHud != null) {
                multipleHUD.hideCustomHud(player, playerRef, HUD_ID);
                playerHuds.remove(playerUuid);
            }
            return;
        }
        
        // Create HUD if not exists
        if (existingHud == null) {
            MyHud hud = new MyHud(playerRef);
            multipleHUD.setCustomHud(player, playerRef, HUD_ID, hud);
            playerHuds.put(playerUuid, hud);
            existingHud = hud;
        }
        
        // Update HUD with new values
        existingHud.updateValues(...);
    }
}
```

**Key Points:**
- Use `DelayedEntitySystem` to avoid updating every tick
- Check `MULTIPLE_HUD_AVAILABLE` before any MHUD calls
- Use namespaced HUD IDs like `"hyforged:my_hud"`
- Track HUD instances per player UUID
- Hide HUD before removing from tracking map
- Only create new HUD if one doesn't exist for the player

---

## CustomUIPage

CustomUIPage is used for static full-screen modal pages.

### Basic Page Implementation

```java
import com.hypixel.hytale.server.core.entity.entities.player.pages.CustomUIPage;
import com.hypixel.hytale.protocol.packets.interface_.CustomPageLifetime;

public class MyPage extends CustomUIPage {
    
    public MyPage(PlayerRef playerRef) {
        super(playerRef, CustomPageLifetime.CanDismiss);
    }

    @Override
    public void build(Ref<EntityStore> ref, UICommandBuilder commandBuilder,
                      UIEventBuilder eventBuilder, Store<EntityStore> store) {
        commandBuilder.append("Pages/MyPage.ui");
    }
}
```

### Opening a Page

```java
Player player = store.getComponent(ref, Player.getComponentType());
player.getPageManager().setPage(ref, store, new MyPage(playerRef));
```

### Page Lifetime Options

```java
import com.hypixel.hytale.protocol.packets.interface_.CustomPageLifetime;

CustomPageLifetime.CanDismiss   // Player can close with ESC
CustomPageLifetime.Dismiss      // Closes immediately (not typically used)
```

---

## InteractiveCustomUIPage<T>

InteractiveCustomUIPage is used for pages with event handling. It uses a generic type parameter for the event data class.

### Complete Interactive Page Implementation

```java
import com.hypixel.hytale.server.core.entity.entities.player.pages.InteractiveCustomUIPage;
import com.hypixel.hytale.codec.builder.BuilderCodec;
import com.hypixel.hytale.codec.KeyedCodec;
import com.hypixel.hytale.codec.Codec;

public class MyInteractivePage extends InteractiveCustomUIPage<MyInteractivePage.EventData> {

    public MyInteractivePage(PlayerRef playerRef) {
        super(playerRef, CustomPageLifetime.CanDismiss, EventData.CODEC);
    }

    @Override
    public void build(Ref<EntityStore> ref, UICommandBuilder commandBuilder,
                      UIEventBuilder eventBuilder, Store<EntityStore> store) {
        commandBuilder.append("Pages/MyPage.ui");
        
        // Bind button click event
        eventBuilder.addEventBinding(
            CustomUIEventBindingType.Activating,
            "#MyButton",
            EventData.of("Action", "buttonClicked"),
            false  // locksInterface - if true, locks UI during processing
        );
        
        // Bind text input value change
        eventBuilder.addEventBinding(
            CustomUIEventBindingType.ValueChanged,
            "#SearchInput",
            EventData.of("@SearchValue", "#SearchInput.Value"),  // @ prefix = UI value reference
            false
        );
    }

    @Override
    public void handleDataEvent(Ref<EntityStore> ref, Store<EntityStore> store, EventData data) {
        if ("buttonClicked".equals(data.action)) {
            // Handle button click
        }
        if (data.searchValue != null) {
            // Handle search input change
            updateSearchResults(data.searchValue);
        }
        // IMPORTANT: Always call sendUpdate after handling events
        sendUpdate(null, false);
    }
    
    private void updateSearchResults(String query) {
        UICommandBuilder commands = new UICommandBuilder();
        UIEventBuilder events = new UIEventBuilder();
        commands.clear("#Results");
        // Build updated content...
        sendUpdate(commands, events, false);
    }

    // Event data class with codec
    public static class EventData {
        public static final BuilderCodec<EventData> CODEC = BuilderCodec.builder(EventData.class, EventData::new)
            .append(new KeyedCodec<>("Action", Codec.STRING), (e, s) -> e.action = s, e -> e.action)
            .add()
            .append(new KeyedCodec<>("@SearchValue", Codec.STRING), (e, s) -> e.searchValue = s, e -> e.searchValue)
            .add()
            .build();

        String action;
        String searchValue;
        
        public static EventData of(String key, String value) {
            EventData data = new EventData();
            if (key.equals("Action")) data.action = value;
            else if (key.equals("@SearchValue")) data.searchValue = value;
            return data;
        }
    }
}
```

### Critical: Always Call sendUpdate

After handling events in `handleDataEvent`, you **must** call `sendUpdate`:

```java
@Override
public void handleDataEvent(Ref<EntityStore> ref, Store<EntityStore> store, EventData data) {
    // Handle your logic here...
    
    // ALWAYS call sendUpdate at the end
    sendUpdate(null, false);  // null for no UI changes, false for not closing
}
```

If you forget `sendUpdate`, the page will get stuck on "Loading...".

### Closing a Page

```java
private void close(Ref<EntityStore> ref, Store<EntityStore> store) {
    Player player = store.getComponent(ref, Player.getComponentType());
    player.getPageManager().setPage(ref, store, Page.None);
}
```

---

## UICommandBuilder

UICommandBuilder is used to construct UI modifications.

### Methods

```java
UICommandBuilder commands = new UICommandBuilder();

// Append .ui file content
commands.append("Pages/MyPage.ui");              // Append to root
commands.append("#Container", "Pages/Item.ui"); // Append to selector

// Append inline UI content
// IMPORTANT: Text values MUST be quoted in inline .ui syntax
commands.appendInline("#List", "Label { Text: \"Item\"; }");

// Insert before element
commands.insertBefore("#Target", "Pages/Header.ui");
commands.insertBeforeInline("#Target", "Label { Text: \"Before\"; }");

// Set properties
commands.set("#Label.Text", "Hello World");
commands.set("#Label.Visible", true);
commands.set("#Slider.Value", 50);
commands.set("#Progress.Value", 0.75f);

// Set complex objects
commands.setObject("#Element.Anchor", new Anchor().setWidth(Value.of(200)));
commands.setObject("#Grid.Slots", new ItemGridSlot[]{ new ItemGridSlot(itemStack) });

// Set with value reference (reference styles from Common.ui)
commands.set("#Button.Style", Value.ref("Common.ui", "DefaultButtonStyle"));

// Remove/clear
commands.remove("#Element");     // Remove element
commands.clear("#Container");    // Clear children
commands.setNull("#Label.Text"); // Set to null
```

### Selector Syntax

Selectors target elements by their ID and optionally their properties:

| Selector | Meaning |
|----------|----------|
| `#ElementId` | Target element by ID |
| `#ElementId.Property` | Target element's property |
| `#Parent #Child` | Nested element selection |
| `#List[0]` | First child of element "List" (indexed access) |
| `#List[0] #Title` | Element "Title" within the first child of "List" |

---

## UIEventBuilder

UIEventBuilder is used to bind UI events to handler methods.

### Basic Event Binding

```java
UIEventBuilder events = new UIEventBuilder();

// Basic event binding (no data)
events.addEventBinding(CustomUIEventBindingType.Activating, "#Button");

// With data payload
events.addEventBinding(
    CustomUIEventBindingType.Activating,
    "#Button",
    EventData.of("Action", "save"),
    false  // locksInterface
);

// Value reference (gets value from UI element)
events.addEventBinding(
    CustomUIEventBindingType.ValueChanged,
    "#TextField",
    EventData.of("@Value", "#TextField.Value"),  // @ prefix = UI value reference
    false
);
```

### Event Binding Parameters

| Parameter | Description |
|-----------|-------------|
| Event type | Type of event to listen for (see events.md) |
| Selector | Element ID to attach the event to |
| Data | Event data to send when triggered |
| locksInterface | If true, locks the UI during event processing |

See [events.md](events.md) for the complete list of event types.

---

## Threading (CRITICAL)

**UI operations MUST run on the world thread** or the game will crash.

### For Commands

```java
public class MyCommand extends AbstractAsyncCommand {
    @Override
    protected CompletableFuture<Void> executeAsync(CommandContext context) {
        if (context.sender() instanceof Player player) {
            Ref<EntityStore> ref = player.getReference();
            Store<EntityStore> store = ref.getStore();
            World world = store.getExternalData().getWorld();
            
            return CompletableFuture.runAsync(() -> {
                PlayerRef playerRef = store.getComponent(ref, PlayerRef.getComponentType());
                // Open page on world thread
                player.getPageManager().setPage(ref, store, new MyPage(playerRef));
            }, world);
        }
        return CompletableFuture.completedFuture(null);
    }
}
```

### For HUDs

```java
World world = store.getExternalData().getWorld();
world.execute(() -> {
    MyHud hud = new MyHud(playerRef);
    hud.show();
});
```

---

## Value Objects Reference

### ItemGridSlot

```java
new ItemGridSlot()
    .setItemStack(new ItemStack(itemId, quantity))
    .setBackground(Value.of(patchStyle))
    .setOverlay(Value.of(overlayStyle))
    .setIcon(Value.of(iconStyle))
    .setName("Custom Name")
    .setDescription("Custom description")
    .setItemIncompatible(false)
    .setActivatable(true)
    .setItemUncraftable(false);
```

### DropdownEntryInfo

```java
new DropdownEntryInfo(LocalizableString.fromString("Option 1"), "value1")
```

### LocalizableString

```java
// Plain string
LocalizableString.fromString("Hello World")

// Localization key
LocalizableString.fromMessageId("server.ui.myKey")

// With parameters
LocalizableString.fromMessageId("server.ui.greeting", Map.of("name", playerName))
```

---

## Checklist

1. ✅ Place .ui files in `resources/Common/UI/Custom/`
2. ✅ Add `"IncludesAssetPack": true` to `manifest.json`
3. ✅ Image files must end with `@2x.png`
4. ✅ Run UI operations on world thread
5. ✅ Call `sendUpdate()` after handling events in InteractiveCustomUIPage
6. ✅ Use proper selectors with `#` prefix
7. ✅ Use MultipleHUD for multiple HUDs per player
8. ✅ Use namespaced IDs for HUDs (e.g., `hyforged:my_hud`)
