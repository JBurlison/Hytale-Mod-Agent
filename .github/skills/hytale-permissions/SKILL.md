---
name: hytale-permissions
description: Manages permission nodes and groups in Hytale plugins using PermissionsModule. Use when checking player permissions, creating permission groups, adding/removing user permissions, implementing custom permission providers, or listening to permission events. Triggers - permission, PermissionsModule, hasPermission, group, PermissionProvider, wildcard, PermissionHolder, addUserPermission, addGroupPermission, PlayerPermissionChangeEvent, PlayerGroupEvent.
---

# Hytale Permission Management

Use this skill when managing permission nodes and groups in Hytale plugins. Permissions control what actions players can perform on the server, from basic commands to advanced administrative functions.

---

## Quick Reference

| Operation | Method |
|-----------|--------|
| Check permission | `PermissionsModule.get().hasPermission(uuid, node)` |
| Check with default | `PermissionsModule.get().hasPermission(uuid, node, defaultValue)` |
| Add user permission | `PermissionsModule.get().addUserPermission(uuid, Set.of(...))` |
| Remove user permission | `PermissionsModule.get().removeUserPermission(uuid, Set.of(...))` |
| Add group permission | `PermissionsModule.get().addGroupPermission(groupName, Set.of(...))` |
| Remove group permission | `PermissionsModule.get().removeGroupPermission(groupName, Set.of(...))` |
| Add user to group | `PermissionsModule.get().addUserToGroup(uuid, groupName)` |
| Remove user from group | `PermissionsModule.get().removeUserFromGroup(uuid, groupName)` |
| Get user's groups | `PermissionsModule.get().getGroupsForUser(uuid)` |

---

## Key Concepts

| Concept | Description |
|---------|-------------|
| Permission Node | A string like `myplugin.feature.use` representing a specific permission |
| Group | A named collection of permissions (e.g., "Admin", "VIP", "Default") |
| Provider | The backend that stores and retrieves permissions |
| Wildcard | A pattern like `*` or `myplugin.*` that matches multiple permissions |

### Permission Check Order

1. **User's direct permissions** — Permissions granted directly to the player
2. **Group permissions** — Permissions from groups the player belongs to
3. **Virtual groups** — Game-mode-based permissions (e.g., Creative mode grants builder tools)
4. **Default value** — Falls back to `false` if no match found

> The first definitive match wins. If a player has a permission granted at the user level, group permissions won't override it.

---

## Accessing PermissionsModule

```java
PermissionsModule perms = PermissionsModule.get();
```

### Limitations

The module does **not** support:
- Listing all defined groups
- Deleting a group entirely

Groups are implicitly created when you first add permissions to them.

---

## Checking Permissions

### Basic Check

```java
boolean canUse = PermissionsModule.get().hasPermission(playerUUID, "myplugin.feature.use");
if (canUse) {
    // Player has permission
} else {
    // Player lacks permission
}
```

### Check with Default Value

Returns the default when no explicit permission is set — useful for features enabled by default that can be revoked:

```java
boolean canUse = PermissionsModule.get().hasPermission(playerUUID, "myplugin.feature.use", true);
```

### Using PermissionHolder Interface

Players and command senders implement `PermissionHolder`, allowing direct checks:

```java
// In a command or event handler where you have access to the player
if (player.hasPermission("myplugin.admin.manage")) {
    // Player has admin permission
}
```

---

## Managing User Permissions

### Adding Permissions

Permissions are additive — new permissions are added on top of existing ones, not replaced.

```java
PermissionsModule perms = PermissionsModule.get();

// Add a single permission
perms.addUserPermission(playerUUID, Set.of("myplugin.vip.chat"));

// Add multiple permissions at once
Set<String> newPerms = Set.of(
    "myplugin.vip.chat",
    "myplugin.vip.fly",
    "myplugin.vip.kit"
);
perms.addUserPermission(playerUUID, newPerms);
```

### Removing Permissions

```java
PermissionsModule perms = PermissionsModule.get();

Set<String> toRemove = Set.of("myplugin.vip.fly");
perms.removeUserPermission(playerUUID, toRemove);
```

---

## Managing Groups

Groups let you assign a collection of permissions to multiple players.

### Adding Permissions to a Group

If the group doesn't exist, it will be created automatically.

```java
PermissionsModule perms = PermissionsModule.get();

Set<String> vipPerms = Set.of(
    "myplugin.vip.chat",
    "myplugin.vip.fly",
    "myplugin.vip.kit"
);
perms.addGroupPermission("VIP", vipPerms);
```

### Removing Permissions from a Group

```java
PermissionsModule perms = PermissionsModule.get();

Set<String> toRemove = Set.of("myplugin.vip.fly");
perms.removeGroupPermission("VIP", toRemove);
```

### Adding a User to a Group

```java
PermissionsModule perms = PermissionsModule.get();
perms.addUserToGroup(playerUUID, "VIP");
```

### Removing a User from a Group

```java
PermissionsModule perms = PermissionsModule.get();
perms.removeUserFromGroup(playerUUID, "VIP");
```

### Getting a User's Groups

```java
PermissionsModule perms = PermissionsModule.get();
Set<String> groups = perms.getGroupsForUser(playerUUID);
for (String group : groups) {
    System.out.println("Player is in group: " + group);
}
```

---

## Built-in Groups

| Group | Permissions | Description |
|-------|-------------|-------------|
| OP | `*` (all permissions) | Server operators with full access |
| Default | None | Base group for all players |

Players without any explicit group assignment are automatically part of the `Default` group.

---

## Wildcards

Wildcards grant or deny multiple permissions with a single pattern.

| Pattern | Effect |
|---------|--------|
| `*` | Grants all permissions |
| `myplugin.*` | Grants all permissions starting with `myplugin.` |
| `-*` | Denies all permissions |
| `-myplugin.admin.*` | Denies all admin permissions in the plugin |

### Wildcard Examples

```java
// Grant all permissions to admins
perms.addGroupPermission("Admin", Set.of("*"));

// Grant all plugin permissions to moderators
perms.addGroupPermission("Moderator", Set.of("myplugin.*"));

// Grant all permissions except admin commands
perms.addGroupPermission("Helper", Set.of(
    "*",
    "-myplugin.admin.*"  // Deny admin permissions
));
```

> **Warning:** Negation permissions (starting with `-`) take precedence at each level. Use them carefully to avoid accidentally blocking permissions.

---

## Built-in Permission Nodes

### HytalePermissions Utility

```java
// Generate permission for a command
String perm = HytalePermissions.fromCommand("gamemode");
// Result: "hytale.command.gamemode"

// Generate permission for a subcommand
String perm = HytalePermissions.fromCommand("gamemode", "creative");
// Result: "hytale.command.gamemode.creative"
```

### Common Permission Nodes

| Node | Description |
|------|-------------|
| `hytale.command.op.add` | Add players to OP group |
| `hytale.command.op.remove` | Remove players from OP group |
| `hytale.editor.brush.use` | Use brush tools |
| `hytale.editor.prefab.use` | Use prefabs |
| `hytale.editor.selection.use` | Use selection tools |
| `hytale.editor.history` | Undo/redo operations |
| `hytale.camera.flycam` | Use fly camera mode |

---

## Listening to Permission Events

### Available Events

| Event | Trigger |
|-------|---------|
| `PlayerPermissionChangeEvent.PermissionsAdded` | Permissions added to a user |
| `PlayerPermissionChangeEvent.PermissionsRemoved` | Permissions removed from a user |
| `PlayerGroupEvent.Added` | User added to a group |
| `PlayerGroupEvent.Removed` | User removed from a group |
| `GroupPermissionChangeEvent.Added` | Permissions added to a group |
| `GroupPermissionChangeEvent.Removed` | Permissions removed from a group |

### Event Listener Example

```java
public class PermissionListener {
    public static void onPermissionsAdded(PlayerPermissionChangeEvent.PermissionsAdded event) {
        UUID playerUUID = event.getPlayerUuid();
        Set<String> added = event.getAddedPermissions();
        System.out.println("Permissions added to " + playerUUID + ": " + added);
    }

    public static void onGroupAdded(PlayerGroupEvent.Added event) {
        UUID playerUUID = event.getPlayerUuid();
        String groupName = event.getGroupName();
        System.out.println("Player " + playerUUID + " joined group: " + groupName);
    }
}
```

### Registering Events

```java
public class MyPlugin extends JavaPlugin {
    @Override
    public void setup() {
        EventRegistry events = this.getEventRegistry();
        events.registerGlobal(
            PlayerPermissionChangeEvent.PermissionsAdded.class,
            PermissionListener::onPermissionsAdded
        );
        events.registerGlobal(
            PlayerGroupEvent.Added.class,
            PermissionListener::onGroupAdded
        );
    }
}
```

---

## Creating a Custom Permission Provider

Useful for database-backed permissions, cross-server synchronization, or features like permission expiry.

### Implementing PermissionProvider

```java
public class DatabasePermissionProvider implements PermissionProvider {
    @Nonnull
    @Override
    public String getName() {
        return "DatabasePermissionProvider";
    }

    // User permission methods
    @Override
    public void addUserPermissions(@Nonnull UUID uuid, @Nonnull Set<String> permissions) {
        // Save to your database
    }

    @Override
    public void removeUserPermissions(@Nonnull UUID uuid, @Nonnull Set<String> permissions) {
        // Remove from your database
    }

    @Override
    public Set<String> getUserPermissions(@Nonnull UUID uuid) {
        // Query your database
        return Set.of();
    }

    // Group permission methods
    @Override
    public void addGroupPermissions(@Nonnull String group, @Nonnull Set<String> permissions) {
        // Save to your database
    }

    @Override
    public void removeGroupPermissions(@Nonnull String group, @Nonnull Set<String> permissions) {
        // Remove from your database
    }

    @Override
    public Set<String> getGroupPermissions(@Nonnull String group) {
        // Query your database
        return Set.of();
    }

    // User-group membership methods
    @Override
    public void addUserToGroup(@Nonnull UUID uuid, @Nonnull String group) {
        // Save to your database
    }

    @Override
    public void removeUserFromGroup(@Nonnull UUID uuid, @Nonnull String group) {
        // Remove from your database
    }

    @Override
    public Set<String> getGroupsForUser(@Nonnull UUID uuid) {
        // Query your database
        return Set.of("Default");
    }
}
```

> **Warning:** Hytale automatically assigns players to game-mode groups (like `Creative` or `Adventure`) using the first provider. If your provider throws an error when the group doesn't exist, the player will be disconnected! Always handle missing groups gracefully.

### Registering Your Provider

```java
public class MyPlugin extends JavaPlugin {
    @Override
    public void setup() {
        // Add your provider alongside the default one
        PermissionsModule.get().addProvider(new DatabasePermissionProvider());
    }
}
```

The `PermissionsModule` aggregates permissions from all registered providers:
- Permission checks query **all** providers
- Write operations (add/remove) use the **first** provider

### Replacing the Default Provider

If you want full control, remove the default provider first:

```java
public class MyPlugin extends JavaPlugin {
    @Override
    public void setup() {
        PermissionsModule perms = PermissionsModule.get();

        // Remove the default provider FIRST
        perms.removeProvider(perms.getFirstPermissionProvider());

        // Then add your provider
        perms.addProvider(new DatabasePermissionProvider());
    }
}
```

> **Note:** When you remove the default provider, the `/op self` command will stop working since it checks for provider tampering.

---

## Best Practices

### Permission Naming Conventions

Follow the pattern: `namespace.category.action`

```java
// Good - clear hierarchy
"myplugin.admin.ban"
"myplugin.user.teleport.home"
"myplugin.vip.chat.color"

// Bad - unclear structure
"myplugin_ban"
"teleport"
"vipChatColor"
```

### Use Constants for Permissions

Define permissions as constants to avoid typos:

```java
public final class MyPermissions {
    public static final String ADMIN_BAN = "myplugin.admin.ban";
    public static final String ADMIN_KICK = "myplugin.admin.kick";
    public static final String USER_HOME = "myplugin.user.home";
    public static final String VIP_FLY = "myplugin.vip.fly";
}

// Usage
if (player.hasPermission(MyPermissions.ADMIN_BAN)) {
    // ...
}
```

### Don't Over-Permission

Only create permissions for actions that genuinely need access control. Not everything needs a permission check.

### Thread Safety

If you create a custom provider, ensure it's thread-safe. Permission checks can occur from multiple threads simultaneously. Use `ReadWriteLock` or `ConcurrentHashMap` for your data structures.

---

## In-Game Commands

### /op Command

| Command | Description |
|---------|-------------|
| `/op self` | Toggle your own OP status (singleplayer or with `--allow-op` flag) |
| `/op add <player>` | Add a player to the OP group |
| `/op remove <player>` | Remove a player from the OP group |

### /perm Command

| Command | Description |
|---------|-------------|
| `/perm user list <uuid>` | List user's permissions |
| `/perm user add <uuid> <perm>` | Add permission to user |
| `/perm user remove <uuid> <perm>` | Remove permission from user |
| `/perm user group list <uuid>` | List user's groups |
| `/perm user group add <uuid> <group>` | Add user to group |
| `/perm user group remove <uuid> <group>` | Remove user from group |
| `/perm group list <group>` | List group's permissions |
| `/perm group add <group> <perm>` | Add permission to group |
| `/perm group remove <group> <perm>` | Remove permission from group |
| `/perm test <perm>` | Test if you have a permission |

---

## Related Classes

- `com.hypixel.hytale.server.core.permissions.PermissionsModule`
- `com.hypixel.hytale.server.core.permissions.PermissionProvider`
- `com.hypixel.hytale.server.core.permissions.PermissionHolder`
- `com.hypixel.hytale.server.core.permissions.HytalePermissions`
- `com.hypixel.hytale.server.core.permissions.PlayerPermissionChangeEvent`
- `com.hypixel.hytale.server.core.permissions.PlayerGroupEvent`
- `com.hypixel.hytale.server.core.permissions.GroupPermissionChangeEvent`
