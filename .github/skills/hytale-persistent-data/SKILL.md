---
name: hytale-persistent-data
description: Stores persistent data on players and entities using custom components with Codec serialization in Hytale plugins. Use when saving player data across sessions, creating custom player components, serializing complex data types to BSON, or persisting entity state. Triggers - persistent data, player data, save data, BuilderCodec, KeyedCodec, putComponent, ensureAndGetComponent, BSON serialization, player state, custom component, session data.
---

# Hytale Persistent Data Storage

This skill provides comprehensive documentation for storing persistent data on players and entities using custom components with Codec serialization.

## Quick Reference

| Task | Approach |
|------|----------|
| Create persistent component | Class implementing `Component<EntityStore>` with `BuilderCodec` |
| Register component | `getEntityStoreRegistry().registerComponent(Class, name, CODEC)` in `setup()` |
| Add temporary component | `store.addComponent(ref, componentType, instance)` |
| Add persistent component | `store.putComponent(ref, componentType, instance)` |
| Get or create component | `store.ensureAndGetComponent(ref, componentType)` |
| Check if exists | `store.getComponent(ref, componentType) != null` |
| Serialize primitives | `Codec.INTEGER`, `Codec.STRING`, `Codec.BOOLEAN`, `Codec.FLOAT`, `Codec.DOUBLE` |
| Serialize collections | `MapCodec`, `ListCodec`, `SetCodec` |

---

## Component Class Structure

### Required Elements

Every persistent component must have:

1. **Fields** - Data to persist
2. **BuilderCodec** - Serialization definition with getters/setters for each field
3. **Default constructor** - Initializes default values
4. **Copy constructor** - For cloning
5. **clone() method** - Returns new instance via copy constructor

### Basic Template

```java
import com.hypixel.hytale.codec.BuilderCodec;
import com.hypixel.hytale.codec.Codec;
import com.hypixel.hytale.codec.KeyedCodec;
import com.hypixel.hytale.ecs.Component;
import com.hypixel.hytale.ecs.entity.store.EntityStore;

import javax.annotation.Nonnull;

public class CustomPlayerData implements Component<EntityStore> {
    
    // === Fields ===
    private int someInteger;
    private String someString;
    
    // === Codec Definition ===
    public static final BuilderCodec<CustomPlayerData> CODEC =
        BuilderCodec.builder(CustomPlayerData.class, CustomPlayerData::new)
            .append(new KeyedCodec<>("SomeInteger", Codec.INTEGER),
                    (data, value) -> data.someInteger = value,  // setter
                    data -> data.someInteger)                    // getter
            .addValidator(Validators.nonNull())
            .add()
            .append(new KeyedCodec<>("SomeString", Codec.STRING),
                    (data, value) -> data.someString = value,
                    data -> data.someString)
            .add()
            .build();
    
    // === Default Constructor ===
    public CustomPlayerData() {
        this.someInteger = 0;
        this.someString = "";
    }
    
    // === Copy Constructor ===
    public CustomPlayerData(CustomPlayerData clone) {
        this.someInteger = clone.someInteger;
        this.someString = clone.someString;
    }
    
    // === Clone Method ===
    @Nonnull
    @Override
    public Component<EntityStore> clone() {
        return new CustomPlayerData(this);
    }
    
    // === Getters and Setters ===
    public int getSomeInteger() { return someInteger; }
    public void setSomeInteger(int value) { this.someInteger = value; }
    
    public String getSomeString() { return someString; }
    public void setSomeString(String value) { this.someString = value; }
}
```

---

## Codec System

### KeyedCodec Requirements

> **IMPORTANT**: The key in `KeyedCodec` must start with a Capital Letter, otherwise serialization may fail.

```java
// ✅ Correct - Capital first letter
new KeyedCodec<>("SomeInteger", Codec.INTEGER)

// ❌ Wrong - lowercase first letter
new KeyedCodec<>("someInteger", Codec.INTEGER)
```

### Primitive Codecs

| Type | Codec |
|------|-------|
| `int` | `Codec.INTEGER` |
| `long` | `Codec.LONG` |
| `float` | `Codec.FLOAT` |
| `double` | `Codec.DOUBLE` |
| `boolean` | `Codec.BOOLEAN` |
| `String` | `Codec.STRING` |

### Collection Codecs

```java
// Map<String, String>
new KeyedCodec<>("SomeMap", 
    new MapCodec<>(Codec.STRING, HashMap::new, false))

// List<String>
new KeyedCodec<>("SomeList",
    new ListCodec<>(Codec.STRING, ArrayList::new))

// Set<Integer>
new KeyedCodec<>("SomeSet",
    new SetCodec<>(Codec.INTEGER, HashSet::new))
```

### BuilderCodec Chain Pattern

```java
public static final BuilderCodec<MyComponent> CODEC =
    BuilderCodec.builder(MyComponent.class, MyComponent::new)
        // Field 1
        .append(new KeyedCodec<>("FieldOne", Codec.INTEGER),
                (data, value) -> data.fieldOne = value,
                data -> data.fieldOne)
        .addValidator(Validators.nonNull())  // Optional validator
        .add()
        // Field 2
        .append(new KeyedCodec<>("FieldTwo", Codec.STRING),
                (data, value) -> data.fieldTwo = value,
                data -> data.fieldTwo)
        .add()
        // Field 3 with collection
        .append(new KeyedCodec<>("FieldThree", 
                new MapCodec<>(Codec.STRING, HashMap::new, false)),
                (data, value) -> data.fieldThree = value,
                data -> data.fieldThree)
        .add()
        .build();
```

---

## Component Registration

Register the component in your plugin's `setup()` method:

```java
public class MyPlugin extends JavaPlugin {
    
    private ComponentType<EntityStore, CustomPlayerData> customPlayerDataComponent;
    
    public MyPlugin(@Nonnull JavaPluginInit init) {
        super(init);
    }
    
    @Override
    protected void setup() {
        // Register the component with its codec
        this.customPlayerDataComponent = this.getEntityStoreRegistry().registerComponent(
            CustomPlayerData.class,
            "CustomPlayerDataComponent",
            CustomPlayerData.CODEC
        );
    }
    
    // Getter for other classes to access
    public ComponentType<EntityStore, CustomPlayerData> getCustomPlayerDataComponent() {
        return this.customPlayerDataComponent;
    }
}
```

---

## Using Components

### addComponent vs putComponent

| Method | Persistence | Use Case |
|--------|-------------|----------|
| `addComponent` | Temporary | Component removed when entity leaves world |
| `putComponent` | Persistent | Component saved and loaded across sessions |

### Adding/Updating Data

```java
private void updatePlayerData(
    @Nonnull Ref<EntityStore> ref, 
    @Nonnull Store<EntityStore> store
) {
    ComponentType<EntityStore, CustomPlayerData> componentType = 
        MyPlugin.instance().getCustomPlayerDataComponent();
    
    // Check if component already exists
    CustomPlayerData existing = store.getComponent(ref, componentType);
    
    if (existing != null) {
        // Update existing component
        existing.setSomeString("Updated Value");
        existing.setSomeInteger(existing.getSomeInteger() + 1);
    } else {
        // Create and put new component
        CustomPlayerData newData = new CustomPlayerData();
        newData.setSomeString("Initial Value");
        newData.setSomeInteger(1);
        
        // Use putComponent for persistence
        store.putComponent(ref, componentType, newData);
    }
}
```

### Retrieving Data (with auto-creation)

Use `ensureAndGetComponent` to get the component, creating it with default values if it doesn't exist:

```java
public class MyCommand extends AbstractPlayerCommand {
    
    public MyCommand() {
        super("mycommand", "Description here");
    }
    
    @Override
    protected void execute(
        @Nonnull CommandContext commandContext,
        @Nonnull Store<EntityStore> store,
        @Nonnull Ref<EntityStore> ref,
        @Nonnull PlayerRef playerRef,
        @Nonnull World world
    ) {
        ComponentType<EntityStore, CustomPlayerData> componentType = 
            MyPlugin.instance().getCustomPlayerDataComponent();
        
        // Gets component or creates with default values
        CustomPlayerData data = store.ensureAndGetComponent(ref, componentType);
        
        // Use the data
        int currentValue = data.getSomeInteger();
        String currentString = data.getSomeString();
        
        // Modify if needed
        data.setSomeInteger(currentValue + 1);
    }
}
```

---

## Complete Example

### Component Class

```java
package com.example.plugin.components;

import com.hypixel.hytale.codec.BuilderCodec;
import com.hypixel.hytale.codec.Codec;
import com.hypixel.hytale.codec.KeyedCodec;
import com.hypixel.hytale.codec.MapCodec;
import com.hypixel.hytale.codec.Validators;
import com.hypixel.hytale.ecs.Component;
import com.hypixel.hytale.ecs.entity.store.EntityStore;

import javax.annotation.Nonnull;
import java.util.HashMap;
import java.util.Map;

public class PlayerStats implements Component<EntityStore> {
    
    private int kills;
    private int deaths;
    private long playTime;
    private Map<String, Integer> achievements;
    
    public static final BuilderCodec<PlayerStats> CODEC =
        BuilderCodec.builder(PlayerStats.class, PlayerStats::new)
            .append(new KeyedCodec<>("Kills", Codec.INTEGER),
                    (data, value) -> data.kills = value,
                    data -> data.kills)
            .addValidator(Validators.nonNull())
            .add()
            .append(new KeyedCodec<>("Deaths", Codec.INTEGER),
                    (data, value) -> data.deaths = value,
                    data -> data.deaths)
            .addValidator(Validators.nonNull())
            .add()
            .append(new KeyedCodec<>("PlayTime", Codec.LONG),
                    (data, value) -> data.playTime = value,
                    data -> data.playTime)
            .add()
            .append(new KeyedCodec<>("Achievements",
                    new MapCodec<>(Codec.INTEGER, HashMap::new, false)),
                    (data, value) -> data.achievements = value,
                    data -> data.achievements)
            .add()
            .build();
    
    public PlayerStats() {
        this.kills = 0;
        this.deaths = 0;
        this.playTime = 0L;
        this.achievements = new HashMap<>();
    }
    
    public PlayerStats(PlayerStats clone) {
        this.kills = clone.kills;
        this.deaths = clone.deaths;
        this.playTime = clone.playTime;
        this.achievements = new HashMap<>(clone.achievements);
    }
    
    @Nonnull
    @Override
    public Component<EntityStore> clone() {
        return new PlayerStats(this);
    }
    
    // Getters and setters
    public int getKills() { return kills; }
    public void setKills(int kills) { this.kills = kills; }
    public void incrementKills() { this.kills++; }
    
    public int getDeaths() { return deaths; }
    public void setDeaths(int deaths) { this.deaths = deaths; }
    public void incrementDeaths() { this.deaths++; }
    
    public long getPlayTime() { return playTime; }
    public void setPlayTime(long playTime) { this.playTime = playTime; }
    public void addPlayTime(long time) { this.playTime += time; }
    
    public Map<String, Integer> getAchievements() { return achievements; }
    public void unlockAchievement(String id) { 
        achievements.put(id, achievements.getOrDefault(id, 0) + 1); 
    }
}
```

### Plugin Registration

```java
package com.example.plugin;

import com.example.plugin.components.PlayerStats;
import com.hypixel.hytale.ecs.entity.store.EntityStore;
import com.hypixel.hytale.ecs.query.ComponentType;
import com.hypixel.hytale.plugin.JavaPlugin;
import com.hypixel.hytale.plugin.JavaPluginInit;

import javax.annotation.Nonnull;

public class MyPlugin extends JavaPlugin {
    
    private static MyPlugin instance;
    private ComponentType<EntityStore, PlayerStats> playerStatsComponent;
    
    public MyPlugin(@Nonnull JavaPluginInit init) {
        super(init);
        instance = this;
    }
    
    @Override
    protected void setup() {
        this.playerStatsComponent = this.getEntityStoreRegistry().registerComponent(
            PlayerStats.class,
            "PlayerStatsComponent",
            PlayerStats.CODEC
        );
    }
    
    public static MyPlugin instance() { return instance; }
    
    public ComponentType<EntityStore, PlayerStats> getPlayerStatsComponent() {
        return this.playerStatsComponent;
    }
}
```

---

## Best Practices

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Component class | PascalCase, descriptive | `PlayerStats`, `QuestProgress` |
| Component name (registration) | PascalCase + "Component" | `"PlayerStatsComponent"` |
| KeyedCodec keys | PascalCase, starts with capital | `"Kills"`, `"PlayTime"` |
| Fields | camelCase | `kills`, `playTime` |

### Performance Tips

1. **Avoid frequent getComponent calls** - Cache the component reference when processing multiple operations
2. **Use ensureAndGetComponent wisely** - It creates a new component if none exists, which may not always be desired
3. **Batch updates** - Modify multiple fields before the component is saved
4. **Keep components focused** - One component per logical data grouping

### Common Pitfalls

| Issue | Solution |
|-------|----------|
| Data not persisting | Use `putComponent` instead of `addComponent` |
| Serialization fails | Ensure KeyedCodec keys start with capital letter |
| NullPointerException | Initialize collections in default constructor |
| Clone issues | Deep copy collections in copy constructor |

---

## Related Resources

- [ECS Theory Guide](https://hytalemodding.dev/en/docs/guides/ecs/hytale-ecs-theory)
- [Entity Component System](https://hytalemodding.dev/en/docs/guides/ecs/entity-component-system)
- [Systems Guide](https://hytalemodding.dev/en/docs/guides/ecs/systems)
- Codec types: `lib/hytale-server/src/main/java/com/hypixel/hytale/codec/`
