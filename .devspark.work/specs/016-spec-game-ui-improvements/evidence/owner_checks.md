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

## T019 / QA-07: physical input walk (owner, 2026-10-17)

| Input | Result |
|---|---|
| Keyboard-only menu navigation | Pass (owner: "menu with keyboard is fine") |
| Mouse | Pass (owner-driven smoke above) |
| Gameplay by mouse | Accepted by the owner ("game play requires mouse which is FINE, accepted"). This is existing behaviour, unchanged by this spec. |
| Physical gamepad menu walk | **Not tested** physically. Simulated D-pad navigation passed (evidence/us2/RESULTS.md). |
| Real-key splash skip | **Not tested.** Synthetic skip behaves identically on main (pre-existing). |

## T035: real-phone check, deferred by the owner to post-deploy

- Decision (owner, 2026-10-17): "defer pixel testing til spec is complete and deployed to web."
- Stage: post-deploy. Owner: project owner. Evidence class required: deployed (the Pixel 7 Pro against the published showcase).
- Recorded in spec.md (Verification, deferred obligation) and in tasks.md Gate Acknowledgements.
