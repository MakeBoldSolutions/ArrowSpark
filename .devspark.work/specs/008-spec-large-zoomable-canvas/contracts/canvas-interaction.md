# Canvas Interaction Contract

This is an internal presentation and player-interface contract, not a network API. Paths resolve from the repository root recorded in plan.md.

## Pure helper API

New scripts/presentation/puzzle_viewport_transform.gd, class_name PuzzleViewportTransform, extends RefCounted:

- configure(grid_size: Vector2i): resets definition dimensions and fit/manual state; no rule reference retained.
- resize_view(area: Vector2): updates validity and applies fit/manual resize policy.
- fit_puzzle(): center D/2 and set fit cell_pixels with margin 16, mode fit.
- zoom_at(factor: float, anchor_local: Vector2): reject nonfinite/nonpositive factors; clamp scale; preserve anchor logical point except bounds clamping. No-op at bound does not change mode.
- pan_pixels(content_delta: Vector2): shift center by -delta/cell_pixels, clamp, set manual mode only on effective movement.
- logical_to_local(point: Vector2) / local_to_logical(point: Vector2): inverse pair defined in research.md; invalid layout must not yield usable hit coordinates.
- cell_at(local_point: Vector2): return Vector2i(-1,-1) for invalid layout, outside viewport or outside board, otherwise floor inverse coordinates.
- reveal_cell(cell: Vector2i, minimum_cell_pixels=48.0, padding=8.0): zoom up if needed then minimally translate to contain padded full head-cell rectangle. Pending invalid-layout requests are owned by board.
- world_position() / world_scale(): derive canonical World projection; no mutation or pixel geometry construction.

Tolerance: projection/inverse assertions <=0.001 logical cell, fit containment <=0.5 logical pixel. User zoom step 1.2 and bounded scales as research specifies. Clamp centers using interior half-extents after 16-pixel margins; smaller axes remain centered.

## PuzzleBoard public boundary

Preserve setup(definition), cell_clicked(cell), hover_cell_changed(cell), departure_finished, play_removed(head), play_blocked(head), set_hovered_head(head), suggest_open_move(head), and clear_suggestion(). Add fit_puzzle(), zoom_in(), zoom_out(), set_pan_mode(enabled), and set_navigation_enabled(enabled), with a view_changed signal if toolbar enablement needs updates. These call the helper, update only World transform, then invalidate/resample hover.

setup configures all views once at canonical 64-pixel extent. Active views parent to World; departing views parent to DepartureClip under World. All children ignore input. Board clips viewport and uses mouse_filter STOP; wheel events are explicitly accepted. DepartureClip clips logical bounds separately. World transform never writes ArrowView.scale, which belongs to pulse feedback.

## Player bindings and arbitration

| Context | Action | Default |
|---|---|---|
| Eligible board under pointer | Zoom | Wheel up/down, pointer anchor |
| Select mode | Select arrow | Primary press, one request per physical press |
| Eligible board | Pan | Middle drag; suppress simultaneous primary |
| Pan toggle on | Pan | Primary drag; primary never selects |
| Board focus | Pan camera | Existing move_* WASD / left stick, 600 screen px/s |
| Board focus | Zoom in | canvas_zoom_in: Equal / right shoulder |
| Board focus | Zoom out | canvas_zoom_out: Minus / left shoulder |
| Board focus | Fit | canvas_fit: F / gamepad Y |
| Toolbar focus | Zoom/Fit/Pan toggle | Existing UI navigation and accept |

Normalize directional vector so diagonals are not faster. Use existing action deadzones. Pan polling is allowed only for focused eligible board; consume matching GUI actions to avoid focus drift. D-pad/Tab remain focus navigation. Tab cycle: Open Move, Zoom Out, Zoom In, Fit Puzzle, Pan, board. Board D-pad-up returns to Pan; toolbar directional neighbors and Tab always permit exit. No new keyboard/gamepad arrow-selection promise is introduced.

Mouse press grabs board focus only when it acts on canvas. Drag initiation captures button; subsequent motion changes presentation only, release anywhere ends gesture; focus/window exit, pause, hiding, results and setup cancel it. Out-of-board release cannot emit selection. Select-mode unmodified primary drag remains existing press-selection behavior and is never advertised as pan.

Toolbar is a separate row beneath existing HUD, outside the transformed area. Wrap or use compact controls at 960x540/800x800 so text, focus and help never overlap the board. Buttons have readable names/tooltips and visible Pan pressed state. Board has visible focus border and help describing current mode and bindings; derive remapped bindings from InputMap rather than hard-code misleading help.

## Assistance, resize and lifecycle

Controller remains sole caller of PuzzleState.request_open_move. Suggestion reveals head at >=48 px/cell with 8 px padding, then pulses the same ArrowView. If already readable and fully padded-visible, do not change view. Empty/completed request remains no-op. Long shape need not wholly fit. Pending reveal after invalid-area recovery never adds an assist or revives a cleared suggestion.

Resize fit view recomputes fit; manual view retains absolute cell scale/logical center then clamps. ArrowView gains set_presentation_layout_valid(bool): gate advancement and direct advance calls without changing route or distance. Off-screen with valid layout is not invalid layout. Board updates this flag only on validity transitions. Controller disables navigation when results show and resets it on new attempt. No persistent write path.

## Compatibility acceptance

Rule/score snapshots are identical before/after navigation; solver/analyzer unaffected. Old tests compare screen-projected geometry through helper/World rather than expect local points to rebuild on resize. Keep outcome/ownership/counter/barrier assertions and improve projection checks; do not retain fake _cell_size/_origin semantics solely for tests. All public rule APIs remain unchanged.
