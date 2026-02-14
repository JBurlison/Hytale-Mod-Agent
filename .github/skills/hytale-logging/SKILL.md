---
name: hytale-logging
description: Documents Hytale's HytaleLogger API for server-side logging in plugins. Use when adding log statements, configuring log levels, formatting log messages with printf-style arguments, or logging exceptions with stack traces. Triggers - log, logger, HytaleLogger, logging, atInfo, atWarning, atSevere, withCause, forEnclosingClass, log level, debug, server log.
---

# Hytale Logging Skill

Use this skill when adding logging to Hytale plugins. Hytale provides `HytaleLogger`, a Flogger-based logger (`com.google.common.flogger.AbstractLogger`) that writes to the server's log file at `{Hytale install}/UserData/Saves/{World}/logs`.

---

## Quick Reference

| Concept | Description |
|---------|-------------|
| **HytaleLogger** | Main logging API, extends `AbstractLogger` from Google Flogger |
| **Package** | `com.hypixel.hytale.logger.HytaleLogger` |
| **Log Levels** | `atInfo()`, `atWarning()`, `atSevere()` (default visible levels) |
| **Arguments** | `printf`-style format specifiers (`%s`, `%d`, `%f`, `%b`, `%c`) |
| **Exceptions** | `.withCause(exception)` to attach stack traces |
| **Backend** | `HytaleLoggerBackend` — manages log levels and sinks |

---

## Creating a Logger

Use `HytaleLogger.forEnclosingClass()` to create a logger scoped to the current class. Declare it as a `public static final` field so it can be reused across the plugin.

```java
import com.hypixel.hytale.logger.HytaleLogger;

public class ExamplePlugin extends JavaPlugin {
    public static final HytaleLogger LOGGER = HytaleLogger.forEnclosingClass();

    @Override
    protected void setup() {
        LOGGER.atInfo().log("ExamplePlugin loaded");
    }
}
```

### Named Logger

You can also create a logger with a custom name. The name appears before the log message in the log file for easier identification.

```java
HytaleLogger LOGGER = HytaleLogger.get("MyPluginName");
```

### Using the Logger from Other Classes

Reference the static logger from your main plugin class:

```java
ExamplePlugin.LOGGER.atInfo().log("hello world");
```

---

## Log Levels

Only `Info`, `Warning`, and `Severe` messages are printed with default configuration.

| Method | Purpose | When to Use |
|--------|---------|-------------|
| `atInfo()` | Informational messages | Normal behavior, startup, state changes |
| `atWarning()` | Potential problems | Situations that could lead to errors |
| `atSevere()` | Serious errors | Failures that prevent correct operation |

```java
LOGGER.atInfo().log("Provide high-level information about normal behavior.");
LOGGER.atWarning().log("Signal a potential problem or a situation that could lead to an error.");
LOGGER.atSevere().log("A serious error that will prevent things from working as expected.");
```

---

## Template Arguments (printf-style)

HytaleLogger uses `printf`-style format specifiers. Pass arguments after the format string — do NOT use string concatenation.

### Common Specifiers

| Specifier | Type | Example |
|-----------|------|---------|
| `%s` | String | `"Hello %s", name` → `Hello World` |
| `%d` | Integer | `"Count: %d", 42` → `Count: 42` |
| `%f` | Float/Double | `"Value: %f", 3.14` → `Value: 3.140000` |
| `%b` | Boolean | `"Active: %b", true` → `Active: true` |
| `%c` | Char | `"Letter: %c", 'A'` → `Letter: A` |

### Example

```java
final String name = "World";
LOGGER.atInfo().log("Hello %s", name);
// prints: Hello World

int count = 5;
LOGGER.atInfo().log("Found %d items for player %s", count, playerName);
```

### Why printf-style over concatenation?

- **Performance**: Arguments are only evaluated if the log level is active
- **Consistency**: Matches Flogger conventions
- **Safety**: Avoids null pointer issues with string concatenation

---

## Exceptions and Causes

Attach exceptions to log messages using `.withCause(exception)` to include the full stack trace.

```java
try {
    // risky operation
} catch (IOException e) {
    LOGGER.atSevere().withCause(e).log("Failed to load configuration file");
}
```

### Chaining with Arguments

```java
try {
    loadResource(path);
} catch (Exception e) {
    LOGGER.atSevere().withCause(e).log("Failed to load resource: %s", path);
}
```

---

## Best Practices

1. **Use `forEnclosingClass()`** — Automatically scopes the logger to the class; no manual name changes needed when refactoring.
2. **Prefer `atInfo()` for normal flow** — Reserve `atWarning()` and `atSevere()` for actual problems.
3. **Use printf-style arguments** — Never concatenate strings in log calls; arguments are lazily evaluated.
4. **Always attach exceptions** — Use `.withCause(e)` instead of logging `e.getMessage()` to preserve stack traces.
5. **Declare logger as `public static final`** — Allows reuse across the plugin and from other classes.
6. **Don't over-log** — Excessive `atInfo()` in tick loops will flood the log file and hurt performance.

---

## Complete Example

```java
import com.hypixel.hytale.logger.HytaleLogger;
import com.hypixel.hytale.server.pluginframework.JavaPlugin;

public class MyPlugin extends JavaPlugin {
    public static final HytaleLogger LOGGER = HytaleLogger.forEnclosingClass();

    @Override
    protected void setup() {
        LOGGER.atInfo().log("MyPlugin setup starting");

        try {
            initializeSystems();
            LOGGER.atInfo().log("MyPlugin setup complete — %d systems initialized", systemCount);
        } catch (Exception e) {
            LOGGER.atSevere().withCause(e).log("MyPlugin setup failed");
        }
    }

    @Override
    protected void start() {
        LOGGER.atInfo().log("MyPlugin started");
    }

    private void onPlayerAction(String playerName, String action) {
        LOGGER.atInfo().log("Player %s performed action: %s", playerName, action);
    }
}
```

---

## Internal Details (Reference Only)

| Class | Package | Role |
|-------|---------|------|
| `HytaleLogger` | `com.hypixel.hytale.logger` | Main logging API |
| `HytaleLoggerBackend` | `com.hypixel.hytale.logger.backend` | Backend, log levels, sinks |
| `HytaleFileHandler` | `com.hypixel.hytale.logger` | File-based log output |
| `HytaleLogManager` | `com.hypixel.hytale.logger` | Log manager integration |

- `HytaleLogger.init()` — Initializes the logging backend (called during server boot).
- `HytaleLogger.replaceStd()` — Redirects `System.out` / `System.err` into logger streams.
- Log files are written to `{Hytale install}/UserData/Saves/{World}/logs`.
