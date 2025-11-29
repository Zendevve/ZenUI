# ZenUI

> **Modern UI automation for World of Warcraft 3.3.5a**
> Intelligent UI visibility management with smooth animations and zero configuration.

[![WoW Version](https://img.shields.io/badge/WoW-3.3.5a-blue)](https://github.com/Zendevve/ZenUI)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

---

## ✨ Features

### 🎮 For Players

- **Zero Configuration** - Works perfectly out of the box
- **Smart Automation** - UI appears when you need it, hides when you don't
- **Buttery Smooth** - Professional fade animations with configurable timing
- **Combat Ready** - Instant UI display in combat with customizable grace periods
- **Slash Commands** - Full control via `/zenui` for quick adjustments

### 💻 For Developers

- **Modern Architecture** - Clean OOP design with 6 modular systems
- **Lightweight** - Only 900 lines of optimized code
- **Extensible** - Easy to customize and extend
- **WotLK Native** - Built specifically for 3.3.5a API
- **Well Documented** - Clear code structure with comprehensive comments

---

## 🚀 Quick Start

### Installation

1. Download the latest release
2. Extract to `<WoW Install>/Interface/AddOns/`
3. Ensure the folder is named `ZenUI`
4. Launch WoW and enjoy!

### First Use

After installation, the addon activates automatically after a 5-second delay. Your UI will:

- ✅ **Show** in combat, resting areas, with targets, or when mousing over action bars
- ✅ **Hide** when exploring, with smooth transitions
- ✅ **Respect** grace periods to prevent flickering

---

## 📖 Usage

### Slash Commands

Access full control with `/zenui`:

```
/zenui              - Show help
/zenui toggle       - Enable/disable addon
/zenui debug        - Toggle debug mode
/zenui status       - Show current state
/zenui frames       - List controlled frames
/zenui reload       - Reload configuration
```

### Advanced Configuration

Edit `WTF/Account/<Account>/SavedVariables/ZenUI.lua`:

```lua
ZenUIDB = {
    ["enabled"] = true,
    ["debug"] = false,
    ["showOnTarget"] = true,
    ["fadeTime"] = 0.8,
    ["gracePeriods"] = {
        ["combat"] = 8.0,     -- Post-combat delay
        ["target"] = 2.0,     -- Post-target delay
        ["mouseover"] = 2.0,  -- Post-mouseover delay
    },
}
```

---

## 🎯 How It Works

### UI Visibility Logic

The UI automatically shows when:
- **In Combat** - Instant display with priority fade
- **Has Living Target** - Quick access to abilities
- **Mouseover Action Bars** - Hover to reveal
- **Resting in City/Inn** - Full UI in safe zones
- **Grace Periods Active** - Smooth transitions

### Smart Features

**Zone Text Avoidance**
Delays transitions during "Entering Zone" text to prevent visual conflicts.

**Buff Frame Anti-Flicker**
Prevents buffs from glitching when updating during fade animations.

**PlayerFrame Hover Hotspot**
Ensures reliable mouseover detection even when frames are faded.

**Failsafe Timer**
4-second safety net forces UI to show if logic encounters issues.

---

## 🏗️ Architecture

### Modular Design

ZenUI uses a clean, modern architecture with six core modules:

```
📦 ZenUI
 ├─ Config          - Centralized settings management
 ├─ Utils           - Common helpers (Print, Clamp, GetTime)
 ├─ FrameController - OOP fade animation system
 ├─ FrameManager    - Orchestrates all frame controllers
 ├─ StateManager    - Centralized decision engine
 └─ EventHandler    - Clean event dispatch system
```

### Performance

- **Single Update Loop** - Efficient frame updates
- **Native WotLK APIs** - No polyfills or hacks
- **Minimal CPU Overhead** - Optimized state checks
- **Smart Caching** - Reduced redundant calculations

---

## 🎨 Controlled Frames

### Core UI Elements

- Action bars (Main, Multi, Pet, Shapeshift)
- Micro menu buttons
- Bag buttons
- Unit frames (Player, Pet, Target of Target)
- Buff frames
- Quest tracker
- Chat buttons
- XP/Reputation bars

### WotLK-Specific

- **VehicleMenuBar** - Vehicle encounters
- **RuneFrame** - Death Knight runes
- **QuestTimerFrame** - Timed quests
- **BonusActionBarFrame** - Special abilities

---

## 🔧 Development

### Code Quality

- **Modern Lua** - OOP patterns with metatables
- **Descriptive Naming** - Self-documenting code
- **Separation of Concerns** - Each module has a single responsibility
- **DRY Principle** - No code duplication

### Extending ZenUI

**Add a Custom Frame:**

```lua
-- In CONTROLLED_FRAMES table
"MyCustomFrame",

-- Mark as conditional if needed
CONDITIONAL_FRAMES = {
    MyCustomFrame = true,
}
```

**Hook into State Changes:**

```lua
-- Access the StateManager
local StateManager = ZenUI.StateManager

-- Check current state
if StateManager.inCombat then
    -- Custom logic
end
```

---

## 🐛 Debugging

### `/zenui status` Output

```
[ZenUI] Current Status:
  Enabled: Yes
  Debug: No
  Loaded: Yes
  In Combat: No
  Has Target: Yes
  Resting: No
  Mouseover: No
  Grace (target): 1.3s
```

### Debug Mode

Enable verbose logging:
```
/zenui debug
```

Watch chat for detailed state changes and trigger events.

---

## 📊 Comparison

### Why ZenUI?

| Feature | ZenUI | Others |
|---------|-------|--------|
| Code Size | 900 lines | 1000+ lines |
| Architecture | Modern OOP | Legacy/Monolithic |
| WotLK Optimized | ✅ Native | ⚠️ Polyfills |
| Grace Periods | ✅ Configurable | ❌ Fixed |
| Slash Commands | ✅ Full | ⚠️ Limited |
| Debug Tools | ✅ Built-in | ❌ None |

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly in WotLK 3.3.5a
5. Submit a pull request

### Development Setup

```bash
git clone https://github.com/Zendevve/ZenUI.git
cd ZenUI
# Make changes to ZenUI.lua
# Test in-game
# Commit and push
```

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Credits

**Author:** Zendevve
**Version:** 1.0.0
**Target:** WoW WotLK 3.3.5a

---

## 📮 Support

- **Issues:** [GitHub Issues](https://github.com/Zendevve/ZenUI/issues)
- **Discussions:** [GitHub Discussions](https://github.com/Zendevve/ZenUI/discussions)

---

<p align="center">
  Made with ❤️ for the WotLK community
</p>
