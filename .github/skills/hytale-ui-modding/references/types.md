# UI Types Reference

Complete reference of all UI elements, property types, and enums available in Hytale UI markup.

---

## Elements

Elements are the building blocks of UI. Each element has specific properties and event callbacks.

### Base Properties (Inherited by All Elements)

These properties are available on virtually all elements:

| Property | Type | Description |
|----------|------|-------------|
| `Visible` | Boolean | Hides the element. Makes parent layouting skip this element as well |
| `HitTestVisible` | Boolean | If true, element will be returned during HitTest (enables click detection) |
| `TooltipText` | String | Enables a text tooltip shown on hover |
| `TooltipTextSpans` | List&lt;LabelSpan&gt; | Tooltip with formatted text spans |
| `TextTooltipStyle` | TextTooltipStyle | Style options for the tooltip |
| `TextTooltipShowDelay` | Float | Delay in seconds before tooltip appears |
| `Anchor` | Anchor | How the element is laid out inside its allocated area |
| `Padding` | Padding | Space around content (background unaffected) |
| `FlexWeight` | Integer | Distribution of remaining space after explicit sizes |
| `Background` | PatchStyle / String | Background image or color |
| `MaskTexturePath` | UI Path (String) | Mask texture for clipping |
| `OutlineColor` | Color | Color for outline |
| `OutlineSize` | Float | Draws outline with specified size |

---

### Group

**Container element** - Accepts children: Yes

The fundamental container for laying out child elements.

| Property | Type | Description |
|----------|------|-------------|
| `LayoutMode` | LayoutMode | How child elements are arranged |
| `ScrollbarStyle` | ScrollbarStyle | Scrollbar appearance |
| `ContentWidth` | Integer | If set, displays horizontal scrollbar |
| `ContentHeight` | Integer | If set, displays vertical scrollbar |
| `AutoScrollDown` | Boolean | Auto-scroll to bottom (unless scrolled up) |
| `KeepScrollPosition` | Boolean | Keep scroll position after unmount |
| `MouseWheelScrollBehaviour` | MouseWheelScrollBehaviourType | Scroll behavior |
| `Overscroll` | Boolean | Extend scrolling areas by element size |

**Event Callbacks:**

| Event | Description |
|-------|-------------|
| `Validating` | Triggered on Enter key press |
| `Dismissing` | Triggered on Escape key press |
| `Scrolled` | Triggered after scrolling |

**Example:**
```ui
Group #Container {
    LayoutMode: Top;
    Padding: (Full: 10);
    Background: PatchStyle(Color: #1a1a2eF0, Border: 4);
    
    Label { Text: "Child 1"; }
    Label { Text: "Child 2"; }
}
```

---

### Label

**Text display** - Accepts children: No

Displays text with optional formatting via spans.

| Property | Type | Description |
|----------|------|-------------|
| `Text` | String | Plain text content |
| `TextSpans` | List&lt;LabelSpan&gt; | Formatted text spans |
| `Style` | LabelStyle | Text styling |

**Event Callbacks:**

| Event | Description |
|-------|-------------|
| `LinkActivating` | Called when a link is clicked |
| `TagMouseEntered` | Called when hovering a tag |

**Example:**
```ui
Label #Title {
    Text: "Hello World";
    Style: (FontSize: 20, RenderBold: true, TextColor: #ffffff);
}

// With rich text
Label #RichText {
    TextSpans: [
        (Text: "Bold ", IsBold: true),
        (Text: "and ", Color: #aaaaaa),
        (Text: "Colored", Color: #ff6600)
    ];
}
```

---

### Button

**Clickable button** - Accepts children: Yes

| Property | Type | Description |
|----------|------|-------------|
| `LayoutMode` | LayoutMode | How child elements are arranged |
| `Disabled` | Boolean | Whether button is clickable |
| `Style` | ButtonStyle | Button visual style |

**Event Callbacks:**

| Event | Description |
|-------|-------------|
| `Activating` | Triggered on click |
| `DoubleClicking` | Triggered on double click |
| `RightClicking` | Triggered on right click |
| `MouseEntered` | Mouse cursor entered bounds |
| `MouseExited` | Mouse cursor left bounds |

**Example:**
```ui
Button #SaveButton {
    Anchor: (Width: 120, Height: 36);
    Disabled: false;
    Style: $Common.@DefaultButtonStyle;
    
    Label { Text: "Save"; }
}
```

---

### TextField

**Text input** - Accepts children: No

| Property | Type | Description |
|----------|------|-------------|
| `Value` | String | Current text value |
| `PlaceholderText` | String | Text shown when empty |
| `PasswordChar` | Char | Character to replace text (for passwords) |
| `Style` | InputFieldStyle | Text style |
| `PlaceholderStyle` | InputFieldStyle | Placeholder text style |
| `Decoration` | InputFieldDecorationStyle | Field decoration style |
| `AutoFocus` | Boolean | Auto-focus when mounted |
| `AutoSelectAll` | Boolean | Auto-select all text (requires AutoFocus) |
| `IsReadOnly` | Boolean | Whether editable |
| `MaxLength` | Integer | Maximum character count |

**Event Callbacks:**

| Event | Description |
|-------|-------------|
| `RightClicking` | Right click on field |
| `Validating` | Enter key pressed |
| `Dismissing` | Escape key pressed |
| `FocusLost` | Field lost focus |
| `FocusGained` | Field gained focus |
| `ValueChanged` | Text value changed |

**Example:**
```ui
TextField #Username {
    Anchor: (Height: 36);
    FlexWeight: 1;
    PlaceholderText: "Enter username...";
    MaxLength: 32;
}

TextField #Password {
    Anchor: (Height: 36);
    PasswordChar: "*";
}
```

---

### Slider

**Range input with draggable handle** - Accepts children: No

| Property | Type | Description |
|----------|------|-------------|
| `Value` | Integer | Current value |
| `Min` | Integer | Minimum allowed value |
| `Max` | Integer | Maximum allowed value |
| `Step` | Integer | Increment/decrement amount |
| `IsReadOnly` | Boolean | Whether editable |
| `Style` | SliderStyle | Slider style |

**Event Callbacks:**

| Event | Description |
|-------|-------------|
| `MouseButtonReleased` | Drag completed |
| `ValueChanged` | Value changed |

**Example:**
```ui
Slider #VolumeSlider {
    Anchor: (Height: 24);
    FlexWeight: 1;
    Value: 50;
    Min: 0;
    Max: 100;
    Step: 1;
}
```

---

### CheckBox

**Toggle input** - Accepts children: No

| Property | Type | Description |
|----------|------|-------------|
| `Value` | Boolean | Checked state |
| `Disabled` | Boolean | Whether clickable |
| `Style` | CheckBoxStyle | CheckBox style |

**Event Callbacks:**

| Event | Description |
|-------|-------------|
| `ValueChanged` | Checked state changed |

**Example:**
```ui
CheckBox #EnableSound {
    Value: true;
}
```

---

### DropdownBox

**Dropdown selection** - Accepts children: Yes

| Property | Type | Description |
|----------|------|-------------|
| `Entries` | IReadOnlyList | Dropdown entries |
| `SelectedValues` | List&lt;String&gt; | Selected values (multi-select) |
| `Value` | String | Selected value (single-select) |
| `Disabled` | Boolean | Whether clickable |
| `Style` | DropdownBoxStyle | Dropdown style |
| `PanelTitleText` | String | Title for dropdown panel |
| `IsReadOnly` | Boolean | Whether editable |
| `MaxSelection` | Integer | Maximum selections allowed |
| `ShowSearchInput` | Boolean | Show search filter |
| `ShowLabel` | Boolean | Show selected label |
| `ForcedLabel` | String | Override label text |
| `NoItemsText` | String | Text when empty |
| `DisplayNonExistingValue` | Boolean | Show value not in entries |

**Event Callbacks:**

| Event | Description |
|-------|-------------|
| `ValueChanged` | Selection changed |
| `DropdownToggled` | Dropdown opened/closed |

**Example:**
```ui
DropdownBox #LanguageSelect {
    Anchor: (Width: 200, Height: 36);
    Value: "en-US";
    ShowSearchInput: true;
}
```

---

### ProgressBar

**Progress display** - Accepts children: No

| Property | Type | Description |
|----------|------|-------------|
| `Value` | Float | Progress value (0.0 - 1.0) |
| `Bar` | PatchStyle / String | Bar appearance |
| `BarTexturePath` | UI Path (String) | Bar texture |
| `EffectTexturePath` | UI Path (String) | Effect overlay texture |
| `EffectWidth` | Integer | Effect width |
| `EffectHeight` | Integer | Effect height |
| `EffectOffset` | Integer | Effect offset |
| `Alignment` | ProgressBarAlignment | Bar alignment |
| `Direction` | ProgressBarDirection | Fill direction |

**Example:**
```ui
ProgressBar #HealthBar {
    Anchor: (Width: 200, Height: 20);
    Value: 0.75;
    Direction: LeftToRight;
    Background: PatchStyle(Color: #333333);
    Bar: PatchStyle(Color: #22cc22);
}
```

---

### ItemGrid

**Scrollable item grid** - Accepts children: No

| Property | Type | Description |
|----------|------|-------------|
| `Slots` | ItemGridSlot[] | Grid slot data |
| `ItemStacks` | ClientItemStack[] | Simple item stacks |
| `SlotsPerRow` | Integer | Items per row |
| `ShowScrollbar` | Boolean | Show scrollbar |
| `Style` | ItemGridStyle | Grid style |
| `ScrollbarStyle` | ScrollbarStyle | Scrollbar style |
| `RenderItemQualityBackground` | Boolean | Show quality backgrounds |
| `InfoDisplay` | ItemGridInfoDisplayMode | Info display mode |
| `AdjacentInfoPaneGridWidth` | Integer | Info pane width |
| `AreItemsDraggable` | Boolean | Enable drag and drop |
| `InventorySectionId` | Integer | Inventory section ID |
| `AllowMaxStackDraggableItems` | Boolean | Allow full stack dragging |
| `DisplayItemQuantity` | Boolean | Show stack quantities |
| `KeepScrollPosition` | Boolean | Preserve scroll position |

**Event Callbacks:**

| Event | Description |
|-------|-------------|
| `SlotDoubleClicking` | Slot double-clicked |
| `DragCancelled` | Drag operation cancelled |
| `SlotMouseEntered` | Mouse entered slot |
| `SlotMouseExited` | Mouse left slot |

**Example:**
```ui
ItemGrid #InventoryGrid {
    FlexWeight: 1;
    SlotsPerRow: 8;
    ShowScrollbar: true;
    AreItemsDraggable: false;
    RenderItemQualityBackground: true;
    Style: $Common.@DefaultItemGridStyle;
}
```

---

### Sprite

**Animated spritesheet image** - Accepts children: No

| Property | Type | Description |
|----------|------|-------------|
| `TexturePath` | UI Path (String) | Spritesheet texture |
| `Frame` | SpriteFrame | Spritesheet layout info |
| `FramesPerSecond` | Integer | Animation speed |
| `IsPlaying` | Boolean | Animation playing state |
| `AutoPlay` | Boolean | Auto-play on mount |
| `Angle` | Float | Rotation in degrees |
| `RepeatCount` | Integer | Repeat count (0 = infinite) |

**Example:**
```ui
Sprite #LoadingSpinner {
    Anchor: (Width: 32, Height: 32);
    TexturePath: "spinner@2x.png";
    FramesPerSecond: 12;
    AutoPlay: true;
    RepeatCount: 0;
}
```

---

### TabNavigation

**Tab bar** - Accepts children: Yes

| Property | Type | Description |
|----------|------|-------------|
| `Tabs` | Tab[] | Tab definitions |
| `SelectedTab` | String | Currently selected tab |
| `AllowUnselection` | Boolean | Allow no selection |
| `Style` | TabNavigationStyle | Tab bar style |

**Event Callbacks:**

| Event | Description |
|-------|-------------|
| `SelectedTabChanged` | Tab selection changed |

**Example:**
```ui
TabNavigation #MainTabs {
    Anchor: (Height: 40);
    SelectedTab: "inventory";
    Style: $Common.@DefaultTabNavigationStyle;
}
```

---

### All Elements List

| Element | Children | Description |
|---------|----------|-------------|
| **Group** | Yes | Container/layout element |
| **Label** | No | Text display |
| **Button** | Yes | Clickable button |
| **TextField** | No | Single-line text input |
| **MultilineTextField** | No | Multi-line text input |
| **NumberField** | No | Numeric input |
| **Slider** | No | Range slider |
| **FloatSlider** | No | Float range slider |
| **CheckBox** | No | Boolean toggle |
| **DropdownBox** | Yes | Dropdown selection |
| **ProgressBar** | No | Progress indicator |
| **CircularProgressBar** | No | Circular progress |
| **ItemGrid** | No | Item slot grid |
| **ItemSlot** | No | Single item slot |
| **ItemIcon** | No | Item icon display |
| **ItemSlotButton** | No | Clickable item slot |
| **Sprite** | No | Animated spritesheet |
| **TabNavigation** | Yes | Tab bar |
| **TabButton** | Yes | Individual tab |
| **TextButton** | Yes | Text-labeled button |
| **ToggleButton** | Yes | Toggle button |
| **ActionButton** | Yes | Action button |
| **BackButton** | Yes | Back navigation |
| **Panel** | Yes | Styled panel |
| **SceneBlur** | No | Background blur effect |
| **TimerLabel** | No | Timer display |
| **HotkeyLabel** | No | Keybind display |
| **ReorderableList** | Yes | Drag-sortable list |
| **ReorderableListGrip** | No | Drag handle |
| **ColorPicker** | No | Color selection |
| **ColorPickerDropdownBox** | Yes | Color dropdown |
| **ColorOptionGrid** | No | Color option grid |
| **CodeEditor** | No | Code editing |
| **AssetImage** | No | Asset image display |
| **CharacterPreviewComponent** | No | Character preview |
| **ItemPreviewComponent** | No | Item preview |
| **BlockSelector** | No | Block selection |
| **DynamicPane** | Yes | Dynamic content pane |
| **DynamicPaneContainer** | Yes | Dynamic pane container |
| **LabeledCheckBox** | No | CheckBox with label |
| **SliderNumberField** | No | Slider with number field |
| **FloatSliderNumberField** | No | Float slider with number field |
| **CompactTextField** | No | Compact text input |
| **DropdownEntry** | No | Dropdown list item |
| **MenuItem** | Yes | Menu item |
| **CheckBoxContainer** | Yes | CheckBox container |

---

## Property Types

Property types define complex value structures used as element properties.

### Anchor

Defines element positioning and sizing within its container.

| Property | Type | Description |
|----------|------|-------------|
| `Left` | Integer | Distance from container's left edge |
| `Right` | Integer | Distance from container's right edge |
| `Top` | Integer | Distance from container's top edge |
| `Bottom` | Integer | Distance from container's bottom edge |
| `Width` | Integer | Fixed width in pixels |
| `Height` | Integer | Fixed height in pixels |
| `MinWidth` | Integer | Minimum width constraint |
| `MaxWidth` | Integer | Maximum width constraint |
| `MinHeight` | Integer | Minimum height constraint |
| `MaxHeight` | Integer | Maximum height constraint |

**Shorthand:**
- `Full` - All sides (Left, Top, Right, Bottom)
- `Horizontal` - Left and Right
- `Vertical` - Top and Bottom

**Example:**
```ui
Anchor: (Width: 200, Height: 40);           // Fixed size
Anchor: (Full: 10);                          // 10px margin all sides
Anchor: (Top: 0, Bottom: 0, Left: 20, Width: 300);  // Mixed
```

---

### Padding

Inner spacing around content.

| Property | Type | Description |
|----------|------|-------------|
| `Left` | Integer | Left padding |
| `Right` | Integer | Right padding |
| `Top` | Integer | Top padding |
| `Bottom` | Integer | Bottom padding |

**Shorthand:**
- `Full` - All sides
- `Horizontal` - Left and Right
- `Vertical` - Top and Bottom

**Example:**
```ui
Padding: (Full: 16);
Padding: (Horizontal: 20, Vertical: 10);
```

---

### PatchStyle

Nine-slice scalable backgrounds.

| Property | Type | Description |
|----------|------|-------------|
| `Color` | Color | Background color |
| `TexturePath` | UI Path (String) | Background texture |
| `Border` | Integer | Border thickness (all sides) |
| `HorizontalBorder` | Integer | Horizontal border thickness |
| `VerticalBorder` | Integer | Vertical border thickness |
| `Area` | Padding | Content area |
| `Anchor` | Anchor | Positioning |

**Example:**
```ui
Background: PatchStyle(Color: #1a1a2eF0, Border: 4);
Background: PatchStyle(TexturePath: "frame@2x.png", Border: 8);
```

---

### LabelStyle

Text styling properties.

| Property | Type | Description |
|----------|------|-------------|
| `FontName` | String | Font name (Default, Secondary, Mono) |
| `FontSize` | Float | Font size |
| `TextColor` | Color | Text color |
| `OutlineColor` | Color | Text outline color |
| `LetterSpacing` | Float | Space between letters |
| `HorizontalAlignment` | LabelAlignment | Horizontal alignment |
| `VerticalAlignment` | LabelAlignment | Vertical alignment |
| `Alignment` | LabelAlignment | Combined alignment |
| `Wrap` | Boolean | Enable text wrapping |
| `RenderUppercase` | Boolean | Render as uppercase |
| `RenderBold` | Boolean | Render bold |
| `RenderItalics` | Boolean | Render italic |
| `RenderUnderlined` | Boolean | Render underlined |

**Example:**
```ui
Style: LabelStyle(
    FontSize: 16,
    TextColor: #ffffff,
    RenderBold: true,
    HorizontalAlignment: Center
);
```

---

### LabelSpan

Rich text span for formatted text.

| Property | Type | Description |
|----------|------|-------------|
| `Text` | String | Span text content |
| `Color` | Color | Text color |
| `OutlineColor` | Color | Outline color |
| `IsBold` | Boolean | Bold text |
| `IsItalics` | Boolean | Italic text |
| `IsUppercase` | Boolean | Uppercase text |
| `IsUnderlined` | Boolean | Underlined text |
| `IsMonospace` | Boolean | Monospace font |
| `Link` | String | Clickable link URL |
| `Params` | Dictionary | Additional parameters |

**Example:**
```ui
TextSpans: [
    (Text: "Normal "),
    (Text: "Bold ", IsBold: true),
    (Text: "Colored", Color: #ff6600)
];
```

---

### ItemGridSlot

Item grid slot data.

| Property | Type | Description |
|----------|------|-------------|
| `ItemStack` | ClientItemStack | Item to display |
| `Background` | PatchStyle / String | Slot background |
| `Overlay` | PatchStyle / String | Overlay on top of item |
| `Icon` | PatchStyle / String | Icon overlay |
| `ExtraOverlays` | List&lt;PatchStyle&gt; | Additional overlays |
| `Name` | String | Custom name override |
| `Description` | String | Custom description |
| `InventorySlotIndex` | Integer | Inventory slot index |
| `IsItemIncompatible` | Boolean | Mark as incompatible |
| `IsActivatable` | Boolean | Can be activated |
| `IsItemUncraftable` | Boolean | Mark as uncraftable |
| `SkipItemQualityBackground` | Boolean | Skip quality background |

---

### All Property Types List

| Type | Description |
|------|-------------|
| **Anchor** | Element positioning/sizing |
| **Padding** | Inner spacing |
| **PatchStyle** | Nine-slice backgrounds |
| **LabelStyle** | Text styling |
| **LabelSpan** | Rich text span |
| **ItemGridSlot** | Item grid slot |
| **ItemGridStyle** | Item grid styling |
| **ClientItemStack** | Item stack data |
| **ButtonStyle** | Button styling |
| **ButtonStyleState** | Button state styling |
| **ButtonSounds** | Button sound effects |
| **CheckBoxStyle** | CheckBox styling |
| **CheckBoxStyleState** | CheckBox state styling |
| **SliderStyle** | Slider styling |
| **InputFieldStyle** | Text input styling |
| **InputFieldDecorationStyle** | Input decoration |
| **InputFieldDecorationStyleState** | Input state decoration |
| **InputFieldIcon** | Input field icon |
| **InputFieldButtonStyle** | Input button styling |
| **DropdownBoxStyle** | Dropdown styling |
| **DropdownBoxSounds** | Dropdown sounds |
| **DropdownBoxSearchInputStyle** | Dropdown search styling |
| **ScrollbarStyle** | Scrollbar styling |
| **TabStyle** | Tab styling |
| **TabStyleState** | Tab state styling |
| **TabNavigationStyle** | Tab bar styling |
| **Tab** | Tab definition |
| **TextButtonStyle** | TextButton styling |
| **TextButtonStyleState** | TextButton state styling |
| **ToggleButtonStyle** | ToggleButton styling |
| **ToggleButtonStyleState** | ToggleButton state styling |
| **LabeledCheckBoxStyle** | LabeledCheckBox styling |
| **LabeledCheckBoxStyleState** | LabeledCheckBox state styling |
| **PopupStyle** | Popup styling |
| **TextTooltipStyle** | Tooltip styling |
| **SoundStyle** | Sound effect |
| **SpriteFrame** | Spritesheet frame info |
| **NumberFieldFormat** | Number formatting |
| **ColorPickerStyle** | ColorPicker styling |
| **ColorPickerDropdownBoxStyle** | Color dropdown styling |
| **ColorPickerDropdownBoxStateBackground** | Color dropdown state |
| **ColorOptionGridStyle** | Color grid styling |
| **BlockSelectorStyle** | Block selector styling |
| **SubMenuItemStyle** | Submenu styling |
| **SubMenuItemStyleState** | Submenu state styling |

---

## Enums

Enums define valid values for specific properties.

### LayoutMode

How a container arranges its children.

| Value | Description |
|-------|-------------|
| `Full` | Children fill parent; positioned via Anchor |
| `Left` | Left-to-right, aligned left |
| `Center` | Left-to-right, centered horizontally |
| `Right` | Left-to-right, aligned right |
| `Top` | Top-to-bottom, aligned top |
| `Middle` | Top-to-bottom, centered vertically |
| `Bottom` | Top-to-bottom, aligned bottom |
| `CenterMiddle` | Left-to-right, centered both axes |
| `MiddleCenter` | Top-to-bottom, centered both axes |
| `LeftScrolling` | Like Left with scrolling |
| `RightScrolling` | Like Right with scrolling |
| `TopScrolling` | Like Top with scrolling |
| `BottomScrolling` | Like Bottom with scrolling |
| `LeftCenterWrap` | Left-to-right, wrap to next row, centered |

---

### LabelAlignment

Text alignment.

| Value | Description |
|-------|-------------|
| `Left` | Align left |
| `Center` | Align center |
| `Right` | Align right |

---

### ProgressBarDirection

Progress bar fill direction.

| Value | Description |
|-------|-------------|
| `LeftToRight` | Fill from left to right |
| `RightToLeft` | Fill from right to left |
| `TopToBottom` | Fill from top to bottom |
| `BottomToTop` | Fill from bottom to top |

---

### ProgressBarAlignment

Progress bar alignment within container.

| Value | Description |
|-------|-------------|
| `Start` | Align to start |
| `Center` | Align to center |
| `End` | Align to end |

---

### TimerDirection

Timer count direction.

| Value | Description |
|-------|-------------|
| `Up` | Count up |
| `Down` | Count down |

---

### All Enums List

| Enum | Values |
|------|--------|
| **LayoutMode** | Full, Left, Center, Right, Top, Middle, Bottom, CenterMiddle, MiddleCenter, LeftScrolling, RightScrolling, TopScrolling, BottomScrolling, LeftCenterWrap |
| **LabelAlignment** | Left, Center, Right |
| **ProgressBarDirection** | LeftToRight, RightToLeft, TopToBottom, BottomToTop |
| **ProgressBarAlignment** | Start, Center, End |
| **TimerDirection** | Up, Down |
| **ResizeType** | None, Horizontal, Vertical, Both |
| **TooltipAlignment** | (alignment values) |
| **ActionButtonAlignment** | (alignment values) |
| **DropdownBoxAlign** | (alignment values) |
| **InputFieldButtonSide** | (side values) |
| **InputFieldIconSide** | (side values) |
| **ItemGridInfoDisplayMode** | (display modes) |
| **ColorFormat** | (color formats) |
| **CodeEditorLanguage** | (language values) |
| **MouseWheelScrollBehaviourType** | (behavior types) |

---

## Source

Full type documentation: https://hytalemodding.dev/en/docs/official-documentation/custom-ui/type-documentation
