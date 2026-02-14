---
name: hytale-npc-templates
description: Documents Hytale's JSON-based NPC template and behavior system for defining NPC AI via data-driven templates. Covers template structure, variants, states, substates, sensors, actions, motions, state transitions, components, detection (sight/hearing), combat (melee attacks, chaining), inter-NPC interaction (beacons), leashing, searching, and reusable instruction components. Use when creating NPC behavior, defining NPC templates, adding NPC states, configuring NPC detection/combat, or building reusable NPC components. Triggers - NPC template, NPC behavior, NPC state, NPC sensor, NPC action, NPC motion, state transition, NPC combat, NPC detection, NPC component, Template_, Variant, BlankTemplate, Instructions, StartState, Random action, Timeout, PlayAnimation, StateTransitions, Component_Instruction, Component_Sensor, Intelligent_Chase, Soft_Leash, Standard_Detection, Damage_Check, beacon, NPC group, AttitudeGroup, DefaultPlayerAttitude, InteractionVars, melee attack, attack chaining, Root Interaction.
---

# Hytale NPC Template & Behavior System

Use this skill when defining NPC behavior through JSON templates. This covers the data-driven side of NPC creation — how NPCs think, act, detect threats, fight, interact with other NPCs, and transition between behavioral states. For programmatic NPC spawning via Java, see the `hytale-spawning-npcs` skill instead.

> **Prerequisite:** Familiarity with JSON asset structure under `Server/` directories and the Hytale ECS architecture.

---

## Quick Reference

| Concept | Description |
|---------|-------------|
| **Template** | Abstract JSON file defining base NPC behavior, parameters, and states |
| **Variant** | Concrete NPC role that extends a template with specific parameter overrides |
| **State** | A top-level behavioral mode (e.g., `Idle`, `Sleep`, `Combat`) |
| **Substate** | A state nested within another, prefixed with `.` (e.g., `.Default`, `.Guard`) |
| **Sensor** | Condition that gates instruction execution (e.g., `State`, `Target`, `Beacon`, `Mob`, `Damage`) |
| **Action** | Operations performed when sensor conditions are met (e.g., `State`, `Timeout`, `Random`, `Attack`) |
| **Motion** | Movement behavior (e.g., `Seek`, `Wander`, `Nothing`, `Follow_Path`) |
| **StateTransition** | Actions performed sequentially when transitioning between states (e.g., animations) |
| **Component** | Reusable instruction/sensor module referenced via `"Reference"` |
| **Parameter** | Configurable value exposed in the template's `Parameters` block |
| **Beacon** | Message-based inter-NPC communication system |
| **NPC Group** | Named set of NPC roles used for filtering (attitudes, beacons, food targets) |
| **Attitude Group** | Defines Friendly/Hostile/Neutral relationships between NPC groups |

---

## File Locations

| File Type | Path |
|-----------|------|
| NPC Templates | `Server/NPC/Templates/Template_<Name>.json` |
| NPC Variants (Roles) | `Server/NPC/Roles/<Name>.json` |
| NPC Components | `Server/NPC/Components/Component_<Class>_<Name>.json` |
| NPC Groups | `Server/NPC/Groups/<GroupName>.json` |
| Attitude Groups | `Server/NPC/AttitudeGroups/<Name>.json` |
| Appearance files | `Server/NPC/Appearances/<Name>.json` |
| Root Interactions | `Server/Item/RootInteractions/Root_NPC_<Name>.json` |
| Attack Interactions | `Server/Item/Interactions/<Name>.json` |
| Spawn Beacons | `Server/NPC/SpawnBeacons/<Name>.json` |

---

## Template Structure

### Blank Template (Starting Point)

Always start from `BlankTemplate` and customize. A template is `"Type": "Abstract"` and defines defaults through `Parameters`.

```json
{
  "Type": "Abstract",
  "Parameters": {
    "Appearance": {
      "Value": "Bear_Grizzly",
      "Description": "Model to be used"
    },
    "DropList": {
      "Value": "Empty",
      "Description": "Drop Items"
    },
    "MaxHealth": {
      "Value": 100,
      "Description": "Max health for the NPC"
    },
    "NameTranslationKey": {
      "Value": "server.npcRoles.Template.name",
      "Description": "Translation key for NPC name display"
    }
  },
  "Appearance": { "Compute": "Appearance" },
  "DropList": { "Compute": "DropList" },
  "MaxHealth": { "Compute": "MaxHealth" },
  "MotionControllerList": [
    {
      "Type": "Walk",
      "MaxWalkSpeed": 3,
      "Gravity": 10,
      "MaxFallSpeed": 8,
      "Acceleration": 10
    }
  ],
  "Instructions": [
    {
      "Sensor": {
        "Type": "Any"
      },
      "BodyMotion": {
        "Type": "Nothing"
      }
    }
  ],
  "NameTranslationKey": { "Compute": "NameTranslationKey" }
}
```

### Variant (Role) File

A variant extends a template with concrete parameter values. Place next to the template.

```json
{
  "Type": "Variant",
  "Reference": "Template_Goblin_Ogre",
  "Modify": {
    "Appearance": "Goblin",
    "MaxHealth": 124
  }
}
```

Variants can also override `InteractionVars`, `Parameters`, and `NameTranslationKey`.

---

## Parameters

Parameters are defined in the `"Parameters"` block and referenced via `{ "Compute": "ParamName" }`. They support computed expressions like `"Compute": "ViewRange / DistractedPenalty"`.

```json
"Parameters": {
  "Appearance": {
    "Value": "Bear_Grizzly",
    "Description": "Model to be used"
  },
  "ViewRange": {
    "Value": 15,
    "Description": "View range in blocks"
  },
  "DistractedPenalty": {
    "Value": 2,
    "Description": "Factor by which view/hearing range is divided when distracted"
  }
}
```

**Computed expressions:** `{ "Compute": "ViewRange / DistractedPenalty" }` divides ViewRange by DistractedPenalty at runtime.

---

## States & Substates

### Setting the Start State

```json
"StartState": "Idle",
```

### Top-Level States

Top-level states are behavioral modes like `Idle`, `Sleep`, `Eat`, `Combat`, `Alerted`, `ReturnHome`, `Search`.

```json
"Instructions": [
  {
    "Sensor": { "Type": "State", "State": "Idle" },
    "Instructions": [ ... ]
  },
  {
    "Sensor": { "Type": "State", "State": "Sleep" },
    "Instructions": [ ... ]
  },
  {
    "Sensor": { "Type": "State", "State": "Combat" },
    "Instructions": [ ... ]
  }
]
```

### Substates

Substates are nested within a parent state and prefixed with `.`. The `.Default` substate is used automatically when entering the parent state.

```json
{
  "Sensor": { "Type": "State", "State": "Idle" },
  "Instructions": [
    {
      "Sensor": { "Type": "State", "State": ".Default" },
      "Instructions": [ ... ]
    },
    {
      "Sensor": { "Type": "State", "State": ".Guard" },
      "Instructions": [ ... ]
    }
  ]
}
```

### Switching States

Use a `State` action to switch:

```json
{ "Type": "State", "State": "Combat" }
```

For substates:

```json
{ "Type": "State", "State": ".Guard" }
```

---

## Sensors

Sensors are conditions that gate instruction execution.

| Sensor Type | Description | Key Fields |
|------------|-------------|------------|
| `State` | Matches current NPC state | `State` |
| `Any` | Always matches | `Once` (execute only once) |
| `Target` | Detects locked/nearby target | `Range`, `TargetSlot`, `Filters` |
| `Mob` | Detects nearby NPCs | `Range`, `Filters` ([`NPCGroup`, `LineOfSight`]) |
| `Beacon` | Listens for inter-NPC messages | `Message`, `Range`, `TargetSlot` |
| `Damage` | Reacts to incoming damage | `Combat`, `TargetSlot` |
| `Leash` | Checks distance from spawn | `Range` |
| `And` | Combines multiple sensors | `Sensors` (array) |
| `Reference` | Uses a reusable sensor component | Component name |

### Sensor with Filters

```json
{
  "Sensor": {
    "Type": "Target",
    "Range": { "Compute": "AttackDistance" },
    "Filters": [
      { "Type": "LineOfSight" }
    ]
  },
  "Actions": [ ... ]
}
```

### Mob Sensor (NPC Group Filtering)

```json
{
  "Sensor": {
    "Type": "Mob",
    "Range": 2.5,
    "Filters": [
      { "Type": "NPCGroup", "IncludeGroups": { "Compute": "FoodNPCGroups" } },
      { "Type": "LineOfSight" }
    ]
  }
}
```

---

## Actions

Actions are operations executed when sensor conditions are met.

| Action Type | Description | Key Fields |
|------------|-------------|------------|
| `State` | Switch to a different state | `State` |
| `ParentState` | Switch using imported state name | `State` (from `_ImportStates`) |
| `Random` | Randomly pick a weighted action | `Actions` (array with `Weight` + `Action`) |
| `Timeout` | Wait for a duration | `Delay` (`[min, max]` or fixed) |
| `PlayAnimation` | Play an animation | `Slot`, `Animation` |
| `Attack` | Execute an attack interaction | `Attack`, `AttackPauseRange` |
| `Inventory` | Manipulate NPC inventory | `Operation`, `Item`, `Slot`, `UseTarget` |
| `Beacon` | Send message to nearby NPCs | `Message`, `TargetGroups`, `SendTargetSlot` |
| `TriggerSpawnBeacon` | Trigger a manual spawn beacon | `BeaconSpawn`, `Range` |
| `SetStat` | Set an entity stat | `Stat`, `Value` |
| `Remove` | Remove the target entity | — |
| `Despawn` | Despawn this NPC | — |
| `Sequence` | Execute multiple actions in same tick | `Actions` (array) |

### Random Action (Weighted State Selection)

```json
{
  "Actions": [
    {
      "Type": "Random",
      "Actions": [
        { "Weight": 70, "Action": { "Type": "State", "State": ".Guard" } },
        { "Weight": 20, "Action": { "Type": "State", "State": "Sleep" } },
        { "Weight": 10, "Action": { "Type": "State", "State": "Eat" } }
      ]
    }
  ]
}
```

### Timeout with State Switch

```json
{
  "Continue": true,
  "ActionsBlocking": true,
  "Actions": [
    { "Type": "Timeout", "Delay": [15, 30] },
    { "Type": "State", "State": ".Default" }
  ]
}
```

### Inventory Actions

| Operation | Description |
|-----------|-------------|
| `SetHotbar` | Place an item in a hotbar slot |
| `EquipHotbar` | Switch active hotbar slot |

```json
{
  "Type": "Inventory",
  "Operation": "SetHotbar",
  "Item": { "Compute": "EatItem" },
  "Slot": 2,
  "UseTarget": false
}
```

> **`UseTarget: false`** is required to act on the NPC itself, not its target.

---

## Instruction Flags

| Flag | Description |
|------|-------------|
| `Continue` | If `true`, continue evaluating subsequent instructions even if this one matches |
| `ActionsBlocking` | If `true`, wait for all actions to complete before proceeding |
| `Once` | (On sensors) Execute only once when first entering the state |

**Common pattern** — timeout then switch state:

```json
{
  "Continue": true,
  "ActionsBlocking": true,
  "Actions": [
    { "Type": "Timeout", "Delay": [5, 10] },
    { "Type": "State", "State": "Idle" }
  ]
}
```

---

## Motions

Motions control NPC movement. Set via `BodyMotion` or `HeadMotion` on instructions.

| Motion Type | Description | Key Fields |
|------------|-------------|------------|
| `Nothing` | Stand still | — |
| `Seek` | Move toward target/position | `SlowDownDistance`, `StopDistance`, `RelativeSpeed`, `UsePathfinder` |
| `Wander` | Random wandering | `MaxHeadingChange`, `RelativeSpeed` |
| `WanderInCircle` | Circular wandering | `Radius`, `MaxHeadingChange`, `RelativeSpeed` |
| `Watch` | Look at target (head only) | — |
| `Aim` | Aim at target (combat) | `RelativeTurnSpeed` |
| `Sequence` | Chain motions | `Motions` (array), `Looped` |
| `Timer` | Motion for a duration | `Time`, `Motion` |

### MotionControllerList

Defined at template level:

```json
"MotionControllerList": [
  {
    "Type": "Walk",
    "MaxWalkSpeed": 3,
    "Gravity": 10,
    "MaxFallSpeed": 8,
    "Acceleration": 10
  }
]
```

### Head Motion (Watch Target)

```json
{
  "Continue": true,
  "Sensor": { "Type": "Target", "Range": { "Compute": "AlertedRange" } },
  "HeadMotion": { "Type": "Watch" }
}
```

### Body Motion with Pathfinding

```json
{
  "Sensor": { "Type": "Leash", "Range": { "Compute": "LeashDistance * 0.3" } },
  "BodyMotion": {
    "Type": "Seek",
    "SlowDownDistance": { "Compute": "LeashDistance * 0.4" },
    "StopDistance": { "Compute": "LeashDistance * 0.2" },
    "RelativeSpeed": 0.8,
    "UsePathfinder": true
  }
}
```

### Search Wander Pattern

```json
"BodyMotion": {
  "Type": "Sequence",
  "Motions": [
    {
      "Type": "Timer",
      "Time": [3, 6],
      "Motion": { "Type": "Wander", "MaxHeadingChange": 1, "RelativeSpeed": 0.5 }
    },
    {
      "Type": "Sequence",
      "Looped": true,
      "Motions": [
        {
          "Type": "Timer",
          "Time": [3, 6],
          "Motion": { "Type": "WanderInCircle", "Radius": 10, "MaxHeadingChange": 60, "RelativeSpeed": 0.5 }
        },
        {
          "Type": "Timer",
          "Time": [2, 3],
          "Motion": { "Type": "Nothing" }
        }
      ]
    }
  ]
}
```

---

## State Transitions

State transitions define actions executed **sequentially** when switching between states. Defined in `"StateTransitions"` at the template level (above `"Instructions"`).

An empty `"From"` or `"To"` array means **all states**.

```json
"StateTransitions": [
  {
    "States": [
      { "From": ["Idle"], "To": ["Sleep"] }
    ],
    "Actions": [
      { "Type": "PlayAnimation", "Slot": "Status", "Animation": "Laydown" },
      { "Type": "Timeout", "Delay": [1, 1] }
    ]
  },
  {
    "States": [
      { "From": ["Sleep"], "To": [] }
    ],
    "Actions": [
      { "Type": "PlayAnimation", "Slot": "Status", "Animation": "Wake" },
      { "Type": "Timeout", "Delay": [1, 1] }
    ]
  }
]
```

### Inventory State Transitions (Equip/Unequip)

```json
{
  "States": [
    { "From": ["Idle"], "To": ["Eat"] }
  ],
  "Actions": [
    { "Type": "Inventory", "Operation": "SetHotbar", "Item": { "Compute": "EatItem" }, "Slot": 2, "UseTarget": false },
    { "Type": "Inventory", "Operation": "EquipHotbar", "Slot": 2, "UseTarget": false }
  ]
}
```

### Combat Entry Transition (Warn Allies)

```json
{
  "States": [
    { "From": [], "To": ["Combat"] }
  ],
  "Actions": [
    { "Type": "PlayAnimation", "Slot": "Status" },
    { "Type": "Beacon", "Message": "Goblin_Ogre_Warn", "TargetGroups": { "Compute": "WarnGroups" }, "SendTargetSlot": "LockedTarget" }
  ]
}
```

---

## Reusable Components

Components are reusable chunks of instruction/sensor logic. They use `"Type": "Component"` and expose parameters.

### Component Structure

```json
{
  "Type": "Component",
  "Class": "Instruction",
  "Parameters": {
    "_ImportStates": ["Main"],
    "Animation": {
      "Value": "",
      "Description": "The animation to play"
    },
    "Duration": {
      "Value": [3, 5],
      "Description": "The amount of time to wait before transitioning"
    }
  },
  "Content": {
    "Continue": true,
    "Instructions": [
      {
        "Reference": "Component_Instruction_State_Timeout",
        "Modify": {
          "_ExportStates": ["Main"],
          "Delay": { "Compute": "Duration" }
        }
      },
      {
        "Reference": "Component_Instruction_Play_Animation",
        "Modify": {
          "Animation": { "Compute": "Animation" }
        }
      }
    ]
  }
}
```

### Using Components (Reference + Modify)

```json
{
  "Reference": "Component_Instruction_Intelligent_Idle_Motion_Follow_Path"
}
```

With parameter overrides:

```json
{
  "Reference": "Component_Instruction_State_Timeout",
  "Modify": {
    "_ExportStates": ["Idle.Default"],
    "Delay": [30, 45]
  }
}
```

### State Import/Export Pattern

- `_ImportStates`: Declares named state slots a component expects from the user.
- `_ExportStates`: Provides concrete state names to fill those slots.
- `ParentState` action: Uses the imported state name to switch states.

```json
// In component:
"_ImportStates": ["Main"],
"Actions": [
  { "Type": "ParentState", "State": "Main" }
]

// When referencing:
"Modify": {
  "_ExportStates": ["Idle.Default"]
}
```

### Common Built-In Components

| Component | Class | Purpose |
|-----------|-------|---------|
| `Component_Instruction_Intelligent_Idle_Motion_Follow_Path` | Instruction | Follow a path marker for idle guard behavior |
| `Component_Instruction_Intelligent_Chase` | Instruction | Smart chase behavior with pathfinding and lost-target handling |
| `Component_Instruction_Soft_Leash` | Instruction | Return home if NPC goes too far from spawn |
| `Component_Instruction_Damage_Check` | Instruction | React to incoming damage |
| `Component_Instruction_Play_Animation` | Instruction | Play a named animation |
| `Component_Instruction_State_Timeout` | Instruction | Wait then switch to a parent state |
| `Component_Instruction_Play_Animation_In_State_For_Duration` | Instruction | Play animation for a random duration then switch state |
| `Component_Sensor_Standard_Detection` | Sensor | Sight + hearing detection with attitude filtering |
| `Component_Sensor_Lost_Target_Detection` | Sensor | Detect a previously-seen target |

---

## Detection System

### Standard Detection Sensor

Handles sight (view range + cone + line of sight) and hearing (range-based, ignores crouching/still targets, blocked by walls).

```json
{
  "Sensor": {
    "Reference": "Component_Sensor_Standard_Detection",
    "Modify": {
      "ViewRange": { "Compute": "ViewRange" },
      "ViewSector": { "Compute": "ViewSector" },
      "HearingRange": { "Compute": "HearingRange" },
      "ThroughWalls": false,
      "AbsoluteDetectionRange": { "Compute": "AbsoluteDetectionRange" },
      "Attitudes": ["Hostile"]
    }
  },
  "Actions": [
    { "Type": "State", "State": "Alerted" }
  ]
}
```

**Detection order:**
1. **Absolute detection range** — guaranteed detection within this radius
2. **View range/sector** — line-of-sight check within the view cone
3. **Hearing range** — detects walking/running (non-crouching) targets, blocked by walls

### Reduced Detection (Distracted States)

Divide ranges by a penalty factor for sleeping/eating states:

```json
"ViewRange": { "Compute": "ViewRange / DistractedPenalty" },
"HearingRange": { "Compute": "ViewRange / DistractedPenalty" }
```

### Damage Check Component

Detects incoming damage and transitions to combat/alert:

```json
{
  "Reference": "Component_Instruction_Damage_Check",
  "Modify": {
    "_ExportStates": ["Alerted", "Alerted"],
    "AlertedRange": { "Compute": "AlertedRange" }
  }
}
```

### Attitude Groups

Define NPC relationship groups:

```json
{
  "Groups": {
    "Friendly": ["Goblin"],
    "Hostile": []
  }
}
```

### Template Attitude Configuration

```json
"DefaultPlayerAttitude": "Hostile",
"DefaultNPCAttitude": "Ignore",
"AttitudeGroup": { "Compute": "AttitudeGroup" }
```

---

## Combat System

### Alerted State Pattern

Transitional state between detection and combat:

```json
{
  "Sensor": { "Type": "State", "State": "Alerted" },
  "Instructions": [
    {
      "Reference": "Component_Instruction_Play_Animation",
      "Modify": { "Animation": "Alerted" }
    },
    {
      "Continue": true,
      "Sensor": {
        "Type": "Target",
        "Range": { "Compute": "AlertedRange" },
        "Filters": [ { "Type": "LineOfSight" } ]
      },
      "HeadMotion": { "Type": "Watch" }
    },
    {
      "Sensor": { "Type": "Target", "Range": { "Compute": "AlertedRange" } },
      "ActionsBlocking": true,
      "Actions": [
        { "Type": "Timeout", "Delay": [1, 1] },
        { "Type": "State", "State": "Combat" }
      ]
    },
    {
      "Actions": [ { "Type": "State", "State": "Idle" } ]
    }
  ]
}
```

### Combat State with Chase Substate

```json
{
  "Sensor": { "Type": "State", "State": "Combat" },
  "Instructions": [
    {
      "Sensor": { "Type": "State", "State": ".Chase" },
      "Instructions": [
        {
          "Sensor": {
            "Type": "Target",
            "Range": { "Compute": "AttackDistance" },
            "Filters": [ { "Type": "LineOfSight" } ]
          },
          "Actions": [ { "Type": "State", "State": ".Default" } ]
        },
        {
          "Reference": "Component_Instruction_Soft_Leash",
          "Modify": {
            "_ExportStates": ["ReturnHome"],
            "LeashDistance": { "Compute": "LeashDistance" },
            "LeashMinPlayerDistance": { "Compute": "LeashMinPlayerDistance" },
            "LeashTimer": { "Compute": "LeashTimer" },
            "HardLeashDistance": { "Compute": "HardLeashDistance" }
          }
        },
        {
          "Reference": "Component_Instruction_Intelligent_Chase",
          "Modify": {
            "_ExportStates": ["Search", "Search", "ReturnHome"],
            "ViewRange": { "Compute": "AlertedRange * 2" },
            "HearingRange": { "Compute": "HearingRange * 2" },
            "StopDistance": 0.1,
            "RelativeSpeed": 0.5
          }
        }
      ]
    },
    {
      "$Comment": "NPC melee attack",
      "Sensor": {
        "Type": "Target",
        "Range": { "Compute": "AttackDistance" },
        "Filters": [ { "Type": "LineOfSight" } ],
        "ActionsBlocking": true,
        "Actions": [
          {
            "Type": "Attack",
            "Attack": { "Compute": "Attack" },
            "AttackPauseRange": { "Compute": "AttackPauseRange" }
          },
          { "Type": "Timeout", "Delay": [0.2, 0.2] }
        ],
        "HeadMotion": {
          "Type": "Aim",
          "RelativeTurnSpeed": { "Compute": "CombatRelativeTurnSpeed" }
        }
      },
      "Actions": [ { "Type": "State", "State": ".Chase" } ]
    }
  ]
}
```

### Key Combat Parameters

```json
"Attack": {
  "Value": "Root_NPC_Goblin_Ogre_Attack",
  "Description": "The attack to use."
},
"AttackDistance": {
  "Value": 2,
  "Description": "The distance at which an NPC will execute attacks"
},
"AttackPauseRange": {
  "Value": [1.5, 2],
  "Description": "Absolute minimum time before a second attack"
},
"CombatRelativeTurnSpeed": {
  "Value": 1.5,
  "Description": "Turn speed modifier in combat"
},
"LeashDistance": {
  "Value": 20,
  "Description": "Range after which NPC starts wanting to return"
},
"HardLeashDistance": {
  "Value": 60,
  "Description": "Absolute maximum from leash position"
}
```

---

## Attack Interactions

### Root Interaction (Chaining Attacks)

```json
{
  "Interactions": [
    {
      "Type": "Chaining",
      "ChainId": "Slashes",
      "ChainingAllowance": 15,
      "Next": [
        "Goblin_Ogre_Swing_Left",
        "Goblin_Ogre_Swing_Right",
        "Goblin_Ogre_Swing_Down"
      ]
    }
  ],
  "Tags": {
    "Attack": ["Melee"]
  }
}
```

NPCs attack in sequence: first `Swing_Left`, then `Swing_Right` (if within 15s), then `Swing_Down`.

### Individual Attack Interaction

```json
{
  "Type": "Simple",
  "Effects": {
    "ItemPlayerAnimationsId": "Goblin_Club",
    "ItemAnimationId": "SwingLeft"
  },
  "RunTime": 0.2,
  "Next": {
    "Type": "Selector",
    "RunTime": 0.25,
    "Selector": {
      "Id": "Horizontal",
      "Direction": "ToLeft",
      "TestLineOfSight": true,
      "ExtendTop": 0.5,
      "ExtendBottom": 2,
      "StartDistance": 0.1,
      "EndDistance": 3.5,
      "Length": 60,
      "RollOffset": 0,
      "YawStartOffset": -30
    },
    "HitEntity": {
      "Interactions": [
        {
          "Parent": "DamageEntityParent",
          "DamageCalculator": {
            "BaseDamage": { "Physical": 8 },
            "RandomPercentageModifier": 0.1
          },
          "DamageEffects": {
            "Knockback": { "Force": 0.5, "RelativeX": -5, "RelativeZ": -5, "VelocityY": 5 },
            "WorldSoundEventId": "SFX_Unarmed_Impact",
            "WorldParticles": [ { "SystemId": "Impact_Blade_01" } ]
          }
        }
      ]
    },
    "Next": {
      "Type": "Simple",
      "RunTime": 0.1
    }
  }
}
```

### InteractionVars (Template-Level Damage Override)

Templates can define overridable interaction variable slots:

```json
"InteractionVars": {
  "Melee_Damage": {
    "Interactions": [
      {
        "Parent": "NPC_Attack_Melee_Damage",
        "DamageCalculator": {
          "Type": "Absolute",
          "BaseDamage": { "Physical": 10 },
          "RandomPercentageModifier": 0.1
        }
      }
    ]
  }
}
```

Variants override these via `"Modify"`:

```json
"InteractionVars": {
  "Melee_SwingDown_Damage": {
    "Interactions": [
      {
        "Parent": "Goblin_Ogre_Swing_Down_Damage",
        "DamageCalculator": {
          "Type": "Absolute",
          "BaseDamage": { "Physical": 20 }
        }
      }
    ]
  }
}
```

---

## Inter-NPC Interaction

### Beacon Communication

NPCs communicate via named beacon messages. One NPC sends a message, another listens for it.

**Listening for a beacon (receiver):**

```json
{
  "Sensor": {
    "Type": "Beacon",
    "Message": "Annoy_Ogre",
    "Range": 5
  },
  "Actions": [
    {
      "Type": "Attack",
      "Attack": { "Compute": "SleepingAttack" },
      "AttackPauseRange": [1, 2]
    }
  ]
}
```

**Sending a beacon (via state transition):**

```json
{
  "Type": "Beacon",
  "Message": "Goblin_Ogre_Warn",
  "TargetGroups": { "Compute": "WarnGroups" },
  "SendTargetSlot": "LockedTarget"
}
```

### NPC Groups

Define groups for filtering:

```json
{
  "IncludeRoles": ["Goblin_Scrapper"]
}
```

```json
{
  "IncludeRoles": ["Edible_Rat"]
}
```

### Spawn Beacons (Manual NPC Spawning)

Trigger beacon-based NPC spawning for inter-NPC behaviors:

**Spawn beacon definition:**

```json
{
  "Environments": [],
  "NPCs": [
    { "Weight": 1, "Id": "Edible Rat" }
  ],
  "SpawnAfterGameTimeRange": ["PT5M", "PT10M"],
  "NPCSpawnState": "Seek",
  "TargetSlot": "LockedTarget"
}
```

**Triggering from template:**

```json
{
  "Continue": true,
  "Sensor": { "Type": "Any", "Once": true },
  "Actions": [
    {
      "Type": "TriggerSpawnBeacon",
      "BeaconSpawn": { "Compute": "FoodNPCBeacon" },
      "Range": 15
    }
  ]
}
```

### Edible Critter Template Pattern

Generic template for NPCs that seek a target and get consumed:

```json
{
  "Type": "Abstract",
  "KnockbackScale": 0.5,
  "Parameters": {
    "Appearance": { "Value": "Rat", "Description": "Model to be used" },
    "WalkSpeed": { "Value": 3, "Description": "How fast this critter moves" },
    "SeekRange": { "Value": 40, "Description": "How far it can be from eater" },
    "MaxHealth": { "Value": 100, "Description": "Max health for the NPC" }
  },
  "Appearance": { "Compute": "Appearance" },
  "StartState": "Idle",
  "MaxHealth": { "Compute": "MaxHealth" },
  "Instructions": [
    {
      "Instructions": [
        {
          "Sensor": { "Type": "State", "State": "Idle" },
          "Instructions": [
            {
              "Sensor": { "Type": "Beacon", "Message": "Approach_Target", "TargetSlot": "LockedTarget" },
              "Actions": [ { "Type": "State", "State": "Seek" } ]
            },
            {
              "ActionsBlocking": true,
              "Actions": [
                { "Type": "Timeout", "Delay": [1, 1] },
                { "Type": "Despawn" }
              ]
            }
          ]
        },
        {
          "Sensor": { "Type": "State", "State": "Seek" },
          "Instructions": [
            {
              "Sensor": { "Type": "Target", "TargetSlot": "LockedTarget", "Range": { "Compute": "SeekRange" } },
              "BodyMotion": { "Type": "Seek", "SlowDownDistance": 0.1, "StopDistance": 0.1 }
            },
            {
              "ActionsBlocking": true,
              "Actions": [
                { "Type": "Timeout", "Delay": [1, 1] },
                { "Type": "State", "State": "Idle" }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

---

## ReturnHome & Search States

### ReturnHome

Handles returning to spawn point after leash triggers. Heals to full on arrival.

```json
{
  "Sensor": { "Type": "State", "State": "ReturnHome" },
  "Instructions": [
    {
      "Sensor": {
        "Type": "And",
        "Sensors": [
          { "Type": "Damage", "Combat": true, "TargetSlot": "LockedTarget",
            "Enabled": { "Compute": "AbsoluteDetectionRange > 0" } },
          { "Type": "Target", "TargetSlot": "LockedTarget",
            "Range": { "Compute": "AbsoluteDetectionRange" } }
        ]
      },
      "Actions": [ { "Type": "State", "State": "Combat" } ]
    },
    {
      "Sensor": { "Type": "Leash", "Range": { "Compute": "LeashDistance * 0.3" } },
      "BodyMotion": {
        "Type": "Seek",
        "SlowDownDistance": { "Compute": "LeashDistance * 0.4" },
        "StopDistance": { "Compute": "LeashDistance * 0.2" },
        "RelativeSpeed": 0.8,
        "UsePathfinder": true
      }
    },
    {
      "Actions": [
        { "Type": "SetStat", "Stat": "Health", "Value": 1000000 },
        { "Type": "State", "State": "Idle" }
      ]
    }
  ]
}
```

### Search State

Wander around looking for lost target before returning to idle:

```json
{
  "Sensor": { "Type": "State", "State": "Search" },
  "Instructions": [
    {
      "Sensor": { "Type": "Damage", "Combat": true, "TargetSlot": "LockedTarget" },
      "Actions": [ { "Type": "State", "State": "Alerted" } ]
    },
    {
      "Instructions": [
        {
          "Sensor": { "Reference": "Component_Sensor_Lost_Target_Detection", "Modify": { ... } },
          "Actions": [ { "Type": "State", "State": "Combat" } ]
        },
        {
          "Sensor": { "Reference": "Component_Sensor_Standard_Detection", "Modify": { ... } },
          "Actions": [ { "Type": "State", "State": "Alerted" } ]
        },
        {
          "BodyMotion": { "Type": "Sequence", "Motions": [ /* wander pattern */ ] },
          "ActionsBlocking": true,
          "Actions": [
            { "Type": "Timeout", "Delay": [4, 5] },
            { "Type": "State", "State": "Idle" }
          ]
        }
      ]
    }
  ]
}
```

---

## Debugging

Add to the top of a template to display the current state:

```json
"Debug": "DisplayState",
```

Use `$Comment` fields for documentation:

```json
"$Comment": "Check for any hostile targets in range that could alert the NPC"
```

---

## NPC Design Process

1. **Read design requirements** — Understand what the NPC should do.
2. **Decide on states** — Break behavior into top-level states (Idle, Sleep, Eat, Combat, etc.) and substates.
3. **Find reusable components** — Check existing `Component_Instruction_*` and `Component_Sensor_*` files.
4. **Identify reusable parts** — Extract common logic into new components.
5. **Build incrementally** — Add one behavior at a time and **test after each addition**.
6. **Parameterize** — Expose configurable values so variants can customize behavior.

### Common Template Header Fields

```json
{
  "Type": "Abstract",
  "Debug": "DisplayState",
  "StartState": "Idle",
  "DefaultPlayerAttitude": "Hostile",
  "DefaultNPCAttitude": "Ignore",
  "AttitudeGroup": { "Compute": "AttitudeGroup" },
  "KnockbackScale": 0.5,
  "Appearance": { "Compute": "Appearance" },
  "DropList": { "Compute": "DropList" },
  "MaxHealth": { "Compute": "MaxHealth" },
  "NameTranslationKey": { "Compute": "NameTranslationKey" }
}
```

---

## Key Points

1. **Templates are Abstract, Variants are concrete** — Templates define reusable behavior; variants provide specific values.
2. **States are the backbone** — Every NPC behavior is organized into states and substates.
3. **Test incrementally** — Add one behavior at a time and test before moving on.
4. **Parameterize everything** — Use `Parameters` + `{ "Compute": "..." }` so variants can customize.
5. **Extract components** — If logic appears in multiple places, make it a component.
6. **Detection priority** — Place `Damage_Check` first, then `Standard_Detection`, then state-specific logic.
7. **Use state transitions for visual polish** — Animations, inventory swaps, and beacon messages.
8. **Beacons for inter-NPC communication** — Don't hard-code NPC coupling; use message passing.
9. **Leash prevents runaway NPCs** — Always add `Soft_Leash` in combat to prevent infinite chasing.
10. **`UseTarget: false`** — Required for actions that modify the NPC itself (inventory, stats).

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Template won't compile | Check that all referenced components exist and state names match |
| NPC stuck in one state | Verify state switch actions and `ActionsBlocking` flags |
| NPC doesn't detect player | Check `ViewRange`, `ViewSector`, `HearingRange`, `AbsoluteDetectionRange` parameters |
| NPC chases forever | Add `Component_Instruction_Soft_Leash` with proper `LeashDistance` |
| Animations not playing | Ensure `PlayAnimation` action uses correct `Slot` and animation name |
| NPC ignores damage | Add `Component_Instruction_Damage_Check` to each state's instructions |
| Items not equipping | Call inventory operations with `"UseTarget": false` |
| State transitions not firing | Ensure `StateTransitions` block is above `Instructions` in the JSON |
| Beacon messages not received | Verify NPC groups and beacon `Range` parameter |
| Food NPC not spawning | Check spawn beacon exists, is placed in world, and `TriggerSpawnBeacon` range is sufficient |

---

## Related Skills

- `hytale-spawning-npcs` — Programmatic NPC spawning via Java (NPCPlugin API)
- `hytale-ecs` — Entity Component System patterns
- `hytale-items` — Item registry, ItemStack, and interactions
- `hytale-entity-effects` — Status effects and buffs
- `hytale-events` — Event system for reacting to NPC-related events

---

## Reference

- Source: [Hytale Modding - NPC Tutorial](https://hytalemodding.dev/en/docs/official-documentation/npc)
