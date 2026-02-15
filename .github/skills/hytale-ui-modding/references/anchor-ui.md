# Anchor UI Reference

Anchor UI allows plugins to inject UI content into predefined anchor points in the client's built-in UI documents (HUDs and pages). Unlike `CustomUIHud` (display-only overlays) or `CustomUIPage` (full-screen modal pages), Anchor UI embeds your content **inside** the game's existing UI — including support for interactive event bindings.

---

## How It Works

1. The client's built-in `.ui` files contain empty `Group` elements with `#Server*` IDs — these are **anchor points**.
2. The server sends an `UpdateAnchorUI` packet referencing an anchor by its **anchor ID**.
3. The client appends the provided UI commands (from a `.ui` file or inline markup) into that anchor element.
4. Optionally, event bindings are included so the injected UI can send events back to the server.

---

## Available Anchor Points

Only elements with `#Server*`-prefixed IDs in the base game UI serve as anchor points. As of the current version, there are **three**:

| Anchor Element | File | Line | Anchor ID | Context |
|----------------|------|------|-----------|---------|
| `Group #ServerEvent {}` | `InGame/Hud/Reticle.ui` | 9 | `ReticleServerEvent` | Always-visible reticle overlay HUD |
| `Group #ServerContent { ... }` | `InGame/Pages/MapPage.ui` | 92 | `MapServerContent` | Map page (visible when map is open) |
| `Group #ServerDetails { ... }` | `InGame/Hud/PlayerList.ui` | 38 | `PlayerListServerDetails` | Player list (visible when holding Tab) |

### Anchor ID Convention

The anchor ID is derived from the `.ui` document file name (without extension or path) concatenated with the element's `#Id` (without the `#`):

```
{DocumentName}{ElementId}
```

Examples:
- `Reticle.ui` + `#ServerEvent` → `ReticleServerEvent`
- `MapPage.ui` + `#ServerContent` → `MapServerContent`  
- `PlayerList.ui` + `#ServerDetails` → `PlayerListServerDetails`

---

## Server-Side API

### UpdateAnchorUI Packet

`UpdateAnchorUI` is a `ToClientPacket` (packet ID **235**) that controls anchor content.

```java
// Decompiled signature (com.hypixel.hytale.protocol.packets.interface_.UpdateAnchorUI)
public class UpdateAnchorUI implements Packet, ToClientPacket {
    public static final int PACKET_ID = 235;
    
    @Nullable public String anchorId;
    public boolean clear;
    @Nullable public CustomUICommand[] commands;
    @Nullable public CustomUIEventBinding[] eventBindings;
    
    public UpdateAnchorUI(@Nullable String anchorId, boolean clear,
                          @Nullable CustomUICommand[] commands,
                          @Nullable CustomUIEventBinding[] eventBindings);
}
```

**Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `anchorId` | `String` | Target anchor ID (e.g., `"ReticleServerEvent"`) |
| `clear` | `boolean` | If `true`, clears existing content before appending |
| `commands` | `CustomUICommand[]` | UI commands to inject (from `UICommandBuilder.getCommands()`) |
| `eventBindings` | `CustomUIEventBinding[]` | Event bindings (from `UIEventBuilder.getEvents()`) |

### AnchorActionModule (Built-in Handler)

The server includes `AnchorActionModule` — a core plugin that routes inbound `CustomPageEvent` packets with a JSON `"action"` field to registered handlers.

```java
// Decompiled (com.hypixel.hytale.server.core.modules.anchoraction.AnchorActionModule)
public class AnchorActionModule extends JavaPlugin {
    
    // Register a handler for an action string
    public void register(@Nonnull String action, @Nonnull AnchorActionHandler handler);
    
    // Register with automatic world-thread dispatch
    public void register(@Nonnull String action, @Nonnull WorldThreadAnchorActionHandler handler);
    
    public void unregister(@Nonnull String action);
    
    @FunctionalInterface
    public interface WorldThreadAnchorActionHandler {
        void handle(@Nonnull PlayerRef playerRef, @Nonnull Ref<EntityStore> ref,
                    @Nonnull Store<EntityStore> store, @Nonnull JsonObject data);
    }
}
```

---

## API Availability in Plugin JAR

> **Important:** As of the current pre-release, `UpdateAnchorUI`, `AnchorActionModule`, `AnchorActionHandler`, and `ToClientPacket` are **NOT** in the plugin API JAR (`HytaleServer-parent`). They exist in the full server but are not exposed to plugins.

| Class | In Plugin API? | Workaround |
|-------|---------------|------------|
| `UpdateAnchorUI` | **No** | Reflection (see below) |
| `AnchorActionModule` | **No** | Inbound `PacketFilter` on `CustomPageEvent` |
| `AnchorActionHandler` | **No** | Not needed when using PacketFilter approach |
| `ToClientPacket` | **No** | Reflection via `PacketHandler.writeNoCache()` |
| `CustomUICommand` | Yes | Direct use via `UICommandBuilder` |
| `CustomUIEventBinding` | Yes | Direct use via `UIEventBuilder` |
| `CustomPageEvent` | Yes | Direct use for inbound event handling |
| `PacketAdapters` / `PacketFilter` | Yes | Direct use for packet interception |

---

## Implementation Pattern (Reflection-Based)

Since the core classes are not in the API JAR, use reflection to construct and send packets.

### 1. Cache Reflection Handles

```java
private static final Constructor<?> UPDATE_ANCHOR_CTOR;
private static final Method WRITE_NO_CACHE;

static {
    try {
        Class<?> updateAnchorClass = Class.forName(
                "com.hypixel.hytale.protocol.packets.interface_.UpdateAnchorUI");
        UPDATE_ANCHOR_CTOR = updateAnchorClass.getConstructor(
                String.class, boolean.class,
                CustomUICommand[].class, CustomUIEventBinding[].class);

        Class<?> toClientPacket = Class.forName(
                "com.hypixel.hytale.protocol.ToClientPacket");
        WRITE_NO_CACHE = PacketHandler.class.getMethod("writeNoCache", toClientPacket);
    } catch (ReflectiveOperationException e) {
        throw new ExceptionInInitializerError("Failed to resolve Anchor UI reflection handles: " + e);
    }
}
```

### 2. Build and Send Anchor Content

```java
public static void send(@Nonnull PlayerRef playerRef) {
    // Build UI commands from a .ui file
    UICommandBuilder commandBuilder = new UICommandBuilder();
    commandBuilder.append("Hyforged/MyAnchorContent.ui");

    // Bind interactive events
    UIEventBuilder eventBuilder = new UIEventBuilder();
    eventBuilder.addEventBinding(
            CustomUIEventBindingType.Activating, "#MyButton",
            EventData.of("action", "myPluginAction"), false);

    // Send via reflection
    sendAnchorPacket(playerRef.getPacketHandler(),
            "ReticleServerEvent",  // anchor ID
            true,                  // clear existing content first
            commandBuilder.getCommands(),
            eventBuilder.getEvents());
}

private static void sendAnchorPacket(@Nonnull PacketHandler handler,
                                     @Nonnull String anchorId,
                                     boolean clear,
                                     CustomUICommand[] commands,
                                     CustomUIEventBinding[] eventBindings) {
    try {
        Object packet = UPDATE_ANCHOR_CTOR.newInstance(anchorId, clear, commands, eventBindings);
        WRITE_NO_CACHE.invoke(handler, packet);
    } catch (ReflectiveOperationException e) {
        LOGGER.warning("Failed to send UpdateAnchorUI: " + e.getMessage());
    }
}
```

### 3. Handle Inbound Events

Since `AnchorActionModule` is not available to plugins, intercept `CustomPageEvent` packets directly using an inbound `PacketFilter`:

```java
private static final Set<String> HANDLED_ACTIONS = Set.of("myPluginAction", "anotherAction");

public static void install() {
    PacketAdapters.registerInbound(MyAnchorUI::filterInbound);
}

private static boolean filterInbound(@Nonnull PacketHandler packetHandler,
                                     @Nonnull Packet packet) {
    if (!(packet instanceof CustomPageEvent event)) return false;
    if (event.type != CustomPageEventType.Data || event.data == null) return false;

    // Parse the "action" field from JSON event data
    String action = parseAction(event.data);
    if (action == null || !HANDLED_ACTIONS.contains(action)) return false;

    // Resolve player
    var auth = packetHandler.getAuth();
    if (auth == null) return true;
    PlayerRef playerRef = Universe.get().getPlayer(auth.getUuid());
    if (playerRef == null) return true;

    // Dispatch to world thread for safe entity access
    Ref<EntityStore> ref = playerRef.getReference();
    if (ref == null || !ref.isValid()) return true;
    Store<EntityStore> store = ref.getStore();
    World world = store.getExternalData().getWorld();
    world.execute(() -> {
        if (ref.isValid()) {
            handleAction(action, playerRef, ref, store);
        }
    });

    return true; // Consume the packet
}

private static String parseAction(@Nonnull String json) {
    try {
        JsonObject obj = JsonParser.parseString(json).getAsJsonObject();
        return obj.has("action") ? obj.get("action").getAsString() : null;
    } catch (Exception e) {
        return null;
    }
}
```

---

## .ui File for Anchor Content

Place your `.ui` file under `src/main/resources/Common/UI/Custom/`. The file is referenced by the path relative to `Custom/` in `UICommandBuilder.append()`.

```
// Example: src/main/resources/Common/UI/Custom/Hyforged/MyAnchorContent.ui

Group #MyButtons {
  Anchor: (Top: 60, Height: 32, Width: 108);
  LayoutMode: Left;

  Button #MyButton {
    Anchor: (Width: 32, Height: 32);
    Background: #1a1a2e(0.75);
    TooltipText: "Do Something";

    Label {
      Text: "X";
      Anchor: (Width: 32, Height: 32);
      Style: (FontSize: 14, RenderBold: true, TextColor: #FFD700, Alignment: Center, VerticalAlignment: Center);
    }
  }
}
```

---

## Timing: UiPacketGate Integration

`UpdateAnchorUI` packets suffer the same race condition as `CustomUIHud` and `CustomUIPage` — if sent before the client has loaded the plugin's asset pack, the `.ui` file won't be found.

**Always send anchor content after `PlayerReadyEvent`.** If your project uses a `UiPacketGate` that defers outbound UI packets, ensure it also captures `UpdateAnchorUI` (packet ID 235):

```java
// In your outbound packet filter, check for UpdateAnchorUI by packet ID
private static final int UPDATE_ANCHOR_UI_PACKET_ID = 235;

if (packet.getId() == UPDATE_ANCHOR_UI_PACKET_ID) {
    // Queue for deferred delivery after PlayerReadyEvent
}
```

---

## Clearing Anchor Content

To remove injected content from an anchor, send an `UpdateAnchorUI` with `clear = true` and null commands/events:

```java
public static void clear(@Nonnull PlayerRef playerRef) {
    sendAnchorPacket(playerRef.getPacketHandler(), "ReticleServerEvent", true, null, null);
}
```

---

## Comparison: Anchor UI vs CustomUIHud vs CustomUIPage

| Feature | Anchor UI | CustomUIHud | CustomUIPage |
|---------|-----------|-------------|--------------|
| Position | Inside existing game UI | Overlay on top of game UI | Full-screen modal |
| Event bindings | Yes | **No** | Yes |
| Always visible | Depends on host element | Yes | No (opens/closes) |
| In plugin API | **No** (reflection required) | Yes | Yes |
| Multiple per player | Yes (different anchors) | Yes (via MultipleHUD) | One at a time |
| Use case | Inject buttons/info into game chrome | Persistent HUD elements | Interactive dialogs/pages |

---

## Hyforged Example: HyforgedReticleUI

See `src/main/java/reign/software/hyforged/hud/HyforgedReticleUI.java` for a complete working example that:
- Injects 3 quick-access buttons (Stats / Passive Tree / Concentration) into the Reticle HUD
- Uses reflection for `UpdateAnchorUI` packet construction
- Handles inbound `CustomPageEvent` via `PacketFilter`
- Opens `CustomUIPage` instances from button clicks
- Integrates with `UiPacketGate` for safe packet timing

UI file: `src/main/resources/Common/UI/Custom/Hyforged/HyforgedReticleButtons.ui`
