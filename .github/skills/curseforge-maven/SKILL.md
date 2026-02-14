---
name: curseforge-maven
description: Add CurseForge mod dependencies from a CurseForge mod URL to Maven builds (Hytale). Uses latest release, adds the CurseForge Maven repo, and supports CURSE_USER/CURSE_TOKEN auth. Triggers: curseforge url, add mod, maven dependency, curseforge maven.
compatibility: Requires Maven and CurseForge credentials via CURSE_USER and CURSE_TOKEN env vars.
metadata:
  version: "1.0"
---

# CurseForge Maven Dependency Skill

Add a CurseForge mod (by URL) as a Maven dependency using the CurseForge Maven endpoint.

## Inputs
- **CurseForge mod URL** (required)
- **Latest file name** (optional but often required): the newest release .jar filename from the project’s Files list

## Requirements
- Environment variables:
  - `CURSE_USER` = your CurseForge account email
  - `CURSE_TOKEN` = your CurseForge API token
- Maven repository: `https://www.curseforge.com/api/maven/`

> Note: CurseForge’s docs indicate Maven auth is embedded in the URL, but in practice some endpoints require API token auth. This skill uses `CURSE_USER`/`CURSE_TOKEN` via Maven server credentials and can fall back to a `?token=` query parameter if needed.

## Project Setup (Maven)
1. Ensure the CurseForge repository exists in [pom.xml](pom.xml):
   - `id`: `curseforge`
   - `url`: `https://www.curseforge.com/api/maven/`
2. Ensure Maven uses credentials via [.mvn/settings.xml](.mvn/settings.xml):
   - `username`: `${env.CURSE_USER}`
   - `password`: `${env.CURSE_TOKEN}`
3. If you still receive 401 errors, update the repository URL to include the token:
   - `https://www.curseforge.com/api/maven/?token=${env.CURSE_TOKEN}`

## How to Derive Maven Coordinates (Latest Release)
Given a mod URL like:
```
https://www.curseforge.com/hytale/mods/<projectSlug>
```

1. **projectSlug** = last path segment (example: `my-mod`).
2. Get the **latest release filename** from the mod’s Files list, e.g.
   - `MyMod-1.2.3-release-universal.jar`
3. Parse the filename:
   - `mavenArtifact` = `MyMod-1.2.3`
   - `mavenVersion` = `release`
   - `projectFileNameTag` (classifier) = `universal`

Maven dependency format:
```xml
<dependency>
  <groupId>projectSlug</groupId>
  <artifactId>mavenArtifact</artifactId>
  <version>release</version>
  <classifier>projectFileNameTag</classifier>
</dependency>
```

## Scripted Add (Recommended)
Use the PowerShell script in:
- [.github/skills/curseforge-maven/scripts/add-curseforge-mod.ps1](.github/skills/curseforge-maven/scripts/add-curseforge-mod.ps1)

It will:
- Extract the slug from the URL
- Ask for (or parse) the latest file name
- Add the dependency and repository to the Maven `pom.xml`

## Edge Cases
- If the filename doesn’t include a tag (e.g., no `-universal`), omit the classifier.
- If `release` doesn’t resolve, use the actual file version from the name instead (e.g., `1.2.3`).
- If the mod is not a `.jar`, Maven dependency may not work.
