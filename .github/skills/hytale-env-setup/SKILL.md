---
name: hytale-env-setup
description: Guides setting up a Hytale plugin development environment and building/testing mods. Covers JDK 25 installation (Windows/macOS/Linux), VS Code configuration, Gradle wrapper, project template, build commands, deploying to the Mods folder, and troubleshooting. Use when a user needs to set up their environment, clone the plugin template, fix build errors, or deploy a plugin for testing. Triggers - setup, environment, env, JDK, Java 25, install, Gradle, build, test, deploy, Mods folder, plugin template, gradlew, build.gradle, settings.gradle, gradle.properties, hytale.home_path, VS Code, development environment.
---

# Hytale Environment Setup & Build/Test

Step-by-step guide for setting up a Hytale plugin development environment and building/testing plugins. Focused on **VS Code** (skip JetBrains).

> **Source:** [Setting Up Your Development Environment](https://hytalemodding.dev/en/docs/guides/plugin/setting-up-env) | [Build and Test Your Mod](https://hytalemodding.dev/en/docs/guides/plugin/build-and-test)

---

## Prerequisites

- Windows 10/11, macOS, or Linux
- At least 8 GB RAM
- 10 GB free disk space
- Administrative privileges

---

## Step 1: Install JDK 25

Hytale modding requires **Java 25** (OpenJDK recommended from [Adoptium](https://adoptium.net/)).

### Windows (Installer)

1. Download OpenJDK 25 from [Adoptium](https://adoptium.net/).
2. Run the installer with default settings.
   - **Enable** "Set or Override JAVA_HOME variable" to avoid version conflicts.
3. Verify in a **new** terminal:
   ```
   java -version
   ```

### Windows (Scoop)

```powershell
# Install Scoop if you don't have it (https://scoop.sh/)
scoop bucket add java
scoop install java/openjdk25
```

### macOS (Homebrew)

```bash
brew install openjdk@25
```

If `java --version` fails, add to PATH:

```bash
echo 'export PATH="$(brew --prefix)/opt/openjdk@25/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install openjdk-25-jdk
```

### Verify

```
java -version
```

Should show Java 25 or later.

---

## Step 2: Install VS Code + Java Extensions

1. Install [VS Code](https://code.visualstudio.com/).
2. Install the **Extension Pack for Java** (Microsoft) — includes:
   - Language Support for Java (Red Hat)
   - Debugger for Java
   - Maven for Java
   - Gradle for Java
   - Test Runner for Java
3. Install the **Gradle for Java** extension if not already included.

### VS Code Java Settings

Ensure VS Code uses JDK 25. In `settings.json`:

```json
{
  "java.configuration.runtimes": [
    {
      "name": "JavaSE-25",
      "path": "C:\\Program Files\\Eclipse Adoptium\\jdk-25",
      "default": true
    }
  ]
}
```

Adjust the path to match your JDK installation.

---

## Step 3: Clone the Plugin Template

The official Hytale plugin template includes a Gradle Wrapper, so you do **not** need a system-wide Gradle install.

```bash
git clone https://github.com/HytaleModding/plugin-template.git MyFirstMod
cd MyFirstMod
```

Or download the ZIP from the repository page and extract it.

### Open in VS Code

```bash
code MyFirstMod
```

VS Code with the Java extension pack will automatically detect the Gradle project, download dependencies, and set up the classpath.

---

## Step 4: Configure the Project

### `settings.gradle.kts`

Set your project name:

```kotlin
rootProject.name = "MyPlugin"
```

### `build.gradle.kts`

The template's build script handles:
- Hytale dependency resolution
- Manifest packaging
- JAR output

### `gradle.properties`

If your Hytale installation is not at the default location, create or edit `gradle.properties` in the project root:

```properties
hytale.home_path=C:\Path\To\Hytale
```

### `manifest.json`

Edit `src/main/resources/manifest.json` with your plugin details. See the `hytale-plugin-config` skill for manifest structure.

---

## Step 5: Build

Open a terminal in the project root and run:

```bash
./gradlew build
```

On Windows (if not using Git Bash):

```powershell
.\gradlew.bat build
```

This will:
1. Compile Java source code
2. Run tests (if present)
3. Package into a JAR in `build/libs/`

### Build Output

The JAR will be at:

```
build/libs/MyPlugin-1.0.jar
```

The exact name depends on `rootProject.name` and `version` in your build files.

### Common Build Error: Hytale Not Found

```
FAILURE: Build failed with an exception.
* What went wrong:
Failed to find Hytale at the expected location.
```

**Fix:** Set the correct path in `gradle.properties`:

```properties
hytale.home_path=C:\Correct\Path\To\Hytale
```

---

## Step 6: Deploy & Test

### 1. Locate the Mods Folder

Default path on Windows:

```
C:\Users\<YourUsername>\AppData\Roaming\Hytale\UserData\Mods
```

> **Tip:** Press `Win + R`, type `%appdata%`, navigate to `Hytale\UserData\Mods`. Create the `Mods` folder if it doesn't exist.

### 2. Copy the JAR

Copy `build/libs/MyPlugin-1.0.jar` into the `Mods` folder.

### 3. Launch & Verify

1. Start Hytale
2. Click "Create a New World"
3. Click the settings cog
4. Click "Mods"
5. Your mod should appear in the list

---

## Hytale Maven Repository

If setting up from scratch (not using the template), add the Hytale dependency:

### Gradle (`build.gradle.kts`)

```kotlin
repositories {
    mavenCentral()
    maven {
        name = "hytale"
        url = uri("https://maven.hytale.com/release")
        // Or "https://maven.hytale.com/pre-release" for pre-release
    }
}

dependencies {
    implementation("com.hypixel.hytale:Server:+") // latest version
}
```

### Maven (`pom.xml`)

```xml
<repositories>
    <repository>
        <id>hytale-release</id>
        <url>https://maven.hytale.com/release</url>
    </repository>
</repositories>

<dependencies>
    <dependency>
        <groupId>com.hypixel.hytale</groupId>
        <artifactId>Server</artifactId>
        <version>LATEST_VERSION_HERE</version>
        <scope>provided</scope>
    </dependency>
</dependencies>
```

---

## Step 7: VS Code Tasks

Create `.vscode/tasks.json` to enable one-click build and deploy from VS Code. **Before creating the deploy task, ask the user where Hytale is installed** so the deploy path can be configured correctly.

### Setup Procedure

1. **Ask the user for their Hytale installation path** (e.g., `C:\Program Files\Hytale` or wherever they installed it).
2. **Derive the Mods folder** from that path: `<hytale_path>\UserData\Mods` (Windows) or check `%APPDATA%\Hytale\UserData\Mods` for the default AppData location.
3. **Set `hytale.home_path`** in `gradle.properties` to the user's Hytale path.
4. **Create `.vscode/tasks.json`** with the tasks below, substituting the deploy path.

### `.vscode/tasks.json`

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "build plugin",
      "type": "shell",
      "command": ".\\gradlew.bat",
      "args": ["build"],
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "problemMatcher": ["$javac"],
      "detail": "Build the plugin JAR via Gradle"
    },
    {
      "label": "build and deploy",
      "type": "shell",
      "command": ".\\gradlew.bat",
      "args": ["build"],
      "group": "build",
      "problemMatcher": ["$javac"],
      "detail": "Build the plugin and copy to Hytale Mods folder",
      "dependsOrder": "sequence",
      "dependsOn": [],
      "presentation": {
        "reveal": "always",
        "panel": "shared"
      }
    },
    {
      "label": "deploy to mods",
      "type": "shell",
      "command": "powershell",
      "args": [
        "-Command",
        "Copy-Item -Path 'build/libs/*.jar' -Destination '${config:hytale.modsPath}' -Force"
      ],
      "problemMatcher": [],
      "detail": "Copy built JAR to Hytale Mods folder",
      "dependsOn": ["build plugin"]
    }
  ]
}
```

> **Note:** The `build and deploy` task can alternatively be a single compound task. The example above uses a separate `deploy to mods` task that depends on `build plugin`.

### `.vscode/settings.json` (Hytale Mods Path)

Store the Mods folder path as a VS Code setting so tasks can reference it via `${config:hytale.modsPath}`:

```json
{
  "hytale.modsPath": "C:\\Users\\<YourUsername>\\AppData\\Roaming\\Hytale\\UserData\\Mods"
}
```

**Replace** `<YourUsername>` with the actual username, or use the full path the user provides.

### macOS / Linux Alternative

For non-Windows, replace the deploy command:

```json
{
  "command": "cp",
  "args": ["build/libs/*.jar", "${config:hytale.modsPath}"]
}
```

And use `./gradlew` instead of `.\\gradlew.bat` in the build tasks.

### `gradle.properties`

Also set the Hytale home path so Gradle can find the game libraries:

```properties
hytale.home_path=C:\Path\To\Hytale
```

---

## First-Time Setup Flow (For Agents)

When a user asks for help and the project is not yet set up, follow this flow:

1. **Check for `.vscode/tasks.json`** — if missing, environment is likely not configured.
2. **Check for `gradle.properties`** — if missing or lacks `hytale.home_path`, need to configure.
3. **Check Java version** — run `java -version` in terminal.
4. **Ask the user:**
   - "Where is Hytale installed on your system?" (e.g., `C:\Program Files\Hytale`)
   - This is needed for both `gradle.properties` (build) and `.vscode/settings.json` (deploy)
5. **Derive the Mods path:**
   - Windows default: `%APPDATA%\Hytale\UserData\Mods`
   - Or under the install path: `<hytale_path>\UserData\Mods`
   - Confirm with the user if unclear.
6. **Create/update files:**
   - `gradle.properties` with `hytale.home_path`
   - `.vscode/tasks.json` with build + deploy tasks
   - `.vscode/settings.json` with `hytale.modsPath`
7. **Verify** the build works: run the `build plugin` task.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `java -version` shows wrong version | Ensure JAVA_HOME points to JDK 25; restart terminal |
| Gradle can't find Hytale | Set `hytale.home_path` in `gradle.properties` |
| JAR not in `build/libs/` | Run `./gradlew build` and check for compile errors |
| Mod not in Hytale mod list | Verify JAR is in `<appdata>/Hytale/UserData/Mods`, check `manifest.json` |
| VS Code doesn't recognize Java | Install Extension Pack for Java; verify `java.configuration.runtimes` |
| Gradle wrapper missing | Run `gradle wrapper` or re-clone the template |

---

## Environment Verification Checklist

Use this to validate a user's environment is ready:

1. `java -version` → Java 25+
2. VS Code installed with Extension Pack for Java
3. Project opens without errors in VS Code
4. `./gradlew build` succeeds
5. JAR exists in `build/libs/`
6. Hytale `Mods` folder exists and is accessible
