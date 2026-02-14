---
name: hytale-blocks
description: Documents how to create custom blocks in Hytale plugins using asset packs and JSON definitions. Use when creating blocks, defining block JSON, configuring block textures, materials, gathering, block types, or setting up block asset folder structure. Triggers - block, create block, custom block, BlockType, block JSON, block definition, block texture, block material, DrawType, Gathering, block creation, asset pack, IncludesAssetPack, block item, Cube block, block sound, block particle.
---

# Hytale Custom Blocks

Reference for creating custom blocks in Hytale plugins via asset packs and JSON item definitions with `BlockType` configuration.

> **Source:** <https://hytalemodding.dev/en/docs/guides/plugin/creating-block>
> **Related skills:** For block *components* and ECS ticking behavior, see `hytale-ecs`. For items and interactions, see `hytale-items`.

---

## Quick Reference

| Task | Approach |
|------|----------|
| Enable asset packs | Set `"IncludesAssetPack": true` in `manifest.json` |
| Define a block | Create `Server/Item/Items/<name>.json` with a `BlockType` section |
| Set block texture | `"Textures": [{ "All": "BlockTextures/<name>.png" }]` |
| Set block material | `"Material": "Solid"` (or `Liquid`, `NonSolid`, etc.) |
| Set draw type | `"DrawType": "Cube"` (or `Cross`, `Slab`, etc.) |
| Add localized name | `Server/Languages/en-US/items.lang` → `<name>.name = Display Name` |
| Set gathering/breaking | `"Gathering": { "Breaking": { "GatherType": "...", "ItemId": "..." } }` |
| Set block icon | `"Icon": "Icons/ItemsGenerated/<name>.png"` |

---

## Prerequisites

### Enable Asset Packs

Your plugin's `manifest.json` must declare asset pack inclusion:

```json
{
  "IncludesAssetPack": true,
  "dependencies": ["Hytale:EntityModule", "Hytale:BlockModule"]
}
```

### Folder Structure

```
src/main/resources/
├── manifest.json
├── Server/
│   ├── Item/
│   │   └── Items/
│   │       └── my_new_block.json       # Block definition
│   └── Languages/
│       └── en-US/
│           └── items.lang              # Translations
└── Common/
    ├── Icons/                          # Item icons
    ├── Blocks/
    │   └── my_new_block/
    │       └── model.blockymodel       # Block model
    └── BlockTextures/
        └── my_new_block.png            # Block texture
```

---

## Translations

Create `Server/Languages/en-US/items.lang`:

```
my_new_block.name = My New Block
my_new_block.description = My Description
```

> The filename `items` becomes the translation key prefix, so `"items.my_new_block.name"` resolves to `My New Block`.

---

## Block JSON Definition

Create `Server/Item/Items/my_new_block.json`:

```json
{
  "TranslationProperties": {
    "Name": "items.my_new_block.name",
    "Description": "items.my_new_block.description"
  },
  "Id": "My_New_Block",
  "MaxStack": 100,
  "Icon": "Icons/ItemsGenerated/my_new_block.png",
  "Categories": [
    "Blocks.Rocks"
  ],
  "PlayerAnimationsId": "Block",
  "Set": "Rock_Stone",
  "BlockType": {
    "Material": "Solid",
    "DrawType": "Cube",
    "Group": "Stone",
    "Flags": {},
    "Gathering": {
      "Breaking": {
        "GatherType": "Rocks",
        "ItemId": "my_new_block"
      }
    },
    "BlockParticleSetId": "Stone",
    "Textures": [
      {
        "All": "BlockTextures/my_new_block.png"
      }
    ],
    "ParticleColor": "#aeae8c",
    "BlockSoundSetId": "Stone",
    "BlockBreakingDecalId": "Breaking_Decals_Rock"
  },
  "ResourceTypes": [
    {
      "Id": "Rock"
    }
  ]
}
```

---

## BlockType Properties

| Property | Description | Examples |
|----------|-------------|---------|
| `Material` | Physics material type | `"Solid"`, `"Liquid"`, `"NonSolid"` |
| `DrawType` | How the block is rendered | `"Cube"`, `"Cross"`, `"Slab"` |
| `Group` | Block category group | `"Stone"`, `"Wood"`, `"Sand"` |
| `Flags` | Additional block flags | `{}` (empty object for defaults) |
| `Gathering.Breaking.GatherType` | Tool type needed to break | `"Rocks"`, `"Wood"`, `"Sand"` |
| `Gathering.Breaking.ItemId` | Item dropped when broken | ID string matching the block's `Id` |
| `BlockParticleSetId` | Particle effect when breaking | `"Stone"`, `"Wood"`, `"Sand"` |
| `Textures` | Array of texture definitions | See Texture Configuration below |
| `ParticleColor` | Break particle color | Hex color string `"#aeae8c"` |
| `BlockSoundSetId` | Sound set for interactions | `"Stone"`, `"Wood"`, `"Sand"` |
| `BlockBreakingDecalId` | Breaking animation decal | `"Breaking_Decals_Rock"` |

### Texture Configuration

Textures are defined as an array of objects. Use `"All"` to apply one texture to all faces, or specify per-face:

```json
"Textures": [
  {
    "All": "BlockTextures/my_block.png"
  }
]
```

Per-face texturing (when supported):

```json
"Textures": [
  {
    "Top": "BlockTextures/my_block_top.png",
    "Bottom": "BlockTextures/my_block_bottom.png",
    "Side": "BlockTextures/my_block_side.png"
  }
]
```

---

## Item Properties (Top-Level)

These properties are standard item fields that the block also uses:

| Property | Description |
|----------|-------------|
| `TranslationProperties` | `Name` and `Description` translation keys |
| `Id` | Unique identifier for the item/block |
| `MaxStack` | Maximum stack size in inventory |
| `Icon` | Path to inventory icon image |
| `Categories` | Array of category tags (e.g., `"Blocks.Rocks"`) |
| `PlayerAnimationsId` | Animation set when held (e.g., `"Block"`) |
| `Set` | Visual set grouping (e.g., `"Rock_Stone"`) |
| `ResourceTypes` | Array of resource type objects with `Id` field |

---

## Edge Cases & Gotchas

- All referenced files (textures, models, icons) must exist at the specified paths or the block will fail to load
- The `Id` field is case-sensitive and must be unique across all items and blocks
- Translation keys follow the pattern `<lang-filename>.<key>.name` — the `.lang` filename is the prefix
- `IncludesAssetPack` must be `true` in manifest — without it, `Common/` assets are ignored
- Block textures go in `Common/BlockTextures/`, not `Common/Textures/`
- The `ItemId` in `Gathering.Breaking` should match the block's `Id` for the block to drop itself when broken
- Check `lib/Server/` for existing block definitions to see all available property values

```
