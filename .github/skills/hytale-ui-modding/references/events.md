# UI Event Binding Types

Use UIEventBuilder.addEventBinding to bind events to elements in your UI.

## Event Binding Syntax

```java
events.addEventBinding(
    CustomUIEventBindingType.EventType,  // The event type
    "#ElementSelector",                   // Element to bind to
    eventData,                            // Data to send when triggered
    locksInterface                        // Whether to lock UI during processing
);
```

---

## Event Types Reference

### Interaction Events

| Event | Trigger | Common Use |
|-------|---------|------------|
| `Activating` | Element is activated (button click, enter key) | Buttons, clickable elements |
| `RightClicking` | Right mouse button click | Context menus |
| `DoubleClicking` | Double click | Quick actions |
| `MouseEntered` | Mouse cursor enters element bounds | Hover effects, tooltips |
| `MouseExited` | Mouse cursor leaves element bounds | Remove hover effects |
| `MouseButtonReleased` | Mouse button released over element | Drag completion |

### Input Events

| Event | Trigger | Common Use |
|-------|---------|------------|
| `ValueChanged` | Input value changes | TextField, Slider, CheckBox, DropdownBox |
| `FocusGained` | Element receives input focus | Input highlighting |
| `FocusLost` | Element loses input focus | Input validation, save on blur |
| `KeyDown` | Key pressed while element has focus | Keyboard shortcuts, special keys |
| `Validating` | Input validation requested | Form validation |

### Page Events

| Event | Trigger | Common Use |
|-------|---------|------------|
| `Dismissing` | Page dismiss attempt (ESC key, close button) | Confirm dialogs, save prompts |

### Tab Events

| Event | Trigger | Common Use |
|-------|---------|------------|
| `SelectedTabChanged` | Tab selection changes | Tab content switching |

### Item Grid Events

| Event | Trigger | Common Use |
|-------|---------|------------|
| `SlotClicking` | ItemGrid slot clicked | Item selection, item actions |
| `SlotDoubleClicking` | ItemGrid slot double-clicked | Quick equip, quick transfer |
| `SlotMouseEntered` | Mouse enters slot | Slot hover, tooltip display |
| `SlotMouseExited` | Mouse leaves slot | Remove tooltips |

### Drag and Drop Events

| Event | Trigger | Common Use |
|-------|---------|------------|
| `DragCancelled` | Drag operation cancelled | Reset drag state |
| `Dropped` | Item dropped on element | Item transfer, placement |
| `SlotMouseDragCompleted` | Drag completed over a slot | Item move between slots |
| `SlotMouseDragExited` | Drag exited a slot | Visual feedback |
| `SlotClickReleaseWhileDragging` | Click released while dragging | Split stacks, drop items |
| `SlotClickPressWhileDragging` | Click pressed while dragging | Multi-select |

### Layout Events

| Event | Trigger | Common Use |
|-------|---------|------------|
| `ElementReordered` | Element order changed in ReorderableList | List sorting |

---

## Usage Patterns

### Button Click

```java
events.addEventBinding(
    CustomUIEventBindingType.Activating,
    "#SaveButton",
    EventData.of("Action", "save"),
    false
);
```

### Text Input Change

Use the `@` prefix in the EventData key to pull the value from the UI element:

```java
events.addEventBinding(
    CustomUIEventBindingType.ValueChanged,
    "#SearchField",
    EventData.of("@Query", "#SearchField.Value"),
    false
);
```

In your EventData class, the key `@Query` will receive the current value of `#SearchField.Value`.

### Slider Value Change

```java
events.addEventBinding(
    CustomUIEventBindingType.ValueChanged,
    "#VolumeSlider",
    EventData.of("@Volume", "#VolumeSlider.Value"),
    false
);
```

### Item Grid Slot Click

```java
events.addEventBinding(
    CustomUIEventBindingType.SlotClicking,
    "#InventoryGrid",
    EventData.of("@SlotIndex", "#InventoryGrid.SelectedSlotIndex"),
    false
);
```

### Tab Selection

```java
events.addEventBinding(
    CustomUIEventBindingType.SelectedTabChanged,
    "#TabNav",
    EventData.of("@Tab", "#TabNav.SelectedTab"),
    false
);
```

### Page Dismiss Confirmation

```java
events.addEventBinding(
    CustomUIEventBindingType.Dismissing,
    "#Root",  // Or the page root element
    EventData.of("Action", "dismiss"),
    false
);
```

In handleDataEvent, you can prevent dismissal by not closing the page and showing a confirmation dialog instead.

---

## Value References

The `@` prefix in EventData keys indicates that the value should be pulled from a UI element property:

```java
EventData.of("@Key", "#ElementId.Property")
```

| Syntax | Meaning |
|--------|---------|
| `"Action"` | Static key, value comes from Java code |
| `"@Value"` | Dynamic key, value comes from UI element specified in the second parameter |

### Common Value References

| Reference | Source |
|-----------|--------|
| `#TextField.Value` | Text field current value |
| `#Slider.Value` | Slider current value |
| `#CheckBox.Value` | Checkbox checked state |
| `#DropdownBox.Value` | Selected dropdown value |
| `#ItemGrid.SelectedSlotIndex` | Selected slot index |

---

## Event Data Class Pattern

```java
public static class EventData {
    public static final BuilderCodec<EventData> CODEC = BuilderCodec.builder(EventData.class, EventData::new)
        // Static fields
        .append(new KeyedCodec<>("Action", Codec.STRING), (e, s) -> e.action = s, e -> e.action)
        .add()
        // Dynamic fields (@ prefix means value from UI)
        .append(new KeyedCodec<>("@Query", Codec.STRING), (e, s) -> e.query = s, e -> e.query)
        .add()
        .append(new KeyedCodec<>("@SlotIndex", Codec.INT), (e, i) -> e.slotIndex = i, e -> e.slotIndex)
        .add()
        .build();

    String action;
    String query;
    int slotIndex;
    
    public static EventData of(String key, String value) {
        EventData data = new EventData();
        // Map keys to fields...
        return data;
    }
}
```

---

## Important Notes

1. **Always call sendUpdate after handling events** in InteractiveCustomUIPage
2. **Value references (@) pull current values** from the UI at the time the event fires
3. **locksInterface parameter**: Set to `true` if you need to prevent user interaction during processing
4. **Selector must match element ID** exactly (with # prefix)
