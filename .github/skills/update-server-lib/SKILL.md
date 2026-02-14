---
name: update-server-lib
description: Updates the Hytale server reference files in lib/ by downloading the latest pre-release server, decompiling the JAR using Vineflower, and updating server assets. Use when needing to update to a new Hytale server version, refreshing decompiled source code, or syncing with the latest pre-release. Triggers - update server, download server, decompile jar, vineflower, update lib, new server version, sync server, refresh server.
---

# Update Server Lib Skill

Updates the `lib/` folder with the latest Hytale pre-release server files including decompiled source code and server assets.

## Prerequisites

Before running these scripts, ensure the following are installed and on PATH:

- **Hytale Downloader**: The `hytale-downloader-windows-amd64.exe` binary (already authenticated). Default location: `C:\hytale-downloader\` (configurable via `HYTALE_DOWNLOADER_PATH` env var)
- **Python 3+**: For running the patcher tool (`py --version` or `python --version`)
- **Java 25+**: `java --version` should show 25.x
- **Maven**: `mvn --version` should work
- **Git**: `git --version` should work

## Directory Structure

```
<HYTALE_DOWNLOADER_PATH>\              # Default: C:\hytale-downloader\
├── hytale-downloader-windows-amd64.exe
├── .hytale-downloader-credentials.json
├── downloads\                              # Created by script
│   └── <version>.zip                       # Downloaded server package
└── extracted\                              # Created by script
    └── <version>\                          # Extracted server files
        ├── Server\
        │   └── HytaleServer.jar
        └── Assets\
            └── Server\

%APPDATA%\Hytale\install\pre-release\package\game\
└── latest\                                 # Symlink to current build
    └── Client\Data\Game\Interface\         # UI source (.ui files)
```

## Usage

Run the CMD scripts from anywhere (they use absolute paths):

### Full Update (Recommended)

```cmd
.\.github\skills\update-server-lib\scripts\Full-Update.cmd
```

This runs both steps in sequence.

### Step 1: Download and Extract Latest Pre-Release

```cmd
.\.github\skills\update-server-lib\scripts\Download-Server.cmd
```

This script:
- Downloads the latest pre-release server using the Hytale downloader
- Extracts the server zip file
- Extracts the Assets.zip within it
- Saves the version for the next step

### Step 2: Decompile and Update Lib

```cmd
.\.github\skills\update-server-lib\scripts\Update-Lib.cmd
```

Or specify a version:

```cmd
.\.github\skills\update-server-lib\scripts\Update-Lib.cmd 2026.01.29-301e13929
```

This script:
- Clones/updates the HytaleModding/patcher tool
- Sets up Python virtual environment
- Runs Vineflower decompilation on HytaleServer.jar
- Copies decompiled source to `lib/hytale-server/src/main/java`
- Copies Server assets to `lib/Server`
- Copies UI assets to `lib/UI`
- Updates HytaleServer.jar in lib root

## Script Configuration

Set the `HYTALE_DOWNLOADER_PATH` environment variable to override the default downloader location. All sub-paths are derived from it automatically.

```cmd
REM Example: set before running scripts, or add to your system environment variables
set HYTALE_DOWNLOADER_PATH=D:\my-hytale-tools
```

| Setting | Default | Description |
|---------|---------|-------------|
| `HYTALE_DOWNLOADER_PATH` | `C:\hytale-downloader` | Path to hytale-downloader folder (env var) |
| `DOWNLOAD_DIR` | `<HYTALE_DOWNLOADER_PATH>\downloads` | Where to save downloaded zips |
| `EXTRACT_DIR` | `<HYTALE_DOWNLOADER_PATH>\extracted` | Where to extract server files |
| `PATCHER_DIR` | `<HYTALE_DOWNLOADER_PATH>\patcher` | Where to clone/use patcher tool |
| `PATCHLINE` | `pre-release` | Patchline to download from |

## Troubleshooting

### Authentication Errors
If you get 401 or authentication errors, delete `.hytale-downloader-credentials.json` in your downloader directory (default: `C:\hytale-downloader\`) and run the downloader manually to re-authenticate.

### Decompilation Fails
- Ensure Python 3.13+ is installed: `py -3.13 --version`
- Ensure Java 25 is on PATH: `java --version`
- Ensure Maven is on PATH: `mvn --version`
- Check the patcher output for specific errors

### Incomplete Extraction
If extraction fails, delete the partially extracted folder and run again.

## Version Tracking

After a successful update, the script creates `.github/skills/update-server-lib/LAST_VERSION.txt` with the downloaded version for reference.

## Notes

- The decompiled code may have compilation errors - this is expected. It's for reference/exploration only.
- Server assets in `lib/Server` are read-only references; don't modify them directly.
- UI assets in `lib/UI` are for reference when building custom UIs.
- Always test your plugin after updating to ensure compatibility with the new server version.
