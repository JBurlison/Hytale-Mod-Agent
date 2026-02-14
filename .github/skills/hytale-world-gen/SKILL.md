---
name: hytale-world-gen
description: Documents Hytale's procedural world generation systems for plugin development. Covers the Java API (Zones, Biomes, Caves) and the data-driven node/JSON system (Density, Curves, Patterns, Material Providers, Props, Scanners, Positions, Assignments, Directionality, Vector Providers, Block Masks). Use when creating custom zones, biomes, caves, terrain, world generation features, density fields, asset packs, or working with the Hytale Node Editor. Triggers - world gen, world generation, zone, biome, cave, ZonePatternGenerator, BiomePatternGenerator, CaveGenerator, CaveType, Zone, CustomBiome, TileBiome, ZoneDiscoveryConfig, ZoneGeneratorResult, CaveBiomeMaskFlags, terrain, procedural generation, border transition, biome mask, density, noise, simplex, curves, patterns, material provider, props, prefab, scanner, positions, assignments, directionality, vector provider, block mask, asset pack, HytaleGenerator, node editor.
---

# Hytale World Generation System

Comprehensive reference for Hytale's procedural world generation systems used to create environments, biomes, and structures dynamically as players explore the world.

> **Related skills:** For ECS fundamentals, see `hytale-ecs`. For persistent data/Codec patterns, see `hytale-persistent-data`. For entity effects, see `hytale-entity-effects`.

## Quick Reference

| Task | Approach |
|------|----------|
| Get zone at position | `zoneGen.generate(seed, x, z)` returns `ZoneGeneratorResult` |
| Get zone from result | `zoneResult.getZone()` returns `Zone` |
| Get biome in zone | `zone.biomePatternGenerator().generateBiomeAt(zoneResult, seed, x, z)` |
| Get cave generator | `zone.caveGenerator()` returns `CaveGenerator` (nullable) |
| Get cave types | `caveGen.getCaveTypes()` returns `CaveType[]` |
| Check biome cave mask | `CaveBiomeMaskFlags.canGenerate(flags)` |
| Get border distance | `zoneResult.getBorderDistance()` |
| Fade near border | `customBiome.getFadeContainer().getMaskFactor(result)` |
| Create zone discovery | `new ZoneDiscoveryConfig(...)` |
| Create biome pattern | `new BiomePatternGenerator(points, tileBiomes, customBiomes)` |
| Create cave config | `new CaveGenerator(caveTypes)` |
| Create custom zone | `new Zone(id, name, discovery, caveGen, biomeGen, prefabs)` |

---

## Overview

Hytale's world generation is organized into three interconnected systems:

```
World Generation
├── Zones       — Large-scale regions defining overall world structure
├── Biomes      — Terrain characteristics and environment within zones
└── Caves       — Underground structures and networks within zones
```

These systems are hierarchical: **Zones** contain **Biomes**, and both Zones and Biomes influence **Cave** generation. They work together to produce smooth transitions and coherent regional themes.

---

## Zones

Zones are the largest-scale division in world generation. Each zone defines its own biome patterns, cave configurations, and unique structures (prefabs).

### Zone Lookup and Generation

```java
// Get zone at a world position
ZonePatternGenerator zoneGen = /* from world generator */;
ZoneGeneratorResult zoneResult = zoneGen.generate(seed, x, z);
Zone zone = zoneResult.getZone();
```

### ZoneGeneratorResult

The result object provides:

| Method | Returns | Description |
|--------|---------|-------------|
| `getZone()` | `Zone` | The zone at the queried position |
| `getBorderDistance()` | `double` | Distance to the nearest zone border |

### Zone Class

A `Zone` encapsulates all generation data for a region:

| Property | Type | Description |
|----------|------|-------------|
| ID | `int` | Unique numeric identifier |
| Name | `String` | Internal name (e.g., `"new_custom_zone"`) |
| Discovery | `ZoneDiscoveryConfig` | Player notification on zone entry |
| Cave Generator | `CaveGenerator` | Cave configuration (nullable) |
| Biome Pattern | `BiomePatternGenerator` | Biome layout within the zone |
| Unique Prefabs | — | Unique structures placed in the zone |

### Creating a Custom Zone

```java
// 1. Configure zone discovery (player notification on entry)
ZoneDiscoveryConfig discovery = new ZoneDiscoveryConfig(
    true,                           // Show notification
    "Custom Zone",                  // Display name
    "zone.forest.discover",         // Sound event
    "icons/forest.png",             // Icon
    true,                           // Major zone
    5.0f, 2.0f, 1.5f               // Duration, fade in, fade out
);

// 2. Create biome pattern
IPointGenerator biomePoints;
IWeightedMap<TileBiome> tileBiomes;
CustomBiome[] customBiomes;

BiomePatternGenerator biomeGen = new BiomePatternGenerator(
    biomePoints,
    tileBiomes,
    customBiomes
);

// 3. Create cave configuration
CaveType[] caveTypes; // cave definitions
CaveGenerator caveGen = new CaveGenerator(caveTypes);

// 4. Assemble the zone
Zone customZone = new Zone(
    100,                    // Unique ID
    "new_custom_zone",      // Internal name
    discovery,              // Discovery config
    caveGen,                // Cave generator
    biomeGen,               // Biome pattern
    uniquePrefabs           // Unique structures
);
```

### ZoneDiscoveryConfig

Controls what the player sees when entering a zone:

| Parameter | Type | Description |
|-----------|------|-------------|
| `showNotification` | `boolean` | Whether to display the zone entry notification |
| `displayName` | `String` | Name shown to the player |
| `soundEvent` | `String` | Sound played on zone entry |
| `icon` | `String` | Icon path for the notification |
| `majorZone` | `boolean` | Whether this is a major zone (affects display) |
| `duration` | `float` | How long the notification is visible (seconds) |
| `fadeIn` | `float` | Fade-in duration (seconds) |
| `fadeOut` | `float` | Fade-out duration (seconds) |

---

## Biomes

Biomes define terrain characteristics, vegetation, and environmental properties within a zone. Each zone has its own `BiomePatternGenerator` that determines biome layout.

### Biome Lookup

```java
// Get the biome at a specific position within a zone
Zone zone = zoneResult.getZone();
BiomePatternGenerator biomeGen = zone.biomePatternGenerator();
Biome biome = biomeGen.generateBiomeAt(zoneResult, seed, x, z);
```

### BiomePatternGenerator

Constructs the biome layout from three inputs:

| Parameter | Type | Description |
|-----------|------|-------------|
| `biomePoints` | `IPointGenerator` | Point distribution controlling biome placement |
| `tileBiomes` | `IWeightedMap<TileBiome>` | Weighted map of tile-level biome data |
| `customBiomes` | `CustomBiome[]` | Custom biome definitions with fade/transition settings |

### Biome Properties

Each `Biome` has at minimum:

| Method | Returns | Description |
|--------|---------|-------------|
| `getId()` | `int` | Unique biome identifier |

### CustomBiome Fading

Custom biomes support smooth transitions near zone borders via a fade container:

```java
CustomBiome customBiome = /* ... */;
FadeContainer fade = customBiome.getFadeContainer();
double maskFadeSum = fade.getMaskFadeSum();
double factor = fade.getMaskFactor(zoneResult);
```

---

## Caves

Caves are underground structures generated within zones. Each zone optionally has a `CaveGenerator` with one or more `CaveType` definitions.

### Cave Lookup

```java
Zone zone = /* ... */;
CaveGenerator caveGen = zone.caveGenerator();
if (caveGen != null) {
    // This zone has caves
    CaveType[] types = caveGen.getCaveTypes();
}
```

### CaveType and Biome Masks

Cave types use biome masks to control where caves can generate:

```java
// Cave type with biome restrictions
Int2FlagsCondition biomeMask = caveType.getBiomeMask();
int biomeId = biome.getId();
int flags = biomeMask.eval(biomeId);

// Check if cave can generate in this biome
if (CaveBiomeMaskFlags.canGenerate(flags)) {
    // Generate cave
}
```

| Class | Purpose |
|-------|---------|
| `CaveGenerator` | Holds cave type definitions for a zone |
| `CaveType` | Individual cave definition with shape, biome mask, etc. |
| `Int2FlagsCondition` | Evaluates biome ID → flags for cave placement |
| `CaveBiomeMaskFlags` | Utility to interpret biome mask flags (e.g., `canGenerate`) |

---

## System Integration

### Zone → Biome Integration

Each zone defines its own biome pattern. The biome generator requires the zone result (for border distance and zone context):

```java
Zone zone = zoneGen.generate(seed, x, z).getZone();
BiomePatternGenerator biomeGen = zone.biomePatternGenerator();
Biome biome = biomeGen.generateBiomeAt(zoneResult, seed, x, z);
```

### Zone → Cave Integration

Each zone defines its own cave patterns. Not all zones have caves:

```java
Zone zone = /* ... */;
CaveGenerator caveGen = zone.caveGenerator();
if (caveGen != null) {
    CaveType[] types = caveGen.getCaveTypes();
}
```

### Biome → Cave Integration

Caves use biome masks to restrict generation to specific biomes:

```java
Int2FlagsCondition biomeMask = caveType.getBiomeMask();
int biomeId = biome.getId();
int flags = biomeMask.eval(biomeId);

if (CaveBiomeMaskFlags.canGenerate(flags)) {
    // Cave can generate in this biome
}
```

### Border Transitions

All systems respect zone boundaries. Custom biomes fade near borders for smooth transitions:

```java
ZoneGeneratorResult result = zoneGen.generate(seed, x, z);
double borderDistance = result.getBorderDistance();

// Fade custom biomes near borders
if (borderDistance < customBiome.getFadeContainer().getMaskFadeSum()) {
    double factor = customBiome.getFadeContainer().getMaskFactor(result);
    // Apply fading based on factor (0.0 = fully faded, 1.0 = full strength)
}
```

---

## Key Classes Summary

| Class | Package Area | Purpose |
|-------|-------------|---------|
| `ZonePatternGenerator` | worldgen | Generates zones at world positions |
| `ZoneGeneratorResult` | worldgen | Result of zone lookup (zone + border distance) |
| `Zone` | worldgen | Zone definition (biomes, caves, prefabs, discovery) |
| `ZoneDiscoveryConfig` | worldgen | Player notification on zone entry |
| `BiomePatternGenerator` | worldgen | Biome layout within a zone |
| `Biome` | worldgen | Biome data (ID, properties) |
| `CustomBiome` | worldgen | Custom biome with fade/transition support |
| `TileBiome` | worldgen | Tile-level biome data |
| `IPointGenerator` | worldgen | Point distribution for biome placement |
| `IWeightedMap<T>` | worldgen | Weighted map for biome selection |
| `CaveGenerator` | worldgen | Cave configuration for a zone |
| `CaveType` | worldgen | Individual cave type definition |
| `Int2FlagsCondition` | worldgen | Biome mask evaluator for caves |
| `CaveBiomeMaskFlags` | worldgen | Flag utility for cave biome masks |
| `FadeContainer` | worldgen | Border fade/transition controller |

---

## Common Patterns

### Full World Position → Zone + Biome + Cave Pipeline

```java
// Complete lookup pipeline
ZonePatternGenerator zoneGen = /* from world generator */;
long seed = /* world seed */;
int x = /* world x */;
int z = /* world z */;

// 1. Determine zone
ZoneGeneratorResult zoneResult = zoneGen.generate(seed, x, z);
Zone zone = zoneResult.getZone();

// 2. Determine biome within zone
BiomePatternGenerator biomeGen = zone.biomePatternGenerator();
Biome biome = biomeGen.generateBiomeAt(zoneResult, seed, x, z);

// 3. Check for caves
CaveGenerator caveGen = zone.caveGenerator();
if (caveGen != null) {
    for (CaveType caveType : caveGen.getCaveTypes()) {
        Int2FlagsCondition biomeMask = caveType.getBiomeMask();
        int flags = biomeMask.eval(biome.getId());
        if (CaveBiomeMaskFlags.canGenerate(flags)) {
            // This cave type can generate here
        }
    }
}

// 4. Handle border transitions
double borderDistance = zoneResult.getBorderDistance();
// Use borderDistance for custom blending/fading logic
```

### Zone Entry Notification Setup

```java
// Minimal zone discovery config
ZoneDiscoveryConfig discovery = new ZoneDiscoveryConfig(
    true,                    // Show notification
    "Enchanted Forest",      // Display name
    "zone.forest.discover",  // Sound event
    "icons/forest.png",      // Icon
    true,                    // Major zone
    5.0f, 2.0f, 1.5f        // Duration, fade in, fade out
);
```

---

---

## Data-Driven World Generation (Node/JSON System)

Beyond the Java plugin API, Hytale's world generation is primarily **data-driven** through JSON asset files and an in-game **Node Editor**. Biomes, terrain shapes, materials, and content placement are all defined declaratively.

> **Detailed references** for every node type are in the `references/` subdirectory of this skill.

### Asset Directory Structure

```
Server/HytaleGenerator/
├── WorldStructure/    # Generator files defining which biomes spawn together
├── Biomes/            # Biome assets with content configurations
├── Density/           # Reusable density assets referenced by other generation assets
└── Assignments/       # Reusable prop assignment assets referenced by biomes
```

### World Instance Configuration

Instances are separate worlds that players can join. Each instance has an `Instance.bson` that specifies which generator to use:

```json
{
  "WorldGen": {
    "Type": "HytaleGenerator",
    "WorldStructure": "Basic",
    "playerSpawn": {
      "X": 123, "Y": 480, "Z": 10000,
      "Pitch": 0, "Yaw": 0, "Roll": 0
    }
  }
}
```

Instance configs are stored at `Server/Instances/`. Create custom instances by duplicating the basic config and changing `WorldStructure` to your asset name.

### Previewing World Generation

| Command | Purpose |
|---------|---------|
| `/viewport --radius 5` | Live-reload area around player as you edit |
| `/instances spawn <instance>` | Create a new world with latest changes |
| Fly south | New chunks generate with latest changes |

### Biome Asset Structure

Every biome has 5 root components:

| Component | Purpose |
|-----------|---------|
| **Terrain** | Density function nodes defining the physical terrain shape |
| **Material Provider** | Logic nodes determining which block types make up terrain |
| **Props** | Object nodes placing prefabs, trees, POIs, grass, etc. |
| **Environment Provider** | Logic nodes determining weather, NPC spawns, sounds per coordinate |
| **Tint Provider** | Function nodes determining color codes for grasses, soils, etc. |

Each biome is self-contained — it controls everything within its boundaries except Base Heights.

### Node System Overview

World generation uses a node-based system of composable JSON assets. Each node type has parameters and inputs:

| Node Category | Purpose | Key Types |
|---------------|---------|-----------|
| **Density** | 3D decimal value fields for terrain shape | SimplexNoise2D/3D, PositionsCellNoise, Distance, Ellipsoid, Cube, Cylinder, Sum, Multiplier, Mix, CurveMapper, Scale, Rotator, Warp nodes |
| **Curves** | f(x)=y mappings for value transformation | Manual, DistanceExponential, DistanceS, Ceiling/Floor, SmoothClamp, Clamp, Inverter, Min/Max |
| **Patterns** | Validate world positions by material/structure | BlockType, BlockSet, Floor, Ceiling, Wall, Surface, Gap, Cuboid, And/Or/Not, FieldFunction |
| **Material Providers** | Determine block types at positions | Constant, Solidity, Queue, SimpleHorizontal, Striped, Weighted, FieldFunction, SpaceAndDepth (with Layers and Conditions) |
| **Positions Provider** | Define infinite 3D position fields | Mesh2D, Mesh3D, List, FieldFunction, Occurrence, BaseHeight, Cache |
| **Scanners** | Scan local world areas for valid positions | Origin, ColumnLinear, ColumnRandom, Area |
| **Props** | Localized content placed in the world | Box, Density, Prefab, Column, Cluster, Union, Weighted, Queue, PondFiller |
| **Assignments** | Assign props to positions | Constant, FieldFunction, Sandwich, Weighted |
| **Directionality** | Determine prop placement direction | Static, Random, Pattern-based |
| **Vector Provider** | Define 3D vectors procedurally | Constant, DensityGradient, Cache |
| **Block Mask** | Control which materials can replace others | DontPlace, DontReplace, Advanced rules |

### Core Concept: Density Fields

Terrain generation is built on **density fields** — maps of decimal values (typically -1 to 1) defining terrain shape:
- **Positive values** → solid terrain
- **Negative values** → empty space (air)
- Density is calculated from the sum of all nodes: `f(x) = z + y`

Common terrain formula: **Simplex 2D noise** + **Y-Curve** (height gradient) = basic terrain shape.

Function nodes manipulate density fields: Absolute (ridged shapes), Normalization (rescaling range), Scale (stretch/contract), Rotator (orientation), Warp (distortion), and many more.

### Core Concept: Props Pipeline

Props place procedural content (trees, prefabs, grass) using three connected systems:

```
Positions → Scanner → Pattern → Prop Placement
```

1. **Positions** provide candidate locations (e.g., Mesh2D grid, BaseHeight offsets)
2. **Scanner** searches around each position (e.g., ColumnLinear scans Y range)
3. **Pattern** validates positions (e.g., Floor pattern checks for solid ground below)
4. **Prop** places content at validated positions (e.g., Prefab with Directionality)

### Asset Packs

Asset Packs override or add assets to the base game. Required for world gen customization:

```json
{
  "Group": "My Group",
  "Name": "Pack Example",
  "Version": "1.0.0",
  "Description": "An Example Asset Pack",
  "Authors": [{"Name": "Me", "Email": "", "Url": ""}],
  "Dependencies": {},
  "DisabledByDefault": false,
  "IncludesAssetPack": false,
  "SubPlugins": []
}
```

- Stored in `C:\Users\<user>\AppData\Roaming\Hytale\UserData\Mods`
- Per-world packs stored in `UserData\Saves\<world>\mods`
- Asset Packs exist entirely on the server — only the host needs them
- Assets inside packs override base game assets

### Import/Export System

Most node types support `Imported` and `Exported` nodes for reusability:
- **Exported**: Makes a node tree available by name, with optional `SingleInstance` for shared caching
- **Imported**: References an exported asset by name
- This enables modular, reusable density fields, curves, patterns, etc.

---

## Notes

- The `worldgen` module is a built-in Hytale module. Plugins interact with it through the public API classes listed above.
- Zone IDs must be unique across the world generation configuration.
- `CaveGenerator` is nullable — not all zones have caves.
- Biome masks use a flags-based system (`Int2FlagsCondition`) for efficient cave-biome filtering.
- Border transitions use `FadeContainer` with `getMaskFadeSum()` and `getMaskFactor()` for smooth blending between zones.
- The `--validate-world-gen` server launch flag can be used to validate world generation assets.
- World gen examples can be found in `HytaleGenerator/Biomes/Examples/`.
- The Hytale Node Editor is accessible in-game from the Content Creation menu (Tab key).
- Performance tip: In Multiplier nodes, order inputs with cheapest mask first — the node skips remaining inputs after a 0 value.
- Performance tip: Use Cache/Cache2D nodes on expensive density lookups that are queried multiple times.

> **Source:** [hytalemodding.dev — World Generation System](https://hytalemodding.dev/en/docs/guides/plugin/world-gen)
> **Source:** [HytaleModding/site — Official World Generation Documentation](https://github.com/HytaleModding/site/tree/main/content/docs/en/official-documentation/worldgen)
