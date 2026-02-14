# Density Nodes Reference

> **Source:** [Official Hytale World Generation Documentation](https://github.com/HytaleModding/site/tree/main/content/docs/en/official-documentation/worldgen)

Density nodes define 3D decimal value fields used to shape terrain. They are composed in trees where outputs feed into inputs.

## Noise Generators

### Constant
Outputs a constant value.
- **Parameters:** `Value` (decimal)
- **Inputs:** 0

### SimplexNoise2D
Outputs [-1, 1] from a 2D simplex noise field varying on x/z plane. Automatically caches per x/z column.
- **Parameters:** `Lacunarity` (float, start: 2.0), `Persistence` (float, start: 0.5), `Scale` (float, start: 50), `Octaves` (int, start: 4), `Seed` (string)
- **Inputs:** 0

### SimplexNoise3D
Outputs [-1, 1] from a 3D simplex noise field varying on x/y/z space.
- **Parameters:** `Lacunarity` (float, start: 2.0), `Persistence` (float, start: 0.5), `ScaleXZ` (float, start: 50), `ScaleY` (float, start: 50), `Octaves` (int, start: 4), `Seed` (string)
- **Inputs:** 0

### PositionsCellNoise
Produces a 2D/3D density field based on distance from a Positions field. Supports advanced cell noise with configurable ReturnTypes.
- **Parameters:** `Positions` (positions slot), `ReturnType` (see below), `DistanceFunction` (Euclidean or Manhattan), `MaxDistance` (float — set slightly over half the distance between position points)
- **Inputs:** 0

**ReturnTypes:**
| Type | Description | Extra Parameters |
|------|-------------|------------------|
| CellValue | Constant density inside each cell sampled from a Density field | `Density` (slot), `DefaultValue` (float) |
| Density | Cell populated with a Density field picked from Delimiters by ChoiceDensity | `Density` (slot), `DefaultValue` (float) |
| Curve | Value defined by a Curve asset based on distance from Positions | `Curve` (curve slot) |
| Distance | Traditional CellNoise distance return | None |
| Distance2 | Traditional CellNoise distance2 return | None |
| Distance2Add | Sum of two nearest distances | None |
| Distance2Sub | Difference of two nearest distances | None |
| Distance2Mul | Product of two nearest distances | None |
| Distance2Div | Division of two nearest distances | None |

**DistanceFunction:** `Euclidean` or `Manhattan` (no parameters)

## Shape Generators

### Distance
Value based on distance from origin {0,0,0}.
- **Parameters:** `Curve` (curve slot — maps distance to density)
- **Inputs:** 0

### Ellipsoid
Deformed sphere with scale, rotation, and spin.
- **Parameters:** `Curve` (curve slot), `Scale` (3D vector slot), `X/Y/Z` (floats), `Spin` (degrees around Y axis)
- **Inputs:** 0
- **Deformation order:** 1. Scale → 2. Align Y axis → 3. Spin

### Cube
Density based on distance from origin axis.
- **Parameters:** `Curve` (curve slot)
- **Inputs:** 0

### Cuboid
Deformed cube with scale, rotation, and spin.
- **Parameters:** `Curve` (curve slot), `Scale` (3D vector slot), `X/Y/Z` (floats), `Spin` (degrees), `NewYAxis` (Point3D slot)
- **Inputs:** 0
- **Deformation order:** 1. Scale → 2. Align Y axis → 3. Spin

### Cylinder
Cylindrical shape with axial and radial curves.
- **Parameters:** `AxialCurve` (curve — density along Y axis), `RadialCurve` (curve — density by distance from Y axis), `Spin` (degrees), `NewYAxis` (Point3D slot)
- **Inputs:** 0

### Axis
Density based on distance from a line through origin.
- **Parameters:** `Axis` (3D vector slot), `X/Y/Z` (floats), `Curve` (curve slot), `IsAnchored` (boolean — uses closest anchor)
- **Inputs:** 0

### Plane
Density based on distance from a user-defined plane through origin.
- **Parameters:** `PlaneNormal` (3D vector slot), `X/Y/Z` (floats), `Curve` (curve slot)
- **Inputs:** 0

### Shell
Density regions of a shell around origin based on direction and distance.
- **Parameters:** `Axis` (3D vector slot), `X/Y/Z` (floats), `Mirror` (boolean), `AngleCurve` (curve slot), `DistanceCurve` (curve slot)
- **Inputs:** 0

## Math Operations

### Sum
Output is the sum of all inputs.
- **Inputs:** [0, ∞)

### Multiplier
Output is the product of all inputs. **Performance tip:** Skips remaining inputs after a 0 value — order with cheapest mask first for optimization (up to ~40% improvement).
- **Inputs:** [0, ∞)

### Max / Min
Greatest/smallest value of all inputs (0 if no inputs).
- **Inputs:** [0, ∞)

### SmoothMax / SmoothMin
Smoothed maximum/minimum between two inputs.
- **Parameters:** `Range` (float, start: 0.2 — greater = more smoothing)
- **Inputs:** 2

### Mix
Mixes two inputs controlled by a third gauge input.
- Gauge ≤ 0.0 → only Density A; Gauge ≥ 1.0 → only Density B; between = proportional mix
- **Inputs:** 3 (Density A, Density B, Gauge)

### MultiMix
Mixes multiple inputs with a Gauge (last input). Keys pin inputs to gauge values.
- **Inputs:** unlimited (last is Gauge)

### Clamp
Ensures output is within [WallA, WallB].
- **Parameters:** `WallA` (float), `WallB` (float)
- **Inputs:** 1

### SmoothClamp
Like Clamp but with smooth transition at limits.
- **Parameters:** `WallA` (float), `WallB` (float), `Range` (float — larger = smoother)
- **Inputs:** 1

### Abs
Absolute value of input.
- **Inputs:** 1

### Sqrt
Square root (modified for negative inputs to always return useful values).
- **Inputs:** 1

### Inverter
Input × -1.
- **Inputs:** 1

### Pow
Input raised to exponent power (modified for negative inputs).
- **Parameters:** `Exponent` (float, start: 2)
- **Inputs:** 1

### CurveMapper
Maps input through a Curve.
- **Parameters:** `Curve` (curve slot)
- **Inputs:** 1

### Normalizer
Rescales input from one range to another.
- **Parameters:** `FromMin`, `FromMax`, `ToMin`, `ToMax` (all floats)
- **Inputs:** 1

## Coordinate & Cache

### XValue / YValue / ZValue
Outputs the local X/Y/Z coordinate.
- **Inputs:** 0

### XOverride / YOverride / ZOverride
Overrides the X/Y/Z coordinate that the input sees.
- **Inputs:** 1

### Cache
Caches input for current coordinates.
- **Parameters:** `Capacity` (int, safe value: 3)
- **Inputs:** 1

## Transform Nodes

### Scale
Stretches/contracts the input density field per axis. Values > 1 stretch, < 1 contract, < 0 flip.
- **Parameters:** `X`, `Y`, `Z` (floats)
- **Inputs:** 1
- **Tip:** Combine with Rotator nodes for non-orthogonal scaling

### Rotator
Aligns input field's Y axis to a new axis and spins.
- **Parameters:** `NewYAxis` (3D vector), `X/Y/Z` (floats), `SpinAngle` (degrees)
- **Inputs:** 1

### Slider
Slides input field in a direction.
- **Parameters:** `SlideX`, `SlideY`, `SlideZ` (floats)
- **Inputs:** 1

### Anchor
Anchors the child field's origin to the contextual Anchor (e.g., cell center from PositionsCellNoise Density ReturnType).
- **Parameters:** `Reverse` (boolean — if true, moves origin back to world origin)
- **Inputs:** 1

## Warp Nodes

### GradientWarp
Warps first input based on gradient of second input. Relatively expensive — minimize use space. Incorporates Cache2D.
- **Parameters:** `SampleRange` (float, recommend 1), `WarpFactor` (float — larger = more warping), `2D` (boolean — uses internal Cache2D), `YFor2D` (float, default 0)
- **Inputs:** 2 (field to warp, warping field)

### FastGradientWarp
Faster implementation using internal simplex noise generator.
- **Parameters:** `WarpScale` (float), `WarpLacunarity` (float), `WarpPersistence` (float), `WarpOctaves` (int), `WarpFactor` (float — max warp distance)
- **Inputs:** 1

### VectorWarp
Warps input along a provided vector. Warp amount = second input value × WarpFactor.
- **Parameters:** `WarpFactor` (float), `WarpVector` (vector slot), `X/Y/Z` (floats)
- **Inputs:** 2 (field to warp, warping intensity field)

### PositionsPinch
Pinches or expands density field around Positions. PinchCurve defines effect shape, MaxDistance defines range.
- **Parameters:** `Positions` (slot), `PinchCurve` (curve slot), `MaxDistance` (float), `NormalizeDistance` (boolean, default true), `HorizontalPinch` (boolean, default false), `PositionsMaxY`, `PositionsMinY` (floats)
- **Inputs:** 1

### PositionsTwist
Twists density field around Positions. TwistCurve output is in degrees (360 = full rotation).
- **Parameters:** `Positions` (slot), `TwistCurve` (curve slot), `TwistAxis` (vector slot), `X/Y/Z` (floats), `MaxDistance` (float), `NormalizeDistance` (boolean, default true)
- **Inputs:** 1

## Context Nodes

### Angle
Angle in degrees between two vectors.
- **Parameters:** `Vector` (3D vector), `VectorProvider` (procedural vector)
- **Inputs:** 0

### DistanceToBiomeEdge
Outputs distance to nearest biome edge in blocks.
- **Inputs:** 0

### Terrain
Outputs interpolated terrain Density. **Only for MaterialProvider nodes — not for Terrain Density nodes.**
- **Inputs:** 0

### BaseHeight
References a BaseHeight from WorldStructure.
- **Parameters:** `BaseHeightName` (string), `Distance` (boolean — false: raw Y coordinate, true: distance from BaseHeight)
- **Inputs:** 0

## Branching Nodes

### Switch
Switches between Density branches based on contextual SwitchState string.
- **Parameters:** `SwitchCases` (list of case slots with `CaseState` string + `Density` slot)
- **Inputs:** 1

### SwitchState
Sets the contextual SwitchState for downstream branches.
- **Parameters:** `SwitchState` (string)
- **Inputs:** 1

## Import/Export

### Imported
Imports an exported Density asset.
- **Parameters:** `Name` (string)

### Exported
Exports a Density field. `SingleInstance` shares the exported tree across all importers (useful for cache optimization).
- **Parameters:** `SingleInstance` (boolean), `Density` (slot)
- **Inputs:** 1
- **Note:** Experimental feature — may cause unexpected behaviors if misused.
