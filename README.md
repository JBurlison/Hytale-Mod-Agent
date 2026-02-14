# Hytale Mod Agent

An AI-powered Hytale plugin development environment featuring a comprehensive library of modding skills, an expert Hytale Modder agent, and automation scripts for keeping everything in sync with the latest Hytale pre-release server.

## Getting Started

### VS Code + GitHub Copilot (Recommended)

1. Copy the `.github` folder from this repo into the root of your Hytale plugin project.
2. Open your project in VS Code with the [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) extension installed.
3. The agent, skills, and instructions will be picked up automatically by Copilot Chat.

### Claude Code

If you're using [Claude Code](https://docs.anthropic.com/en/docs/claude-code) instead of Copilot:

1. Copy the `.github` folder into your project root and **rename it to `.claude`**.
2. Rename `copilot-instructions.md` to `CLAUDE.md`.
3. Agent and skill files will work as-is under the `.claude` directory.

---

## Table of Contents

- [Updating the Server Library](#updating-the-server-library)
  - [Prerequisites](#server-update-prerequisites)
  - [Configure the Downloader Path](#configure-the-downloader-path)
  - [Run the Update](#run-the-update)
- [Updating Hytale Skills](#updating-hytale-skills)
  - [When to Update](#when-to-update)
  - [How to Invoke](#how-to-invoke)
- [Using the Hytale Modder Agent](#using-the-hytale-modder-agent)
- [Project Structure](#project-structure)
- [Available Skills](#available-skills)

---

## Updating the Server Library

The `update-server-lib` skill downloads the latest Hytale pre-release server, decompiles the JAR using Vineflower, and syncs the decompiled source and game assets into the `lib/` directory for reference. This will allow the agent to reference the latest server code and JSON assets when generating plugin code.

### Server Update Prerequisites

Ensure the following are installed and on PATH:

- **Hytale Downloader** — `hytale-downloader-windows-amd64.exe` (already authenticated)
- **PowerShell 5.1+** — included with Windows 10/11 (`$PSVersionTable.PSVersion`)
- **Python 3.13+** — `py -3.13 --version`
- **Java 25+** — `java --version`
- **Maven** — `mvn --version`
- **Git** — `git --version`

### Configure the Downloader Path

Set the `HYTALE_DOWNLOADER_PATH` environment variable to tell the scripts where your Hytale downloader is located. The default is `C:\hytale-downloader`.

```powershell
[System.Environment]::SetEnvironmentVariable("HYTALE_DOWNLOADER_PATH", "D:\my-hytale-tools", "User")
```

**Expected directory structure:**

```
<HYTALE_DOWNLOADER_PATH>\
├── hytale-downloader-windows-amd64.exe
├── .hytale-downloader-credentials.json
├── downloads\          # Created by script
└── extracted\          # Created by script
```

| Setting | Default | Description |
|---------|---------|-------------|
| `HYTALE_DOWNLOADER_PATH` | `C:\hytale-downloader` | Root path to the hytale-downloader folder |
| `DOWNLOAD_DIR` | `<HYTALE_DOWNLOADER_PATH>\downloads` | Where downloaded zips are saved |
| `EXTRACT_DIR` | `<HYTALE_DOWNLOADER_PATH>\extracted` | Where server files are extracted |
| `PATCHER_DIR` | `<HYTALE_DOWNLOADER_PATH>\patcher` | Where the patcher tool is cloned |
| `PATCHLINE` | `pre-release` | Patchline to download from |

### Run the Update

**Full update (recommended)** — downloads, extracts, decompiles, and syncs everything:

```cmd
.\.github\skills\update-server-lib\scripts\Full-Update.cmd
```

**Step-by-step:**

```cmd
# Step 1: Download and extract the latest pre-release
.\.github\skills\update-server-lib\scripts\Download-Server.cmd

# Step 2: Decompile and update lib/
.\.github\skills\update-server-lib\scripts\Update-Lib.cmd

# Or specify a version explicitly:
.\.github\skills\update-server-lib\scripts\Update-Lib.cmd 2026.01.29-301e13929
```

After a successful update, the script writes the version to `.github/skills/update-server-lib/LAST_VERSION.txt`.

**What gets updated:**

| Target | Contents |
|--------|----------|
| `lib/hytale-server/src/main/java` | Decompiled server source code |
| `lib/Server` | Server game assets (JSON definitions, configs) |
| `lib/UI` | Client UI assets (.ui files) |
| `lib/HytaleServer.jar` | The server JAR |

### Troubleshooting

| Problem | Solution |
|---------|----------|
| Authentication errors (401) | Delete `.hytale-downloader-credentials.json` and re-authenticate the downloader manually |
| Decompilation fails | Verify Python 3.13+, Java 25, and Maven are on PATH |
| Incomplete extraction | Delete the partial folder in `extracted/` and re-run |

---

## Updating Hytale Skills

The `update-hytale-skills` skill synchronizes all `hytale-*` skills in `.github/skills/` with upstream documentation from the [HytaleModding site](https://hytalemodding.dev) and the decompiled server source.

### When to Update

- **After running `update-server-lib`** — a new server version may introduce API changes
- **When the HytaleModding docs site has been updated** — new guides or changed content
- **Periodically** (e.g., weekly) — to catch community doc improvements
- **When a skill's code examples seem outdated** — API references may have drifted

### How to Invoke

This skill is designed to be invoked via the **Hytale Modder agent** in VS Code (GitHub Copilot Chat). Ask it to:

> "Update the hytale skills" or "Run the update-hytale-skills skill"

The agent will:

1. Check the [HytaleModding/site](https://github.com/HytaleModding/site) GitHub repo for recent content changes
2. Fetch updated MDX source files from `content/docs/en/`
3. Compare upstream content against each skill's current `SKILL.md`
4. Update skills with new API methods, code examples, and documentation
5. Discover new documentation pages that may warrant new skills
6. Cross-reference decompiled server source for skills without upstream docs

**Source repository:** `https://github.com/HytaleModding/site` (content root: `content/docs/en/`)

---

## Using the Hytale Modder Agent

The **Hytale Modder** agent (`.github/agents/hytale-modder.agent.md`) is a specialized AI assistant for Hytale plugin development. It's available in VS Code via GitHub Copilot Chat.

**Invoke it by mentioning `@hytale-modder` in Copilot Chat**, or it will be automatically selected for Hytale modding tasks.

**What it can do:**

- Build plugins using ECS architecture and data-driven JSON
- Create custom items, NPCs, commands, events, UIs, and world generation
- Spawn entities and NPCs with custom behavior
- Set up camera controls, hotbar actions, and player input handling
- Manage permissions, persistent data, teleportation, and instances
- Reference decompiled server source and vanilla game JSON for accuracy

**Example prompts:**

- *"I need a healing potion item that restores 50 health"*
- *"Create a system that damages entities standing in lava"*
- *"Add a /teleport command with permission checks"*
- *"Make a mana bar HUD"*
- *"I want a merchant NPC that sells items"*

The agent automatically loads relevant skills from `.github/skills/` based on the task and cross-references the decompiled server source in `lib/` for API accuracy.

---

## Project Structure

```
Hytale-Mod-Agent/
├── .github/
│   ├── copilot-instructions.md      # Global Copilot instructions
│   ├── agents/
│   │   └── hytale-modder.agent.md   # Hytale Modder agent definition
│   └── skills/                      # Modding knowledge skills
│       ├── hytale-ecs/              # ECS architecture
│       ├── hytale-events/           # Event system
│       ├── hytale-items/            # Items & crafting
│       ├── hytale-ui-modding/       # Custom UIs
│       ├── hytale-world-gen/        # World generation
│       ├── update-server-lib/       # Server update scripts
│       ├── update-hytale-skills/    # Skill sync procedure
│       └── ...                      # 30+ additional skills
├── lib/                             # Reference files (generated by update-server-lib)
│   ├── hytale-server/               # Decompiled server source
│   ├── Server/                      # Game JSON assets
│   └── UI/                          # Client UI assets
└── src/                             # Your plugin source
    └── main/
        ├── java/                    # Plugin Java code
        └── resources/
            ├── manifest.json        # Plugin manifest
            └── Server/              # Server-side data & translations
```

