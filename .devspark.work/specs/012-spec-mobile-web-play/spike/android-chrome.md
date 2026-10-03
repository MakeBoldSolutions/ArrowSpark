# Spike Record — Google Pixel 7 / Android Chrome

**Date**: · **Tester**: · **Build id**: · **Real hardware**: yes (required; otherwise this is a supplemental note, not a record)

| Item | Value |
|---|---|
| Device model | |
| OS version | |
| Browser and version | |
| Landscape CSS viewport (chrome shown / hidden) | |
| devicePixelRatio | |
| Canvas-to-CSS scale | |
| Readable text sizes (CSS px) per HUD/menu role | |
| Working zoom: on-device cell size (CSS px) | |

## FR-001 findings (observations only; leave blank until observed)

| # | Question | Result (pass / fail / not performed + reason) | Evidence |
|---|---|---|---|
| R1 | Tap → existing selection at working zoom (≥ 20 distinct removable arrows; blocked taps); Fit-zoom usability reported separately | | |
| R1a | Does Godot emit both touch and mouse events for one tap? | | |
| R1b | Any premature selection (on press, before release or pinch)? count | | |
| R1c | Any double-fire from one tap? count | | |
| R2 | Reference Knot readable in landscape via scaling alone | | |
| R3 | Pinch and pan through the existing viewport transform | | |
| R4 | Same-origin iframe behavior (gestures, page scroll/zoom, completion message) | | |
| R5 | Minimum usable landscape CSS viewport | | |
| R6 | Controls/layouts blocking use | | |
| R7 | Fullscreen / audio start / gestures / iframe interaction permitted | | |

## Control audit (required controls)

| Control | Rendered CSS px (w × h) | ≥ 44 × 44 | Note |
|---|---|---|---|
| Back | | | |
| Fit Puzzle | | | |
| Open Move | | | |
| Pan mode | | | |
| Zoom in / out | | | |
| Results actions | | | |
| Replay | | | |
| Level Select / navigation | | | |

## Orientation / resize
Observations on rotate, browser-chrome show/hide, attempt preserved?

## Classification
Supported · Supported with documented limitation · Unsupported in Spec 012 — **Why:**

## Owner-reported observations (2026-10-03, preview build 76ee3e9, `/play/?spike`, unmodified game)

Reported by the owner on a real Pixel 7; model, Android version, Chrome version, landscape CSS viewport and devicePixelRatio still to be recorded (T006).

- Game loads on the phone through `?spike` (R4, partial: loads in the iframe).
- Pinch to zoom in/out: **does not work** (expected: no touch gesture code exists yet; R3 needs the prototype).
- One-finger drag while zoomed in: **does not pan** with Pan mode off (expected from the current design; the board only pans with Pan mode or middle drag).
- Tapping the Pan button toggles Pan mode; with Pan on, one-finger drag **pans**; tapping Pan again turns it off and the owner can **play** (tap on arrows works) (R1 partial: taps reach the existing selection, presumably through the engine's touch-to-mouse emulation; R3 partial: pan through the existing mouse path works).
- Not yet recorded: probe overlay values and event counters, whether selection fires on press or release, any double-fire, page scroll/zoom leakage, audio start, Back/Results/Replay/Level Select, orientation change, button sizes.

## Real-device probe reading (owner screenshot, Pixel 7, portrait; evidence/pixel7-portrait-probe.png)

| Item | Value |
|---|---|
| Viewport | 411 x 891 CSS px, portrait (browser chrome state not recorded) |
| devicePixelRatio | 2.625 |
| Canvas | 1078 x 2338 px; canvas>css 0.381 (= 1/dpr, so the game UI is unscaled device pixels) |
| pointer:fine / hover | no / no (the shipped admission query `(pointer: fine)` is false here) |
| maxTouchPoints | 5 |
| Browser-level event counts after the session | touchstart 41, touchend 41, pointerdown 41, mousedown 0, click 0 |
| Game state in the shot | Remaining 108, Mistakes 11 (Reference Knot), board zoomed and panned |

Observations (not conclusions):
- **R1a (partial):** the browser delivered 41 touch and 41 pointer-down events and **no mouse or click events**, so Chrome is not synthesizing mouse events (consistent with `touch-action: none`). The taps still operated the game, so the touch-to-mouse step happens inside Godot. Whether Godot emits both a touch and a mouse event per tap, premature selection and double-fire remain unmeasured at engine level.
- **R2/R6 (supporting):** the HUD and toolbar fit in one row each at 411 CSS px, but buttons render about 28-43 CSS px wide and only about 16-17 CSS px tall (estimated from the screenshot at about 2.3 screenshot px per CSS px), far below 44 x 44.
- **Portrait:** the game loaded and was playable in portrait (with Pan mode), with the board fitted to the narrow width; the plan only promised landscape. Recorded as a supplemental observation for the freeze decision, not a scope change.
- **Mistakes 11 vs 7 arrows removed:** consistent with imprecise taps on small Fit-zoom cells, premature selection, or deliberate blocked taps; cannot be attributed from this data.
- Still unrecorded: device/Android/Chrome versions, landscape viewport, press-vs-release timing, page scroll/zoom leakage, audio, remaining flow checks.

## Real-device probe reading, landscape (owner screenshot; evidence/pixel7-landscape-probe.png)

| Item | Value |
|---|---|
| Viewport | 850 x 411 CSS px, landscape (browser chrome state not recorded; a black strip about 39 CSS px wide is visible at the left edge, possibly a display cutout or system inset; Pixel 7 landscape is 915 CSS px wide) |
| devicePixelRatio | 2.625 |
| Canvas | 2231 x 1078 px; canvas>css 0.381 |
| pointer:fine / hover / maxTouchPoints | no / no / 5 |
| Browser-level event counts (cumulative session) | touchstart 70, touchend 70, pointerdown 70, mousedown 0, click 0 |
| Game state in the shot | Remaining 105, Mistakes 17, board zoomed in with the Zoom In button |

Observations (not conclusions):
- Same behavior as portrait per the owner: one-finger drag and pinch do nothing; Zoom In/Out/Fit/Pan buttons work; Pan mode then drag pans.
- Browser-level counts again show touch and pointer events but no mouse or click events (R1a partial; engine-level emission still unmeasured).
- Control sizes (estimated from the screenshot at about 2.35 screenshot px per CSS px): Back about 27 x 17 CSS px, Zoom Out about 43 x 17, Show Me an Open Move about 88 x 17; none reaches 44 high (R6).
- Chrome of the game (HUD plus toolbar) uses about 57 of 411 CSS px of height (about 14%); raising both rows to 44 CSS px would use about 88 px (about 21%) by simple arithmetic, an estimate to confirm in the prototype, not a finding.
- Mistakes 17 after 10 arrows removed (portrait session: 11 mistakes after 7): consistent with the earlier reading; cause (precision at small cells, press-time selection or deliberate blocked taps) still not attributable.
- Still unrecorded: press vs release timing, page scroll/zoom leakage, audio, Android and Chrome versions, Back/Results/Replay/Level Select flow, orientation-change behavior (the owner did switch between portrait and landscape and the game kept running).
