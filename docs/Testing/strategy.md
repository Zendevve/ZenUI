# Testing Strategy

## Philosophy
Since we are developing for a legacy game client (WoW 3.3.5a) without a modern external test runner, **Manual Testing** is our primary verification method, supported by **Static Analysis**.

## 1. Static Analysis
Run `luacheck` before every commit to catch:
*   Global variable leaks (Critical in WoW AddOns).
*   Undefined variables.
