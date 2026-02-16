# Complete UI Examples

This document provides full, working examples of common UI patterns.

---

## Example 1: Simple HUD

A basic HUD that displays a status message.

### Hud/SimpleHud.ui

```ui
$Common = "../Common.ui";

Group #Root {
    Anchor: (Bottom: 100, Left: 20, Width: 200, Height: 40);
    Background: PatchStyle(Color: #1a1a2eD0);
    Padding: (Full: 8);
    LayoutMode: CenterMiddle;
    
    Label #StatusText {
        Text: "Status: Ready";
        Style: (FontSize: 14, TextColor: #ffffff);
    }
}
```

### Java Implementation

```java
public class SimpleHud extends CustomUIHud {
    private String statusText = "Status: Ready";
    
    public SimpleHud(PlayerRef playerRef) {
        super(playerRef);
    }
    
    @Override
    protected void build(UICommandBuilder cmd) {
        cmd.append("Hud/SimpleHud.ui");
    }
    
    public void setStatus(String text) {
        this.statusText = text;
        UICommandBuilder cmd = new UICommandBuilder();
        cmd.set("#StatusText.Text", text);
        sendUpdate(cmd);
    }
}
```

---

## Example 2: Interactive Dialog Page

A confirmation dialog with OK/Cancel buttons.

### Pages/ConfirmDialog.ui

```ui
$Common = "../Common.ui";

Group #Root {
    Anchor: (Full: 0);
    Background: PatchStyle(Color: #000000(0.6));
    LayoutMode: CenterMiddle;
    
    Group #Dialog {
        Anchor: (Width: 400, Height: 200);
        Background: PatchStyle(Color: #1a1a2eF0, Border: 4);
        LayoutMode: Top;
        Padding: (Full: 20);
        
        Label #Title {
            Text: %ui.confirm.title;
            Style: (FontSize: 20, RenderBold: true, HorizontalAlignment: Center);
            Anchor: (Height: 32);
        }
        
        Label #Message {
            Text: %ui.confirm.message;
            Style: (FontSize: 14, HorizontalAlignment: Center, Wrap: true);
            Anchor: (Height: 60);
        }
        
        Group #Spacer {
            FlexWeight: 1;
        }
        
        Group #ButtonRow {
            LayoutMode: CenterMiddle;
            Anchor: (Height: 50);
            
            Button #CancelButton {
                Text: %ui.general.cancel;
                Anchor: (Width: 120, Height: 36, Right: 10);
                Style: $Common.@SecondaryButtonStyle;
            }
            
            Button #OkButton {
                Text: %ui.general.ok;
                Anchor: (Width: 120, Height: 36);
                Style: $Common.@PrimaryButtonStyle;
            }
        }
    }
}
```

### Java Implementation

```java
public class ConfirmDialog extends InteractiveCustomUIPage<ConfirmDialog.EventData> {
    
    private final String titleKey;
    private final String messageKey;
    private final Runnable onConfirm;
    
    public ConfirmDialog(PlayerRef playerRef, String titleKey, String messageKey, Runnable onConfirm) {
        super(playerRef, CustomPageLifetime.CanDismiss, EventData.CODEC);
        this.titleKey = titleKey;
        this.messageKey = messageKey;
        this.onConfirm = onConfirm;
    }
    
    @Override
    public void build(Ref<EntityStore> ref, UICommandBuilder cmd,
                      UIEventBuilder events, Store<EntityStore> store) {
        cmd.append("Pages/ConfirmDialog.ui");
        
        // Set dynamic text if needed
        if (titleKey != null) {
            cmd.set("#Title.Text", "%" + titleKey);
        }
        if (messageKey != null) {
            cmd.set("#Message.Text", "%" + messageKey);
        }
        
        // Bind button events
        events.addEventBinding(CustomUIEventBindingType.Activating, "#OkButton",
            EventData.action("confirm"), false);
        events.addEventBinding(CustomUIEventBindingType.Activating, "#CancelButton",
            EventData.action("cancel"), false);
    }
    
    @Override
    public void handleDataEvent(Ref<EntityStore> ref, Store<EntityStore> store, EventData data) {
        if ("confirm".equals(data.action)) {
            if (onConfirm != null) {
                onConfirm.run();
            }
            close(ref, store);
            return;
        }
        if ("cancel".equals(data.action)) {
            close(ref, store);
            return;
        }
        sendUpdate(null, false);
    }
    
    private void close(Ref<EntityStore> ref, Store<EntityStore> store) {
        Player player = store.getComponent(ref, Player.getComponentType());
        player.getPageManager().setPage(ref, store, Page.None);
    }
    
    public static class EventData {
        public static final BuilderCodec<EventData> CODEC = BuilderCodec.builder(EventData.class, EventData::new)
            .append(new KeyedCodec<>("Action", Codec.STRING), (e, s) -> e.action = s, e -> e.action)
            .add()
            .build();
        
        String action;
        
        public static EventData action(String action) {
            EventData data = new EventData();
            data.action = action;
            return data;
        }
    }
}
```

---

## Example 3: Search Page with Dynamic Results

A page with a search field that updates results dynamically.

### Pages/SearchPage.ui

```ui
$Common = "../Common.ui";

@ResultItem = Group {
    Anchor: (Height: 40);
    LayoutMode: Left;
    Padding: (Horizontal: 10, Vertical: 5);
    Background: PatchStyle(Color: #2a2a3e);
    
    Label #Name {
        Text: @ItemName;
        Style: (FontSize: 14);
        Anchor: (Width: 200);
    }
    
    Label #Description {
        Text: @ItemDescription;
        Style: (FontSize: 12, TextColor: #aaaaaa);
        FlexWeight: 1;
    }
    
    Button #SelectButton {
        Text: "Select";
        Anchor: (Width: 80, Height: 30);
    }
};

Group #Root {
    Anchor: (Full: 0);
    Background: PatchStyle(Color: #000000(0.7));
    LayoutMode: CenterMiddle;
    
    Group #Container {
        Anchor: (Width: 600, Height: 500);
        Background: PatchStyle(Color: #1a1a2eF0, Border: 4);
        LayoutMode: Top;
        Padding: (Full: 16);
        
        Label #Title {
            Text: %ui.search.title;
            Style: (FontSize: 22, RenderBold: true);
            Anchor: (Height: 36);
        }
        
        Group #SearchRow {
            LayoutMode: Left;
            Anchor: (Height: 40, Bottom: 10);
            
            TextField #SearchInput {
                PlaceholderText: %ui.search.placeholder;
                Anchor: (Height: 36);
                FlexWeight: 1;
            }
            
            Button #ClearButton {
                Text: "X";
                Anchor: (Width: 36, Height: 36, Left: 8);
            }
        }
        
        Group #ResultsContainer {
            FlexWeight: 1;
            LayoutMode: TopScrolling;
            ScrollbarStyle: $Common.@DefaultScrollbarStyle;
            
            // Results will be dynamically added here
        }
        
        Group #Footer {
            LayoutMode: Right;
            Anchor: (Height: 50, Top: 10);
            
            Label #ResultCount {
                Text: "0 results";
                Style: (FontSize: 12, TextColor: #888888);
                Anchor: (Width: 100);
            }
            
            Group #Spacer { FlexWeight: 1; }
            
            Button #CloseButton {
                Text: %ui.general.close;
                Anchor: (Width: 100, Height: 36);
            }
        }
    }
}
```

### Java Implementation

```java
public class SearchPage extends InteractiveCustomUIPage<SearchPage.EventData> {
    
    private final List<SearchResult> allResults;
    private List<SearchResult> filteredResults;
    
    public SearchPage(PlayerRef playerRef, List<SearchResult> results) {
        super(playerRef, CustomPageLifetime.CanDismiss, EventData.CODEC);
        this.allResults = results;
        this.filteredResults = new ArrayList<>(results);
    }
    
    @Override
    public void build(Ref<EntityStore> ref, UICommandBuilder cmd,
                      UIEventBuilder events, Store<EntityStore> store) {
        cmd.append("Pages/SearchPage.ui");
        
        // Build initial results
        buildResults(cmd, events);
        
        // Bind events
        events.addEventBinding(CustomUIEventBindingType.ValueChanged, "#SearchInput",
            EventData.of("@Query", "#SearchInput.Value"), false);
        events.addEventBinding(CustomUIEventBindingType.Activating, "#ClearButton",
            EventData.of("Action", "clear"), false);
        events.addEventBinding(CustomUIEventBindingType.Activating, "#CloseButton",
            EventData.of("Action", "close"), false);
    }
    
    @Override
    public void handleDataEvent(Ref<EntityStore> ref, Store<EntityStore> store, EventData data) {
        if ("close".equals(data.action)) {
            close(ref, store);
            return;
        }
        
        if ("clear".equals(data.action)) {
            UICommandBuilder cmd = new UICommandBuilder();
            cmd.set("#SearchInput.Value", "");
            filteredResults = new ArrayList<>(allResults);
            rebuildResults(cmd);
            sendUpdate(cmd, false);
            return;
        }
        
        if ("select".equals(data.action) && data.itemId != null) {
            handleSelection(data.itemId);
            close(ref, store);
            return;
        }
        
        if (data.query != null) {
            filterResults(data.query);
            UICommandBuilder cmd = new UICommandBuilder();
            rebuildResults(cmd);
            sendUpdate(cmd, false);
            return;
        }
        
        sendUpdate(null, false);
    }
    
    private void filterResults(String query) {
        if (query == null || query.isEmpty()) {
            filteredResults = new ArrayList<>(allResults);
        } else {
            String lowerQuery = query.toLowerCase();
            filteredResults = allResults.stream()
                .filter(r -> r.name().toLowerCase().contains(lowerQuery))
                .collect(Collectors.toList());
        }
    }
    
    private void buildResults(UICommandBuilder cmd, UIEventBuilder events) {
        for (int i = 0; i < filteredResults.size(); i++) {
            SearchResult result = filteredResults.get(i);
            String id = "Result" + i;
            
            cmd.appendInline("#ResultsContainer", String.format(
                "@ResultItem #%s { @ItemName = \"%s\"; @ItemDescription = \"%s\"; }",
                id, escapeString(result.name()), escapeString(result.description())
            ));
            
            events.addEventBinding(CustomUIEventBindingType.Activating,
                "#" + id + " #SelectButton",
                EventData.select(result.id()), false);
        }
        
        cmd.set("#ResultCount.Text", filteredResults.size() + " results");
    }
    
    private void rebuildResults(UICommandBuilder cmd) {
        cmd.clear("#ResultsContainer");
        UIEventBuilder events = new UIEventBuilder();
        buildResults(cmd, events);
        // Note: In a full implementation, you'd need to send events too
    }
    
    private String escapeString(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
    
    private void handleSelection(String itemId) {
        // Handle the selection
    }
    
    private void close(Ref<EntityStore> ref, Store<EntityStore> store) {
        Player player = store.getComponent(ref, Player.getComponentType());
        player.getPageManager().setPage(ref, store, Page.None);
    }
    
    public static class EventData {
        public static final BuilderCodec<EventData> CODEC = BuilderCodec.builder(EventData.class, EventData::new)
            .append(new KeyedCodec<>("Action", Codec.STRING), (e, s) -> e.action = s, e -> e.action)
            .add()
            .append(new KeyedCodec<>("@Query", Codec.STRING), (e, s) -> e.query = s, e -> e.query)
            .add()
            .append(new KeyedCodec<>("ItemId", Codec.STRING), (e, s) -> e.itemId = s, e -> e.itemId)
            .add()
            .build();
        
        String action;
        String query;
        String itemId;
        
        public static EventData of(String key, String value) {
            EventData data = new EventData();
            if ("Action".equals(key)) data.action = value;
            return data;
        }
        
        public static EventData select(String itemId) {
            EventData data = new EventData();
            data.action = "select";
            data.itemId = itemId;
            return data;
        }
    }
    
    public record SearchResult(String id, String name, String description) {}
}
```

---

## Example 4: Item Grid Inventory

An inventory page with an item grid.

### Pages/Inventory.ui

```ui
$Common = "../Common.ui";

Group #Root {
    Anchor: (Full: 0);
    Background: PatchStyle(Color: #000000(0.6));
    LayoutMode: CenterMiddle;
    
    Group #Container {
        Anchor: (Width: 450, Height: 400);
        Background: PatchStyle(Color: #1a1a2eF0, Border: 4);
        LayoutMode: Top;
        Padding: (Full: 16);
        
        Label #Title {
            Text: %ui.inventory.title;
            Style: (FontSize: 20, RenderBold: true);
            Anchor: (Height: 32, Bottom: 12);
        }
        
        ItemGrid #InventoryGrid {
            FlexWeight: 1;
            SlotsPerRow: 8;
            AreItemsDraggable: false;
            ShowScrollbar: true;
            KeepScrollPosition: true;
            RenderItemQualityBackground: true;
            Style: $Common.@DefaultItemGridStyle;
        }
        
        Group #Footer {
            LayoutMode: Right;
            Anchor: (Height: 50, Top: 12);
            
            Button #CloseButton {
                Text: %ui.general.close;
                Anchor: (Width: 100, Height: 36);
            }
        }
    }
}
```

### Java Implementation

```java
public class InventoryPage extends InteractiveCustomUIPage<InventoryPage.EventData> {
    
    private final List<ItemStack> items;
    
    public InventoryPage(PlayerRef playerRef, List<ItemStack> items) {
        super(playerRef, CustomPageLifetime.CanDismiss, EventData.CODEC);
        this.items = items;
    }
    
    @Override
    public void build(Ref<EntityStore> ref, UICommandBuilder cmd,
                      UIEventBuilder events, Store<EntityStore> store) {
        cmd.append("Pages/Inventory.ui");
        
        // Build item grid slots
        ItemGridSlot[] slots = items.stream()
            .map(item -> new ItemGridSlot()
                .setItemStack(item)
                .setActivatable(true))
            .toArray(ItemGridSlot[]::new);
        
        cmd.setObject("#InventoryGrid.Slots", slots);
        
        // Bind events
        events.addEventBinding(CustomUIEventBindingType.SlotClicking, "#InventoryGrid",
            EventData.of("@SlotIndex", "#InventoryGrid.SelectedSlotIndex"), false);
        events.addEventBinding(CustomUIEventBindingType.Activating, "#CloseButton",
            EventData.of("Action", "close"), false);
    }
    
    @Override
    public void handleDataEvent(Ref<EntityStore> ref, Store<EntityStore> store, EventData data) {
        if ("close".equals(data.action)) {
            close(ref, store);
            return;
        }
        
        if (data.slotIndex >= 0 && data.slotIndex < items.size()) {
            ItemStack selectedItem = items.get(data.slotIndex);
            handleItemClick(selectedItem, data.slotIndex);
        }
        
        sendUpdate(null, false);
    }
    
    private void handleItemClick(ItemStack item, int slotIndex) {
        // Handle item selection
    }
    
    private void close(Ref<EntityStore> ref, Store<EntityStore> store) {
        Player player = store.getComponent(ref, Player.getComponentType());
        player.getPageManager().setPage(ref, store, Page.None);
    }
    
    public static class EventData {
        public static final BuilderCodec<EventData> CODEC = BuilderCodec.builder(EventData.class, EventData::new)
            .append(new KeyedCodec<>("Action", Codec.STRING), (e, s) -> e.action = s, e -> e.action)
            .add()
            .append(new KeyedCodec<>("@SlotIndex", Codec.INT), (e, i) -> e.slotIndex = i, e -> e.slotIndex)
            .add()
            .build();
        
        String action;
        int slotIndex = -1;
        
        public static EventData of(String key, String value) {
            EventData data = new EventData();
            if ("Action".equals(key)) data.action = value;
            return data;
        }
    }
}
```

---

## Key Patterns Summary

1. **Always import Common.ui** for consistent styling
2. **Use templates (@Name)** for reusable UI components
3. **Use translation keys (%key)** for all user-facing text
4. **Use @ prefix in EventData** for dynamic value references
5. **Always call sendUpdate()** after handling events
6. **Escape strings** when building inline UI dynamically
7. **Use namespaced IDs** for HUDs with MultipleHUD
8. **Run UI operations on world thread**
