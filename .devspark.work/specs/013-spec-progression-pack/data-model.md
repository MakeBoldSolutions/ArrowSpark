# Data Model: ArrowSpark Progression Pack

No persisted data is added or changed. The camera is transient and resets every attempt.

## Camera (existing `PuzzleViewportTransform`, behavior change only)

| Field | Meaning | Change |
|---|---|---|
| `board_size` (cells) | Puzzle grid dimensions | none |
| `viewport_size` (px) | Visible area | none |
| `cell_pixels` | Zoom scale, in `[fit, max(192, fit)]` | none |
| `center_cells` | Camera center in cell units | domain widens from the interior half-extent to the board rectangle `[0, board_size]` per axis, except locked to board center at the Fit floor |
| `fit_mode` | True after setup/Fit until an effective pan or zoom | none |

Rules: at the Fit floor, `center_cells == board_size / 2`; above it, `0 <= center_cells[axis] <= board_size[axis]`; mapping `p = viewport / 2 + (q - center_cells) * cell_pixels` is unchanged, so hit testing and rendering projection need no change.

## Progression Level (catalog entry)

| Field | Notes |
|---|---|
| `id` | stable lowercase snake_case, chosen once |
| `title` | distinct, player-appropriate |
| `group` | `arrowspark_levels`, ordered before `reference_knot` |
| `build` | literal-data builder returning a `PuzzleDefinition` (width, height, arrows, tails) |

Derived, not stored: content version (`PuzzleContentVersion.of`), group-relative position, next-in-group.

## Design-Learning Record (a durable reference document, not data)

Per level: id, title, design intent (primary challenge), analyzer characteristics (arrow count, board size, density, initial legal moves, dependency depth and edges, components, longest chain, arrow length average and max, bends, single-cell share; "unavailable" where tooling does not report), designer notes (where searched, insight, rewarding follow-ups, tedious or satisfying, rescan, best release). Cross-level summary separating **observed facts**, **designer judgments** and **open questions**. No generator commitments.
