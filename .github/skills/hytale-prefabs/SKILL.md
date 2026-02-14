---
name: hytale-prefabs
description: Documents Hytale's prefab system for creating, saving, loading, and managing reusable structures via in-game commands. Use when creating prefabs, saving structures, loading prefabs, editing prefab worlds, or working with reusable structures. Triggers - prefab, prefab system, /prefab, /editprefab, reusable structure, structure, save structure, load structure, prefab world, prefab editing, prefab commands, paste brush, selection brush.
---

# Hytale Prefabs

Reference for Hytale's prefab system — creating, saving, loading, and managing reusable structures via in-game commands.

> **Source:** <https://hytalemodding.dev/en/docs/guides/prefabs>
> **Related skills:** For spawning entities within prefabs, see `hytale-spawning-entities`. For world generation with prefabs, see `hytale-world-gen`.

---

## Quick Reference

| Task | Approach |
|------|----------|
| Create a new prefab world | `/editprefab new <world_name>` |
| Save a prefab | `/prefab save` (use selection brush first) |
| Load a prefab | `/prefab load` |
| List all prefabs | `/prefab list` |
| Delete a prefab | `/prefab delete` |
| Exit prefab editing world | `/editprefab exit` |
| Select a prefab area | Use the selection brush in the editing world |
| Paste a prefab | Use the Paste brush, press `E` to select from menu |
| See command options | Append `--help` to any command (e.g., `/prefab save --help`) |

---

## Key Concepts

- **Prefab editing world** — A dedicated world created for building and editing prefabs. Created with `/editprefab new`.
- **Prefabs** — Physical structures saved as JSON files. A single editing world can contain multiple prefabs.
- **Selection brush** — In-game tool used to select the area to save as a prefab.
- **Paste brush** — In-game tool used to place saved prefabs. Press `E` to open the selection menu.

---

## Basic Workflow

1. `/editprefab new my_prefab_world` — Create a new prefab editing world
2. Build the structure you want in the editing world
3. Use the **selection brush** to select the area
4. `/prefab save` — Save the selected area as a prefab
5. `/editprefab exit` — Exit the editing world
6. Use the **Paste brush**, press `E` to select the prefab from the "server" dropdown (top-right of menu)

---

## Commands

### `/prefab`

Manages prefab files on disk.

| Subcommand | Description |
|------------|-------------|
| `save` | Saves the prefab to the file system |
| `load` | Loads a prefab into the game |
| `delete` | Deletes the prefab from the file system |
| `list` | Lists all prefabs in the file system |

### `/editprefab`

Manages the physical structure editing workflow.

| Subcommand | Description |
|------------|-------------|
| `new` | Creates a new prefab editing world from scratch |
| `load` | Creates a new editing world with an existing prefab pasted in |
| `exit` | Exits the current prefab editing world |
| `select` | Selects the prefab area the user is looking at (within 200 blocks) |
| `save` | Saves the current prefab using the existing or selected area |
| `saveui` | Opens the save UI for managing all prefabs in the current world |
| `saveas` | Saves the selected prefab into a new file |
| `kill` | Despawns all entities in the currently selected prefab |
| `setbox` | Sets the bounding box of the currently selected prefab |
| `info` | Shows information about the currently selected prefab |
| `tp` | Opens teleport UI to jump to a prefab in the current editing world |
| `modified` | Lists all modified prefabs with unsaved changes |

> Use `--help` at the end of any command to see all available options (e.g., `/editprefab save --help`).

---

## Known Issues

- After saving edits to an existing prefab, the prefab may not reflect changes immediately. **Workaround:** exit and re-enter the world.
- When pasting a prefab, it may not always display accurately. **Workaround:** press `T` to toggle the material view; usually at least one view is correct.
- `/prefab delete` may error with `Assert not in thread`.

---

## Edge Cases & Gotchas

- The world name in `/editprefab new <world_name>` is the *world* name, not the prefab name. Worlds can contain multiple prefabs.
- Saved prefabs appear in the "server" dropdown of the Paste brush menu (top-right).
- Prefabs are saved as JSON files to the server file system.
- This is primarily a command-based workflow — there is currently no public Java API for programmatic prefab manipulation from plugins.

```
