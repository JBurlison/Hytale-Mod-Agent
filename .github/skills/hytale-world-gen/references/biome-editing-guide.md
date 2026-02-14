# Biome Editing Guide

> **Source:** [Official Hytale World Generation Documentation](https://github.com/HytaleModding/site/tree/main/content/docs/en/official-documentation/worldgen)

## Asset Locations

World generation assets are in the `HytaleGenerator` directory within server assets:

```
Server/HytaleGenerator/
├── WorldStructure/   # Generator files defining which biomes spawn together
├── Biomes/           # Biome assets with content configurations
├── Density/          # Reusable density assets referenced by other assets
└── Assignments/      # Prop assignment assets referenced by biome assets
```

## World Instances

Instances are separate worlds players can join via `/instances`. Each has an `Instance.bson` in `Server/Instances/`:

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

Create custom instances by duplicating the basic Instance config and changing `WorldStructure` to your custom asset name.

## Editing Biomes

The Hytale Node Editor is used for editing world generation assets. Access it in-game from the Content Creation menu (press Tab).

Open biomes via the file menu, navigating to the Biomes directory:
```
Server/HytaleGenerator/Biomes/Basic.json
```

> **Requirement:** You must have an Asset Pack with a Biome.

## Biome Asset Structure

Every biome has a root Biome node that splits into 5 components:

### 1. Terrain
Mathematical function nodes that calculate the physical shape of the biome's terrain. Uses Density nodes.

### 2. Material Provider
Logical nodes determining what block types make up the biome's terrain. Uses Material Provider nodes with conditions and layers.

### 3. Props
Object function nodes that add objects such as prefabs to the terrain. Configure content like trees, POIs, grass, etc. Uses Props, Scanners, Patterns, Positions, and Assignments.

### 4. Environment Provider
Logical nodes determining the environment asset at a given coordinate within the biome. Controls weather, NPC spawns, and ambient sounds.

### 5. Tint Provider
Logical function nodes that determine a color code used by certain material types (typically grasses and soils).

> **Note:** Each biome is self-contained — it controls everything within its boundaries. The only exception is Base Heights.

## Previewing Changes

| Method | Command/Action | Description |
|--------|----------------|-------------|
| Viewport | `/viewport --radius 5` | Live-reloads an area around the player as you edit |
| New Instance | `/instances spawn <instance>` | Creates a new world showing latest changes |
| Fly South | — | New chunks generate with the latest changes |

## Asset Packs

An Asset Pack is a zip or folder with a `manifest.json` inside. All Asset Packs require a manifest, and assets must be in the correct folder structure.

```json
{
  "Group": "My Group",
  "Name": "Pack Example",
  "Version": "1.0.0",
  "Description": "An Example Asset Pack",
  "Authors": [{"Name": "Me", "Email": "", "Url": ""}],
  "Website": "",
  "Dependencies": {},
  "OptionalDependencies": {},
  "LoadBefore": {},
  "DisabledByDefault": false,
  "IncludesAssetPack": false,
  "SubPlugins": []
}
```

### Storage Locations

| Location | Path |
|----------|------|
| Global mods | `C:\Users\<user>\AppData\Roaming\Hytale\UserData\Mods` |
| Per-world | `C:\Users\<user>\AppData\Roaming\Hytale\UserData\Saves\<world>\mods` |

- Asset Packs created in-game with the Asset Editor are stored per-world. Copy to the global Mods folder for use in other worlds.
- Asset Packs exist entirely on the server — only the server/host needs them installed.
- Assets inside packs override base game assets. You can also add new assets.
- Can be downloaded from hosting sites such as CurseForge.
