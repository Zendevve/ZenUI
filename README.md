<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://img.shields.io/badge/ZenHUD-Minimalist%20UI%20Automation-8b5cf6?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNmZmZmZmYiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIj48Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSIxMCIvPjxwYXRoIGQ9Ik0xMiA2djZsNCAyIi8+PC9zdmc+">
  <source media="(prefers-color-scheme: light)" srcset="https://img.shields.io/badge/ZenHUD-Minimalist%20UI%20Automation-8b5cf6?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiMwMDAwMDAiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIj48Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSIxMCIvPjxwYXRoIGQ9Ik0xMiA2djZsNCAyIi8+PC9zdmc+">
  <img alt="ZenHUD Banner" src="https://img.shields.io/badge/ZenHUD-Minimalist%20UI%20Automation-8b5cf6?style=for-the-badge">
</picture>

<p align="center">
  <strong>Intelligent UI visibility management for World of Warcraft 3.3.5a</strong><br>
  Your UI appears when you need it, vanishes when you don't. Zero configuration.
</p>

<p align="center">
  <a href="https://github.com/Zendevve/ZenHUD/releases"><img src="https://img.shields.io/github/v/release/Zendevve/ZenHUD?style=flat-square&color=blue" alt="Release"></a>
  <a href="https://github.com/Zendevve/ZenHUD/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Zendevve/ZenHUD?style=flat-square&color=green" alt="License"></a>
  <a href="https://github.com/Zendevve/ZenHUD"><img src="https://img.shields.io/badge/WoW-3.3.5a-orange?style=flat-square" alt="WoW Version"></a>
  <a href="https://github.com/Zendevve/ZenHUD/commits/main"><img src="https://img.shields.io/github/last-commit/Zendevve/ZenHUD?style=flat-square" alt="Last Commit"></a>
</p>

---

## Table of Contents

- [Why ZenHUD?](#why-ZenHUD)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [ElvUI / Tukui Support](#elvui--tukui-support)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [License](#license)

---

## Why ZenHUD?

> **Problem**: The default WoW UI clutters your screen during exploration, obscuring the beautiful world Blizzard created.
>
> **Solution**: ZenHUD automatically hides your action bars, unit frames, and buffs when you don't need them, and instantly shows them when combat starts, you target something, or hover over the UI area.

| Feature | ZenHUD | Manual Hiding | Other Addons |
|---------|:-----:|:-------------:|:------------:|
| Zero Configuration | âœ… | âŒ | âš ï¸ |
| Combat Safety | âœ… Instant | âŒ | âš ï¸ |
| Smooth Animations | âœ… | âŒ | âš ï¸ |
| ElvUI Support | âœ… | N/A | âŒ |
| Lightweight (~900 LOC) | âœ… | N/A | âŒ |

---

## Features

### Smart Automation
- **Combat**: UI appears instantly when combat starts
- **Targeting**: UI shows when you select a living target
- **Mouseover**: Hover action bars to reveal them
- **Resting**: Full UI in cities and inns
- **Grace Periods**: Smooth transitions, no flickering

### Performance
- **Throttled Detection**: 20Hz mouseover polling (not 60Hz)
- **FadeOnly Mode**: Alpha-only changes for ElvUI (no taint)
- **Single Update Loop**: Minimal CPU overhead

### Customization
- **Frame Groups**: Toggle action bars, unit frames, buffs independently
- **Fade Time**: 0.1s to 2.0s configurable
- **Faded Opacity**: 0% to 100% (ghost mode)
- **Per-Character Settings**: Different configs per alt

---

## Installation

### Prerequisites
- World of Warcraft **3.3.5a** (WotLK)
- No other dependencies

### Steps

```bash
# 1. Download the latest release
# 2. Extract to your AddOns folder
<WoW Install>/Interface/AddOns/ZenHUD/

# 3. Verify folder structure
ZenHUD/
  â”œâ”€â”€ ZenHUD.toc
  â”œâ”€â”€ ZenHUD.lua
  â”œâ”€â”€ Config.lua
  â””â”€â”€ ... (other .lua files)
```

4. Launch WoW â†’  ZenHUD activates automatically after 5 seconds

---

## Usage

### Slash Commands
