# Prop Placement Nodes Reference (Props, Positions, Scanners, Assignments, Directionality)

> **Source:** [Official Hytale World Generation Documentation](https://github.com/HytaleModding/site/tree/main/content/docs/en/official-documentation/worldgen)

These node categories work together in a pipeline to place content in the world:

```
Positions (where to look) → Scanner (how to search) → Pattern (what's valid) → Prop (what to place)
                                                                                  ↑
                                                                            Assignments (which prop)
                                                                            Directionality (facing)
```

---

## Props

Localized content that reads and writes to the world.

### Box
Testing/debugging prop that generates a box. Uses Pattern and Scanner.
- **Parameters:** `Range` (3D int vector: X, Y, Z distances), `BoxBlockType` (block type), `Pattern` (Pattern slot), `Scanner` (Scanner slot)

### Density
Generates a prop from a Density field and MaterialProvider. Uses Pattern, Scanner, and BlockMask.
- **Parameters:** `Range` (3D int vector), `PlacementMask` (BlockMask slot), `Pattern` (Pattern slot), `Scanner` (Scanner slot), `Density` (Density slot — shape), `Material` (MaterialProvider slot — block types)

### Prefab
Places a Prefab structure in a suitable spot. Uses Directionality, Scanner, and BlockMask.
- **Parameters:**
  - `WeightedPrefabPaths` — list of weighted entries: `Path` (folder/file), `Weight` (float), `LegacyPath` (boolean — true: `Server/World/Default/Prefabs/`, false: `Server/WorldgenAlt/Prefabs/`)
  - `Directionality` (slot — controls facing)
  - `Scanner` (Scanner slot)
  - `BlockMask` (BlockMask slot)
  - `MoldingDirection` (optional: "UP", "DOWN", or "NONE" default)
  - `MoldingChildren` (optional boolean — children also mold)
  - `MoldingScanner` (optional Scanner slot — use LinearScanner with Local=true, ResultCap=1)
  - `MoldingPattern` (optional Pattern slot — finds surface to mold to)
  - `LoadEntities` (optional boolean — load entities from prefabs)

### Column
Prop contained within a single column.
- **Parameters:** `ColumnBlocks` (list of `BlockType` string + `Y` int relative to origin), `Directionality` (slot), `Scanner` (Scanner slot), `BlockMask` (optional)

### Cluster
Places a cluster of Column Props around an origin. Density of placement varies by distance from origin.
- **Parameters:** `Range` (int — distance from origin, start: 10), `DistanceCurve` (curve — density by distance), `Seed` (string), `Pattern` (optional), `Scanner` (optional), `WeightedProps` (list of `Weight` float + `ColumnProp` slot)
- **Important:** Column Props in a Cluster must use Scanner/Pattern that operate within a single column.

### Union
Places all props in the list at the same position.
- **Parameters:** `Props` (list of prop slots)

### Offset
Offsets child Prop's position.
- **Parameters:** `Offset` (3D int vector), `Prop` (Prop slot)

### Weighted
Picks which Prop to place based on seed and weights.
- **Parameters:** `Entries` (list of `Weight` float + `Prop` slot), `Seed` (string)

### Queue
Places first Prop in queue that can be placed (based on its Scanner/Pattern config).
- **Parameters:** `Queue` (ordered list of Prop slots, first = highest priority)

### PondFiller
Fills terrain depressions with material (e.g., water). **Performance note:** impact depends on bounding box size — optimize per use case.
- **Parameters:** `BoundingMin` (3D point — lowest corner), `BoundingMax` (3D point — greatest corner), `BarrierBlockSet` (BlockSet slot — solid terrain types), `FillMaterial` (MaterialProvider slot — fill blocks), `Pattern` (Pattern slot), `Scanner` (Scanner slot)

### Imported
Imports an exported Prop.
- **Parameters:** `Name` (string)

---

## Positions Provider

Defines infinite 3D position fields used by Props and Density nodes.

### Mesh2D
Generates a mesh of random points on a 2D plane.
- **Parameters:** `PointGenerator` (slot), `PointsY` (vertical Y position)
- **PointGenerator Parameters:** `Jitter` (0-0.5, start: 0.2), `ScaleX`/`ScaleY`/`ScaleZ` (positive decimals), `Seed` (string)

### Mesh3D
Generates a mesh of random points in 3D space.
- **Parameters:** `PointGenerator` (slot)

### List
Static list of positions in world coordinates.
- **Parameters:** `Positions` (list of X, Y, Z integers)

### Anchor
Anchors child Positions to contextual Anchor point.
- **Parameters:** `Reverse` (boolean — reverses back to world origin)

### Sphere
Masks out positions farther than Range from origin.
- **Parameters:** `Range` (decimal — max distance)

### FieldFunction
Masks positions using a Density field and delimiters.
- **Parameters:** `FieldFunction` (Density slot), `Delimiters` (list with `Min`/`Max`), `Positions` (slot)

### Occurrence
Discards positions based on Density field probability.
- Density ≤ 0 → 0% chance kept; Density ≥ 1 → 100% kept; between = proportional
- **Parameters:** `FieldFunction` (Density slot), `Seed` (string), `Positions` (slot)

### Offset
Offsets positions by a vector.
- **Parameters:** `OffsetX`, `OffsetY`, `OffsetZ` (decimals), `Positions` (slot)

### BaseHeight
Vertically offsets positions by BaseHeight amount. Positions outside the Y region are discarded.
- **Parameters:** `BaseHeightName` (string), `MaxYRead` (decimal — exclusive), `MinYRead` (decimal — inclusive)

### Union
Combines all positions into one field.
- **Parameters:** `Positions` (list of slots)

### SimpleHorizontal
Keeps only positions within a Y range.
- **Parameters:** `RangeY` (range), `Positions` (slot)

### Cache
Caches output in 3D sections. Useful for expensive Positions trees queried multiple times.
- **Parameters:** `SectionsSize` (int > 0, start: 32), `CacheSize` (int ≥ 0, start: 50; 0 = no cache), `Positions` (slot)
- **Tip:** Place close to the root of Positions tree.

### Imported
Imports an exported PositionProvider.
- **Parameters:** `Name` (string)

---

## Scanners

Scan local parts of the world for valid positions matching a Pattern.

### Origin
Only scans the origin position.
- No parameters.

### ColumnLinear
Scans a column of blocks linearly (top-down or bottom-up).
- **Parameters:** `MaxY` (int — upper exclusive), `MinY` (int — lower inclusive), `RelativeToPosition` (boolean — relative to scan origin Y instead of world Y:0), `BaseHeightName` (optional string — overrides RelativeToPosition), `TopDownOrder` (boolean), `ResultCap` (positive int — max valid results)

### ColumnRandom
Scans a column randomly with two strategies.
- **Parameters:** `MaxY` (int), `MinY` (int), `Strategy` ("DART_THROW" — random samples, good for many valid positions; or "PICK_VALID" — finds all valid then picks, good for few valid positions), `Seed` (string), `ResultCap` (int), `RelativeToPosition` (boolean), `BaseHeightName` (optional string)

### Area
Scans an expanding area around the origin using a child Scanner.
- **Parameters:** `ScanRange` (int ≥ 0 — distance in blocks, start: 0), `ScanShape` ("CIRCLE" or "SQUARE"), `ResultCap` (int), `ChildScanner` (Scanner slot — applied to each column)

### Imported
Imports an exported Scanner.
- **Parameters:** `Name` (string)

---

## Assignments

Assign Props to each position in a Positions field.

### Constant
Assigns one Prop to all positions.
- **Parameters:** `Prop` (Prop slot)

### FieldFunction
Selects which props to assign based on a Density field and value delimiters.
- **Parameters:** `FieldFunction` (Density slot), `Delimiters` (list with `Min`/`Max` + `Assignments` slot)

### Sandwich
Selects props based on vertical (world Y) position delimiters.
- **Parameters:** `Delimiters` (list with `MinY`/`MaxY` + `Assignments` slot)

### Weighted
Picks props randomly based on weights and seed.
- **Parameters:** `Seed` (string), `SkipChance` (0-1 — chance to skip), `WeightedAssignments` (list of weighted Assignments slots)

### Imported
Imports an exported Assignments.
- **Parameters:** `Name` (string)

---

## Directionality

Determines the direction (rotation) to place a Prop.

### Static
Fixed direction.
- **Parameters:** `Rotation` (int: 0, 90, 180, or 270; default 0), `Pattern` (Pattern slot — locates position, doesn't affect direction)

### Random
Random direction based on seed.
- **Parameters:** `Seed` (string), `Pattern` (Pattern slot)

### Pattern (Directionality Type)
Direction based on environment. Links directions to Pattern assets for each cardinal direction.
- **Parameters:** `InitialDirection` (string: "N", "S", "E", "W" — prop's original facing), `NorthPattern`/`SouthPattern`/`EastPattern`/`WestPattern` (Pattern slots), `Seed` (string — for tie-breaking)

---

## Vector Provider

Defines 3D decimal vectors procedurally.

### Constant
Fixed vector.
- **Parameters:** `Vector` (3D decimal vector)

### DensityGradient
Gradient of a Density field — shows direction/rate of density change.
- **Parameters:** `SampleDistance` (positive decimal, optimal: 1.0), `Density` (Density slot)

### Cache
Caches vector per position. Only use if downstream VectorProvider is expensive and queried multiple times.
- **Parameters:** `SampleDistance` (decimal), `Density` (Density slot)

### Exported
Exports a VectorProvider. SingleInstance shares across all importers.
- **Parameters:** `SingleInstance` (boolean), `VectorProvider` (slot)
- **Note:** Experimental feature.

### Imported
Imports an exported VectorProvider.
- **Parameters:** `Name` (string)
