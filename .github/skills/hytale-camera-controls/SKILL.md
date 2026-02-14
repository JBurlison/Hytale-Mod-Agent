---
name: hytale-camera-controls
description: Documents Hytale's camera system for customizing player camera via ServerCameraSettings and SetServerCamera packets. Use when creating custom camera modes, top-down cameras, side-scroller cameras, isometric cameras, adjusting zoom distance, camera smoothing, rotation, cursor display, or resetting camera to default. Triggers - camera, ServerCameraSettings, SetServerCamera, ClientCameraView, camera preset, top-down, side-scroller, isometric, camera distance, camera rotation, camera zoom, first person, third person, camera controls, RotationType, MouseInputType, MovementForceRotationType.
---

# Hytale Camera Controls

Use this skill when customizing the player camera in Hytale plugins. The camera is controlled server-side by sending a `SetServerCamera` packet with `ServerCameraSettings` to configure distance, rotation, input mode, movement alignment, and more.

> **Source:** <https://hytalemodding.dev/en/docs/guides/plugin/customizing-camera-controls>

---

## Quick Reference

| Task | How |
|------|-----|
| Set custom camera | Send `SetServerCamera(ClientCameraView.Custom, true, settings)` |
| Reset to default | Send `SetServerCamera(ClientCameraView.Custom, false, null)` |
| Lock camera | Set `isLocked = true` in the packet |
| Top-down view | See Top-Down preset below |
| Side-scroller view | See Side-Scroller preset below |
| Isometric view | See Isometric preset below |
| Prevent wall clipping | Use `PositionDistanceOffsetType.DistanceOffsetRaycast` |

---

## Required Imports

```java
import com.hypixel.hytale.protocol.ApplyLookType;
import com.hypixel.hytale.protocol.ClientCameraView;
import com.hypixel.hytale.protocol.Direction;
import com.hypixel.hytale.protocol.MouseInputType;
import com.hypixel.hytale.protocol.MovementForceRotationType;
import com.hypixel.hytale.protocol.PositionDistanceOffsetType;
import com.hypixel.hytale.protocol.RotationType;
import com.hypixel.hytale.protocol.ServerCameraSettings;
import com.hypixel.hytale.protocol.Vector3f;
import com.hypixel.hytale.protocol.packets.camera.SetServerCamera;
```

---

## The Basics

### Applying Custom Camera Settings

Create a `ServerCameraSettings` object, configure its fields, and send it to the player via a `SetServerCamera` packet:

```java
ServerCameraSettings settings = new ServerCameraSettings();
settings.distance = 10.0f;            // Zoom distance from player
settings.isFirstPerson = false;       // Third-person mode
settings.positionLerpSpeed = 0.2f;    // Smooth camera follow

playerRef.getPacketHandler().writeNoCache(
    new SetServerCamera(ClientCameraView.Custom, true, settings)
);
```

### Resetting to Default Camera

Pass `false` and `null` to restore the default camera:

```java
playerRef.getPacketHandler().writeNoCache(
    new SetServerCamera(ClientCameraView.Custom, false, null)
);
```

---

## Camera Presets

### Top-Down (RTS / ARPG Style)

Source: `com.hypixel.hytale.server.core.command.commands.player.camera.PlayerCameraTopdownCommand`

```java
ServerCameraSettings settings = new ServerCameraSettings();
settings.positionLerpSpeed = 0.2f;
settings.rotationLerpSpeed = 0.2f;
settings.distance = 20.0f;
settings.displayCursor = true;
settings.isFirstPerson = false;
settings.movementForceRotationType = MovementForceRotationType.Custom;
// Align movement with camera yaw (horizontal rotation only)
settings.movementForceRotation = new Direction(-0.7853981634f, 0.0f, 0.0f); // 45° right
settings.eyeOffset = true;
settings.positionDistanceOffsetType = PositionDistanceOffsetType.DistanceOffset;
settings.rotationType = RotationType.Custom;
settings.rotation = new Direction(0.0f, -1.5707964f, 0.0f); // Look straight down
settings.mouseInputType = MouseInputType.LookAtPlane;
settings.planeNormal = new Vector3f(0.0f, 1.0f, 0.0f); // Ground plane

playerRef.getPacketHandler().writeNoCache(
    new SetServerCamera(ClientCameraView.Custom, true, settings)
);
```

### Side-Scroller (2D Platformer Style)

Source: `com.hypixel.hytale.server.core.command.commands.player.camera.PlayerCameraSideScrollerCommand`

```java
ServerCameraSettings settings = new ServerCameraSettings();
settings.positionLerpSpeed = 0.2f;
settings.rotationLerpSpeed = 0.2f;
settings.distance = 15.0f;
settings.displayCursor = true;
settings.isFirstPerson = false;
settings.movementForceRotationType = MovementForceRotationType.Custom;
settings.movementMultiplier = new Vector3f(1.0f, 1.0f, 0.0f); // Lock Z-axis
settings.eyeOffset = true;
settings.positionDistanceOffsetType = PositionDistanceOffsetType.DistanceOffset;
settings.rotationType = RotationType.Custom;
settings.mouseInputType = MouseInputType.LookAtPlane;
settings.planeNormal = new Vector3f(0.0f, 0.0f, 1.0f); // Side plane

playerRef.getPacketHandler().writeNoCache(
    new SetServerCamera(ClientCameraView.Custom, true, settings)
);
```

### Isometric Character Camera (Diablo Style)

```java
ServerCameraSettings settings = new ServerCameraSettings();
settings.positionLerpSpeed = 0.2f;
settings.rotationLerpSpeed = 0.2f;
settings.isFirstPerson = false;
settings.distance = 6f;
settings.allowPitchControls = false;
settings.displayCursor = true;

// Force the camera's rotation to be set by the server
settings.applyLookType = ApplyLookType.Rotation;

// Notify that we provide a custom rotation
settings.rotationType = RotationType.Custom;

// Set the typical isometric rotation
Direction rotation = new Direction(
    (float) Math.toRadians(45f),   // yaw
    (float) Math.toRadians(-35f),  // pitch
    0f                             // roll
);
settings.rotation = rotation;
settings.movementForceRotation = rotation;

playerRef.getPacketHandler().writeNoCache(
    new SetServerCamera(ClientCameraView.Custom, true, settings)
);
```

---

## Common Settings Explained

### Position & Rotation

| Setting | Type | Description |
|---------|------|-------------|
| `positionLerpSpeed` | `float` (0.0–1.0) | How smoothly the camera follows the player. Lower = smoother but slower. |
| `rotationLerpSpeed` | `float` (0.0–1.0) | How smoothly the camera rotates. Lower = smoother but slower. |
| `distance` | `float` | Camera distance from the player. Higher = more zoomed out. |
| `rotation` | `Direction(yaw, pitch, roll)` | Camera angle in **radians**. |
| `rotationType` | `RotationType` | How rotation is calculated. Use `RotationType.Custom` for your own `rotation` value. |

### Movement Alignment

| Setting | Type | Description |
|---------|------|-------------|
| `movementForceRotationType` | `MovementForceRotationType` | `AttachedToHead` = movement follows where player looks; `Custom` = use `movementForceRotation`. |
| `movementForceRotation` | `Direction` | When using `Custom`, sets the direction for W/S movement. Match yaw with camera but keep pitch at 0. |
| `movementMultiplier` | `Vector3f` | Scale movement on each axis. E.g., `(1,1,0)` locks Z-axis for 2D movement. |

### Input & Display

| Setting | Type | Description |
|---------|------|-------------|
| `displayCursor` | `boolean` | Show or hide the mouse cursor. |
| `mouseInputType` | `MouseInputType` | `LookAtPlane` = mouse moves cursor on a plane (top-down); `LookAtTarget` = mouse rotates camera. |
| `planeNormal` | `Vector3f` | For `LookAtPlane`, defines which plane the mouse moves on. `(0,1,0)` = ground plane. |

### Advanced

| Setting | Type | Description |
|---------|------|-------------|
| `positionDistanceOffsetType` | `PositionDistanceOffsetType` | `DistanceOffset` = simple offset; `DistanceOffsetRaycast` = prevents camera clipping through walls. |
| `eyeOffset` | `boolean` | Offset camera from the player's eye position. |
| `isFirstPerson` | `boolean` | `true` for first-person, `false` for third-person. |
| `allowPitchControls` | `boolean` | Allow player to adjust pitch. Set `false` to lock vertical angle. |
| `applyLookType` | `ApplyLookType` | `ApplyLookType.Rotation` forces the camera rotation to be server-controlled. |

---

## Tips

- **Zoom:** Adjust `distance` (higher = further out).
- **Smoothness:** `positionLerpSpeed` and `rotationLerpSpeed` control how quickly the camera catches up to its target.
- **Wall clipping:** Use `PositionDistanceOffsetType.DistanceOffsetRaycast` to prevent the camera from going through walls.
- **Lock camera:** Set `isLocked = true` in the packet to prevent player changes.
- **2D movement:** Set `movementMultiplier` to zero out an axis (e.g., `new Vector3f(1, 1, 0)` for side-scroller).
- **Isometric cameras:** Always set `movementForceRotation` to match camera yaw for proper movement alignment.
- **Angle calculations:** Use `Math.toRadians(degrees)` to convert degrees to radians. All rotation values use radians.
- **Movement alignment:** When using `MovementForceRotationType.Custom`, match the yaw from your camera rotation but keep pitch at `0` so movement stays on the horizontal plane.

---

## Enums Reference

### ClientCameraView
- `ClientCameraView.Custom` — Required view type for applying custom camera settings.

### RotationType
- `RotationType.Custom` — Use the `rotation` value from settings.

### MovementForceRotationType
- `MovementForceRotationType.AttachedToHead` — Movement follows where the player looks.
- `MovementForceRotationType.Custom` — Use `movementForceRotation` to define movement direction.

### MouseInputType
- `MouseInputType.LookAtPlane` — Mouse moves cursor on a defined plane (good for top-down/isometric).
- `MouseInputType.LookAtTarget` — Mouse rotates the camera around the player.

### PositionDistanceOffsetType
- `PositionDistanceOffsetType.DistanceOffset` — Simple distance offset from player.
- `PositionDistanceOffsetType.DistanceOffsetRaycast` — Distance offset with raycast to prevent wall clipping.

### ApplyLookType
- `ApplyLookType.Rotation` — Server controls the camera rotation.
