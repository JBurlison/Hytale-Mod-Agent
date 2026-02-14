# Terrain Nodes Reference (Patterns, Material Providers, Block Mask)

> **Source:** [Official Hytale World Generation Documentation](https://github.com/HytaleModding/site/tree/main/content/docs/en/official-documentation/worldgen)

---

## Patterns

Patterns validate world locations based on material composition and other criteria. Used by Props and Scanners to find valid positions.

### BlockType
Checks against the block's material.
- **Parameters:** `Material` (block material name)

### BlockSet
Checks if block material belongs to a BlockSet.
- **Parameters:** `BlockSet` (slot)

### Offset
Offsets the child Pattern by a vector.
- **Parameters:** `Pattern` (Pattern slot), `Offset` (3D integer vector)

### Floor
Checks for a floor below the position.
- **Parameters:** `Floor` (Pattern slot — validates block under origin), `Origin` (Pattern slot — validates at origin)

### Ceiling
Checks for a ceiling above the position.
- **Parameters:** `Ceiling` (Pattern slot — validates block above origin), `Origin` (Pattern slot — validates at origin)

### Wall
Checks for a wall next to the position. Supports N/S/E/W directions.
- **Parameters:** `Wall` (Pattern slot — validates adjacent block), `Origin` (Pattern slot), `Directions` (list: "N", "S", "E", "W"), `RequireAllDirections` (boolean)

### Surface
Validates a transition from one set of materials to another (e.g., soil floor in air).
- **Parameters:** `Surface` (Pattern slot), `Medium` (Pattern slot), `SurfaceRadius` (decimal ≥ 0), `MediumRadius` (decimal ≥ 0), `SurfaceGap` (int ≥ 0), `MediumGap` (int ≥ 0), `Facings` (list: "N","S","E","W","U","D"), `RequireAllFacings` (boolean)

### Gap
Validates a space between two anchors (e.g., for bridge placement).
- **Parameters:** `GapSize` (decimal ≥ 0), `AnchorSize` (decimal ≥ 0), `AnchorRoughness` (decimal ≥ 0, start: 1), `DepthDown` (int ≥ 0), `DepthUp` (int ≥ 0), `Angles` (list of degrees, 0=Z axis, 90=X axis), `GapPattern` (Pattern slot), `AnchorPattern` (Pattern slot)

### Cuboid
Defines a cuboid region relative to origin. Validates if all inner positions pass SubPattern.
- **Parameters:** `Min` (3D point — inclusive min), `Max` (3D point — inclusive max), `SubPattern` (Pattern slot)

### And / Or / Not
Logical operators combining patterns.
- **And Parameters:** `Patterns` (list of Pattern slots) — all must validate
- **Or Parameters:** `Patterns` (list of Pattern slots) — at least one must validate
- **Not Parameters:** `Pattern` (single Pattern slot) — validates where nested does not

### FieldFunction
Validates if Density field value at position is within delimiters. **Performance note:** expensive — place last in Pattern hierarchy.
- **Parameters:** `FieldFunction` (Density slot), `Delimiters` (list with `Min`/`Max` decimal bounds)

### Imported
Imports an exported Pattern.
- **Parameters:** `Name` (string)

---

## Material Providers

Determine which block type to place at each position.

### Constant
One constant block type.
- **Parameters:** `BlockType` (string, e.g. "Rock_Stone")

### Solidity
Splits into Solid and Empty terrain blocks.
- **Parameters:** `Solid` (Material Provider slot), `Empty` (Material Provider slot)

### Queue
Priority queue of Material Providers. First slot to provide a block wins.
- **Parameters:** `Queue` (list of Material Provider slots, top = highest priority)

### SimpleHorizontal
Applies child Material Provider on a vertical range. If BaseHeight provided, Y values are relative to it.
- **Parameters:** `TopY` (int), `Top BaseHeight` (string, optional), `BottomY` (int), `Bottom BaseHeight` (string, optional), `Material` (Material Provider slot)

### Striped
Applies Material Provider on horizontal stripes of varying thickness.
- **Parameters:** `Stripes` (list with `TopY`/`BottomY` ints, inclusive), `Material` (Material Provider slot)

### Weighted
Picks Material Provider from weighted list.
- **Parameters:** `Seed` (string), `SkipChance` (0-1 — % of blocks skipped), `WeightedMaterials` (list with `Weight`/`Material` entries)

### FieldFunction
Selects 3D region using a noise function and value delimiters.
- **Parameters:** `FieldFunction` (Density slot — shares seeds with terrain density), `Delimiters` (list with `From`/`To` floats + `Material` slot; higher in list = higher priority)

### SpaceAndDepth
Places layers of blocks on floor or ceiling surfaces. Layers pile like a cake into the surface depth.
- **Parameters:** `LayerContext` (string: "DEPTH_INTO_FLOOR" or "DEPTH_INTO_CEILING"), `MaxExpectedDepth` (int — sum of max thicknesses of all layers), `Condition` (optional Condition slot), `Layers` (list of Layer objects)

#### Condition Types
Conditions check environment validity before applying material.

| Type | Parameters | Description |
|------|-----------|-------------|
| EqualsCondition | `ContextToCheck`, `Value` (int) | Context equals value |
| GreaterThanCondition | `ContextToCheck`, `Threshold` (int) | Context > threshold |
| SmallerThanCondition | `ContextToCheck`, `Threshold` (int) | Context < threshold |
| AndCondition | `Conditions` (list) | All must validate |
| OrCondition | `Conditions` (list) | Any must validate |
| NotCondition | `Condition` (single slot) | Inverts result |
| AlwaysTrueCondition | None | Always validates |

Context values: `SPACE_ABOVE_FLOOR`, `SPACE_BELOW_CEILING`

#### Layer Types

| Type | Parameters | Description |
|------|-----------|-------------|
| ConstantThickness | `Material` (slot), `Thickness` (int ≥ 0) | Same thickness everywhere |
| RangeThickness | `Material` (slot), `RangeMin`/`RangeMax` (int ≥ 0), `Seed` | Random thickness in range |
| WeightedThickness | `Material` (slot), `PossibleThicknesses` (weighted list), `Seed` | Weighted random thickness |
| NoiseThickness | `Material` (slot), `ThicknessFunctionXZ` (Density slot — 2D) | Thickness from noise function |

### Imported
Imports an exported MaterialProvider.
- **Parameters:** `Name` (string)

---

## Block Mask

Controls which materials can replace which other materials when placing content.

- **Source Material:** The material being placed
- **Destination Material:** The material already in the world

### Rules

| Rule | Description |
|------|-------------|
| **DontPlace** | BlockSet — source materials that will not be placed |
| **DontReplace** | BlockSet — destination materials that cannot be replaced (default) |
| **Advanced** | List of override rules with `Source` BlockSet and `CanReplace` BlockSet |

Advanced rules override DontReplace for specific source/destination combinations.

**Parameters:** `DontPlace` (BlockSet slot), `DontReplace` (BlockSet slot), `Advanced` (list of rules)
