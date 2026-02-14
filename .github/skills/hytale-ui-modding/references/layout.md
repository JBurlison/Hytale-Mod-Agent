# Layout Reference

The layout system determines how UI elements are positioned and sized on screen. Understanding layout is crucial for creating well-structured, responsive interfaces.

## Layout Fundamentals

Every UI element has four key layout concepts:

1. **Container Rectangle** - The space allocated by the parent element
2. **Anchor** - How the element positions and sizes itself within the container
3. **Padding** - Inner spacing that affects where children are positioned
4. **LayoutMode** - How the element arranges its children (if it's a container)

Visual representation:

```
┌─────────────────────────────────────┐
│  Container Rectangle (from parent)  │
│  ┌───────────────────────────────┐  │
│  │  Anchored Rectangle           │  │
│  │  ┌─────────────────────────┐  │  │
│  │  │ Padding                 │  │  │
│  │  │  ┌───────────────────┐  │  │  │
│  │  │  │  Content Area     │  │  │  │
│  │  │  └───────────────────┘  │  │  │
│  │  └─────────────────────────┘  │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

---

## Anchor

Anchor controls how an element positions and sizes itself within its container rectangle.

### Anchor Properties

| Property | Type | Description |
|----------|------|-------------|
| `Left` | int | Distance from container's left edge |
| `Right` | int | Distance from container's right edge |
| `Top` | int | Distance from container's top edge |
| `Bottom` | int | Distance from container's bottom edge |
| `Width` | int | Fixed width in pixels |
| `Height` | int | Fixed height in pixels |
| `MinWidth` | int | Minimum width constraint |
| `MaxWidth` | int | Maximum width constraint |
| `MinHeight` | int | Minimum height constraint |
| `MaxHeight` | int | Maximum height constraint |

### Shorthand Properties

| Shorthand | Expands To |
|-----------|------------|
| `Full` | Left, Top, Right, Bottom (all sides) |
| `Horizontal` | Left and Right |
| `Vertical` | Top and Bottom |

### Fixed Size

Creates an element with explicit dimensions:

```ui
Button {
    Anchor: (Width: 200, Height: 40);
}
```

Result: A 200×40 pixel button.

### Positioning

Position an element at specific offsets from the container edges:

```ui
Label {
    Anchor: (Top: 10, Left: 20, Width: 100, Height: 30);
}
```

- Top: 10 pixels from container's top edge
- Left: 20 pixels from container's left edge
- Width: 100 pixels wide
- Height: 30 pixels tall

### Anchoring to Edges

Anchor to bottom-right corner:

```ui
Button {
    Anchor: (Bottom: 10, Right: 10, Width: 100, Height: 30);
}
```

Anchors the button 10 pixels from the bottom and right edges.

### Stretching

Fill the entire container:

```ui
Group {
    Anchor: (Top: 0, Bottom: 0, Left: 0, Right: 0);
}
```

Or use the shorthand:

```ui
Group {
    Anchor: (Full: 0);
}
```

Stretch with margins:

```ui
Group {
    Anchor: (Full: 10);
}
```

This creates 10 pixels of margin on all sides.

### Mixed Anchoring

Combine fixed dimensions with stretching:

```ui
Panel {
    Anchor: (Top: 10, Bottom: 10, Left: 20, Width: 300);
}
```

- Fixed width of 300 pixels
- Stretches vertically between top and bottom edges
- 10 pixels from top and bottom
- 20 pixels from left

---

## Padding

Padding creates inner spacing, affecting where children are positioned.

### Uniform Padding

Apply the same padding to all sides:

```ui
Group {
    Padding: (Full: 20);
}
```

Result: 20 pixels of padding on all sides.

### Directional Padding

Different padding per edge:

```ui
Group {
    Padding: (Top: 10, Bottom: 20, Left: 15, Right: 15);
}
```

### Shorthand

Combine horizontal and vertical:

```ui
Group {
    Padding: (Horizontal: 20, Vertical: 10);
}
// Equivalent to:
// Top: 10, Bottom: 10, Left: 20, Right: 20
```

### Effect on Children

When a child uses `Anchor: (Full: 0)`, it fills the parent but respects padding:

```ui
Group {
    Anchor: (Width: 200, Height: 100);
    Padding: (Full: 10);
    Label {
        Anchor: (Full: 0);
    }
}
```

Visual result:

```
┌──────────────────────┐
│ Group (200×100)      │
│  ┌────────────────┐  │
│  │ Label          │  │ ← 10px padding all around
│  │                │  │
│  └────────────────┘  │
└──────────────────────┘
```

---

## LayoutMode

LayoutMode determines how a container arranges its children.

### Top (Vertical Stack)

Children stack vertically from top to bottom:

```ui
Group {
    LayoutMode: Top;
    Button { Anchor: (Height: 30); }
    Button { Anchor: (Height: 30); }
    Button { Anchor: (Height: 30); }
}
```

Result:

```
┌──────────┐
│ Button 1 │
├──────────┤
│ Button 2 │
├──────────┤
│ Button 3 │
└──────────┘
```

**Spacing:** Use `Anchor.Bottom` to add spacing after each element:

```ui
Button { Anchor: (Height: 30, Bottom: 10); }  // 10px gap after this button
```

### Bottom (Vertical Stack, Bottom-Aligned)

Children stack vertically but align to the bottom edge:

```ui
Group {
    LayoutMode: Bottom;
    Button { Anchor: (Height: 30); }
    Button { Anchor: (Height: 30); }
    Button { Anchor: (Height: 30); }
}
```

### Left (Horizontal Stack)

Children arrange horizontally from left to right:

```ui
Group {
    LayoutMode: Left;
    Button { Anchor: (Width: 80); }
    Button { Anchor: (Width: 80); }
    Button { Anchor: (Width: 80); }
}
```

Result:

```
┌────────┬────────┬────────┐
│ Button │ Button │ Button │
│   1    │   2    │   3    │
└────────┴────────┴────────┘
```

**Spacing:** Use `Anchor.Right` for spacing between elements.

### Right (Horizontal Stack, Right-Aligned)

Children arrange horizontally, aligned to the right side of the parent:

```ui
Group {
    LayoutMode: Right;
    Button { Anchor: (Width: 80); }
    Button { Anchor: (Width: 80); }
    Button { Anchor: (Width: 80); }
}
```

### Center

Centers children horizontally within the parent:

```ui
Group {
    LayoutMode: Center;
    Group #Dialog {
        Anchor: (Width: 400, Height: 300);
    }
}
```

### Middle

Centers children vertically within the parent:

```ui
Group {
    LayoutMode: Middle;
    Group #Dialog {
        Anchor: (Width: 400, Height: 300);
    }
}
```

### CenterMiddle (Horizontal Stack, Fully Centered)

Children stack horizontally from left to right, centered both horizontally and vertically:

```ui
Group {
    LayoutMode: CenterMiddle;
    Button { Anchor: (Width: 80); }
    Button { Anchor: (Width: 80); }
    Button { Anchor: (Width: 80); }
}
```

Result:

```
┌────────────────────────────────────────────┐
│                                            │
│                                            │
│         ┌──────┐ ┌──────┐ ┌──────┐         │
│         │  B1  │ │  B2  │ │  B3  │         │
│         └──────┘ └──────┘ └──────┘         │
│                                            │
│                                            │
└────────────────────────────────────────────┘
```

### MiddleCenter (Vertical Stack, Fully Centered)

Children stack vertically from top to bottom, centered both horizontally and vertically:

```ui
Group {
    LayoutMode: MiddleCenter;
    Button { Anchor: (Height: 30); }
    Button { Anchor: (Height: 30); }
    Button { Anchor: (Height: 30); }
}
```

Result:

```
┌────────────────────────────────────────────┐
│                                            │
│              ┌──────────┐                  │
│              │ Button 1 │                  │
│              ├──────────┤                  │
│              │ Button 2 │                  │
│              ├──────────┤                  │
│              │ Button 3 │                  │
│              └──────────┘                  │
│                                            │
└────────────────────────────────────────────┘
```

### Full (Absolute Positioning)

Children use absolute positioning via their Anchor properties:

```ui
Group {
    LayoutMode: Full;
    Label {
        Anchor: (Top: 20, Left: 20, Width: 100, Height: 30);
    }
}
```

### TopScrolling / BottomScrolling

Like Top/Bottom, but adds a scrollbar if content exceeds container height:

```ui
Group {
    LayoutMode: TopScrolling;
    ScrollbarStyle: $Common.@DefaultScrollbar;
    // ... many children
}
```

### LeftScrolling / RightScrolling

Like Left/Right, but adds a scrollbar for horizontal scrolling:

```ui
Group {
    LayoutMode: LeftScrolling;
    ScrollbarStyle: $Common.@DefaultScrollbar;
    // ... many children
}
```

### LeftCenterWrap (Wrapping Horizontal Stack)

Children flow left to right. When there's no more horizontal space, they wrap to the next row. Each row is horizontally centered:

```ui
Group {
    LayoutMode: LeftCenterWrap;
    Button { Anchor: (Width: 80, Height: 30); }
    Button { Anchor: (Width: 80, Height: 30); }
    Button { Anchor: (Width: 80, Height: 30); }
    Button { Anchor: (Width: 80, Height: 30); }
    Button { Anchor: (Width: 80, Height: 30); }
}
```

Result:

```
┌────────────────────────────────────────────┐
│                                            │
│       ┌──────┐ ┌──────┐ ┌──────┐           │
│       │  B1  │ │  B2  │ │  B3  │           │
│       └──────┘ └──────┘ └──────┘           │
│            ┌──────┐ ┌──────┐               │
│            │  B4  │ │  B5  │               │
│            └──────┘ └──────┘               │
│                                            │
└────────────────────────────────────────────┘
```

### Complete LayoutMode Reference

| Mode | Direction | Alignment | Scrollable Variant |
|------|-----------|-----------|-------------------|
| `Top` | Vertical | Top | `TopScrolling` |
| `Bottom` | Vertical | Bottom | `BottomScrolling` |
| `Left` | Horizontal | Left | `LeftScrolling` |
| `Right` | Horizontal | Right | `RightScrolling` |
| `Center` | - | Horizontal center | - |
| `Middle` | - | Vertical center | - |
| `CenterMiddle` | Horizontal | Both centered | - |
| `MiddleCenter` | Vertical | Both centered | - |
| `Full` | Absolute | Via Anchor | - |
| `LeftCenterWrap` | Horizontal wrap | Centered rows | - |
| `RightCenterWrap` | Horizontal wrap | Centered rows | - |

---

## FlexWeight

FlexWeight distributes remaining space among children after fixed-size elements are placed.

### Basic Usage

```ui
Group {
    LayoutMode: Left;
    Anchor: (Width: 400);
    Button {
        Anchor: (Width: 100);
    }
    Group {
        FlexWeight: 1;  // Takes all remaining space
    }
    Button {
        Anchor: (Width: 100);
    }
}
```

Result:
- First button: 100px
- Middle group: 200px (400 - 100 - 100 = 200)
- Last button: 100px

### Multiple FlexWeights

When multiple elements have FlexWeight, space is distributed proportionally:

```ui
Group {
    LayoutMode: Left;
    Anchor: (Width: 600);
    Group { FlexWeight: 1; }
    Group { FlexWeight: 2; }
    Group { FlexWeight: 1; }
}
```

Remaining space (600px) is split:
- First group: 600 × (1/4) = 150px
- Second group: 600 × (2/4) = 300px
- Third group: 600 × (1/4) = 150px

---

## Visibility

Control whether an element is displayed:

```ui
Button #HiddenButton {
    Visible: false;
}
```

Effect:
- Element and its children are not displayed
- Element is **not** included in layout (doesn't take up space)

---

Source: https://hytalemodding.dev/en/docs/official-documentation/custom-ui/layout
