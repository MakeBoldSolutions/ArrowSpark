# Contract: Touch Input → Board / Viewport Transform

Applies only after the matrix freeze, and only to the extent the spike showed necessary.

1. **Authority.** Every view change goes through `PuzzleViewportTransform` (`zoom_at`, `pan_pixels`, `fit_puzzle`). The board then runs its existing `_apply_view_change`. No other class owns zoom, pan or hit-test math.
2. **Selection (release-time).** A touch starts as a pending tap and emits exactly one `cell_clicked(cell)` (via the transform `cell_at`) only on finger release, and only if all hold: no second finger appeared; movement stayed below the tap/drag threshold; Pan mode did not take ownership; pinch did not take ownership; and no cancellation occurred (focus loss, pause, visibility change, results). The controller resolves outcome, mistakes and score unchanged.
3. **Pan.** One-finger drag pans only while Pan mode is on. With Pan mode off, a one-finger drag emits no selection and moves nothing.
4. **Pinch.** Two-finger pinch calls `zoom_at(factor, midpoint)`; bounds are the transform's existing min/max; no extra clamp elsewhere.
5. **Cancel rules.** A second finger, or movement past the tap/drag threshold, cancels the pending tap; focus loss, pause, visibility change, results overlay and `set_navigation_enabled(false)` cancel any gesture without selecting or moving.
6. **No hover dependence.** No state or action requires hover; hover feedback stays a desktop enhancement.
7. **Mouse parity and emulation.** Existing mouse branches (left press, middle drag, wheel) are unchanged for real mouse input. The board does not rely on touch-to-mouse emulation: while a real touch sequence owns the board, emulated mouse events are ignored (smallest safe mechanism chosen at implementation), so one touch can never select twice or select before release.
7a. **Capability source (game side).** Touch availability is a plain static query on `game_visual_style.gd`; it only conditions sizing, scaling and help text. Gesture handling reacts to the events that arrive and needs no mode flag.
8. **Keyboard/gamepad.** Focused-board zoom/fit/pan actions and remapping continue to work (constitution III).
9. **Out of contract.** Inertia, rotate gestures, double-tap zoom and other gesture features are not part of Spec 012.
