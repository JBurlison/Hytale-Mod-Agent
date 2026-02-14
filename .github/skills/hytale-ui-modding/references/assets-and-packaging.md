# Assets and Packaging

## UI assets

- Images must use the @2x.png suffix.
- Store assets under Common/UI/Custom/.
- Reference them with TexturePath: "MyImage.png".

Example:

```ui
Sprite {
  TexturePath: "Icons/MyIcon.png";
}
```

Files on disk:

- src/main/resources/Common/UI/Custom/Icons/MyIcon@2x.png

## manifest.json

Ensure IncludesAssetPack is enabled so custom UI assets are shipped to clients.

## UIPath rules

Paths are relative to the current .ui file:

- "MyButton.png" resolves next to the .ui file
- "../MyButton.png" goes up one folder
