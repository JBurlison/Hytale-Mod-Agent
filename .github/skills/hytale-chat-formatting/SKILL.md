---
name: hytale-chat-formatting
description: Formats chat messages in Hytale plugins using PlayerChatEvent and TinyMessage rich text. Use when creating chat formatters, applying colors/gradients, adding clickable links, styling messages, or handling chat events. Triggers - chat, message, PlayerChatEvent, TinyMsg, gradient, chat color, rich text, sendMessage, Formatter.
---

# Hytale Chat Formatting Skill

Use this skill when working on chat message formatting in Hytale plugins. This covers the `PlayerChatEvent`, manual `Message` formatting, and the TinyMessage rich text library.

---

## Quick Reference

| Concept | Description |
|---------|-------------|
| **PlayerChatEvent** | Event triggered when a player sends a chat message |
| **Formatter** | Interface to customize how chat messages are displayed |
| **Message** | Hytale's message object for styled text |
| **TinyMsg** | Third-party library for rich text parsing (gradients, colors, links) |

---

## PlayerChatEvent

The `PlayerChatEvent` is triggered when a player sends a chat message. You can:
- Cancel the event to block the message
- Modify the content
- Set a custom formatter
- Access the sender and target list

### Event Properties

| Method | Description |
|--------|-------------|
| `getSender()` | Returns the `PlayerRef` who sent the message |
| `getContent()` | Returns the message content as a String |
| `setContent(String)` | Modify the message content |
| `setCancelled(boolean)` | Cancel the event to block the message |
| `setFormatter(Formatter)` | Set a custom formatter for the message |
| `getTargets()` | List of players who will see the message |

---

## Manual Formatting (Standard Approach)

Use `Message` API directly for basic formatting without external dependencies.

### Basic Example

```java
import com.hypixel.hytale.server.core.Message;
import com.hypixel.hytale.server.core.Color;
import com.hypixel.hytale.server.event.player.PlayerChatEvent;
import com.hypixel.hytale.server.player.PlayerRef;

public class ChatFormatter {
    public static void onPlayerChat(PlayerChatEvent event) {
        PlayerRef sender = event.getSender();
        
        // Block specific words
        if (event.getContent().equalsIgnoreCase("poo")) {
            event.setCancelled(true);
            sender.sendMessage(Message.raw("Hey, you cannot say that!").color(Color.RED));
            return;
        }
        
        // Modify message content
        if (event.getContent().equalsIgnoreCase("you stink")) {
            event.setContent("i stink");
        }
        
        // Set custom formatter
        event.setFormatter((playerRef, message) ->
            Message.join(
                Message.raw("[COOL] ").color(Color.RED),
                Message.raw(sender.getUsername()).color(Color.YELLOW),
                Message.raw(" : " + message).color(Color.PINK)
            ));
    }
}
```

### Formatter Interface

```java
public interface Formatter {
    @Nonnull
    Message format(@Nonnull PlayerRef playerRef, @Nonnull String message);
}
```

### Message API Methods

| Method | Description |
|--------|-------------|
| `Message.raw(String)` | Create a message from raw text |
| `Message.join(Message...)` | Join multiple messages together |
| `.color(Color)` | Apply a color to the message |

### Available Colors

Standard `Color` class provides: `RED`, `YELLOW`, `PINK`, `BLUE`, `GREEN`, `WHITE`, `BLACK`, `GOLD`, `GRAY`, `AQUA`, etc.

---

## TinyMessage - Rich Text Library

TinyMessage is a lightweight rich text parser for Hytale servers, similar to Minecraft's MiniMessage. It provides an easier way to create styled messages with gradients, hex colors, and clickable links.

### Features

- **Gradients**: Multi-color text gradients
- **Hex Colors**: Custom colors using hex codes
- **Standard Styles**: Bold, italic, underline, monospace
- **Clickable Links**: URL links in chat
- **Nested Styling**: Combine multiple styles

---

## TinyMessage Tags Reference

### Color Tags

| Tag | Aliases | Example | Description |
|-----|---------|---------|-------------|
| `<color:X>` | `<c:X>`, `<colour:X>` | `<color:red>text</color>` | Named or hex color |
| `<gradient:X:Y:Z>` | `<grnt:X:Y:Z>` | `<gradient:red:blue>text</gradient>` | Color gradient |

### Style Tags

| Tag | Aliases | Example | Description |
|-----|---------|---------|-------------|
| `<bold>` | `<b>` | `<b>text</b>` | Bold text |
| `<italic>` | `<i>`, `<em>` | `<i>text</i>` | Italic text |
| `<underline>` | `<u>` | `<u>text</u>` | Underlined text |
| `<monospace>` | `<mono>` | `<mono>text</mono>` | Monospace font |
| `<reset>` | `<r>` | `<b>bold<reset>normal` | Reset all formatting |

### Link Tags

| Tag | Aliases | Example | Description |
|-----|---------|---------|-------------|
| `<link:URL>` | `<url:link>` | `<link:https://example.com>click</link>` | Clickable link |

### Named Colors

`black`, `dark_blue`, `dark_green`, `dark_aqua`, `dark_red`, `dark_purple`, `gold`, `gray`, `dark_gray`, `blue`, `green`, `aqua`, `red`, `light_purple`, `yellow`, `white`

---

## TinyMessage Usage Examples

### Basic Usage

```java
import fi.sulku.hytale.TinyMsg;
import com.hypixel.hytale.server.core.Message;

// Parse a formatted string into a Message
Message message = TinyMsg.parse("<gradient:red:blue>Hello World!</gradient>");
player.sendMessage(message);

// Multiple styles
TinyMsg.parse("<b><color:gold>Bold Gold Text</color></b>");

// Clickable gradient link
TinyMsg.parse("<link:https://example.com><gradient:aqua:blue>Click me!</gradient></link>");

// Complex nested styling
TinyMsg.parse("<b>Bold <i>and italic <color:red>and red</color></i></b>");

// Reset styles mid-text
TinyMsg.parse("<b>Bold <reset>normal text");
```

### Chat Event with TinyMessage

```java
public class ChatFormatter {
    private void onPlayerChat(PlayerChatEvent event) {
        PlayerRef sender = event.getSender();
        
        if (event.getContent().equalsIgnoreCase("poo")) {
            event.setCancelled(true);
            sender.sendMessage(TinyMsg.parse("<red>Hey, you cannot say that!</red>"));
            return;
        }
        
        if (event.getContent().equalsIgnoreCase("you stink")) {
            event.setContent("i stink");
        }
        
        // Custom chat format with TinyMessage
        event.setFormatter((playerRef, message) ->
            TinyMsg.parse("<red>[COOL] </red><yellow>" + sender.getUsername() 
                + "</yellow><pink> : " + message + "</pink>"));
    }
}
```

### Gradient Examples

```java
// Two-color gradient
TinyMsg.parse("<gradient:red:blue>Rainbow text!</gradient>");

// Multi-color gradient
TinyMsg.parse("<gradient:gold:red:black>Fire gradient!</gradient>");

// Gradient with hex colors
TinyMsg.parse("<gradient:#FF0000:#00FF00>Custom gradient</gradient>");
```

### Hex Color Examples

```java
// Hex color
TinyMsg.parse("<color:#FF55FF>Custom purple</color>");

// Named color
TinyMsg.parse("<color:gold>Gold text</color>");

// Short form
TinyMsg.parse("<c:#AABBCC>Short syntax</c>");
```

---

## TinyMessage Installation

### For Server Owners

Download `TinyMessage.jar` from releases and place in server's `mods` folder.

### For Developers

#### manifest.json

Add the dependency to your manifest:

```json
"Dependencies": {
  "Zoltus:TinyMessage": "*"
}
```

#### Maven (pom.xml)

```xml
<repositories>
    <repository>
        <id>jitpack.io</id>
        <url>https://jitpack.io</url>
    </repository>
</repositories>

<dependency>
    <groupId>com.github.Zoltus</groupId>
    <artifactId>TinyMessage</artifactId>
    <version>2.0.1</version>
    <scope>provided</scope>
</dependency>
```

#### Gradle (build.gradle)

```groovy
repositories {
    maven { url = uri("https://jitpack.io") }
}

dependencies {
    compileOnly("com.github.Zoltus:TinyMessage:2.0.1")
}
```

---

## API Reference

### TinyMsg.parse(String text)

Parses a string with TinyMsg tags and returns a `Message` object.

**Parameters:**
- `text` - The string containing TinyMessage tags

**Returns:**
- `Message` - A Hytale `Message` object ready to be sent to players

---

## Common Patterns

### Rank Prefix Chat Format

```java
event.setFormatter((playerRef, message) ->
    TinyMsg.parse("<gradient:gold:yellow>[ADMIN]</gradient> <white>" 
        + playerRef.getUsername() + "</white><gray>: " + message + "</gray>"));
```

### Colored Server Announcements

```java
public void announce(String text) {
    Message announcement = TinyMsg.parse(
        "<b><gradient:red:gold>[SERVER]</gradient></b> <white>" + text + "</white>");
    // Send to all players
}
```

### Private Message Format

```java
public void sendPrivateMessage(PlayerRef from, PlayerRef to, String message) {
    Message formatted = TinyMsg.parse(
        "<gray>[</gray><light_purple>PM</light_purple><gray>]</gray> "
        + "<i><color:#AAAAAA>" + from.getUsername() + " → " + to.getUsername() 
        + ": " + message + "</color></i>");
    to.sendMessage(formatted);
}
```

---

## Choosing an Approach

| Use Case | Recommended Approach |
|----------|---------------------|
| Simple color formatting | Manual `Message` API |
| Complex gradients/styling | TinyMessage |
| No external dependencies | Manual `Message` API |
| Rapid development | TinyMessage |
| Clickable links in chat | TinyMessage |

---

## Resources

- [HytaleModding Chat Formatting Guide](https://hytalemodding.dev/en/docs/guides/plugin/chat-formatting)
- [TinyMessage GitHub Repository](https://github.com/Zoltus/TinyMessage/)
- [TinyMessage Releases](https://github.com/Zoltus/TinyMessage/releases)

---

## License

TinyMessage is available under the MIT License.
