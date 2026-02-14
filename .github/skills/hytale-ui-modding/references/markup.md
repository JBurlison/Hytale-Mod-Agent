# Markup Reference

A UI document (.ui file) contains trees of elements. There can be multiple root elements in a single document.

## Basic Syntax

An element is the basic building block of a user interface. Here's the fundamental syntax:

```ui
// Basic declaration of an element
// with its Anchor property set to attach on all sides of its parent
// with 10 pixels of margin
Group { Anchor: (Left: 10, Top: 10, Right: 10, Bottom: 10); }
Group { Anchor: (Full: 10); } // More concise version

// Declaration of a Label with a name
// (can be used to access the element from game code)
Label #MyLabel {
    Style: LabelStyle(FontSize: 16); // or just Style: (FontSize: 16), type can be inferred.
    Text: "Hi! I am text.";
}

// Declaration of a Group containing 2 children
Group {
    LayoutMode: Left;
    Label { Text: "Child 1"; FlexWeight: 2; }
    Label { Text: "Child 2"; FlexWeight: 1; }
}
```

### Syntax Rules

- **Elements**: `ElementType [#Id] { properties... children... }`
- **IDs**: Prefix with `#` for Java/event access (e.g., `#MyLabel`)
- **Properties**: `PropertyName: value;`
- **Comments**: `// single line comment`
- **Tuples/Objects**: `(Key1: value1, Key2: value2)`

---

## Documents

A UI document can have multiple root elements. Each root element becomes a separate tree in the UI hierarchy.

---

## Named Expressions

Named expressions are reusable values declared with the `@` prefix. They must be declared at the top of the block (before properties and children).

### Basic Named Expressions

```ui
// Example of named expressions, declared and used with @ prefix
@Title = "Hytale";
@ExtraSpacing = 5;

Label {
    Text: @Title;
    Style: (LetterSpacing: 2 + @ExtraSpacing);
}
```

### Named Expression Scoping

Named expressions are scoped to the subtree where they are declared. They can be declared at any level, including document root.

### Spread Operator

Use the spread operator `...` to reuse a named expression while overriding some of its fields:

```ui
@MyBaseStyle = LabelStyle(FontSize: 24, LetterSpacing: 2);

Label {
    Style: (...@MyBaseStyle, FontSize: 36);
}
```

### Layering Multiple Named Expressions

You can combine multiple named expressions:

```ui
@TitleStyle = LabelStyle(FontSize: 24, HorizontalAlignment: Center);
@BigTextStyle = LabelStyle(FontSize: 36);
@SpacedTextStyle = LabelStyle(LetterSpacing: 2);

Label {
    Style: (...@BigTextStyle, ...@SpacedTextStyle);
}
```

### Document References

A document can reference another document and access its named expressions using the `$` prefix:

```ui
// Document references are defined with $ prefix
$Common = "../Common.ui";

TextButton {
    Style: $Common.@DefaultButtonStyle;
}
```

---

## Templates

Templates are named expressions that contain element trees. You can instantiate them multiple times with customizations.

### Declaring and Using Templates

```ui
// This is the template
@Row = Group {
    Anchor: (Height: 50);
    Label #Label { Anchor: (Left: 0, Width: 100); Text: @LabelText; }
    Group #Content { Anchor: (Left: 100); }
};

// Here we'll be using it twice in the document tree
Group #Rows {
    LayoutMode: TopScrolling;
    @Row #MyFirstRow {
        @LabelText = "First row";
        #Content { TextField {} }
    }
    @Row #MySecondRow {
        @LabelText = "Second row";
    }
}
```

### Template Customization Rules

- You can override local named expressions inside template instances
- You can insert additional children at any point in the template tree by targeting the child's ID
- Local named expressions must be defined at the very top of the block, before properties and child elements

---

## Property Types

### Basic Types

| Type | Example | Notes |
|------|---------|-------|
| Boolean | `Visible: false;` | `true` or `false` |
| Int | `Height: 20;` | Whole numbers |
| Float, Double, Decimal | `Min: 0.2;` | Decimal numbers |
| String | `Text: "Hi!";` | Quoted text |
| Char | `PasswordChar: "*";` | Single character only (same syntax as string) |
| Color | `Background: #ffffff;` | Hex color literals |
| Object | `Style: (Background: #ffffff)` | Parentheses with key-value pairs |
| Array | `TextSpans: [(Text: "Hi", IsBold: true)]` | Square brackets with objects |

### Translations

Translation keys can be referenced anywhere you can provide a string. They are converted to localized strings when the element is instantiated:

```ui
Label {
    Text: %ui.general.cancel;
}
```

The translation key uses the `%` prefix and references keys from language files.

### Colors

Color literals can be written in several formats:

| Format | Description | Example |
|--------|-------------|---------|
| `#rrggbb` | 6-digit hex (fully opaque) | `#ffffff` |
| `#rrggbb(a.a)` | 6-digit hex with alpha (0-1) | `#000000(0.3)` |
| `#rrggbbaa` | 8-digit hex with alpha | `#ffffff80` |

**Preferred:** The `#rrggbb(a.a)` format is recommended for readability.

```ui
Group {
    Background: #000000(0.3);  // 30% opacity black
}
```

### Font Names

Font names are strings that map to `UIFontName` internally:

```ui
Label {
    Text: "Hi";
    Style: (FontName: "Secondary");
}
```

**Available Font Names:**

| Name | Use Case |
|------|----------|
| `Default` | Standard text; used unless specified otherwise |
| `Secondary` | Headlines or elements that should stand out |
| `Mono` | Development only (profiling, error overlays) |

### Paths (UIPath)

Paths reference other UI assets and are always relative to the current file location:

```ui
// UIPath syntax is the same as String
Sprite {
    TexturePath: "MyButton.png";
}
```

**Path Resolution Examples:**

| Reference | Current File | Resolved Path |
|-----------|--------------|---------------|
| `MyButton.png` | `Menu/MyAwesomeMenu.ui` | `Menu/MyButton.png` |
| `../MyButton.png` | `Menu/MyAwesomeMenu.ui` | `MyButton.png` |
| `../../MyButton.png` | `Menu/Popup/Templates/MyAwesomeMenu.ui` | `Menu/MyButton.png` |

### Objects

Objects contain a set of properties in parentheses:

```ui
Group {
    Anchor: (
        Height: 10,
        Width: 20
    );
}
```

Type inference is supported. If the property type is known, you don't need to specify the type name:

```ui
// Explicit type
Style: LabelStyle(FontSize: 16);

// Inferred type (when property expects LabelStyle)
Style: (FontSize: 16);
```

### Arrays

Arrays use square brackets and contain objects:

```ui
Label {
    TextSpans: [
        (Text: "Hello ", IsBold: true),
        (Text: "World", IsBold: false)
    ];
}
```

---

## Visual Studio Code Extension

There is an official VS Code extension that adds syntax highlighting for `.ui` files:

https://marketplace.visualstudio.com/items?itemName=HypixelStudiosCanadaInc.vscode-hytaleui

---

Source: https://hytalemodding.dev/en/docs/official-documentation/custom-ui/markup
