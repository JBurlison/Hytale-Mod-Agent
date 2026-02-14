# Translations & Localization

This document covers localization in Hytale UI - both translating your mod's UI text and contributing to the HytaleModding community translations.

---

## Translating Your Mod's UI

### Translation Keys in .ui Files

Use the `%` prefix to reference translation keys in your UI markup:

```ui
Label {
    Text: %ui.mymod.greeting;
}

Button {
    Text: %ui.mymod.button.save;
}
```

### Language Files

Translation strings are stored in `.lang` files under `Server/Languages/`:

```
src/main/resources/
└── Server/
    └── Languages/
        ├── en-US/
        │   └── ui.lang
        ├── es-ES/
        │   └── ui.lang
        └── fallback.lang
```

### Language File Format

Language files use a simple key-value format:

```properties
# en-US/ui.lang
ui.mymod.greeting = Hello, adventurer!
ui.mymod.button.save = Save
ui.mymod.button.cancel = Cancel
ui.mymod.inventory.title = Inventory
```

```properties
# es-ES/ui.lang
ui.mymod.greeting = ¡Hola, aventurero!
ui.mymod.button.save = Guardar
ui.mymod.button.cancel = Cancelar
ui.mymod.inventory.title = Inventario
```

### Fallback Configuration

The `fallback.lang` file maps locales to their fallback:

```properties
# fallback.lang
en-GB = en-US
es-MX = es-ES
pt-BR = pt-PT
```

### Using Translations in Java

```java
import com.hypixel.hytale.server.core.i18n.LocalizableString;
import com.hypixel.hytale.server.core.i18n.Message;

// From a translation key
LocalizableString text = LocalizableString.fromMessageId("ui.mymod.greeting");

// With parameters
LocalizableString text = LocalizableString.fromMessageId(
    "ui.mymod.welcome", 
    Map.of("name", playerName)
);

// In language file:
// ui.mymod.welcome = Welcome, {name}!

// Plain string (no translation)
LocalizableString text = LocalizableString.fromString("Static text");

// Using Message class for chat
Message.translation("chat.mymod.joined", Map.of("player", playerName));
```

### Translation Parameters

Use `{paramName}` for dynamic values:

```properties
# Language file
ui.mymod.level = Level: {level}
ui.mymod.damage = You dealt {amount} damage to {target}!
```

```ui
Label {
    Text: %ui.mymod.level;
}
```

Set the parameter value from Java:

```java
UICommandBuilder cmd = new UICommandBuilder();
cmd.set("#LevelLabel.Text", 
    LocalizableString.fromMessageId("ui.mymod.level", Map.of("level", String.valueOf(playerLevel))));
```

### Best Practices

1. **Use namespaced keys** - Prefix with your mod name: `ui.mymod.feature.key`
2. **Keep keys descriptive** - `ui.mymod.inventory.empty` not `ui.mymod.ie`
3. **Externalize all user-facing text** - Never hardcode display strings
4. **Support parameters** - Use `{param}` for dynamic content
5. **Provide fallback locale** - Always have en-US as base
6. **Test all locales** - Verify translations fit in your UI layouts

---

## Contributing to HytaleModding Translations

Help translate the HytaleModding documentation website to your language.

### How to Contribute

All translations are managed via Crowdin:

1. Visit [translate.hytalemodding.dev](https://translate.hytalemodding.dev/)
2. Log in (create account if needed)
3. Click on your language
4. Click on the file/article you wish to translate
5. Start translating!
6. Approved translations will appear on the website

### Translation Guidelines

- **Be confident** - You should be able to read your translation and understand the meaning easily
- **Keep it simple** - Use the simplest form of language possible
- **Use English words** if the translation is unknown to the majority in your country
- **Use your imagination** - Feel free to change context as long as meaning is preserved
- **Follow Hytale's official translations** when available

### What NOT to Translate

**Callout types** - Only translate title and content:
```mdx
<Callout type="warning" title="Translate this title!">
  Translate the text in between!
</Callout>
```
Do NOT translate "warning" - it's a technical identifier.

**Icon names** - These are technical identifiers:
```mdx
icon: Globe
```
Translating icon names will break icon rendering.

**Code blocks** - Keep code samples in their original form.

### Discussion & Support

1. Join the [HytaleModding Discord](https://discord.gg/hytalemodding)
2. Open the `#translation` channel for general translation discussion
3. Run `/translator <your-language>` to join your language's thread
4. If your language isn't available:
   - Request it on Crowdin if not listed
   - Ping **Neil** on Discord if it's on Crowdin but missing from the bot

---

## Source

- Official UI Markup: https://hytalemodding.dev/en/docs/official-documentation/custom-ui/markup
- Translation Guidelines PR: https://github.com/HytaleModding/site/pull/396
