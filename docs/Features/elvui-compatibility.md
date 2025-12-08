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
