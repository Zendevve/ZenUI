# ADR-001: Modular OOP Architecture

Status: Accepted
Date: 2025-12-19
Owner: Zendevve
Related Features: All

---

## Context
WoW AddOns often devolve into monolithic "spaghetti code" files (`Core.lua` with 3000 lines). This makes maintenance, debugging, and feature addition difficult. We needed a structure that supports complex state logic and animation management without tight coupling.

## Decision
We adopted a **Modular Object-Oriented** approach using Lua metatables.
The codebase is split into distinct modules with single responsibilities:
1.  **Config**: Settings & SavedVariables.
2.  **Utils**: Helper functions.
3.  **StateManager**: "The Brain" - decides *what* should happen.
4.  **FrameManager**: "The Conductor" - orchestrates lists of frames.
5.  **FrameController**: "The Worker" - handles individual frame logic/animation.
6.  **EventHandler**: "The Ear" - listens to game events.

## Alternatives Considered
*   **Monolithic (`ZenHUD.lua` only)**: Rejected. Too hard to maintain.
*   **Functional/Procedural**: Rejected. Managing state for 50+ individual frames (alpha, visibility, animation progress) is messy without Frame objects.

## Consequences
### Positive
*   **Testability**: Logic is isolated. `StateManager` can be tested independently of `FrameManager`.
