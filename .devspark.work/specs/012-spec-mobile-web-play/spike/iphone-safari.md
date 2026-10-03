# Spike Record — iPhone (model/iOS to confirm) / browser to confirm (looks like Safari)

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

## Owner-supplied reading, iPhone portrait (a family member's phone; evidence/iphone-portrait-probe.jpg)

Device model, iOS version and browser (Safari vs another iOS browser) are **not yet recorded**; the screenshot shows a Dynamic Island (iPhone 14 Pro or later, inference) and Safari-style iOS chrome (inference). Do not treat this as a matrix row until the identity block is filled.

| Item | Value |
|---|---|
| Frame viewport inside the page (the game iframe) | 346 x 195 CSS px, landscape-shaped 16:9 box on a portrait page |
| devicePixelRatio | 3 |
| Canvas | 1038 x 585 px; canvas>css 0.333 (unscaled device pixels) |
| pointer:fine / hover / maxTouchPoints | no / no / 5 |
| Browser-level event counts | touchstart 2, touchend 2, pointerdown 2, mousedown 0, click 0 |
| Game state in the shot | Level Select open (so at least one tap reached a menu button); Level Select list clipped and scrollable |

Observations (not conclusions):
- The game loads and renders in the same-origin iframe on iOS, and a tap reached the game (R4/R1 partial). As on Android, the browser reports touch and pointer events with no mouse or click events.
- On a portrait page the game sits in a small 16:9 box (346 x 195 CSS px) with the surrounding page scrolling (the page is scrolled in the shot); at that size the game text and controls are very small. This is the unmodified Spec 011 frame layout, not a conclusion about landscape.
- The address bar shows a speaker indicator, which suggests the tab was playing sound (R7 audio start, partial; not confirmed by the owner).
- The Fullscreen button looks greyed out; consistent with fullscreen being unavailable for the iframe on iPhone Safari (R7 partial, inference to confirm).
- The page text still reads "Designed for desktop browsers with a mouse or trackpad and a keyboard" because only the gate was bypassed.
- Not yet recorded: model/iOS/browser, landscape reading, arrow tap, pinch/drag/Pan, press-vs-release, page scroll/zoom leakage during gestures, Back/Results/Replay/Level Select flow, orientation change.
