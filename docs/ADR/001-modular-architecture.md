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
