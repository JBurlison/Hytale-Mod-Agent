# Hytale plugin
This is a Hytale plugin project. Hytale plugins are used to extend the functionality of the Hytale server. Plugins can add new features, modify existing behavior, or integrate with other systems. Plugins are typically written in Java and packaged as JAR files that can be loaded by the Hytale server. The plugins are sent to the client at runtime so they are only needed on the server.

- When you want to build the plugin, run the task build plugin
- Hytale uses an Entity Component System (ECS) architecture. Very data driven. Do not hard code values.
- Before implementing new features, review the ECS patterns and existing components in the Hytale server code.
- The source code for the Hytale server can be found in the `lib/hytale-server/src/main/java/com/hypixel` directory.
- The games JSON that makes up all items, blocks, and other in-game assets can be found in the `lib/Server` directory. you can use this to look up item IDs, block IDs, and other in-game assets. Do not modify these files directly, they are for reference.
- To update lib/ with the latest Hytale server, use the `update-server-lib` skill (`.github/skills/update-server-lib/`). This downloads the pre-release server, decompiles the JAR, and syncs assets.
- To update hytale-* skills after a server update or when docs change, use the `update-hytale-skills` skill (`.github/skills/update-hytale-skills/`). This checks the HytaleModding/site GitHub repo for content changes and reconciles skill content.
- Avoid enums, this is data driven from JSON files via resources. Reference `lib/Server` directory for structure and json examples.
- `lib/UI` contains the Hytale client UI code. Use this to look up how to build custom UIs using .ui files.
- Review TODOs when implementing a plan as they may be from a previous implementation or design decision awaiting the plan.
- When working with systems, aim to make things generic and data driven. Leverage tags and JSON data wherever possible.
- DO NOT hard code values; always use data-driven approaches and JSON configuration.
- Prefer single-file JSON definitions for features that extend Hytale (e.g., buffs/debuffs, effects, interactions). Avoid multi-file JSON solutions unless there is a clear, logical design need.
- There is a build and deploy task that will build the plugin and copy it to the local Hytale server plugins directory for testing. Use this to speed up your development workflow.
- There should be no warnings or errors when compiling the plugin. (ignoring pom.xml warnings)
- Any user-facing text must be localized via translation keys (e.g., `Message.translation(...)`) and added to language resources under `src/main/resources/Server/Languages/<locale>/*.lang` (filename becomes the key prefix). `src/main/resources/Server/Languages/fallback.lang` is only for locale fallback mappings (e.g., `en-GB = en-US`).

## .github/skills
- Evaluate skills when given a task or problem to solve.
- Multiple skills may be required to complete a task or solve a problem effectively.
- Skills should be applied in a context-aware manner, considering the specific requirements and constraints of the task.
- Continuously evaluate and update the skill set as new information and context become available.\
- Skills should be updated when you learn new information about that skill.
	- This includes learning new APIs, libraries, frameworks, or best practices related to that skill.
	- An example would be learning specific Hytale modding APIs or ECS patterns. Skills are meant to document knowledge about specific use cases and APIs.

## Hytale ECS notes (follow these patterns)
- ECS is composition over inheritance. Entities are identifiers only, Components are pure data, Systems contain logic.
- Use `Store<EntityStore>` to access component data. Do not keep direct references to entity objects; use `Ref<EntityStore>` handles and validate as needed.
- `Store` uses archetypes (chunked storage). Keep systems query-driven and data-oriented.
- `EntityStore` provides world access and entity lookup (UUID, network id). `ChunkStore` is for chunk/block data and world chunks.
- Build entities via `Holder<EntityStore>` then add to the store; treat it as a staging cart for components.
- Components implement `Component<EntityStore>` (entities) or `Component<ChunkStore>` (blocks) and must provide a default constructor and `clone()` (copy constructor pattern).
- Components must define a `BuilderCodec` for serialization (field-level with `KeyedCodec`). See `hytale-persistent-data` skill for full Codec reference.
- Use `CommandBuffer` for entity/component changes instead of mutating the store directly (thread safety + ordering).
- Systems:
	- `EntityTickingSystem` for per-entity tick logic.
	- `TickingSystem` for global per-tick logic.
	- `DelayedEntitySystem` for interval-based entity updates.
	- `RefChangeSystem` for reacting to component add/set/remove.
- Block components use `ChunkStore` and require `worldChunk.setTicking(x, y, z, true)` + a RefSystem initializer to enable block ticking.
- Queries filter entities (`Query.and`, `Query.not`). Only entities matching the query are processed.
- Use `SystemGroup` and dependencies to control execution order (e.g., damage pipeline stages).
- Register components in plugin `setup()` and systems in `start()`. Use `EntityStoreRegistry` for entities, `ChunkStoreRegistry` for blocks.
- Block plugins must declare `Hytale:EntityModule` and `Hytale:BlockModule` dependencies in `manifest.json`.
- See `hytale-ecs` skill for full ECS reference with code examples.

## Project Structure
```text
your-plugin-name/
|-- src/
|   `-- main/
|       |-- java/
|       |   `-- com/
|       |       `-- yourname/
|       |           `-- yourplugin/
|       |               `-- YourPlugin.java
|       `-- resources/
|           |-- manifest.json
|           |-- Common/          # Assets (models, textures)
|           `-- Server/          # Server-side data
|-- build.gradle
|-- settings.gradle
|-- gradle.properties
|-- README.md
`-- run/                         # Generated when you run the server

```