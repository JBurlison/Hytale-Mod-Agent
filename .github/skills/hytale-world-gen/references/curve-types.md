# Curve Types Reference

> **Source:** [Official Hytale World Generation Documentation](https://github.com/HytaleModding/site/tree/main/content/docs/en/official-documentation/worldgen)

Curves map decimal values to other decimal values (f(x) = y). Used throughout world generation for value transformation.

## Base Curves

### Manual
Plot points connected with straight lines. Function is constant before first point and after last point.
- **Parameters:** List of {x, y} points

### DistanceExponential
As input approaches Range, outputs 0.0. At input 0.0, outputs 1.0. Shape controlled by Exponent.
- **Parameters:** `Exponent` (affects shape), `Range` (value after which output is constant 0.0)

### DistanceS
Combines two DistanceExponent curves for an S-shaped profile. At input 0.0, outputs 1.0. At Range, outputs 0.0.
- **Parameters:** `ExponentA` (float > 0 — first half shape), `ExponentB` (float > 0 — second half shape), `Range` (float > 0), `Transition` (optional 0-1, default 1.0 — lower = more sudden transition), `TransitionSmooth` (optional 0-1, default 1.0)

## Limit/Clamp Curves

### Ceiling
Caps the output of a child curve.
- **Parameters:** `Ceiling` (decimal — max output), `Curve` (curve slot)

### Floor
Sets a minimum for the output of a child curve.
- **Parameters:** `Floor` (decimal — min output), `Curve` (curve slot)

### SmoothCeiling
Caps output with smooth approach to the limit.
- **Parameters:** `Ceiling` (decimal), `Range` (decimal ≥ 0 — smoothing amount, start: ¼ of child range), `Curve` (curve slot)

### SmoothFloor
Sets smooth minimum for output.
- **Parameters:** `Floor` (decimal), `Range` (decimal ≥ 0), `Curve` (curve slot)

### SmoothClamp
Limits output within walls with smooth transitions.
- **Parameters:** `WallA` (decimal), `WallB` (decimal), `Range` (decimal ≥ 0), `Curve` (curve slot)

### Clamp
Hard clamp between two walls.
- **Parameters:** `WallA` (decimal), `WallB` (decimal), `Curve` (curve slot)

## Combination Curves

### SmoothMax
Smoothed maximum of two curves.
- **Parameters:** `Range` (decimal ≥ 0 — start: ¼ of child range), `CurveA` (curve slot), `CurveB` (curve slot)

### SmoothMin
Smoothed minimum of two curves.
- **Parameters:** `Range` (decimal ≥ 0), `CurveA` (curve slot), `CurveB` (curve slot)

### Max
Maximum value of all child curves.
- **Parameters:** `Curves` (list of curve slots)

### Min
Minimum value of all child curves.
- **Parameters:** `Curves` (list of curve slots)

### Multiplier
Product of all child curves.
- **Parameters:** `Curves` (list of curve slots)

### Sum
Sum of all child curves.
- **Parameters:** `Curves` (list of curve slots)

## Logic/Transform Curves

### Inverter
Positive → negative and vice versa.
- **Parameters:** `Curve` (curve slot)

### Not
Logical NOT: when child outputs 1 → outputs 0; when 0 → outputs 1; scaled in between.
- **Parameters:** `Curve` (curve slot)

## Import

### Imported
Imports an exported Curve.
- **Parameters:** `Name` (string — the exported Density asset name)
