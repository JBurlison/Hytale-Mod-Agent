# Item HUD UI Reference

Added in server version **2026.02.26-7681d338c**.

Items can now declare `.ui` HUD overlays directly in their JSON definition. The client automatically shows these UIs when that item is the player's active/held item and hides them when another item is selected. No server-side Java plugin code is needed to manage the lifecycle.

---

## How It Works

1. You create a `.ui` file as normal (in `Common/UI/Custom/`).
2. You reference it in the item's JSON via the `HudUI` array field.
3. The client loads and renders the UI when the item becomes active, and tears it down automatically when the item is deactivated.

This is purely **asset-driven** — the client handles show/hide entirely. Use the standard `CustomUIHud`/`MultipleHUD` Java API only if you need to send dynamic server-driven updates to the HUD content (see [java-api.md](java-api.md)).

---

## Item JSON Field

Add a `HudUI` array to your item JSON file. Each entry has two fields:

| Field  | Type   | Required | Description |
|--------|--------|----------|-------------|
| `Path` | String | Yes      | Path to the `.ui` file, relative to the asset root (same convention as other asset paths) |
| `Type` | Enum   | No       | Render mode — `Hud` (default) or `Legend` |

### `Type` Values

| Value    | Description |
|----------|-------------|
| `Hud`    | Standard HUD overlay drawn on top of the game world |
| `Legend` | Legend-style overlay (e.g., a key/legend panel) |

---

## Minimal Example

**Item JSON** (`src/main/resources/Server/Hyforged/Item/Items/MyItem.json`):

```json
{
  "Id": "Hyforged:MyItem",
  "Icon": "Items/MyItem.png",
  "MaxStack": 1,
  "HudUI": [
    {
      "Path": "Common/UI/Custom/Items/MyItemHud.ui",
      "Type": "Hud"
    }
  ]
}
```

**UI file** (`src/main/resources/Common/UI/Custom/Items/MyItemHud.ui`):

```
$Common.ui

Group #MyItemHud {
    Anchor: { Left: 0.5, CenterX: 0, Right: 0.5, Top: 0.85, CenterY: 0, Bottom: 0.85 };
    Width: 200;
    Height: 40;

    Label #ItemLabel {
        Text: %items.myitem.hud_hint;
        Style: @LabelStyles.Default;
        Anchor: Fill;
    };
};
```

---

## Multiple HUD UIs on One Item

You can attach more than one UI to a single item by adding multiple entries to the `HudUI` array:

```json
"HudUI": [
  {
    "Path": "Common/UI/Custom/Items/MyItemMainHud.ui",
    "Type": "Hud"
  },
  {
    "Path": "Common/UI/Custom/Items/MyItemLegend.ui",
    "Type": "Legend"
  }
]
```

---

## Dynamic / Server-Driven Updates

The item HUD UI is static by default — the client just renders the `.ui` markup. If you need to push live data into it from the server, use the standard `CustomUIHud` + `MultipleHUD` approach alongside the item HUD:

- The item's `HudUI` handles the persistent layout/structure shown when the item is active.
- A server-side `CustomUIHud` (via MHUD) can overlay additional dynamic data.

For fully dynamic item HUDs owned entirely by the server, skip `HudUI` in the item JSON and just use `MultipleHUD` managed by a system that watches the player's active item slot. See [java-api.md](java-api.md) for the MHUD ECS pattern.

---

## Key Constraints

- `HudUI` is an **array** — multiple entries are supported.
- The `Path` follows the same asset path conventions as all other Hytale assets (no leading slash, forward slashes).
- The UI file must be included in your asset pack. Declare it under `IncludesAssetPack` in `manifest.json`. See [assets-and-packaging.md](assets-and-packaging.md).
- The `Type` field defaults to `Hud` if omitted.
- The client manages show/hide automatically; there is no server-side hook to intercept this.

---

## Source Reference

```
com.hypixel.hytale.server.core.asset.type.item.config.ItemHudUI
com.hypixel.hytale.protocol.ItemHudUI
com.hypixel.hytale.protocol.ItemHudUIType  (Hud = 0, Legend = 1)
```

`Item.java` codec:
```java
.addField(
    new KeyedCodec<>("HudUI", new ArrayCodec<>(ItemHudUI.CODEC, ItemHudUI[]::new)),
    (item, s) -> item.hudUI = s,
    item -> item.hudUI
)
```
