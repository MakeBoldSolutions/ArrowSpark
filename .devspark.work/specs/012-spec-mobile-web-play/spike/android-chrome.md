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
