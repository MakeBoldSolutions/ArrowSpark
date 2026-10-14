# Research: ArrowSpark Progression Pack

No `NEEDS CLARIFICATION` markers remain. Items below record the decisions the plan depends on.

## R-01 Camera clamp: clamp the center to the board rectangle

- **Decision**: In `_clamped_center`, clamp each axis of `center_cells` to `[0, board_size[axis]]` (a board point can be centered, including corners) for any scale above Fit. At Fit scale the center stays at `board_size / 2` (spec: Fit is locked and centered). The clamp still applies when an axis' board fits inside the viewport at a zoomed-in scale only through this same rule, so no special case other than "fit mode / at-fit scale".
- **Rationale**: Exactly satisfies "every board point, including corners, can be centered" and "part of the board always remains in the viewport" (at the extreme the viewport shows half a viewport of board). The visible world is whatever is beyond the edge; no buffer size to tune or scale with the viewport, so the spec's "buffer size" planning question resolves to "none needed".
- **Alternatives considered**: padded world rectangle sized in cells or in viewport fractions (varies with zoom and window size; can still miss the center); only a mild margin (does not satisfy corner centering).
- **Definition of "at Fit scale"**: `cell_pixels` within `_EPSILON` of `fit_cell_pixels()` (the scale floor). Anything above is "beyond Fit" and gets the wide clamp. A manual zoom that returns to the floor re-locks the center to the board center, so zooming all the way out never leaves the board off-center. `fit_mode` flag semantics are unchanged.
- **Implication for resize**: manual mode keeps scale and center and re-clamps with the same rule.

## R-02 Departing arrows with empty world visible

- **Observation**: `PuzzleBoard` parents departing views to `DepartureClip`, which clips to the logical board extent. `ArrowView.start_departure` computes a finish distance in cell units to clear the board edge by `EXIT_CLEARANCE_MARGIN_CELLS` (0.001), at 10 cells/s. At Fit there is only a 16 px margin so the clip is invisible. With the center clamp from R-01 the area beyond the edge can be on screen, so an arrow would be sliced at an invisible line, then disappear.
- **Decision**: Stop clipping departures (`clip_contents` false on `DepartureClip`; the board's own clip to the viewport still bounds drawing) and raise `EXIT_CLEARANCE_MARGIN_CELLS` so a departing arrow travels well past the edge before it is removed. The finish distance stays a pure cell-unit function of direction, position and grid size, preserving the documented "independent of pixel layout" invariant.
- **Margin value**: choose when implementing from the visible extent: at maximum zoom the viewport spans few cells so a small margin is enough; at low zoom with the camera centered on an edge, half the viewport spans many cells and the arrow may still be visible at the end. A modest constant (start at 6 cells, about 0.6 s added at 10 cells/s) hides the removal in the common zoomed-in case and is accepted as a bounded cosmetic limitation at extreme zoom-out. The owner confirms in smoke test; if rejected, the fallback is to restore the clip.
- **Alternatives considered**: a visible board outline (UI change, out of scope); fade-out over the last cells (more code; kept as a possible follow-up); leaving the clip (artifact at edges).

## R-03 Anchor stability near edges

- `zoom_at` computes the new center from the anchored logical point; with the wider clamp the anchor drifts only when the new center is clamped. The new bounds rarely clamp for an anchor on or near the board, so SC-010 should hold to well under a pixel; the headless check proves it on edge anchors at several scales. The only legitimate drift is at the Fit floor, where the center is intentionally re-locked.

## R-04 Hit testing and reveal

- `cell_at` already returns no cell outside the board; unchanged. `reveal_cell` clamps through `_clamped_center`, so the new bounds apply; the head still ends up inside the padded viewport. The tests at `puzzle_viewport_transform_check.gd` around corner reveal need re-deriving, not removal.

## R-05 Checks that encode the old behavior

- `tests/puzzle_viewport_transform_check.gd`: assertions that the board corner "sits on the fit margin" at the extremes (lines ~113 to 117) and the clamp tests. Replace with: corners reach the center at multiple scales; Fit floor locks the center; resize re-clamps; anchor error under one pixel; pan stops with part of the board in view.
- `tests/puzzle_canvas_check.gd`: `_pan_to_logical_corner` asserts the corner cell is fully in view at working scale; extend to centering and to departure-clip assertions (eight references to the clip).
- `tests/arrow_departure_geometry_check.gd`: expectations that include the old margin.
- Documented in `.knowledge/architecture/arrow-puzzle.md` (Canvas Navigation): rewrite the clamp sentence and the departure/clip sentence.

## R-06 Levels: authoring approach and proof

- **Decision**: Level boards are fixed literal data in `puzzle_catalog.gd` using the same shape-list pattern as the Reference Knot (`_tail_along` vertices), placed in `arrowspark_levels` before `reference_knot`. Candidate ids and titles are decided during authoring (the spec's illustrative titles are guidance); ids are stable once chosen.
- **Proof**: the analyzer and solver tests (`puzzle_analyzer_check.gd`, `puzzle_catalog_check.gd`) already iterate the catalog; add per-level valid/solvable assertions, and capture FR-008 characteristics with `run_puzzle_structural_report.py` (non-gating) into the design-learning record.
- **Pacing/size**: boards between Foundations (up to a Dense Board) and the 46 × 32 Knot; roughly 12 × 9 up to about 36 × 26, rising in arrow length, bends and density.
- **Content version**: derived from geometry by `PuzzleContentVersion`, so no manual step; confirm each new level yields a distinct version and existing ones are unchanged.
- **Solver time**: use the existing sampled-check precedent if a level is slow.

## R-07 Play entry and Level Select numbering

- `new_game()` in the main menu sets `reference_knot`; change to the first progression level id. Group-relative numbering and group-scoped Next Puzzle shift automatically; `puzzle_catalog_check.gd` assertions on "ArrowSpark Levels has 1 entry", `group_position("reference_knot") == 1`, total `22` and `SAMPLED_BRANCH_ENTRY` must be updated to the intended contents.

## R-08 Verification on real devices

- Constitution Principle V requires desktop smoke, browser smoke and a real phone for the mobile beta. The phone check covers: corner centering, pinch near an edge, and one or more new levels (SC-003, SC-009). Anything not run is recorded as not tested.
