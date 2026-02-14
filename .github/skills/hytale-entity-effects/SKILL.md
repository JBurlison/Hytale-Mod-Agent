---
name: hytale-entity-effects
description: Documents Hytale's Entity Effect system for applying status effects, buffs, debuffs, DoTs, and visual effects to entities. Use when creating effects for NPCs, applying effects via affixes, working with EffectControllerComponent, or defining effect JSON. Triggers - effect, entity effect, status effect, debuff, buff, DoT, burn, stun, slow, poison, freeze, root, ApplicationEffects, EffectControllerComponent, effect JSON.
---

# Hytale Entity Effects System

This skill provides comprehensive documentation for Hytale's Entity Effect system, including JSON schema, API usage, and integration patterns.

## Quick Reference

| Task | Approach |
|------|----------|
| Create status effect | JSON in `Server/Entity/Effects/Status/` |
| Apply effect to entity | `EffectControllerComponent.addEffect(ref, entityEffect, accessor)` |
| Remove effect from entity | `EffectControllerComponent.removeEffect(ref, effectIndex, accessor)` |
| Create damage-over-time | `DamageCalculator` + `DamageCalculatorCooldown` in effect JSON |
| Disable movement | `ApplicationEffects.MovementEffects.DisableAll: true` |
| Disable abilities | `ApplicationEffects.AbilityEffects.Disabled: [...]` |
| Apply visual tint | `ApplicationEffects.EntityBottomTint` / `EntityTopTint` |
| Add particles | `ApplicationEffects.Particles: [{ "SystemId": "..." }]` |

## Effect Categories

Hytale organizes effects into subdirectories by purpose:

| Directory | Purpose | Examples |
|-----------|---------|----------|
| `Status/` | Status effects (debuffs/buffs) | Burn, Stun, Slow, Poison, Freeze, Root |
| `Potion/` | Consumable effects | Health regen, Stamina regen, Morph |
| `Movement/` | Movement-related effects | Dodge invulnerability |
| `Immunity/` | Damage resistance effects | Fire immunity, Environmental immunity |
| `Weapons/` | Weapon ability effects | Signature moves, special attacks |
| `Damage/` | Visual damage feedback | Red flash on hit |
| `Food/` | Food consumption effects | Nutrition buffs |
| `Stamina/` | Stamina system effects | Stamina drain, recovery |

---

## JSON Schema Reference

### Core EntityEffect Properties

```json
{
  "Name": "Effect_Name",
  "Duration": 10,
  "Infinite": false,
  "Debuff": true,
  "OverlapBehavior": "Overwrite",
  "RemovalBehavior": "Duration",
  "Invulnerable": false,
  "StatusEffectIcon": "UI/StatusEffects/Icon.png",
  "Locale": "effect.custom.name",
  "ApplicationEffects": { },
  "DamageCalculator": { },
  "DamageCalculatorCooldown": 1,
  "DamageEffects": { },
  "StatModifiers": { },
  "ValueType": "Absolute",
  "DamageResistance": { },
  "ModelChange": "ModelName",
  "ModelOverride": { }
}
```

### Property Reference

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `Name` | string | - | Localization key for display name |
| `Duration` | float | 0 | Duration in seconds |
| `Infinite` | boolean | false | Effect persists until explicitly removed |
| `Debuff` | boolean | false | True for negative effects, false for buffs |
| `OverlapBehavior` | enum | `IGNORE` | Behavior when effect is reapplied |
| `RemovalBehavior` | enum | `COMPLETE` | How the effect ends |
| `Invulnerable` | boolean | false | Makes entity invulnerable while active |
| `StatusEffectIcon` | string | - | Path to UI icon (relative to Common/) |
| `Locale` | string | - | Translation key for death cause |

### OverlapBehavior Values

| Value | Description |
|-------|-------------|
| `EXTEND` | Adds new duration to remaining duration |
| `OVERWRITE` | Replaces with new duration |
| `IGNORE` | Keeps existing effect, ignores new application |

### RemovalBehavior Values

| Value | Description |
|-------|-------------|
| `COMPLETE` | Standard removal when duration expires |
| `INFINITE` | Never removed by duration |
| `DURATION` | Explicitly duration-based |

---

## ApplicationEffects Schema

`ApplicationEffects` defines visual, audio, and gameplay effects while the effect is active.

```json
{
  "ApplicationEffects": {
    "EntityBottomTint": "#000000",
    "EntityTopTint": "#ff0000",
    "EntityAnimationId": "Hurt",
    "ScreenEffect": "ScreenEffects/Fire.png",
    "HorizontalSpeedMultiplier": 0.5,
    "KnockbackMultiplier": 0,
    "LocalSoundEventId": "SFX_Effect_Burn_Local",
    "WorldSoundEventId": "SFX_Effect_Burn_World",
    "ModelVFXId": "Burn",
    "MouseSensitivityAdjustmentTarget": 0.25,
    "MouseSensitivityAdjustmentDuration": 0.1,
    "Particles": [ ],
    "FirstPersonParticles": [ ],
    "MovementEffects": { },
    "AbilityEffects": { }
  }
}
```

### Visual Properties

| Property | Type | Description |
|----------|------|-------------|
| `EntityBottomTint` | color | Hex color tint for bottom of entity |
| `EntityTopTint` | color | Hex color tint for top of entity |
| `EntityAnimationId` | string | Animation to trigger on entity |
| `ScreenEffect` | string | Screen overlay effect path |
| `ModelVFXId` | string | VFX model to attach to entity |

### Gameplay Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `HorizontalSpeedMultiplier` | float | 1.0 | Multiplier for movement speed (0.5 = 50% speed) |
| `KnockbackMultiplier` | float | 1.0 | Multiplier for knockback received |
| `MouseSensitivityAdjustmentTarget` | float | - | Target mouse sensitivity (0-1) |
| `MouseSensitivityAdjustmentDuration` | float | - | Time to reach target sensitivity |

### Audio Properties

| Property | Type | Description |
|----------|------|-------------|
| `LocalSoundEventId` | string | Sound played to affected player only |
| `WorldSoundEventId` | string | Sound played to all nearby players |
| `WorldRemovalSoundEventId` | string | Sound when effect ends (world) |
| `LocalRemovalSoundEventId` | string | Sound when effect ends (local) |

---

## Particles

Particles attach visual effects to entity bones/nodes.

### ModelParticle Schema

```json
{
  "Particles": [
    {
      "SystemId": "Effect_Fire",
      "TargetEntityPart": "Entity",
      "TargetNodeName": "Head",
      "Color": "#ff0000",
      "Scale": 1.0,
      "PositionOffset": { "X": 0, "Y": 0, "Z": 0 },
      "RotationOffset": { },
      "DetachedFromModel": false
    }
  ]
}
```

### Particle Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `SystemId` | string | Yes | Particle system identifier |
| `TargetEntityPart` | enum | Yes | Where to attach (`Entity`, `Self`) |
| `TargetNodeName` | string | No | Bone/node name to attach to |
| `Color` | color | No | Tint color for particles |
| `Scale` | float | No | Size multiplier (default: 1.0) |
| `PositionOffset` | Vector3f | No | Position offset from node |
| `RotationOffset` | Direction | No | Rotation offset |
| `DetachedFromModel` | boolean | No | If true, particles spawn in world space |

---

## MovementEffects Schema

Disables specific movement inputs while effect is active.

```json
{
  "MovementEffects": {
    "DisableAll": true,
    "DisableForward": false,
    "DisableBackward": false,
    "DisableLeft": false,
    "DisableRight": false,
    "DisableSprint": false,
    "DisableJump": false,
    "DisableCrouch": false
  }
}
```

**Note:** Setting `DisableAll: true` automatically enables all individual disable flags.

### Movement Effect Examples

**Stun (complete immobilization):**
```json
{
  "MovementEffects": {
    "DisableAll": true
  }
}
```

**Root (no walking, can still look around):**
```json
{
  "MovementEffects": {
    "DisableAll": true
  },
  "AbilityEffects": {
    "Disabled": []
  }
}
```

---

## AbilityEffects Schema

Disables specific ability types while effect is active.

```json
{
  "AbilityEffects": {
    "Disabled": [
      "Primary",
      "Secondary",
      "Ability1",
      "Ability2",
      "Ability3"
    ]
  }
}
```

### Ability Types

| Value | Description |
|-------|-------------|
| `Primary` | Primary attack/action (LMB) |
| `Secondary` | Secondary attack/action (RMB) |
| `Ability1` | First ability slot |
| `Ability2` | Second ability slot |
| `Ability3` | Third ability slot |

---

## DamageCalculator Schema

Applies periodic damage while effect is active.

```json
{
  "DamageCalculator": {
    "Type": "Absolute",
    "Class": "Unknown",
    "BaseDamage": {
      "Fire": 5,
      "Poison": 10
    },
    "RandomPercentageModifier": 0.1,
    "SequentialModifierStep": 0,
    "SequentialModifierMinimum": 0
  },
  "DamageCalculatorCooldown": 1
}
```

### DamageCalculator Properties

| Property | Type | Description |
|----------|------|-------------|
| `Type` | enum | `Absolute` or `Percent` |
| `Class` | enum | Damage class for modifier application |
| `BaseDamage` | map | Damage amounts keyed by damage type |
| `RandomPercentageModifier` | float | Random variance (+/-) |
| `SequentialModifierStep` | float | Damage change per tick |
| `SequentialModifierMinimum` | float | Minimum damage after modifiers |

### DamageCalculatorCooldown

Time in seconds between damage ticks. Example: `"DamageCalculatorCooldown": 1` = damage every 1 second.

### Common Damage Types

| Type | Description |
|------|-------------|
| `Fire` | Fire/burning damage |
| `Poison` | Poison damage |
| `Ice` | Cold/frost damage |
| `Lightning` | Electric damage |
| `Physical` | Physical damage |

---

## DamageEffects Schema

Visual/audio feedback when damage is dealt by the effect.

```json
{
  "DamageEffects": {
    "WorldSoundEventId": "SFX_Effect_Burn_World",
    "PlayerSoundEventId": "SFX_Effect_Burn_Local",
    "ModelParticles": [ ],
    "WorldParticles": [ ],
    "Knockback": { },
    "CameraEffect": "CameraEffect_Name",
    "StaminaDrainMultiplier": 1.0
  }
}
```

---

## StatModifiers Schema

Apply stat changes while effect is active.

```json
{
  "StatModifiers": {
    "Health": 50,
    "MoveSpeed": -25,
    "AttackDamage": 10
  },
  "ValueType": "Percent"
}
```

### ValueType

| Value | Description |
|-------|-------------|
| `Absolute` | Direct value change (100 = max value) |
| `Percent` | Percentage change |

---

## DamageResistance Schema

Apply damage resistance while effect is active.

```json
{
  "DamageResistance": {
    "Fire": [
      {
        "Amount": 1.0,
        "CalculationType": "Multiplicative"
      }
    ]
  }
}
```

An `Amount` of `1.0` with `Multiplicative` calculation = 100% damage reduction (immunity).

---

## ModelChange / ModelOverride

Change entity appearance while effect is active.

### Simple Model Change
```json
{
  "ModelChange": "Corgi"
}
```

### Complex Model Override (with animations)
```json
{
  "ModelOverride": {
    "Model": "VFX/Spells/Roots/Model.blockymodel",
    "Texture": "VFX/Spells/Roots/Model.png",
    "AnimationSets": {
      "Spawn": {
        "Animations": [
          {
            "Animation": "VFX/Spells/Roots/Spawn.blockyanim",
            "Looping": false
          }
        ]
      },
      "Despawn": {
        "Animations": [
          {
            "Animation": "VFX/Spells/Roots/Despawn.blockyanim",
            "Looping": false
          }
        ]
      }
    }
  }
}
```

---

## Complete Effect Examples

### Burn Effect (DoT + Visuals)
```json
{
  "ApplicationEffects": {
    "EntityBottomTint": "#100600",
    "EntityTopTint": "#cf2302",
    "ScreenEffect": "ScreenEffects/Fire.png",
    "WorldSoundEventId": "SFX_Effect_Burn_World",
    "LocalSoundEventId": "SFX_Effect_Burn_Local",
    "Particles": [{ "SystemId": "Effect_Fire" }],
    "ModelVFXId": "Burn"
  },
  "DamageCalculatorCooldown": 1,
  "DamageCalculator": {
    "BaseDamage": { "Fire": 5 }
  },
  "DamageEffects": {
    "WorldSoundEventId": "SFX_Effect_Burn_World",
    "PlayerSoundEventId": "SFX_Effect_Burn_Local"
  },
  "OverlapBehavior": "Overwrite",
  "Debuff": true,
  "StatusEffectIcon": "UI/StatusEffects/Burn.png",
  "Duration": 3
}
```

### Stun Effect (CC + Disable)
```json
{
  "Duration": 10,
  "ApplicationEffects": {
    "EntityBottomTint": "#ffa93f",
    "ScreenEffect": "ScreenEffects/Snow.png",
    "Particles": [{
      "SystemId": "Stunned",
      "TargetEntityPart": "Entity",
      "TargetNodeName": "Head"
    }],
    "EntityTopTint": "#da72ff",
    "MovementEffects": {
      "DisableAll": true
    },
    "AbilityEffects": {
      "Disabled": ["Primary", "Secondary", "Ability1", "Ability3"]
    }
  }
}
```

### Slow Effect (Speed Reduction)
```json
{
  "Duration": 10,
  "ApplicationEffects": {
    "HorizontalSpeedMultiplier": 0.5
  }
}
```

### Root Effect (Immobilize + Visuals)
```json
{
  "Duration": 10,
  "ModelOverride": {
    "Model": "VFX/Spells/Roots/Model.blockymodel",
    "Texture": "VFX/Spells/Roots/Model.png",
    "AnimationSets": {
      "Spawn": {
        "Animations": [{
          "Animation": "VFX/Spells/Roots/Spawn.blockyanim",
          "Looping": false
        }]
      },
      "Despawn": {
        "Animations": [{
          "Animation": "VFX/Spells/Roots/Despawn.blockyanim",
          "Looping": false
        }]
      }
    }
  },
  "ApplicationEffects": {
    "EntityTopTint": "#008000",
    "EntityBottomTint": "#000000",
    "ScreenEffect": "ScreenEffects/Poison.png",
    "Particles": [{ "SystemId": "Effect_Poison" }],
    "MovementEffects": { "DisableAll": true },
    "KnockbackMultiplier": 0
  }
}
```

### Regen Effect (Healing + Visuals)
```json
{
  "StatModifiers": { "Health": 50 },
  "ValueType": "Percent",
  "DamageCalculatorCooldown": 5,
  "Duration": 5.05,
  "OverlapBehavior": "Overwrite",
  "StatusEffectIcon": "Icons/ItemsGenerated/Potion_Health.png",
  "ApplicationEffects": {
    "Particles": [{
      "SystemId": "Potion_Health_Heal",
      "TargetEntityPart": "Entity",
      "TargetNodeName": "Pelvis"
    }]
  },
  "StatModifierEffects": {
    "WorldParticles": [{ "SystemId": "Potion_Health_Implosion" }],
    "WorldSoundEventId": "SFX_Deployable_Totem_Heal_Despawn"
  }
}
```

### Morph Effect (Model Change)
```json
{
  "StatusEffectIcon": "Icons/ItemsGenerated/Potion_Purify.png",
  "OverlapBehavior": "Overwrite",
  "Duration": 60,
  "ModelChange": "Corgi",
  "ApplicationEffects": {
    "Particles": [{ "SystemId": "Potion_Morph_Burst" }],
    "WorldSoundEventId": "SFX_Wolf_Alerted"
  }
}
```

### Immunity Effect (Damage Resistance)
```json
{
  "Infinite": true,
  "DamageResistance": {
    "Fire": [{
      "Amount": 1.0,
      "CalculationType": "Multiplicative"
    }]
  }
}
```

---

## Java API Reference

### EffectControllerComponent

The component that manages active effects on an entity.

#### Getting the Component
```java
ComponentType<EntityStore, EffectControllerComponent> effectType = 
    EffectControllerComponent.getComponentType();
EffectControllerComponent effects = componentAccessor.getComponent(entityRef, effectType);
```

#### Adding Effects
```java
// Get effect from asset registry
EntityEffect burnEffect = EntityEffect.getAssetMap().getAsset("Status/Burn");

// Add effect with default duration
effects.addEffect(entityRef, burnEffect, componentAccessor);

// Add effect with custom duration
effects.addEffect(entityRef, burnEffect, 5.0f, OverlapBehavior.EXTEND, componentAccessor);

// Add infinite effect
effects.addInfiniteEffect(entityRef, effectIndex, entityEffect, componentAccessor);
```

#### Removing Effects
```java
int effectIndex = EntityEffect.getAssetMap().getIndex("Status/Burn");
effects.removeEffect(entityRef, effectIndex, RemovalBehavior.COMPLETE, componentAccessor);
```

#### Checking Effect State
```java
// Check if effect is active
boolean hasBurn = effects.hasEffect(burnEffectIndex);

// Check invulnerability
boolean isInvulnerable = effects.isInvulnerable();

// Set invulnerability
effects.setInvulnerable(true);
```

### EntityEffect Asset Access
```java
// Get asset store
AssetStore<String, EntityEffect, ?> store = EntityEffect.getAssetStore();

// Get asset map for lookups
IndexedLookupTableAssetMap<String, EntityEffect> assetMap = EntityEffect.getAssetMap();

// Get effect by ID
EntityEffect effect = assetMap.getAsset("Status/Burn");

// Get effect index (for fast lookups)
int effectIndex = assetMap.getIndex("Status/Burn");
```

---

## Projectile System

Projectiles are used by triggered effects (like `spawn_projectile` in affixes) and require **two JSON files** to function.

### Required Files

| File Type | Location | Purpose |
|-----------|----------|---------|
| Projectile Definition | `Server/<Mod>/Projectiles/<Name>.json` | Physics, damage, explosions, sounds |
| Model Asset | `Server/<Mod>/Models/Projectiles/<Name>.json` | Visual appearance, particles, light |

### How They Connect

```
Affix "spawn_projectile" Effect
  └─ "ProjectileId": "hyforged:meteor"
       └─ Server/Hyforged/Projectiles/Meteor.json
            └─ "Appearance": "Hyforged/Meteor"
                 └─ Server/Hyforged/Models/Projectiles/Meteor.json
                      └─ "Model": "Items/Projectiles/Fireball.blockymodel"
```

### Projectile Definition Schema

Location: `Server/Hyforged/Projectiles/<Name>.json`

```json
{
  "Appearance": "Hyforged/Meteor",
  "Radius": 0.3,
  "Height": 0.3,
  "MuzzleVelocity": 30,
  "TerminalVelocity": 80,
  "Gravity": 15,
  "Bounciness": 0,
  "ImpactSlowdown": 0,
  "SticksVertically": false,
  "TimeToLive": 10,
  "Damage": 80,
  "DeadTime": 0.1,
  "HitSoundEventId": "SFX_Fireball_Hit",
  "MissSoundEventId": "SFX_Fireball_Miss",
  "DeathSoundEventId": "SFX_Explosion",
  "HitParticles": { "SystemId": "Impact_Fire" },
  "MissParticles": { "SystemId": "Explosion_Medium" },
  "DeathParticles": { "SystemId": "Explosion_Large" },
  "DeathEffectsOnHit": true,
  "ExplosionConfig": { }
}
```

### Projectile Properties Reference

| Property | Type | Description |
|----------|------|-------------|
| `Appearance` | string | Reference to Model Asset (without .json) |
| `Radius` | double | Collision radius |
| `Height` | double | Collision height |
| `MuzzleVelocity` | double | Initial speed when spawned |
| `TerminalVelocity` | double | Maximum speed |
| `Gravity` | double | Gravity strength (0 = no drop) |
| `Bounciness` | double | 0-1, how much it bounces off surfaces |
| `SticksVertically` | boolean | Stick to surfaces on hit |
| `TimeToLive` | double | Seconds before auto-despawn (0 = instant on miss) |
| `Damage` | integer | Base damage on hit |
| `DeadTime` | double | Delay before despawn after hit |
| `DeathEffectsOnHit` | boolean | Play death effects when hitting entity |

### Shot Properties

| Property | Type | Description |
|----------|------|-------------|
| `VerticalCenterShot` | double | Vertical spawn offset |
| `HorizontalCenterShot` | double | Horizontal spawn offset |
| `DepthShot` | double | Forward spawn offset |
| `PitchAdjustShot` | boolean | Adjust for pitch when spawning |
| `ComputeYaw` | boolean | Rotate to face travel direction |
| `ComputePitch` | boolean | Pitch to match trajectory |
| `ComputeRoll` | boolean | Apply roll based on velocity |

### ExplosionConfig Schema

For area-of-effect damage on impact:

```json
{
  "ExplosionConfig": {
    "DamageEntities": true,
    "DamageBlocks": false,
    "BlockDamageRadius": 0,
    "EntityDamageRadius": 5,
    "EntityDamageFalloff": 1.0,
    "Knockback": {
      "Type": "Point",
      "Force": 8,
      "VelocityType": "Set",
      "VelocityConfig": {
        "AirResistance": 0.97,
        "GroundResistance": 0.94,
        "Threshold": 3.0
      }
    }
  }
}
```

| Property | Type | Description |
|----------|------|-------------|
| `DamageEntities` | boolean | Damage entities in radius |
| `DamageBlocks` | boolean | Damage/destroy blocks |
| `EntityDamageRadius` | double | Radius for entity damage |
| `EntityDamageFalloff` | double | Damage reduction over distance |
| `Knockback.Type` | string | `Point` (away from center) or `Direction` |
| `Knockback.Force` | double | Knockback strength |

---

## Model Asset Schema (Projectiles)

Location: `Server/Hyforged/Models/Projectiles/<Name>.json`

```json
{
  "Model": "Items/Projectiles/Fireball.blockymodel",
  "Texture": "Items/Projectiles/Fireball.png",
  "HitBox": {
    "Max": { "X": 0.3, "Y": 0.3, "Z": 0.3 },
    "Min": { "X": -0.3, "Y": -0.3, "Z": -0.3 }
  },
  "MinScale": 2,
  "MaxScale": 2,
  "Particles": [
    {
      "SystemId": "Fire_Projectile",
      "TargetNodeName": ""
    }
  ],
  "Light": {
    "Color": "#ff4400"
  }
}
```

### Model Asset Properties

| Property | Type | Description |
|----------|------|-------------|
| `Model` | string | Path to .blockymodel file |
| `Texture` | string | Path to texture file |
| `HitBox` | object | Visual bounding box |
| `MinScale` / `MaxScale` | double | Random scale range |
| `Particles` | array | Attached particle systems |
| `Light` | object | Dynamic light emitted |

### Reusing Existing Models

You can reference Hytale's built-in models:
- `Items/Projectiles/Fireball.blockymodel` — Fire orb
- `Items/Projectiles/Projectile.blockymodel` — Generic projectile
- `Items/Projectiles/Tornado.blockymodel` — Tornado effect

Or create custom models in `Common/Models/`.

---

## Complete Projectile Examples

### Meteor (Large AOE Fire)

**Projectile:** `Server/Hyforged/Projectiles/Meteor.json`
```json
{
  "Appearance": "Hyforged/Meteor",
  "Radius": 0.5,
  "Height": 0.5,
  "MuzzleVelocity": 25,
  "TerminalVelocity": 60,
  "Gravity": 20,
  "TimeToLive": 15,
  "Damage": 80,
  "DeadTime": 0,
  "MissSoundEventId": "SFX_Explosion",
  "DeathSoundEventId": "SFX_Explosion",
  "MissParticles": { "SystemId": "Explosion_Large" },
  "DeathParticles": { "SystemId": "Explosion_Large" },
  "DeathEffectsOnHit": true,
  "ExplosionConfig": {
    "DamageEntities": true,
    "EntityDamageRadius": 4,
    "EntityDamageFalloff": 0.5,
    "Knockback": { "Type": "Point", "Force": 10 }
  }
}
```

**Model:** `Server/Hyforged/Models/Projectiles/Meteor.json`
```json
{
  "Model": "Items/Projectiles/Fireball.blockymodel",
  "Texture": "Items/Projectiles/Fireball.png",
  "HitBox": {
    "Max": { "X": 0.5, "Y": 0.5, "Z": 0.5 },
    "Min": { "X": -0.5, "Y": -0.5, "Z": -0.5 }
  },
  "MinScale": 3,
  "MaxScale": 3,
  "Particles": [
    { "SystemId": "Fire_Projectile", "TargetNodeName": "" },
    { "SystemId": "Smoke_Trail", "TargetNodeName": "" }
  ],
  "Light": { "Color": "#ff6600" }
}
```

### Arcane Bolt (Fast Multi-Shot)

**Projectile:** `Server/Hyforged/Projectiles/ArcaneBolt.json`
```json
{
  "Appearance": "Hyforged/ArcaneBolt",
  "Radius": 0.1,
  "Height": 0.2,
  "MuzzleVelocity": 50,
  "TerminalVelocity": 50,
  "Gravity": 0,
  "TimeToLive": 5,
  "Damage": 15,
  "DeadTime": 0,
  "HitSoundEventId": "SFX_Magic_Impact",
  "HitParticles": { "SystemId": "Impact_Arcane" },
  "MissParticles": { "SystemId": "Impact_Arcane" }
}
```

**Model:** `Server/Hyforged/Models/Projectiles/ArcaneBolt.json`
```json
{
  "Model": "Items/Projectiles/Fireball.blockymodel",
  "Texture": "Items/Projectiles/Fireball_Textures/Void.png",
  "HitBox": {
    "Max": { "X": 0.15, "Y": 0.15, "Z": 0.15 },
    "Min": { "X": -0.15, "Y": -0.15, "Z": -0.15 }
  },
  "MinScale": 0.8,
  "MaxScale": 1.0,
  "Particles": [
    { "SystemId": "Effect_Arcane", "TargetNodeName": "" }
  ],
  "Light": { "Color": "#9900ff" }
}
```

---

## Integration with Hyforged Affixes

When creating NPC affixes that apply effects, use the `apply_effect` triggered effect:

```json
{
  "Id": "hyforged:poisonous",
  "Type": "npc_rare",
  "DisplayName": "Poisonous",
  "Description": "Attacks poison enemies.",
  "TriggeredEffects": [
    {
      "Trigger": "on_hit",
      "Effect": "apply_effect",
      "Params": {
        "effect_id": "Status/Poison",
        "duration": 8,
        "chance": 0.25
      }
    }
  ]
}
```

### Custom Effect for Affixes

If Hytale's built-in effects don't match your needs, create custom effects:

1. Create effect JSON in `src/main/resources/Server/Hyforged/Entity/Effects/`
2. Reference with `hyforged:Effect_Name` in affix `apply_effect`

```json
{
  "Id": "hyforged:arcane-burn",
  "DisplayName": "effect.hyforged.arcane_burn.name",
  "Duration": 5,
  "Debuff": true,
  "DamageCalculatorCooldown": 0.5,
  "DamageCalculator": {
    "BaseDamage": { "Arcane": 15 }
  },
  "ApplicationEffects": {
    "EntityTopTint": "#9900ff",
    "EntityBottomTint": "#330066",
    "Particles": [{ "SystemId": "Effect_Arcane" }]
  }
}
```

---

## Best Practices

1. **Keep effects modular** - Separate visual effects from gameplay effects when possible
2. **Use OverlapBehavior wisely** - `EXTEND` for stacking DoTs, `OVERWRITE` for refreshing CC
3. **Provide visual feedback** - Always include tints/particles for debuffs so players know what's affecting them
4. **Test duration carefully** - Balance duration against DamageCalculatorCooldown for DoTs
5. **Consider immunity frames** - Use `Invulnerable: true` for short dodge effects to prevent chain-stunning
6. **Namespace custom effects** - Use `hyforged:` prefix for Hyforged-specific effects
