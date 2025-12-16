# Feature: Fade Animations

**Status**: Implemented
**Owner**: ZenHUD

## 1. Purpose
To provide smooth, professional-grade transitions between visible and hidden states, rather than abrupt popping, reinforcing the "Zen" aesthetic.

## 2. Business Rules & Constraints
*   **Smoothness**: Alpha must interpolate linearly over `config.fadeTime`.
*   **Interruption**: If a fade is interrupted (e.g., fading out, then sudden combat), it must reverse from the *current* alpha, not snap to 0 or 1.
*   **BuffFrame Flicker**: Standard BuffFrames in WotLK flicker if hidden/shown rapidly. Use "Deferred Fading" to handle this specific frame.
*   **Performance**: Hide the frame completely (`frame:Hide()`) when alpha reaches 0 to save CPU cycles.

## 3. User Flows / Interaction
1.  **Fade Out**: StateManager says Hide -> Frame Alpha 1.0 -> 0.9... -> 0.0 -> Frame Hidden.
2.  **Fade In**: StateManager says Show -> Frame Shown -> Alpha 0.0 -> 0.1... -> 1.0.
3.  **Interrupt**: Fading Out (at 0.5) -> Combat Starts -> Fading In (0.5 -> 1.0).

## 4. Technical Design (Summary)
*   **Components**: `FrameController.lua`.
*   **Logic**: Per-frame update loop managed by `FrameManager`.
*   **Variables**: `currentAlpha`, `targetAlpha`, `startAlpha`, `duration`.

