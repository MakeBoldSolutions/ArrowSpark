# Data Model: Reference Puzzle and Level Groups

## Catalog Entry (existing, extended)

| Field | Type | Notes |
|---|---|---|
| `id` | String | Stable, unique, unchanged for all 21 existing entries; new `reference_knot` |
| `title` | String | Display title; unchanged for existing entries |
| `build` | Callable | Zero-arg builder returning a fresh `PuzzleDefinition` |
| `group` | String | **New.** One of `foundations`, `puzzle_lab`, `arrowspark_levels` |

Validation: every entry has exactly one `group` from the known set; ids unique; `group` is never read by rules, solver, analyzer, scoring or viewport code.

## Puzzle Group (metadata constants in `PuzzleCatalog`)

| id | Title | Presentation order | Members (catalog order) |
|---|---|---|---|
| `arrowspark_levels` | ArrowSpark Levels | 1 | `reference_knot` |
| `foundations` | Foundations | 2 | `intro`, `first_bend`, `multi_bend`, `dependency_chain`, `forced_sequence`, `multiple_choices`, `dense_board`, `subtle_blockers` |
| `puzzle_lab` | Puzzle Lab | 3 | `nested_chain`, `cascade_key_arrow`, `dense_unravel`, `bent_network`, `long_range_blocker`, `composed_shaped`, `canvas_validation`, `knot_long_geometry`, `knot_interwoven_paths`, `knot_dense_core`, `knot_regions`, `knot_single_release`, `knot_boundary` |

Derived (not stored): group display position `group_position(id)` = 1-based index within its group.

## Session state (existing, extended, in-memory only)

- `PuzzleSession._current_id` (existing).
- `PuzzleSession._level_select_requested: bool` (**new**, one-shot, consumed by the main menu; never persisted).

## Reference Puzzle

A `PuzzleDefinition` (width, height, `arrows: head→direction`, `tails: head→Array[Vector2i]`) authored via the existing shape-list + `_tail_along` style. Not a new type. Conceptual design vocabulary (neighborhood, bridge arrow, discovery beat, insight chain, major release) is documentation only and MUST NOT appear as runtime state.

## Design Report / Playtest Observation

Documents, not runtime data. Playtest observation record fields: session date, candidate version, tester, prior familiarity, input method, Open Move use, and unedited answers to the fifteen questions (Q1–Q15).
