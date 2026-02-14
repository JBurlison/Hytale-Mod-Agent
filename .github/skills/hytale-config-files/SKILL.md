---
name: hytale-config-files
description: Creates and manages plugin configuration files in Hytale using Config<T>, BuilderCodec, and KeyedCodec for persistent settings that survive server restarts. Use when creating config classes, loading/saving plugin settings, defining serializable config options, or accessing config from other classes. Triggers - config, configuration, Config, withConfig, config file, plugin settings, plugin config, config save, config load, configuration file, server settings.
---

# Hytale Plugin Configuration Files

Use this skill when creating and managing configuration files for Hytale plugins. Configuration files allow plugins to store persistent settings that survive server restarts.

> **Source:** <https://hytalemodding.dev/en/docs/guides/plugin/creating-configuration-file>

---

## Quick Reference

| Task | Approach |
|------|----------|
| Create config class | Class with `BuilderCodec<T>` defining serializable fields |
| Register config | `this.withConfig("Name", MyConfig.CODEC)` in plugin field initializer |
| Ensure file exists | `config.save()` in `setup()` |
| Read config values | `config.get().getFieldName()` |
| Modify config values | `config.get().setFieldName(value)` then `config.save()` |
| Access from other classes | Pass `Config<T>` or plugin reference with a getter |

---

## Key Concepts

### Config Class

A plain Java class that holds your configuration data. It must define a `BuilderCodec<T>` that tells Hytale how to serialize/deserialize each field. The class does NOT need to implement `Component<EntityStore>` — it is a standalone config object.

### Config<T> Wrapper

The `Config<T>` class (provided by Hytale) wraps your config class and manages file I/O. You obtain an instance via `JavaPlugin.withConfig()`.

### BuilderCodec Keys Must Be Capitalized

Keys in `KeyedCodec` must start with a **capital letter**. Lowercase keys will throw an error when loading the configuration file.

### Config File Location

Configuration files are stored in the `mods` folder of the server, persisting across restarts.

---

## Required Imports

```java
import com.hypixel.hytale.codec.Codec;         // Careful: use this Codec, not other Codec imports
import com.hypixel.hytale.codec.KeyedCodec;
import com.hypixel.hytale.codec.builder.BuilderCodec;
```

---

## Creating a Configuration Class

Define a class with fields, a `BuilderCodec`, a default constructor, getters, and setters.

```java
import com.hypixel.hytale.codec.Codec;
import com.hypixel.hytale.codec.KeyedCodec;
import com.hypixel.hytale.codec.builder.BuilderCodec;

public class MyConfig {

    // === Codec Definition ===
    public static final BuilderCodec<MyConfig> CODEC =
        BuilderCodec.builder(MyConfig.class, MyConfig::new)
            .append(new KeyedCodec<Integer>("SomeValue", Codec.INTEGER),
                    (config, value) -> config.someValue = value,   // setter
                    (config) -> config.someValue)                  // getter
            .add()
            .append(new KeyedCodec<String>("SomeString", Codec.STRING),
                    (config, value) -> config.someString = value,
                    (config) -> config.someString)
            .add()
            .build();

    // === Fields with defaults ===
    private int someValue = 12;
    private String someString = "My default string";

    // === Default Constructor ===
    public MyConfig() {
    }

    // === Getters ===
    public int getSomeValue() {
        return someValue;
    }

    public String getSomeString() {
        return someString;
    }

    // === Setters ===
    public void setSomeValue(int someValue) {
        this.someValue = someValue;
    }

    public void setSomeString(String someString) {
        this.someString = someString;
    }
}
```

### Key Rules

- **Codec keys must be capitalized** — `"SomeValue"` not `"someValue"`.
- Each field needs a getter lambda and a setter lambda in the codec chain.
- Default field values are used when the config file doesn't yet exist.
- The config class does **not** need `clone()` or `Component<EntityStore>` — that's only for ECS components.

---

## Loading, Saving, and Using the Configuration

### Registering the Config in Your Plugin

Register the config as a **field initializer** in your `JavaPlugin` class using `this.withConfig()`. The config must be loaded before `setup()` completes — loading it after will throw an error.

Call `config.save()` in `setup()` to ensure the file is created on first run.

```java
import com.hypixel.hytale.server.plugin.JavaPlugin;
import com.hypixel.hytale.server.plugin.JavaPluginInit;
import com.hypixel.hytale.server.plugin.config.Config;

import javax.annotation.Nonnull;

public class ExamplePlugin extends JavaPlugin {

    // Register config — MUST be in the field initializer, not in setup()
    private final Config<MyConfig> config = this.withConfig("MyConfig", MyConfig.CODEC);

    public ExamplePlugin(@Nonnull JavaPluginInit init) {
        super(init);
    }

    @Override
    protected void setup() {
        // Ensures the config file is created if it doesn't exist
        config.save();
    }

    // Getter for other classes to access
    public Config<MyConfig> getConfig() {
        return config;
    }
}
```

### Important Timing

| When | What |
|------|------|
| Field initialization | Call `this.withConfig(...)` to register the config |
| `setup()` | Call `config.save()` to write defaults if file missing |
| After `setup()` | **Too late** — loading config here throws an error |

---

### Accessing Config from Other Classes

Pass the plugin instance or the `Config<T>` directly to other classes.

```java
public class SomeOtherClass {

    private final ExamplePlugin plugin;

    public SomeOtherClass(ExamplePlugin plugin) {
        this.plugin = plugin;
    }

    public void someMethod() {
        // Read values
        MyConfig myConfig = plugin.getConfig().get();
        int value = myConfig.getSomeValue();
        String str = myConfig.getSomeString();

        // Modify values
        myConfig.setSomeValue(999);
        myConfig.setSomeString("A new string");

        // Persist changes to disk
        plugin.getConfig().save();
    }
}
```

---

## Common Codec Types for Config Fields

| Java Type | Codec | Example Key |
|-----------|-------|-------------|
| `int` | `Codec.INTEGER` | `"MaxPlayers"` |
| `long` | `Codec.LONG` | `"CooldownMs"` |
| `float` | `Codec.FLOAT` | `"SpeedMultiplier"` |
| `double` | `Codec.DOUBLE` | `"SpawnRadius"` |
| `boolean` | `Codec.BOOLEAN` | `"Enabled"` |
| `String` | `Codec.STRING` | `"WelcomeMessage"` |

For complex types (maps, lists, sets), see the `hytale-persistent-data` skill which documents `MapCodec`, `ListCodec`, and `SetCodec`.

---

## Config vs Persistent Data

| | Config (`Config<T>`) | Persistent Data (`Component<EntityStore>`) |
|---|---|---|
| **Purpose** | Plugin-wide settings | Per-entity/per-player data |
| **Storage** | File in `mods/` folder | BSON on entity store |
| **Registration** | `this.withConfig(...)` | `getEntityStoreRegistry().registerComponent(...)` |
| **Requires** | `BuilderCodec<T>` only | `BuilderCodec<T>`, `Component<EntityStore>`, `clone()` |
| **Access** | `config.get()` | `store.getComponent(ref, type)` |
| **When to use** | Server settings, feature toggles, thresholds | Player progress, entity state, session data |

---

## Complete Example

A full plugin with a configuration file for a welcome message and max player setting:

```java
// === WelcomeConfig.java ===
import com.hypixel.hytale.codec.Codec;
import com.hypixel.hytale.codec.KeyedCodec;
import com.hypixel.hytale.codec.builder.BuilderCodec;

public class WelcomeConfig {

    public static final BuilderCodec<WelcomeConfig> CODEC =
        BuilderCodec.builder(WelcomeConfig.class, WelcomeConfig::new)
            .append(new KeyedCodec<String>("WelcomeMessage", Codec.STRING),
                    (c, v) -> c.welcomeMessage = v,
                    c -> c.welcomeMessage)
            .add()
            .append(new KeyedCodec<Boolean>("EnableWelcome", Codec.BOOLEAN),
                    (c, v) -> c.enableWelcome = v,
                    c -> c.enableWelcome)
            .add()
            .append(new KeyedCodec<Integer>("MaxWarnings", Codec.INTEGER),
                    (c, v) -> c.maxWarnings = v,
                    c -> c.maxWarnings)
            .add()
            .build();

    private String welcomeMessage = "Welcome to the server!";
    private boolean enableWelcome = true;
    private int maxWarnings = 3;

    public WelcomeConfig() {}

    public String getWelcomeMessage() { return welcomeMessage; }
    public void setWelcomeMessage(String msg) { this.welcomeMessage = msg; }

    public boolean isEnableWelcome() { return enableWelcome; }
    public void setEnableWelcome(boolean enable) { this.enableWelcome = enable; }

    public int getMaxWarnings() { return maxWarnings; }
    public void setMaxWarnings(int max) { this.maxWarnings = max; }
}
```

```java
// === WelcomePlugin.java ===
import com.hypixel.hytale.server.plugin.JavaPlugin;
import com.hypixel.hytale.server.plugin.JavaPluginInit;
import com.hypixel.hytale.server.plugin.config.Config;

import javax.annotation.Nonnull;

public class WelcomePlugin extends JavaPlugin {

    private final Config<WelcomeConfig> config = this.withConfig("WelcomeConfig", WelcomeConfig.CODEC);

    public WelcomePlugin(@Nonnull JavaPluginInit init) {
        super(init);
    }

    @Override
    protected void setup() {
        config.save(); // Create file with defaults if it doesn't exist
    }

    public Config<WelcomeConfig> getWelcomeConfig() {
        return config;
    }
}
```

---

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Error when loading config | Codec key not capitalized | Change `"someValue"` → `"SomeValue"` |
| Error: config loaded too late | `withConfig()` called in `setup()` or later | Move to field initializer |
| Config file not created | `config.save()` not called in `setup()` | Add `config.save()` to `setup()` |
| Changes not persisted | Forgot to call `save()` after modification | Call `config.save()` after changing values |
| Wrong `Codec` import | Using a different library's `Codec` class | Use `com.hypixel.hytale.codec.Codec` |
```
