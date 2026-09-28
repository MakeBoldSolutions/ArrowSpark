# Research: Large Zoomable Puzzle Canvas

Date: 2026-09-28. Scope: design research only; no prototype, gameplay regression, or rendered performance measurements have been run.

## 1. Presentation ownership

**Decision:** Retain PuzzleBoard as the unscaled, clipped Control occupying BoardArea. Add a passive child Control named World with origin at the logical board origin. Active ArrowViews and the existing board-bounds DepartureClip live under World. A new pure RefCounted PuzzleViewportTransform owns conversion, fit, focal zoom, pan bounds, and resize calculations. The board owns the instance; no rule class depends on it.

**Rationale:** puzzle_board.gd currently calculates cell_extent from available size and walks every arrow on resize. ArrowView already draws at a given extent and animates in cell units. A single parent transform lets static shapes retain canonical geometry while the board remains the sole GUI target. World is not managed by a Container and ignores mouse events. Child scaling leaves ArrowView's own feedback pulse independent.

**Alternatives:** Camera2D would require more canvas/GUI boundary work; SubViewport adds an unnecessary render/input boundary; changing every ArrowView extent on wheel events rebuilds all geometry unnecessarily. No addon changes or new package dependency is needed.

**Sources:** scenes/puzzle/puzzle_board.gd, scenes/puzzle/arrow_view.gd, scenes/puzzle/arrow_puzzle.tscn. Godot 4.4 [Control documentation](https://docs.godotengine.org/en/4.4/classes/class_control.html) documents GUI filtering, clipping and scale; [transform documentation](https://docs.godotengine.org/en/4.4/tutorials/math/matrices_and_transforms.html) describes parent-relative transforms. The architecture choice is our inference from these capabilities and current code.

## 2. Coordinates, bounds and resize

**Decision:** Canonical visual cell extent B=64 logical pixels; logical cell centers are (x+0.5,y+0.5). Let D be board dimensions, V available board Control size, s displayed pixels/cell, c logical focal center. World.scale=(s/B,s/B); World.position=V/2-c*s. Logical q maps to board-local screen p=V/2+(q-c)*s; inverse q=c+(p-V/2)/s. Hit cell=floor(q), with viewport and logical bounds checked before emitting. Screen/global input first converts to the unscaled PuzzleBoard local space through its canvas transform; no controller or ArrowView performs camera math.

Fit margin m=16 logical pixels per edge. Fit s=min((V.x-2m)/D.x,(V.y-2m)/D.y). Positive usable view is required. User zoom range is [fit_s,max(192,fit_s)], step factor 1.2, working scale 64 and minimum comfortable selection scale 48 pixels/cell. Overview below 48 remains legal. Fit is the minimum zoom; arbitrary zoom-out is not allowed. The upper bound preserves a fit view on unusually large windows rather than making fit impossible.

For an anchor p, compute q at old scale, then c'=q-(p-V/2)/s_new. Apply pan bounds after anchoring; edge clamping is the only intentional anchor drift. With r=(V-2m)/(2s), clamp each center axis to [r,D-r] when D>2r; otherwise center that axis at D/2. Mouse drag delta moves content: c'=c-delta/s. Directional navigation moves the camera center in the named direction. Fit always centers original dimensions, never remaining geometry.

Store fit_mode. Setup/Fit sets it; actual zoom/pan sets manual mode. Resize in fit_mode recomputes fit. Manual resize retains s and c, clamping only when new scale/bounds require it, and does not silently re-enter fit_mode. Invalid area (width or height <=32) suspends interaction and departures, retaining last valid state; recovery applies this same policy. No divide by zero.

**Rationale:** Fit-only resize remains natural for small puzzles; manual navigation preserves orientation. Absolute displayed cell scale avoids shrinking a user's working view when the window changes.

**Alternatives:** Resetting every resize to fit loses place; allowing unlimited pan/zoom loses orientation; fitting remaining arrows causes jumps as arrows leave.

## 3. Input and focus

**Decision:** Preserve ordinary left-press selection in Select mode. Middle-button drag pans. Add a focusable Pan toggle for trackpad/one-button users; in Pan mode, primary drag pans and primary presses never select. No drag-distance threshold or delayed selection is needed. A middle press takes precedence and suppresses simultaneous primary presses until release/cancel. Cancel drag on pause, hidden board, focus loss, results, setup or lost-button state; release outside the board must end capture without selecting.

Wheel over eligible board zooms around pointer; explicit Zoom Out / Zoom In buttons and keyboard/gamepad actions zoom around viewport center. Toolbar buttons: Zoom Out, Zoom In, Fit Puzzle, Pan (toggle). Board is focusable and has a visible focus outline and concise help. Tab traverses Open Move -> Zoom Out -> Zoom In -> Fit -> Pan -> board -> Open Move. D-pad traverses toolbar/focus; on board D-pad up returns to Pan. Board-focused existing move_up/down/left/right (WASD / left stick) pan the camera at 600 screen pixels/second using normalized direction, independent of zoom. Consume their GUI action events so a stick event does not also move focus. Poll movement only while the board owns focus, window is focused, tree is unpaused, results hidden, and no overlay owns input.

Add custom actions canvas_zoom_in (Equal and numpad plus / right shoulder), canvas_zoom_out (Minus and numpad minus / left shoulder), canvas_fit (F / gamepad Y). These act only with board focus; wheel remains board GUI input. Existing InputActionsList defaults show_all_actions=true and AppSettings handles all custom actions, so new keyboard/gamepad bindings use the existing remapping UI. Reuse existing move actions rather than replacing bindings. Mode toggle is an ordinary focusable button operated through existing UI accept; middle mouse is a convenience, not the only path.

**Rationale:** Current left-press selection makes shared unmodified left-drag panning fragile. Explicit modes guarantee zero selection at gesture start. Navigation-only keyboard/gamepad capability is required here; a new non-mouse arrow-selection system is not introduced.

**Alternatives:** Space-left dragging conflicts with normal UI accept and adds modifier arbitration. Global per-frame action polling without focus/overlay eligibility leaks actions through menus. No pinch handling is added, but input adapters call device-independent board navigation methods.

## 4. Open Move reveal

**Decision:** Controller still calls request_open_move exactly once. Board.suggest_open_move first ensures the target head cell is visible at s>=48, then applies the existing whole-arrow pulse. If s<48 increase to min(48,max_s) about current center. If head-cell rectangle plus 8 screen-pixel padding is inside the viewport, keep location. Otherwise pan minimally on each axis to include that padded head rectangle, then clamp. No reveal animation, camera tween, automatic selection, or extra request. In an invalid viewport retain the pending target and reveal/highlight on valid layout without another rule call. Cleared/replaced suggestions clear this pending target.

**Rationale:** The head provides direction and a selectable identity even for an arrow longer than the viewport. Already readable visible heads do not trigger movement. The existing suggested feedback supersedes hover and persists until a selection or replacement.

**Alternatives:** Fit entire arrow can make it unreadably small; center every target disrupts already useful views; highlighting an off-screen shape alone gives no usable feedback.

## 5. Departures and completion

**Decision:** Keep ArrowDepartureGeometry and rule code unchanged. ArrowView draws at canonical B throughout navigation, with existing feedback and cell-distance speed. DepartureClip remains bounded by D*B under World; board also clips to V. Reparenting active views into DepartureClip preserves canonical position. No navigation event invokes set_shape, setup, start_departure, or set_cell_extent. Resize changes parent projection only.

Add an explicit presentation-layout-valid setter to ArrowView so invalid board size pauses advancement without replacing B or rebuilding its route; direct test calls must obey the flag. Off-screen but valid views continue processing; do not gate processing on visibility-in-viewport. Full-tail clearance uses the authored board and emits once; controller pending counter and results barrier remain authoritative. Replacement cancels old departures. Pan/zoom is allowed while draining until results cover the board, then navigation is disabled.

**Rationale:** ArrowView already stores route and progress in cell units, while its own scale is used by feedback. A common ancestor transform preserves both. Existing resize tests that inspect pixel geometry will need world-projected assertions, while retaining the same logical route and completion guarantees.

## 6. Validation content and supported envelope

**Decision:** Append one plainly labeled catalog entry, id canvas_validation, title Large Canvas Validation. Keep the original fourteen entries, IDs, order and geometry unchanged. Authored fixture is 40x30, 12 arrows, including at least three bent paths of 20–60 cells, all four directions, a tail-caused dependency, a deterministic open head near top-left, and occupied regions near each corner. Use explicit authored cells or deterministic expansion of literal orthogonal path vertices; no procedural/random generator. Solver validates the fixture and supplies its zero-mistake witness. Tests pin all original definitions and only update intentional count/last-entry expectations.

Acceptance envelope: this fixture plus all original catalog content; desktop windows 960x540, 1280x720, 800x800, and 1920x1080. At s=64 fixture is 2560x1920 and exceeds both working viewport axes even at 1920x1080. Fit uses actual post-HUD/toolbar area. No artificial dimension limit is added to PuzzleDefinition; larger content is outside this feature's measured guarantee.

**Rationale:** Catalog entry exercises actual selection, replay, results and session scoring without a separate demo loader or controller injection path. Sparse validation geometry is sufficient; no difficulty tuning.

## 7. Performance and verification

**Decision:** Add focused pure-transform tests and real scene canvas tests to the isolated launcher. A 10-second warmed desktop navigation capture at 1280x720 on the implementation workstation uses the large fixture, continuous pan/zoom and three overlapping long departures. Acceptance: navigation-handler p95 <=2 ms, rendered frame-time p95 <=33.3 ms, no observed input stall >=100 ms attributable to navigation. Record CPU/GPU, engine version, build and actual viewport; these are fixture/workstation acceptance budgets, not universal device promises. Test instrumentation stays in test fixtures; no runtime telemetry service.

Use assertions that pan/zoom preserves ArrowView identities and canonical geometry and calls no whole-board setup; measure before optimizing. Existing test helpers tied to _cell_size/_origin or direct parent position must convert through the new transform rather than weakening gameplay assertions.

Both isolated regression launchers and Godot import/script validation remain mandatory. Current executable reports 4.7.2.stable.official.ed1daf0bf although project contract targets 4.4. Implementation must use a 4.4-compatible executable for target validation or record it as outstanding; a 4.7.2 run is supplementary evidence, not an engine upgrade.

## 8. Knowledge projection and workflow consistency

Five lexical seeds match the delta: arrow-puzzle, game-visual-system, gameplay-contract, save-progression, arrowgame-constitution. The context-projection command with --max-hops 2 returned those five at distance 0, zero unresolved seeds, no accepted hop-1/hop-2 neighbors, and no truncation. No semantic edges are invented from prose links. All five candidates are relevant and retained.

The tasks command contains a final-phase deletion sentence inconsistent with its own release-only lifecycle and the shared preamble. Apply the shared lifecycle: retain the complete working bundle and linkage until /devspark.release archives it; generate no deletion task. Required verify:end-to-end remains pending until code and real flows exist; do not fabricate a pre-implementation pass to satisfy the verification template's pre-flight wording.
