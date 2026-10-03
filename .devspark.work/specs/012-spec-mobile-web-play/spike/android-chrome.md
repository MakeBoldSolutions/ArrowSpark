# Spike Record — Google Pixel 7 Pro / Google Chrome 154 (plus Microsoft Edge Beta 155, supplemental)

**Date**: · **Tester**: · **Build id**: · **Real hardware**: yes (required; otherwise this is a supplemental note, not a record)

| Item | Value |
|---|---|
| Device model | Google Pixel 7 Pro (per edge://version: `Pixel 7 Pro Build/CP3A.260905.009`) |
| OS version | Android 17 (SDK 37) per edge://version; the reduced user agent string reports `Android 10; K` and must not be used |
| Browser and version | **Google Chrome 154.0.8037.126 (Official Build, 64-bit)** per chrome://version (evidence/pixel7pro-chrome-version.png); first round was Microsoft Edge Beta 155.0.4283.25 / Chromium 155.0.8059.12 (evidence/pixel7pro-edge-version.png), supplemental only. |
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

## Correction: which device and browser were actually tested (owner's edge://version screenshot)

The earlier observations above were first described as "Pixel 7 / Android Chrome". The version page shows the browser was **Microsoft Edge Beta 155 (Chromium 155.0.8059.12) on a Google Pixel 7 Pro running Android 17**. Consequences:
- The device is a Pixel 7 Pro, not a Pixel 7. The probe's 2.625 devicePixelRatio and 411 x 891 CSS portrait viewport are what this device reported in its current display setting (inference: the Pro's FHD+ mode; unconfirmed).
- The required target is **current Android Chrome**. These readings are Chromium-on-Android evidence from Edge Beta and **may not be claimed as Android Chrome support**. A repeat in Google Chrome (version from `chrome://version`) is still needed, and an Edge Beta result should not become a matrix row on its own.
- The shared Chromium engine makes the findings likely to transfer, but that is an expectation to test, not evidence.

## Google Chrome run on the same phone (owner screenshots; evidence/pixel7pro-chrome-landscape-probe.png, pixel7pro-chrome-version.png)

Identity confirmed: **Google Chrome 154.0.8037.126 (Official Build, 64-bit), Android 17 (SDK 37), Pixel 7 Pro, build CP3A.260905.009**.

| Item | Value |
|---|---|
| Viewport | 850 x 411 CSS px, landscape (same black strip at the left edge as the Edge run) |
| devicePixelRatio / canvas | 2.625 / 2231 x 1078 px (canvas>css 0.381) |
| pointer:fine / hover / maxTouchPoints | no / no / 5 |
| Browser-level event counts (session) | touchstart 37, touchend 37, pointerdown 37, mousedown 0, click 0 |
| Game state | Remaining 100, Mistakes 6, board zoomed in |

Owner report: Chrome behaves the same as Edge (pinch and one-finger drag do not work; the Zoom/Fit/Pan buttons work; tapping works). Probe readings in landscape are identical to the Edge run. This satisfies the "current Android Chrome" identity requirement for these particular observations; the device-class claim is still limited to this one Pixel 7 Pro.

Still unrecorded for Android (both browsers): press-vs-release timing, page scroll/zoom leakage during gestures, audio start, Back/Results/Replay/Level Select flow, engine-level touch+mouse emission, premature selection and double-fire counts, and whether the left black strip hides game area.

## Owner follow-up answers (Pixel 7 Pro, Chrome)

- Tapping an arrow removes it, and gameplay "works just like on desktop" (R1 supported by experience on this device; arrows leave when tapped).
- **Press vs release was not distinguished** by the owner's answer. The unmodified code emits selection on press (`puzzle_board.gd` left-press branch), so press-time selection is the expected behavior; not yet observed as such. Premature selection and double-fire counts remain unmeasured.
- The owner played with the game in **full screen** (the page's Fullscreen button), so page scroll/zoom leakage could not be judged; the leakage check (R4) still has to be run with the game embedded in the page, not full screen.
- **R7 (partial):** entering the page's fullscreen mode on Android Chrome worked (the owner played in it). Audio start not yet reported.

## Owner follow-up answers, round 2 (Pixel 7 Pro, Chrome, game embedded in the page, not full screen)

- **R4 gesture leakage (positive on this device):** gestures inside the game window affect only the game; the page behind does not scroll or zoom. The page moves only when the gesture starts outside the game window. Consistent with `touch-action: none` in the game shell; observed on this one device and browser only, with one-finger drags (pinch inside the game does nothing in the game, and the owner reports no page zoom either).
- **Audio:** the owner heard **no sound**. A repository check found no `.ogg`, `.wav` or `.mp3` files outside `node_modules` and the site tree (`find` over the repo), so the game may have no audio content at all; if so, "no sound" is expected and the audio-start question has nothing to unlock. To confirm with a desktop baseline (does the desktop build ever make sound?) before drawing any R7 conclusion.

## Owner follow-up, round 3 (Pixel 7 Pro, Chrome, full screen)

- In the page's full-screen mode, **Back, Zoom In, Zoom Out, Pan and the menus all function well**, and the owner finds play "more fun on mobile since you can click the arrows faster" than with a mouse (qualitative, one tester, unmodified game).
- Pinch zoom and Pan-off one-finger drag remain unimplemented in the unmodified build; a throwaway prototype (branch `012-spike-touch-prototype`, PR #7) now tries them for the next device round.

## Touch prototype, simulated check (T010; supplemental emulation, not a device reading)

Prototype: branch `012-spike-touch-prototype` (draft PR #7, preview `https://green-bay-09bdc1010-7.centralus.5.azurestaticapps.net/play/?spike`, game build `f3d72dd`). Release-time tap, one-finger Pan-mode drag and two-finger pinch call the existing `PuzzleViewportTransform` (`pan_pixels`, `zoom_at`); synthesized mouse events (device = emulation) are ignored on the board. CI on PR #7: the Godot regression workflow and the Azure build/deploy passed.

Driven with Chromium touch events (Pixel-7-sized landscape 915 x 412, CDP multi-touch; evidence/prototype-touch-sim-contact-sheet.png, left to right then second row: start, pinch out, one-finger drag with Pan off, drag with Pan on, pinch in), counting pixels that changed between steps:
- pinch out: board zoomed in (about 440k pixels changed);
- one-finger drag, Pan off: board unchanged (461 pixels, hover highlight only);
- one-finger drag, Pan on: board panned (about 342k pixels);
- pinch in: board zoomed back out (about 436k pixels);
- browser-level counters rose with each gesture (touchstart = touchend = pointerdown), mousedown 0.
This shows the code path works under simulated touch. It does not show real-finger behavior, tap timing, or iOS; the owner's Pixel run is the real test.

Layout observation from the page-embedded run (emulation): in landscape at 915 x 412 the page's game frame is 16:9 about 826 x 465 CSS px, taller than the 412 px viewport, and the page's sticky header overlays the top of the frame when the page is scrolled, so the game's top toolbar can be covered. The owner has so far played in full screen, which avoids this on Android; iPhone Safari probably has no iframe fullscreen (unverified). This belongs in the T034-T036 page-layout work, not a Godot change.

