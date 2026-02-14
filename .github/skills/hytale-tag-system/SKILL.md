---
name: hytale-tag-system
description: Documents Hytale's hierarchical tag system and how to use it in Hyforged. Use when implementing tag-based lookups, defining tagged assets, or understanding tag expansion patterns. Triggers - tags, tagging, AssetRegistry, tag categories, tag queries.
---

# Hytale Tag System

This skill documents Hytale's hierarchical tag system and how Hyforged integrates with it for stats, items, blocks, and other assets.

## Overview

Hytale uses a **hierarchical tag system** where tags are defined as a map of categories to value arrays. This creates a rich, queryable tag structure that enables flexible asset lookups.

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Tag Category** | A named group (e.g., `"Type"`, `"Element"`, `"Domain"`) |
| **Tag Value** | Values within a category (e.g., `["fire", "elemental"]`) |
| **Tag Index** | Integer index for O(1) lookups via `AssetRegistry` |
| **Tag Expansion** | Hierarchical tags expand to multiple searchable strings |

---

## JSON Format

Tags in Hytale assets use a **map structure**, not a flat array:

```json
{
  "Tags": {
    "Category1": ["value1", "value2"],
    "Category2": ["value3"]
  }
}
```

### Example: Item Tags
```json
{
  "Id": "hytale:adamantite_axe",
  "Tags": {
    "Type": ["Weapon"],
    "Family": ["Axe"]
  }
}
```

### Example: Stat Tags
```json
{
  "Id": "hyforged:fire-resistance-bps",
  "Tags": {
    "Domain": ["defense"],
    "Type": ["resistance"],
    "Element": ["fire", "elemental"],
    "Modifier": ["percent"],
    "Source": ["derived"]
  }
}
```

---

## Tag Expansion

When tags are loaded, Hytale's `AssetExtraInfo.Data.putTags()` **expands** each entry into multiple searchable tags:

| Input | Expanded Tags |
|-------|---------------|
| `"Domain": ["offense"]` | `Domain`, `offense`, `Domain=offense` |
| `"Element": ["fire", "elemental"]` | `Element`, `fire`, `elemental`, `Element=fire`, `Element=elemental` |

### Expansion Rules

For each entry `"Category": ["val1", "val2", ...]`:
1. The **category key** becomes a tag: `Category`
2. Each **value** becomes a tag: `val1`, `val2`
3. Each **category=value** combination becomes a tag: `Category=val1`, `Category=val2`

This enables flexible querying:
- `hasTag("fire")` - matches any asset with "fire" in ANY category
- `hasTag("Element=fire")` - matches only assets with `"Element": ["fire"]`
- `hasTag("Element")` - matches any asset with an Element category

---

## AssetRegistry API

Hytale's `AssetRegistry` provides the global tag index system:

### Core Methods

```java
// Get existing tag index (returns Integer.MIN_VALUE if not found)
int tagIndex = AssetRegistry.getTagIndex("fire");

// Get or create tag index (creates if not existing)
int tagIndex = AssetRegistry.getOrCreateTagIndex("fire");
```

### Integer Indices

Tags are stored as integer indices for O(1) lookups:

```java
// Fast membership test
IntSet entityTags = entity.getData().getExpandedTagIndexes();
int fireIndex = AssetRegistry.getTagIndex("fire");
if (entityTags.contains(fireIndex)) {
    // Entity has fire tag
}
```

---

## StatDefinitionRegistry Tag API

The Hyforged stat system provides convenience methods for tag queries:

### Basic Tag Methods

```java
StatDefinitionRegistry registry = StatDefinitionRegistry.get();

// Check if any stat has a tag
boolean exists = registry.hasTag("fire");

// Get stats by tag (any expanded tag)
Collection<StatDefinition> stats = registry.getStatsForTag("fire");
Set<Integer> indices = registry.getStatIndicesForTag("fire");
List<StatId> statIds = registry.getStatIdsForTag("fire");
```

### Category-Based Methods (Recommended)

For hierarchical tags, use the explicit category-based API:

```java
// Check if any stat has Type=resistance
boolean exists = registry.hasTagValue("Type", "resistance");

// Get all resistance stats
Collection<StatDefinition> resistances = registry.getStatsForTagValue("Type", "resistance");

// Get fire elemental stats
Set<Integer> fireStats = registry.getStatIndicesForTagValue("Element", "fire");

// Get all ability score stat IDs
List<StatId> abilityScores = registry.getStatIdsForTagValue("Type", "ability-score");
```

### Integer Index Methods (Performance)

For hot paths, use pre-resolved integer indices:

```java
// Resolve once, use many times
int fireTagIndex = registry.getOrCreateTagIndex("Element=fire");

// Fast O(1) lookup
IntSet stats = registry.getStatIndicesForTagIndex(fireTagIndex);
```

---

## Standard Tag Categories

### Stats

| Category | Values | Purpose |
|----------|--------|---------|
| `Domain` | `offense`, `defense`, `resource`, `utility`, `attributes` | Primary functional classification |
| `Element` | `physical`, `fire`, `cold`, `lightning`, `chaos`, `elemental` | Damage/resistance element |
| `Type` | `damage`, `resistance`, `rating`, `ability-score`, `speed`, `critical`, `ailment`, `leech`, `skill-level`, `area`, `resource` | What the stat represents |
| `Modifier` | `flat`, `percent`, `more` | How the stat value applies |
| `Source` | `derived`, `base` | Origin of the stat value |
| `Mechanic` | `attack`, `spell`, `projectile`, `melee`, `ranged`, `minion`, `aura`, `totem`, `trap` | Usage mechanism |
| `Resource` | `health`, `mana`, `stamina`, `rage` | Which resource it affects |
| `Ailment` | `bleed`, `poison`, `ignite`, `chill`, `shock`, `freeze` | Specific ailment type |
| `Weapon` | `sword`, `axe`, `mace`, `dagger`, `bow`, `crossbow`, `staff`, `unarmed` | Weapon type affinity |

### Items (Hytale Native)

| Category | Values | Purpose |
|----------|--------|---------|
| `Type` | `Weapon`, `Armor`, `Tool`, `Consumable`, `Material` | Item classification |
| `Family` | `Sword`, `Axe`, `Helmet`, `Chestplate`, etc. | Item family |
| `Material` | `Wood`, `Stone`, `Iron`, `Gold`, `Adamantite` | Material type |
| `Tier` | `Basic`, `Common`, `Rare`, `Epic`, `Legendary` | Quality tier |

---

## Implementing Tags in New Assets

### 1. Define JSON Schema with Map Codec

```java
// In your asset class
public static final AssetBuilderCodec<String, MyAsset> CODEC = AssetBuilderCodec
    .builder(MyAsset.class, MyAsset::new, ...)
    .appendInherited(
        new KeyedCodec<>("Tags", new MapCodec<>(Codec.STRING_ARRAY, HashMap::new)),
        (asset, value) -> asset.rawTags = value != null ? value : new HashMap<>(),
        asset -> asset.rawTags,
        (asset, parent) -> asset.rawTags = new HashMap<>(parent.rawTags)
    )
    .add()
    .build();

private Map<String, String[]> rawTags = new HashMap<>();
```

### 2. Expand Tags on Load

```java
public Set<String> getExpandedTags() {
    Set<String> expanded = new HashSet<>();
    for (Map.Entry<String, String[]> entry : rawTags.entrySet()) {
        String category = entry.getKey();
        expanded.add(category);
        for (String value : entry.getValue()) {
            expanded.add(value);
            expanded.add(category + "=" + value);
        }
    }
    return expanded;
}
```

### 3. Register Tags with AssetRegistry

```java
// During asset registration
for (String tag : asset.getExpandedTags()) {
    int tagIndex = AssetRegistry.getOrCreateTagIndex(tag);
    tagToAssetIndices.computeIfAbsent(tagIndex, k -> new IntOpenHashSet()).add(assetIndex);
}
```

---

## Best Practices

### DO

- ✅ Use category-based API (`getStatsForTagValue("Type", "resistance")`) for explicit queries
- ✅ Pre-resolve tag indices for hot paths
- ✅ Use consistent category names across asset types
- ✅ Document your tag categories in the asset schema
- ✅ Use IntSet for efficient tag membership tests

### DON'T

- ❌ Use flat tag arrays (`"Tags": ["fire", "damage"]`) - use hierarchical format
- ❌ Create duplicate tags across different categories with same meaning
- ❌ Store tag strings at runtime - resolve to indices
- ❌ Assume tag order matters - it doesn't

---

## Related Files

- `AssetRegistry` - Hytale's global tag index registry
- `AssetExtraInfo.Data.putTags()` - Tag expansion logic
- `StatDefinitionRegistry` - Stat-specific tag queries
- `StatDefinitionAsset` - JSON codec for stat tags
- `TagSet` / `TagSetLookupTable` - Advanced tag grouping (like NPCGroup)

## ADR Reference

See ADR-0008 in `.memory_bank/ADRs.md` for the decision rationale behind adopting Hytale's tag system.
