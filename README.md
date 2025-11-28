# ZenUI

> **Minimalist UI automation for World of Warcraft 3.3.5a**
> Smart, contextual interface visibility that adapts to your gameplay.

---

## What It Does

ZenUI intelligently manages your interface visibility based on context:

- **Combat** → UI appears instantly
- **Targeting enemies** → UI fades in
- **Resting in cities** → Full UI available
- **Exploring the world** → Clean, unobstructed view
- **Mouseover hotspots** → UI reveals on demand

No config panels. No keybinds. No micromanagement. Just install and play.

---

## Features

### Context-Aware Display
The addon monitors your game state and shows/hides UI elements automatically. Enter combat? Your action bars appear. Leave the city? Everything fades away. It's designed to stay out of your way until you need it.

### Smooth Transitions
All visibility changes use smooth fade animations (configurable duration). Grace periods prevent flickering during rapid state changes:
- **8 seconds** after combat ends
- **2 seconds** after losing target
- **2 seconds** after cursor leaves action bars

### Controlled Elements
- Action bars (main, multi, pet, stance)
- Player & pet frames
- Buffs & debuffs
- Micro menu buttons
- Bag buttons
- XP/reputation bars
- Quest tracker

### Technical Details
- **5-second startup delay** prevents conflicts with other addon initialization
- **Zone change detection** with debouncing to avoid flicker during transitions
- **Party frame support** shows/hides party members dynamically
- **DragonFlight UI compatible** automatically detects and adapts to DFUI addon

---

## Installation

1. Download or clone this repository
2. Copy the `ZenUI` folder to `<WotLK>/Interface/AddOns/`
3. Launch WoW and enable at character select
4. **Done.** The addon works immediately.

---

## Configuration

Settings are stored in `ZenUIDB` (SavedVariables). Modify via in-game commands:

```lua
-- Enable/disable the addon
/run ZenUIDB.enabled = true  -- or false

-- Toggle debug messages
/run ZenUIDB.debug = true

-- Control target-based UI display
/run ZenUIDB.showOnTarget = false

-- Adjust fade animation speed (seconds)
/run ZenUIDB.fadeTime = 5.0

-- Apply changes
/reload
```

**Default settings:**
- `enabled = true`
- `debug = false`
- `showOnTarget = true`
- `fadeTime = 3.0`

---

## How It Works

### State Detection
The addon evaluates your current context every frame:

1. **Priority states** (combat, targeting, mouseover) → Show UI
2. **Grace periods** (post-combat, post-target) → Keep UI visible
3. **Resting state** → Show UI with debouncing
4. **Default** → Hide UI for clean exploration

### Frame Management
Each UI element gets a dedicated controller with fade logic. Controllers respect frame relationships (e.g., pet frame only shows when you have a pet) and handle edge cases like buff updates mid-fade.

### Performance
- Throttled update loops (50ms tick rate)
- Minimal event handlers
- Defensive API checks
- No per-frame heavy operations

---

## Compatibility

- **WoW Version:** 3.3.5a (WotLK)
- **Action Bar Addons:** Works alongside Bartender, Dominos, etc.
- **Unit Frame Addons:** Compatible with most UF replacements
- **DragonFlight UI:** Auto-detects and adjusts behavior

---

## Troubleshooting

**UI not hiding?**
- Wait 5 seconds after login (startup delay)
- Ensure you're not in a resting area
- Check `/run print(ZenUIDB.enabled)` returns `true`

**UI flickering?**
- Increase grace periods (see Configuration)
- Check for conflicting addons that force UI visibility

**Specific frame not controlled?**
- Enable debug: `/run ZenUIDB.debug = true; ReloadUI()`
- Check chat for "OK: FrameName" vs "Skip: FrameName"
- Some frames may not exist in all clients

---

## Development

### Project Structure
```
ZenUI/
├── ZenUI.toc    # Addon metadata
├── ZenUI.lua    # Core logic (controllers, events, fade system)
└── README.md    # This file
```

### Key Concepts
- **Controllers:** Per-frame fade state machines
- **Grace periods:** Prevent rapid hide/show cycles
- **Zone guards:** Delay transitions during zone text display
- **Debouncing:** Smooth zone change handling

### Modifying Frame List
Edit `FRAME_NAMES` table in `ZenUI.lua` (~line 63) to add/remove controlled elements.

---

## Credits

**Created by:** Zendevve
**License:** Do whatever you want with it
**Ported from:** Classic 1.12 → WotLK 3.3.5a

---

## Contributing

Issues and suggestions welcome. This is a minimal utility addon - feature creep is intentionally avoided to maintain simplicity.

**Repository:** [github.com/Zendevve/ZenUI](https://github.com/Zendevve/ZenUI)
