# Spike Record — <device> / <browser>

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
