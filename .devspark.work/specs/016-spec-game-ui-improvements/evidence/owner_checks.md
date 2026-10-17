# Owner checks (2026-10-17)

## T034: browser smoke, local web build

The local dev server served the game from `web/public/game/local/`, refreshed with export 5d045e5 (Godot 4.4-stable).

| Browser | Family | Result |
|---|---|---|
| Chrome | Chromium | Pass — owner: "look great" |
| Firefox | Gecko | Pass |
| Perplexity browser | Chromium-based | Pass |
| VS Code internal browser | Chromium-based | Pass |
| Edge | Chromium-based | Not tested individually (inside the supported set, not claimed) |

## T036 / SC-007: owner sign-off

The owner reviewed the live build across the browsers above: "all look great, totally approve!" This is recorded as sign-off that the UI reads as the same brand as the showcase and as a finished consumer game.

## Still outstanding

- T019: owner confirmation of a physical keyboard-only and gamepad-only menu walk, and a real-key splash skip.
- T035: real-phone (Pixel 7 Pro) landscape check over HTTPS, covering menu size and tap/drag/pinch feel versus main.
