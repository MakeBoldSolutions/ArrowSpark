# US1 rendered evidence (2026-10-16, Godot 4.4.1, rendered, isolated user data)

## SC-001 / QA-01: proportion of window height (capture_menus.gd MEASURE)

| Window | Scale | Title | Play button | Play (physical px) |
|---|---|---|---|---|
| 1280×720 | 1.0 | 0.0931 | 0.0681 | 49 |
| 1920×1080 | 1.5 | 0.0931 | 0.0694 | 75 |
| 2560×1440 | 2.0 | 0.0931 | 0.0681 | 98 |
| 3840×2160 (exclusive fullscreen) | 3.0 | 0.0931 | 0.0681 | 147 |
| 2560×1080 (21:9) | 1.5 | 0.0931 | 0.0694 | 75 |
| 1280×960 (4:3) | 1.0 | 0.0698 | 0.0510 | 49 (expand adds height, as designed) |

At the 16:9 sizes the Play button varies by at most 1.9%, inside ±5%. PASS.

QA-02: the 21:9 and 4:3 captures show the content centred and fully visible.

## SC-006 / QA-03: gameplay parity (gameplay_smoke.gd)

Sequence: one blocked tap, then the solver witness.

| Puzzle | main @1280×720 | branch @1280×720 | branch @2560×1440 |
|---|---|---|---|
| first_knot | blocked (7,2); mistakes 1, score 8/9, accuracy 0.9 | identical | identical |
| reference_knot | blocked (40,0); mistakes 1, score 114/115, accuracy 0.99138 | identical | identical |

The puzzle captures at both sizes show identical framing and the HUD scaled with the screen. PASS.

## Incident

The first 4K run used fullscreen without isolated user data, and the template persisted `FullscreenEnabled=true` and `ScreenResolution=3840x2160` to the owner's real `%APPDATA%/Godot/app_userdata/ArrowSpark/config.cfg`. It was restored to windowed 1280×720 with audio untouched. All later runs use per-run isolated `APPDATA`.
