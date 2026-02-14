```markdown
# Custom UI Overview

Custom UI is Hytale's framework for creating **custom user interfaces** controlled by the game server. Unlike the built-in Client UI (which is part of the game client and cannot be modified), Server UI allows you to create interactive screens and HUD overlays through Java plugins and asset packs.

## What You Can Do

- **Create custom interactive pages** - Shop interfaces, quest dialogs, server settings menus, admin panels
- **Add custom HUD overlays** - Quest trackers, status displays, custom health bars, server information
- **Design with markup** - Use `.ui` files to define reusable UI templates
- **Handle user interactions** - Respond to button clicks, form submissions, and other events
- **Localize your UI** - Support multiple languages using the game's translation system

---

## How Custom UI Fits Into Hytale's UI

Hytale's user interface is divided into two categories:

### Client UI (Not Moddable)

Built-in interfaces controlled by the C# game client:

- Main menu and settings
- Character creation
- Built-in HUD (health, hotbar, chat)
- Inventory and crafting screens
- Development tools

**You cannot modify these** - they are part of the core game client.

### In-Game UI (Moddable via Server)

Server-controlled interfaces that you can create and customize:

#### Custom Pages

Full-screen interactive overlays that appear during gameplay:

- Can be dismissed by the player (ESC key)
- Capture all input (keyboard and mouse)
- Support loading states while waiting for server responses
- Perfect for: shops, dialogs, menus, configuration screens

#### Custom HUDs

Persistent overlay elements drawn on top of the game world:

- Display-only (no user interaction)
- Always visible during gameplay
- Lightweight and non-intrusive
- Perfect for: quest objectives, status indicators, server info panels

---

## Architecture Overview

Server UI uses a **command-based architecture**:

```
┌─────────────────────┐          ┌──────────────────────┐
│   Java Server       │          │    C# Client         │
│   (Your Plugin)     │          │    (Game)            │
├─────────────────────┤          ├──────────────────────┤
│                     │          │                      │
│ InteractiveCustomUI │          │   CustomPage or      │
│ Page                │          │   CustomHud          │
│   ↓ build()         ├────────→ │     ↓ Apply          │
│ UICommandBuilder    │          │   Element Tree       │
│   - append()        │          │     ↓ Layout         │
│   - set()           │          │   Rendered UI        │
│   - clear()         │          │                      │
│                     │          │                      │
│   handleDataEvent() │←─────────│   User Interaction   │
│   Process input     │ Events   │   (click, type, etc) │
│   sendUpdate()      │          │                      │
└─────────────────────┘          └──────────────────────┘
```

**The flow:**

1. Your Java code builds UI using `UICommandBuilder`
2. Commands are sent to the client as data
3. Client parses `.ui` markup files and creates visual elements
4. User interacts with the UI
5. Events are sent back to your Java code
6. You process events and send updates back

---

## Key Principles

### Declarative, Not Imperative

You don't create UI objects directly. Instead, you send **commands** that describe what you want:

- "Append this button template to that container"
- "Set this label's text to 'Hello World'"
- "Clear all children from this list"

### Asset-Driven

UI structure is defined in `.ui` markup files (assets), not hardcoded in Java. This enables:

- Designers to modify layouts without touching code
- Reusable UI components
- Consistent visual language

### Event-Driven

User interactions trigger events that flow back to your server code. You register event bindings and handle them in `handleDataEvent()`.

### Selector-Based

You target specific UI elements using **selectors:**

| Selector | Meaning |
|----------|---------|
| `#MyButton` | Element with ID "MyButton" |
| `#List[0]` | First child of element "List" |
| `#List[0] #Title` | Element "Title" in the first child of "List" |
| `#Label.TextColor` | The TextColor property of element "Label" |

---

Source: https://hytalemodding.dev/en/docs/official-documentation/custom-ui

```
