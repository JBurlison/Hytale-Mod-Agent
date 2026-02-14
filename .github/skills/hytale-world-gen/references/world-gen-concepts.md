# World Generation Concepts

> **Source:** [Official Hytale World Generation Documentation](https://github.com/HytaleModding/site/tree/main/content/docs/en/official-documentation/worldgen)

## Generative Noise

Hytale's terrain generation is founded on **density fields** — maps of decimal values used to define terrain shape. Density fields can be built from sources of procedural noise (such as Simplex and Cellular), contextual data, and processing nodes.

## Density and Solidity

Density generates a range of values, typically between 1 and -1:
- **Positive values** = solid terrain
- **Negative values** = empty space (air)
- Density is calculated from the sum: `f(x) = z + y`

## Function Nodes

All density fields can be manipulated with function nodes provided in the node editor. Important transformations:

### Absolute
Makes all negative values positive, creating ridged shapes on noise fields.

### Normalization
Moves the 0 value to a new position and stretches the field to a new range. Used to control what fraction of the field is solid vs empty.

> **Note:** The Hytale Node Editor does not currently support noise visualization, but examples can be found in `HytaleGenerator/Biomes/Examples/`.

## Noise-Based Terrain

A basic terrain shape is created by combining:
1. **Simplex 2D** — 2-dimensional generative noise field
2. **Y-Curve** — 2-dimensional curve drawn between a height differential

This formula creates most of the terrain in Hytale.

## Material Providers

Materials use logical function nodes to determine which block type is placed at each location. These run on:
- **Solid portions** of the terrain field (terrain blocks)
- **Negative portions** (e.g., filling in a water level)

Key concepts:
- **Solidity** splits into Solid and Empty material providers
- **Queue** creates a priority list of materials (top = highest priority)

> **Note:** The Hytale Node Editor sets node priority based on position in the editor, shown as a number in the top right corner.

## Props

Props generate content in specific limited regions. Hytale provides different Prop types for procedurally placing content in the world.

The prop placement pipeline:

```
Positions → Scanner → Pattern → Content Placement
```

| Component | Purpose |
|-----------|---------|
| **Positions** | Provides candidate locations for scanning |
| **Scanner** | Defines an area/column around each position to search |
| **Pattern** | Validates positions based on world material composition |
