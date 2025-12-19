# Contributing to ZenHUD

First off, thanks for taking the time to contribute! â ¤ï¸

The following is a set of guidelines for contributing to ZenHUD. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Heads Up!](#heads-up)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Pull Requests](#pull-requests)
- [Styleguides](#styleguides)
  - [Lua Styleguide](#lua-styleguide)

## Code of Conduct

This project and everyone participating in it is governed by the [ZenHUD Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## Heads Up!

> [!IMPORTANT]
> **ZenHUD is a "Code First, Docs First" project.**
> We practice **README Driven Development (RDD)**. If you are adding a new feature, you must first update the README to describe how it works before writing the implementation.

## Development Setup

To develop for World of Warcraft 3.3.5a, you don't need a complex build chain, but you do need to link your code to the game client.

1.  **Fork and Clone** the repo.
2.  **Symlink** the directory to your WoW AddOns folder.

    **Windows (PowerShell):**
    ```powershell
    New-Item -ItemType SymboliLink -Path "C:\Path\To\WoW\Interface\AddOns\ZenHUD" -Target "D:\Dev\ZenHUD"
    ```

3.  **Reload UI**: In-game, use `/reload` to apply code changes.

## How to Contribute

### Reporting Bugs

Bugs are tracked as GitHub issues. Create an issue and provide the following:
- Use a clear and descriptive title.
- Describe the exact steps to reproduce the problem.
- **Console Errors**: If you have Lua errors, please enable `/console scriptErrors 1` and paste the stack trace.

### Suggesting Enhancements

Open an issue to discuss your idea. If it's a major feature, please draft a proposal first.

### Pull Requests

1.  Fork the repo and create your branch from `main`.
2.  If you've added code that should be tested, add tests.
3.  If you've changed APIs, update the documentation.
4.  Ensure the test suite passes.
5.  Make sure your code lints.

## Styleguides

### Lua Styleguide

- **Indentation**: 4 spaces. No tabs.
- **Locals**: Always use `local` variables unless global exposure is strictly necessary.
- **Naming**: `PascalCase` for functions/classes, `camelCase` for variables.
- **Comments**: Comment confusing logic.
- **Fragments**: Keep functions small and focused.

```lua
-- Good
local function CalculateHealth(unit)
    if not UnitExists(unit) then return 0 end
    return UnitHealth(unit) / UnitHealthMax(unit) * 100
end

-- Bad
function calc_hp(u)
    return UnitHealth(u)/UnitHealthMax(u)*100
end
```
