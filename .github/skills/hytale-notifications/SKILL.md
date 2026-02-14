---
name: hytale-notifications
description: Sends in-game notifications to players in Hytale plugins using NotificationUtil. Use when displaying item pickup-style notifications, toast messages, alert messages with icons, or any player notification with primary/secondary text. Triggers - notification, toast, alert, NotificationUtil, sendNotification, item pickup, player notification, message popup.
---

# Hytale Notifications Skill

Use this skill when sending in-game notifications to players in Hytale plugins. Notifications appear similar to item pickup messages and consist of a primary message, secondary message, and an optional icon.

---

## Quick Reference

| Concept | Description |
|---------|-------------|
| **NotificationUtil** | Utility class for sending notifications to players |
| **Primary Message** | Main `Message` displayed in the notification |
| **Secondary Message** | Additional `Message` displayed below the primary |
| **Icon** | An item icon shown on the left side of the notification |
| **PacketHandler** | Required to send notifications to a specific player |

---

## Notification Structure

A notification consists of three main components:

1. **Primary Message**: The main `Message` displayed prominently in the notification
2. **Secondary Message**: Additional `Message` displayed below the primary message
3. **Icon**: An item icon that visually represents the notification, shown on the left side

---

## Required Imports

```java
import com.hypixel.hytale.server.core.Message;
import com.hypixel.hytale.server.core.Universe;
import com.hypixel.hytale.server.item.ItemStack;
import com.hypixel.hytale.server.item.ItemWithAllMetadata;
import com.hypixel.hytale.server.player.PlayerRef;
import com.hypixel.hytale.server.util.NotificationUtil;
```

---

## Sending Notifications

Use the `NotificationUtil` class to send notifications to players. You need access to the `PacketHandler` of the player.

### Getting PacketHandler

The `PacketHandler` can be obtained from a `PlayerRef` using the `getPacketHandler()` method:

```java
// From an event
PlayerRef playerRef = Universe.get().getPlayer(player.getUuid());
var packetHandler = playerRef.getPacketHandler();
```

### NotificationUtil.sendNotification()

| Parameter | Type | Description |
|-----------|------|-------------|
| `packetHandler` | `PacketHandler` | The player's packet handler |
| `primaryMessage` | `Message` | Main notification text |
| `secondaryMessage` | `Message` | Secondary text below primary |
| `icon` | `ItemWithAllMetadata` | Item icon to display |

---

## Basic Example

```java
import com.hypixel.hytale.server.core.Message;
import com.hypixel.hytale.server.core.Universe;
import com.hypixel.hytale.server.event.player.PlayerReadyEvent;
import com.hypixel.hytale.server.item.ItemStack;
import com.hypixel.hytale.server.item.ItemWithAllMetadata;
import com.hypixel.hytale.server.util.NotificationUtil;

public class NotificationExample {
    
    public static void onPlayerReady(PlayerReadyEvent event) {
        var player = event.getPlayer();
        var playerRef = Universe.get().getPlayer(player.getUuid());
        var packetHandler = playerRef.getPacketHandler();
        
        // Create messages
        var primaryMessage = Message.raw("THIS WORKS!!!").color("#00FF00");
        var secondaryMessage = Message.raw("This is the secondary message").color("#228B22");
        
        // Create icon from item
        var icon = new ItemStack("Weapon_Sword_Mithril", 1).toPacket();
        
        // Send notification
        NotificationUtil.sendNotification(
            packetHandler,
            primaryMessage,
            secondaryMessage,
            (ItemWithAllMetadata) icon
        );
    }
}
```

---

## Common Use Cases

### Achievement/Quest Notification

```java
public void sendAchievementNotification(PlayerRef playerRef, String achievement) {
    var packetHandler = playerRef.getPacketHandler();
    
    var primary = Message.raw("Achievement Unlocked!").color("#FFD700");
    var secondary = Message.raw(achievement).color("#FFFFFF");
    var icon = new ItemStack("Item_Trophy_Gold", 1).toPacket();
    
    NotificationUtil.sendNotification(
        packetHandler,
        primary,
        secondary,
        (ItemWithAllMetadata) icon
    );
}
```

### Item Received Notification

```java
public void sendItemReceivedNotification(PlayerRef playerRef, String itemId, int quantity) {
    var packetHandler = playerRef.getPacketHandler();
    
    var primary = Message.raw("Item Received").color("#00FF00");
    var secondary = Message.raw("+" + quantity + " " + itemId).color("#AAAAAA");
    var icon = new ItemStack(itemId, quantity).toPacket();
    
    NotificationUtil.sendNotification(
        packetHandler,
        primary,
        secondary,
        (ItemWithAllMetadata) icon
    );
}
```

### Warning/Alert Notification

```java
public void sendWarningNotification(PlayerRef playerRef, String warning) {
    var packetHandler = playerRef.getPacketHandler();
    
    var primary = Message.raw("Warning!").color("#FF0000");
    var secondary = Message.raw(warning).color("#FFAAAA");
    var icon = new ItemStack("Item_Warning_Sign", 1).toPacket();
    
    NotificationUtil.sendNotification(
        packetHandler,
        primary,
        secondary,
        (ItemWithAllMetadata) icon
    );
}
```

### Level Up Notification

```java
public void sendLevelUpNotification(PlayerRef playerRef, int newLevel) {
    var packetHandler = playerRef.getPacketHandler();
    
    var primary = Message.raw("LEVEL UP!").color("#FFD700");
    var secondary = Message.raw("You are now level " + newLevel).color("#FFFFFF");
    var icon = new ItemStack("Item_Star", 1).toPacket();
    
    NotificationUtil.sendNotification(
        packetHandler,
        primary,
        secondary,
        (ItemWithAllMetadata) icon
    );
}
```

---

## Message Styling

Notifications use the standard `Message` API for styling:

| Method | Description |
|--------|-------------|
| `Message.raw(String)` | Create message from raw text |
| `.color(String)` | Apply hex color (e.g., `"#00FF00"`) |
| `.color(Color)` | Apply named color constant |
| `Message.join(Message...)` | Join multiple messages |

### Hex Color Examples

```java
// Green success
Message.raw("Success!").color("#00FF00");

// Gold achievement
Message.raw("Achievement").color("#FFD700");

// Red warning
Message.raw("Warning").color("#FF0000");

// Blue info
Message.raw("Info").color("#0088FF");
```

---

## Creating Icons

Icons are created from `ItemStack` objects converted to packet format:

```java
// Create from item ID and quantity
var icon = new ItemStack("Weapon_Sword_Mithril", 1).toPacket();

// Cast to ItemWithAllMetadata for sendNotification
NotificationUtil.sendNotification(
    packetHandler,
    primary,
    secondary,
    (ItemWithAllMetadata) icon
);
```

### Common Icon Items

| Item ID | Use Case |
|---------|----------|
| `Weapon_Sword_*` | Combat notifications |
| `Item_Trophy_*` | Achievement notifications |
| `Item_Coin_*` | Currency notifications |
| `Food_*` | Food/buff notifications |
| `Tool_*` | Tool-related notifications |

---

## Utility Wrapper Class

Consider creating a utility wrapper for consistent notification styling:

```java
public class Notifications {
    
    public static void success(PlayerRef player, String title, String message, String iconId) {
        send(player, title, "#00FF00", message, "#AAFFAA", iconId);
    }
    
    public static void warning(PlayerRef player, String title, String message, String iconId) {
        send(player, title, "#FFAA00", message, "#FFDDAA", iconId);
    }
    
    public static void error(PlayerRef player, String title, String message, String iconId) {
        send(player, title, "#FF0000", message, "#FFAAAA", iconId);
    }
    
    public static void info(PlayerRef player, String title, String message, String iconId) {
        send(player, title, "#0088FF", message, "#AADDFF", iconId);
    }
    
    private static void send(PlayerRef player, String title, String titleColor,
                             String message, String messageColor, String iconId) {
        var packetHandler = player.getPacketHandler();
        var primary = Message.raw(title).color(titleColor);
        var secondary = Message.raw(message).color(messageColor);
        var icon = new ItemStack(iconId, 1).toPacket();
        
        NotificationUtil.sendNotification(
            packetHandler,
            primary,
            secondary,
            (ItemWithAllMetadata) icon
        );
    }
}
```

---

## Best Practices

1. **Keep messages concise**: Notifications are meant for quick information
2. **Use appropriate colors**: Green for success, red for errors, gold for achievements
3. **Choose relevant icons**: Match the icon to the notification context
4. **Avoid spamming**: Don't send too many notifications in quick succession
5. **Localize text**: Use translation keys for user-facing notification text

---

## Related APIs

- [Chat Formatting](../hytale-chat-formatting/SKILL.md) - For styled chat messages
- [Message API](#message-styling) - Core message styling
- [PlayerRef](https://hytalemodding.dev/en/docs/server/entities) - Player reference access

---

## References

- [Official Documentation](https://hytalemodding.dev/en/docs/guides/plugin/send-notifications)
