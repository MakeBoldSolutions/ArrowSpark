# Contract: Camera Bounds (presentation only)

Unchanged public API of `PuzzleViewportTransform`: `configure`, `resize_view`, `fit_puzzle`, `zoom_at`, `pan_pixels`, `pan_camera_pixels`, `reveal_cell`, `logical_to_local`, `local_to_logical`, `cell_at`, `world_position`, `world_scale`, `fit_cell_pixels`, `max_cell_pixels`, `can_zoom_in`, `can_zoom_out`. No new signals on `PuzzleBoard`.

## Invariants (all must hold after every call)

1. **Reach**: for any scale above the Fit floor, for each of the four board corners `c`, some sequence of `pan_pixels` calls yields `center_cells == c` (corner at viewport center, within 0.001 cell).
2. **Fit lock**: at the Fit floor, `center_cells == board_size / 2` and `pan_pixels` does not change the view. Fit Puzzle, setup, and a zoom-out reaching the floor all restore it.
3. **Bounded**: `0 <= center_cells[axis] <= board_size[axis]` always, so part of the board is always inside the viewport.
4. **Anchor**: for `zoom_at(f, a)` with the result not clamped by invariant 2 or the scale limits, `local_to_logical(a)` before and after differ by less than one screen pixel at the new scale.
5. **Reveal**: `reveal_cell(cell)` leaves the padded head cell inside the viewport (unchanged contract) and applies invariants 2 and 3.
6. **Hit testing**: `cell_at` is unchanged; points outside the board return `(-1, -1)`.
7. **Resize**: manual mode keeps scale and logical center and re-applies invariants 2 and 3; fit mode refits.

## Departure presentation

Departing arrows are not clipped to the board extent; their finish distance remains a pure cell-unit function of direction, head cell, grid size and the exit margin constant. The board's own clip to the viewport bounds all drawing.

## Out of the contract

Rules, solver, state, scoring, input mapping, gestures and persistence.
