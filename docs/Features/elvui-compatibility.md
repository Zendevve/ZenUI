# Feature: ElvUI / Tukui Compatibility

**Status**: Implemented
**Owner**: ZenHUD

## 1. Purpose
Enable ZenHUD's automatic visibility system to work with popular ElvUI and Tukui replacement frames, not just the default Blizzard UI.

## 2. Business Rules & Constraints
*   **Detection**: ElvUI/Tukui must be detected *after* they initialize their frames.
*   **FadeOnly**: ElvUI action bars use `fadeOnly` mode (alpha only) to avoid taint.
*   **Toggleable**: Users can disable the `elvui` frame group via Options if conflicts arise.
*   **No Blizzard Conflict**: If ElvUI is loaded, Blizzard frames are typically hidden by ElvUI itself; ZenHUD won't interfere.

## 3. User Flows / Interaction
1.  **ElvUI Installed**: User launches WoW -> ElvUI loads -> ZenHUD detects via `ADDON_LOADED` -> ZenHUD registers ElvUI frames after 2s delay.
2.  **Without ElvUI**: No ElvUI -> ZenHUD only controls Blizzard frames.

## 4. Technical Design (Summary)
*   **Detection Event**: `ADDON_LOADED` for "ElvUI" or "Tukui".
*   **Frame Patterns**: `ELVUI_FRAME_PATTERNS` table in `FrameManager.lua`.
*   **Registration**: `FrameManager:RegisterElvUIFrames()` scans `_G` for matching frames.
*   **Config**: `frameGroups.elvui` defaults to `true`.

## 5. Test Scenarios (Verification)
| ID | Description | Setup | Action | Expected Result |
| :--- | :--- | :--- | :--- | :--- |
| **01** | **ElvUI Detection** | ElvUI installed | Load game | Chat: "Detected ElvUI, registering frames..." |
| **02** | **Frame Registration** | ElvUI installed | `/ZenHUD frames` | List includes `ElvUI_Bar1`, `ElvUF_Player`, etc. |
