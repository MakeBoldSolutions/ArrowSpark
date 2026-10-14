---
id: touch-gestures
type: authoritative-reference
title: Touch Gestures in Godot (Web and Mobile)
appliesTo:
  - scenes/puzzle/puzzle_board.gd
  - tests/puzzle_canvas_check.gd
  - web/src/styles/arrowspark.css
  - web/game-shell/shell.css
---

# Touch Gestures in Godot (Web and Mobile)

How ArrowSpark handles touch, and what the research behind it found. Owner direction (2026-10-10): gestures must be modeless, as in the games they like. One set of gestures does both navigation and action, with no Pan button needed: pinch zooms, one-finger drag pans, a tap acts.

## What the board does

`PuzzleBoard._gui_input` tracks raw `InputEventScreenTouch` / `InputEventScreenDrag` events and feeds the one viewport authority, `PuzzleViewportTransform` (`zoom_at`, `pan_pixels`). No second zoom or hit-test model exists.

- **Tap acts on release.** A touch is a pending tap. It emits one `cell_clicked` only on release, and only if no second finger appeared and movement stayed under `_TOUCH_SLOP_PIXELS` (32).
- **One-finger drag pans.** Crossing the slop cancels the tap and starts a pan; the board catches up from the touch-down point so it does not jump. It works with Pan mode off. Pan mode and the Pan button remain for mouse users.
- **Two-finger pinch zooms** about the midpoint, and moving both fingers together pans. Bounds are the transform's own: the camera center may reach any point of the board (above the Fit scale), and the scale is between Fit and the maximum.
- **After a pinch**, the remaining finger is locked out (no select, no pan) until every finger lifts.
- **Emulated mouse is ignored.** Godot synthesizes mouse events from touch with `device == InputEvent.DEVICE_ID_EMULATION`; the board drops them so one touch never selects twice or before release.
- Tests: `_check_modeless_touch` in `tests/puzzle_canvas_check.gd` synthesizes touch events (headless cannot test real fingers).

## Godot practices found in research

1. **Prefer raw touches over gesture events on the web.** Godot 4 has `InputEventMagnifyGesture` (pinch) and `InputEventPanGesture` (two-finger pan), but on Android they need `input_devices/pointing/android/enable_pan_and_scale_gestures`, and a Godot forum report describes them not firing in mobile-browser web exports. Tracking touches by `index` in a dictionary and computing the pinch from the two points works everywhere.
2. **Pinch recipe.** Store each finger's position by `index`, remove it on release. One finger is pan, two is pinch. Zoom by the ratio of the current to the previous finger distance, about the midpoint (zoom to the pinch point, not the screen center). Re-baseline the distance whenever the finger count changes.
3. **Ignore the tail of a pinch.** When one finger lifts first, the other becomes a one-finger drag and can fire a stray pan or action. Lock the leftover finger until all fingers lift.
4. **Act on release, with a slop.** Selection on touch-down fires before the user can pinch or pan, and is hard for large fingers. Use a pending tap that a second finger or movement cancels.
5. **Scale pan by zoom** when moving a camera; here the transform already owns that math.
6. **Testing.** "Emulate Touch From Mouse" can exercise single-touch paths only; pinch needs two touches. Use synthesized events in headless checks, and a real device for the final answer. Chromium device emulation is not proof: it zoomed under simulated multi-touch while the real Pixel did not.

## Web: the browser can take the gesture first

On the web the browser decides whether a gesture belongs to the page or the game. Chrome combines `touch-action` across the iframe boundary, so `touch-action: none` inside the game shell (`web/game-shell/shell.css`) is not enough: the host page must also set it on the frame (`.game-frame__stage` in `web/src/styles/arrowspark.css`). Without it the page can claim a two-finger gesture as page zoom and the game only receives a cancel. This was the leading explanation for pinch failing on a real Pixel 7 Pro; it is a hypothesis until re-tested on the device. Side effect: dragging on the game area does not scroll the page.

## Libraries considered and not adopted

- **Godot Touch Input Manager** (Federico-Ciuffardi, MIT, Godot 4): tap, swipe and multi-finger tap as custom events and signals. Pinch was not seen in its description, and it would add a second owner of input.
- **Gesture Recognizer** (Godot 4.2): recognizes drawn shapes ($Q recognizer), not pinch or swipe.
- **InputController**: tap, double tap, long press and hold for actions; no pinch.

The needed logic is about sixty lines driving the existing transform, so no addon is warranted. No official Godot guide covers combined tap, pan and pinch for web exports.

## Open verification

- Pinch, drag and tap were re-tested on the real Pixel 7 Pro in Chrome after the `touch-action` change and the modeless rewrite: pinch zoom and one-finger drag worked without issue and all levels were played through. Other Android devices and browsers have not been tested.
- iPhone Safari remains unverified.
