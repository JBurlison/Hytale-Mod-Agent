# Hytale UI Modding Reference Index

A comprehensive library of UI modding documentation for Hytale plugins.

---

## Reference Files

### Core Concepts

| File | Description |
|------|-------------|
| [overview.md](overview.md) | **Architecture overview** - What Custom UI is, how it fits into Hytale (Client UI vs Server UI), command-based architecture diagram, key principles (Declarative, Asset-Driven, Event-Driven, Selector-Based). |
| [layout.md](layout.md) | **Layout system** - Anchor positioning/sizing, Padding, LayoutMode (vertical/horizontal stacking, centering, scrolling, wrapping), FlexWeight distribution, Visibility. Includes visual diagrams. |
| [markup.md](markup.md) | **Markup syntax** - Element declarations, named expressions (@), templates, document references ($), property types (strings, colors, objects, arrays), translation keys (%). |
| [common-styling.md](common-styling.md) | **Common.ui integration** - Import patterns, referencing styles and components, available templates (@TextButton, @Container, etc.), Value.ref() in Java. |
| [type-documentation.md](type-documentation.md) | **Type reference overview** - How to navigate the official type docs, commonly used elements/properties/enums quick reference. |
| [types.md](types.md) | **Complete types reference** - Detailed documentation of ALL UI elements (Group, Label, Button, TextField, ItemGrid, etc.), property types (Anchor, Padding, PatchStyle, LabelStyle, etc.), and enums (LayoutMode, LabelAlignment, etc.) with full property tables. |

### Java API

| File | Description |
|------|-------------|
| [java-api.md](java-api.md) | **Java UI classes** - CustomUIHud, MultipleHUD (MHUD for multiple HUDs), CustomUIPage, InteractiveCustomUIPage with event handling, UICommandBuilder, UIEventBuilder, threading requirements, ECS patterns. |
| [events.md](events.md) | **Event binding** - Complete CustomUIEventBindingType reference (Activating, ValueChanged, SlotClicking, etc.), value references with @ prefix, EventData codec patterns. |

### Practical Guides

| File | Description |
|------|-------------|
| [examples.md](examples.md) | **Complete examples** - Simple HUD, interactive dialog, search page with dynamic results, item grid inventory. Full .ui files and Java implementations. |
| [assets-and-packaging.md](assets-and-packaging.md) | **Assets & packaging** - File locations, @2x.png naming, manifest.json IncludesAssetPack, UIPath resolution, image formats. |
| [translations.md](translations.md) | **Translations & Localization** - Using translation keys (%) in UI, language files (.lang), LocalizableString in Java, translation parameters. Also covers contributing to HytaleModding website translations via Crowdin. |
| [troubleshooting.md](troubleshooting.md) | **Common issues** - UI stuck on loading, blank pages, missing images, event handling problems, selector issues, threading crashes. |

---

## Quick Navigation by Task

| I want to... | Read |
|--------------|------|
| Understand the UI architecture | [overview.md](overview.md) |
| Position an element | [layout.md](layout.md) - Anchor section |
| Stack elements vertically/horizontally | [layout.md](layout.md) - LayoutMode section |
| Create reusable UI components | [markup.md](markup.md) - Templates section |
| Use game-styled buttons | [common-styling.md](common-styling.md) - Components section |
| Look up element properties | [types.md](types.md) - Elements section |
| Look up property type fields | [types.md](types.md) - Property Types section |
| Look up enum values | [types.md](types.md) - Enums section |
| Handle button clicks | [events.md](events.md) - Activating event |
| Create a HUD | [java-api.md](java-api.md) - CustomUIHud section |
| Show multiple HUDs | [java-api.md](java-api.md) - MultipleHUD section |
| Create an interactive page | [java-api.md](java-api.md) - InteractiveCustomUIPage section |
| Display an item grid | [examples.md](examples.md) - Item Grid Inventory |
| Localize/translate UI text | [translations.md](translations.md) - Translation Keys section |
| Contribute website translations | [translations.md](translations.md) - HytaleModding Translations section |
| Fix "stuck on loading" | [troubleshooting.md](troubleshooting.md) |

---

## Official Documentation Sources

- [Common Styling](https://hytalemodding.dev/en/docs/official-documentation/custom-ui/common-styling)
- [Layout](https://hytalemodding.dev/en/docs/official-documentation/custom-ui/layout)
- [Markup](https://hytalemodding.dev/en/docs/official-documentation/custom-ui/markup)
- [Type Documentation](https://hytalemodding.dev/en/docs/official-documentation/custom-ui/type-documentation)
