# Common Styling Reference

This document describes the shared UI components and styles defined in `Common.ui`. Use these to create custom UIs that match the base game's visual style.

## Overview

The `Common.ui` file provides shared styles and components that deliver a cohesive UI experience with the core game UI. These are pre-built, battle-tested components you should prefer over creating your own from scratch.

## Location

Common.ui is located at `Common/UI/Custom/Common.ui` within the Hytale pack.

---

## Importing Common.ui

### Direct Import (file in Common/UI/Custom/)

If your .ui file is directly in `Common/UI/Custom/`:

```ui
$Common = "Common.ui";

// Then reference styles and components:
$Common.@TextButton { @Text = "My Button"; }
$Common.@Container { ... }
```

### Relative Import (file in subfolder)

If your custom UI document is in a subfolder of `Common/UI/Custom/`, use relative path traversal:

```ui
$Common = "../Common.ui";
```

For deeper nesting:

```ui
// Two levels deep
$Common = "../../Common.ui";
```

See the [Markup path documentation](markup.md) for more details on path resolution.

---

## Referencing Styles

Once imported, reference styles from Common.ui using the `$Common.@StyleName` syntax:

```ui
$Common = "../Common.ui";

Label {
    Style: $Common.@DefaultLabelStyle;
}

Group {
    ScrollbarStyle: $Common.@DefaultScrollbarStyle;
}
```

---

## Referencing Components (Templates)

Common.ui also provides pre-built component templates:

```ui
$Common = "../Common.ui";

Group #ButtonRow {
    LayoutMode: Left;
    
    // Use the TextButton template
    $Common.@TextButton #SaveButton {
        @Text = "Save";
    }
    
    $Common.@TextButton #CancelButton {
        @Text = "Cancel";
    }
}
```

---

## Common Components and Styles

The exact list of available styles and components can be viewed via the `/ui-gallery` command in-game. (Note: This command is planned for a future patch.)

### Frequently Used Styles

| Style Name | Description |
|------------|-------------|
| `@DefaultLabelStyle` | Standard label text styling |
| `@DefaultButtonStyle` | Standard button styling |
| `@DefaultScrollbarStyle` | Default scrollbar for scrolling groups |

### Frequently Used Components

| Component | Description |
|-----------|-------------|
| `@TextButton` | Primary styled button |
| `@SecondaryTextButton` | Secondary styled button |
| `@TertiaryTextButton` | Tertiary styled button |
| `@CancelTextButton` | Cancel/destructive button |
| `@BackButton` | Back navigation button |
| `@Container` | Styled window frame with title |
| `@PageOverlay` | Full-screen overlay background |
| `@NumberField` | Numeric input field |
| `@AssetImage` | Asset image display |
| `@CheckBoxWithLabel` | Checkbox with text label |

---

## Best Practices

1. **Always import Common.ui** - Use shared styles instead of duplicating them locally
2. **Use relative paths correctly** - Adjust the path based on your file's location relative to `Common/UI/Custom/`
3. **Prefer templates over raw elements** - Use `$Common.@TextButton` instead of building a button from scratch
4. **Check /ui-gallery** - When available, use this command to see live examples of all Common.ui styles

---

## Value References from Java

In Java code, you can reference Common.ui styles:

```java
import com.hypixel.hytale.server.core.ui.Value;

// Reference a style from Common.ui
commands.set("#Element.Style", Value.ref("Common.ui", "DefaultButtonStyle"));
commands.set("#ScrollGroup.ScrollbarStyle", Value.ref("Common.ui", "DefaultScrollbar"));
```

---

Source: https://hytalemodding.dev/en/docs/official-documentation/custom-ui/common-styling
