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

