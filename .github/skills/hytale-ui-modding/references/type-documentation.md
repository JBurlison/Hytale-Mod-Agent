# Type Documentation Reference

The type documentation is a generated index of all UI elements, property types, and enums available in markup. Use it as your reference when you need exact property names, types, or valid enum values.

---

## Elements

Elements are the building blocks of UI. Each element type has specific properties.

### Commonly Used Elements

| Element | Purpose | Key Properties |
|---------|---------|----------------|
| `Group` | Container/layout | `LayoutMode`, `Background`, `Padding`, `ScrollbarStyle` |
| `Label` | Text display | `Text`, `TextSpans`, `Style`, `TextColor` |
| `Button` | Clickable button | `Text`, `Disabled`, `Style`, `Background` |
| `TextField` | Text input | `Value`, `PlaceholderText`, `MaxLength`, `ReadOnly`, `Password`, `PasswordChar`, `AutoGrow`, `MaxVisibleLines` |
| `Slider` | Range input | `Value`, `Min`, `Max`, `Step`, `Style` |
| `CheckBox` | Toggle input | `Value` (boolean) |
| `DropdownBox` | Dropdown selection | `Value`, `Entries` (DropdownEntryInfo[]) |
| `ProgressBar` | Progress display | `Value` (0.0-1.0), `BarTexturePath`, `EffectTexturePath`, `Direction`, `Alignment`, `Color` |
| `CircularProgressBar` | Circular progress | `Value`, `MaskTexturePath` |
| `Sprite` | Animated image | `TexturePath`, `Frame`, `FramesPerSecond` |
| `ItemIcon` | Item display | `ItemId`, `Quantity` |
| `ItemSlot` | Full item slot | `ItemStack`, `Background`, `Overlay`, `Icon` |
| `ItemGrid` | Scrollable item grid | `Slots`, `SlotsPerRow`, `AreItemsDraggable`, `ShowScrollbar`, `KeepScrollPosition`, `RenderItemQualityBackground` |
| `TabNavigation` | Tab bar | Works with tab content groups |
| `TimerLabel` | Timer display | Specialized label for timers |

### Full Element List

- ActionButton
- AssetImage
- BackButton
- BlockSelector
- Button
- CharacterPreviewComponent
- CheckBox
- CheckBoxContainer
- CircularProgressBar
- CodeEditor
- ColorOptionGrid
- ColorPicker
- ColorPickerDropdownBox
- CompactTextField
- DropdownBox
- DropdownEntry
- DynamicPane
- DynamicPaneContainer
- FloatSlider
- FloatSliderNumberField
- Group
- HotkeyLabel
- ItemGrid
- ItemIcon
- ItemPreviewComponent
- ItemSlot
- ItemSlotButton
- Label
- LabeledCheckBox
- MenuItem
- MultilineTextField
- NumberField
- Panel
- ProgressBar
- ReorderableList
- ReorderableListGrip
- SceneBlur
- Slider
- SliderNumberField
- Sprite
- TabButton
- TabNavigation
- TextButton
- TextField
- TimerLabel
- ToggleButton

---

## Property Types

Property types define the structure of complex values used in element properties.

### Commonly Used Property Types

| Type | Purpose |
|------|---------|
| `Anchor` | Element positioning and sizing |
| `Padding` | Inner spacing |
| `PatchStyle` | Nine-slice scalable backgrounds |
| `ScrollbarStyle` | Scrollbar appearance |
| `LabelStyle` | Text styling (font, size, color, alignment) |
| `ButtonStyle` | Button visual states |
| `SliderStyle` | Slider appearance |
| `TabStyle` | Tab appearance |
| `TabNavigationStyle` | Tab bar styling |
| `TextButtonStyle` | Text button styling |
| `ItemGridSlot` | Item grid slot data |
| `LabelSpan` | Rich text span |

### Full Property Type List

- Anchor
- BlockSelectorStyle
- ButtonSounds
- ButtonStyle
- ButtonStyleState
- CheckBoxStyle
- CheckBoxStyleState
- ClientItemStack
- ColorOptionGridStyle
- ColorPickerDropdownBoxStateBackground
- ColorPickerDropdownBoxStyle
- ColorPickerStyle
- DropdownBoxSearchInputStyle
- DropdownBoxSounds
- DropdownBoxStyle
- InputFieldButtonStyle
- InputFieldDecorationStyle
- InputFieldDecorationStyleState
- InputFieldIcon
- InputFieldStyle
- ItemGridSlot
- ItemGridStyle
- LabeledCheckBoxStyle
- LabeledCheckBoxStyleState
- LabelSpan
- LabelStyle
- NumberFieldFormat
- Padding
- PatchStyle
- PopupStyle
- ScrollbarStyle
- SliderStyle
- SoundStyle
- SpriteFrame
- SubMenuItemStyle
- SubMenuItemStyleState
- Tab
- TabNavigationStyle
- TabStyle
- TabStyleState
- TextButtonStyle
- TextButtonStyleState
- TextTooltipStyle
- ToggleButtonStyle
- ToggleButtonStyleState

---

## Enums

Enums define valid values for certain properties.

### Commonly Used Enums

| Enum | Values | Purpose |
|------|--------|---------|
| `LayoutMode` | Top, Bottom, Left, Right, Center, Middle, CenterMiddle, MiddleCenter, Full, TopScrolling, BottomScrolling, LeftScrolling, RightScrolling, LeftCenterWrap, RightCenterWrap | How a container arranges children |
| `LabelAlignment` | Left, Right, Center | Text horizontal alignment |
| `ProgressBarDirection` | LeftToRight, RightToLeft, BottomToTop, TopToBottom | Progress bar fill direction |
| `ProgressBarAlignment` | Start, Center, End | Progress bar alignment |
| `TimerDirection` | Up, Down | Timer count direction |
| `ResizeType` | None, Horizontal, Vertical, Both | Resize behavior |

### Full Enum List

- ActionButtonAlignment
- CodeEditorLanguage
- ColorFormat
- DropdownBoxAlign
- InputFieldButtonSide
- InputFieldIconSide
- ItemGridInfoDisplayMode
- LabelAlignment
- LayoutMode
- MouseWheelScrollBehaviourType
- ProgressBarAlignment
- ProgressBarDirection
- ResizeType
- TimerDirection
- TooltipAlignment

---

## How to Use Type Documentation

When you need specific details:

1. **Find the element type** you're working with
2. **Look up its properties** in the element documentation
3. **Check the property type** to understand what structure is expected
4. **Reference enums** for valid values when a property expects an enum

### Example: ProgressBar

To create a progress bar:

```ui
ProgressBar #HealthBar {
    Anchor: (Width: 200, Height: 20);
    Value: 0.75;
    Direction: LeftToRight;  // ProgressBarDirection enum
    Alignment: Start;         // ProgressBarAlignment enum
    Color: #22cc22;
}
```

---

## Online Reference

For the most up-to-date and detailed documentation, visit:
https://hytalemodding.dev/en/docs/official-documentation/custom-ui/type-documentation

The online documentation includes:
- Complete property lists for each element
- Detailed descriptions of each property type
- All valid enum values with descriptions

---

Source: https://hytalemodding.dev/en/docs/official-documentation/custom-ui/type-documentation
