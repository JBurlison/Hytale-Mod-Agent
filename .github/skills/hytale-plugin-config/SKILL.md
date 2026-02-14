---
name: hytale-plugin-config
description: Creates and manages plugin configuration files in Hytale using Config<T>, BuilderCodec, and withConfig(). Use when adding plugin settings, creating config classes, loading/saving config files, or accessing config data from other classes. Triggers - config, configuration, plugin config, Config, withConfig, plugin settings, config file, save config, load config, configuration class, plugin options.
---

# Hytale Plugin Configuration Files

This skill documents how to create, load, save, and use configuration files in Hytale plugins using the `Config<T>` API.

> **Related skills:** For Codec/BuilderCodec serialization details, see `hytale-persistent-data`. For ECS component registration, see `hytale-ecs`.

## Quick Reference

| Task | Approach |
|------|----------|
| Define config class | Plain class with `BuilderCodec<T>` and default constructor |
| Register config | `this.withConfig("Name", MyConfig.CODEC)` in plugin field initializer |
| Save config to file | `config.save()` in `setup()` (creates file if missing) |
| Read config value | `config.get().getSomeValue()` |
| Modify config value | `config.get().setSomeValue(newVal)` then `config.save()` |
| Config file location | Server `mods/` folder |

---

## Configuration Class

A configuration class is a plain Java class (NOT an ECS component) with a `BuilderCodec<T>` that defines how each field serializes/deserializes.

### Critical Rules

1. **Codec keys MUST be capitalized** — lowercase keys throw an error at load time.
2. **Must have a default (no-arg) constructor** — the codec uses it as a factory.
3. **Does NOT implement `Component`** — config classes are not ECS components.

### Template

```java
import com.hypixel.hytale.codec.Codec;
import com.hypixel.hytale.codec.KeyedCodec;
import com.hypixel.hytale.codec.builder.BuilderCodec;

public class MyConfig {

    // === Codec Definition ===
    // Keys MUST be capitalized (e.g. "SomeValue", not "someValue")
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

    // === Default Constructor (required) ===
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

---

## Registering and Loading the Config

### Rules

- `withConfig(...)` **MUST** be called as a field initializer (or in the constructor) — calling it after `setup()` throws an error.
- Call `config.save()` in `setup()` to create the config file on disk if it doesn't already exist.

### Plugin Setup Template

```java
import com.hypixel.hytale.server.plugin.Config;
import com.hypixel.hytale.server.plugin.JavaPlugin;

public class ExamplePlugin extends JavaPlugin {

    // Register config — MUST be a field initializer (before setup())
    private final Config<MyConfig> config = this.withConfig("MyConfig", MyConfig.CODEC);

    @Override
    public void setup() {
        // Ensures the config file is created if it doesn't exist
        config.save();
    }
}
```

The first argument to `withConfig()` is the config file name (without extension). The file is created in the server's `mods/` folder.

---

## Accessing Config Values

### From the Plugin Class

```java
public void someMethod() {
    MyConfig myConfig = config.get();
    int value = myConfig.getSomeValue();
    String str = myConfig.getSomeString();
}
```

### From Other Classes

Pass the plugin instance or expose a getter:

**Option A — Pass plugin reference:**

```java
public class SomeOtherClass {
    private final ExamplePlugin plugin;

    public SomeOtherClass(ExamplePlugin plugin) {
        this.plugin = plugin;
    }

    public void someMethod() {
        MyConfig myConfig = plugin.getConfig().get();
        int value = myConfig.getSomeValue();
        String str = myConfig.getSomeString();
    }
}
```

**Option B — Expose a typed getter on the plugin:**

```java
// In ExamplePlugin
public Config<MyConfig> getPluginConfig() {
    return config;
}
```

---

## Modifying and Saving Config

Changes to config values persist across server restarts when saved:

```java
MyConfig myConfig = config.get();

// Modify values
myConfig.setSomeValue(999);
myConfig.setSomeString("A new string");

// Save changes back to disk
config.save();
```

---

## Common Codec Types for Config Fields

Use these `Codec` types in `KeyedCodec` for your config fields:

| Java Type | Codec | Example Key |
|-----------|-------|-------------|
| `int` | `Codec.INTEGER` | `"MaxPlayers"` |
| `float` | `Codec.FLOAT` | `"SpawnRate"` |
| `double` | `Codec.DOUBLE` | `"DamageMultiplier"` |
| `boolean` | `Codec.BOOLEAN` | `"EnableFeature"` |
| `String` | `Codec.STRING` | `"WelcomeMessage"` |
| `long` | `Codec.LONG` | `"CooldownMs"` |
| `List<T>` | `ListCodec` | `"AllowedWorlds"` |
| `Map<K,V>` | `MapCodec` | `"LevelThresholds"` |
| `Set<T>` | `SetCodec` | `"BannedItems"` |

> For advanced codec usage (nested objects, collections, validators), see the `hytale-persistent-data` skill.

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Lowercase codec key (`"someValue"`) | **Capitalize:** `"SomeValue"` |
| Calling `withConfig()` inside `setup()` | **Move to field initializer** or constructor |
| Forgetting `config.save()` in `setup()` | Config file won't be created on first run |
| Forgetting `.add()` after `.append(...)` | Codec builder chain is incomplete |
| Forgetting `.build()` at end of codec | Codec is not finalized |
| Not saving after modifying values | Changes are lost on restart — call `config.save()` |

---

## Complete Example

### Config Class

```java
import com.hypixel.hytale.codec.Codec;
import com.hypixel.hytale.codec.KeyedCodec;
import com.hypixel.hytale.codec.builder.BuilderCodec;

public class ServerConfig {

    public static final BuilderCodec<ServerConfig> CODEC =
        BuilderCodec.builder(ServerConfig.class, ServerConfig::new)
            .append(new KeyedCodec<Integer>("MaxPlayers", Codec.INTEGER),
                    (c, v) -> c.maxPlayers = v,
                    c -> c.maxPlayers)
            .add()
            .append(new KeyedCodec<Boolean>("PvpEnabled", Codec.BOOLEAN),
                    (c, v) -> c.pvpEnabled = v,
                    c -> c.pvpEnabled)
            .add()
            .append(new KeyedCodec<String>("Motd", Codec.STRING),
                    (c, v) -> c.motd = v,
                    c -> c.motd)
            .add()
            .append(new KeyedCodec<Double>("DamageMultiplier", Codec.DOUBLE),
                    (c, v) -> c.damageMultiplier = v,
                    c -> c.damageMultiplier)
            .add()
            .build();

    private int maxPlayers = 20;
    private boolean pvpEnabled = true;
    private String motd = "Welcome to the server!";
    private double damageMultiplier = 1.0;

    public ServerConfig() {
    }

    public int getMaxPlayers() { return maxPlayers; }
    public void setMaxPlayers(int maxPlayers) { this.maxPlayers = maxPlayers; }

    public boolean isPvpEnabled() { return pvpEnabled; }
    public void setPvpEnabled(boolean pvpEnabled) { this.pvpEnabled = pvpEnabled; }

    public String getMotd() { return motd; }
    public void setMotd(String motd) { this.motd = motd; }

    public double getDamageMultiplier() { return damageMultiplier; }
    public void setDamageMultiplier(double damageMultiplier) { this.damageMultiplier = damageMultiplier; }
}
```

### Plugin Class

```java
import com.hypixel.hytale.server.plugin.Config;
import com.hypixel.hytale.server.plugin.JavaPlugin;

public class MyPlugin extends JavaPlugin {

    private final Config<ServerConfig> config = this.withConfig("ServerConfig", ServerConfig.CODEC);

    @Override
    public void setup() {
        config.save();
    }

    @Override
    public void start() {
        ServerConfig cfg = config.get();
        getLogger().info("Max players: " + cfg.getMaxPlayers());
        getLogger().info("PvP enabled: " + cfg.isPvpEnabled());
        getLogger().info("MOTD: " + cfg.getMotd());
        getLogger().info("Damage multiplier: " + cfg.getDamageMultiplier());
    }

    public Config<ServerConfig> getServerConfig() {
        return config;
    }
}
```
```
