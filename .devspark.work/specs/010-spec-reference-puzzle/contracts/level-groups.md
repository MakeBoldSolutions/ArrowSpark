# Contract: Level Groups (internal API and UI behavior)

## PuzzleCatalog additions (static, pure)

| Function | Returns | Behavior |
|---|---|---|
| `group_ids()` | `Array[String]` | Groups in presentation order: `arrowspark_levels`, `foundations`, `puzzle_lab` |
| `group_title(group_id)` | `String` | Display title; `""` if unknown |
| `group_of(id)` | `String` | Group id of an entry; `""` if unknown id |
| `ids_in_group(group_id)` | `Array[String]` | Members in catalog order; empty if unknown |
| `group_position(id)` | `int` | 1-based position within its group; `0` if unknown |
| `next_in_group(id)` | `String` | Next id in the same group, `""` at the group's end (never crosses or wraps) |

Existing `count()`, `id_at()`, `title_at()`, `index_of()`, `ids()`, `get_title()`, `get_definition()` are unchanged in signature and behavior.

## PuzzleSession

- `has_next()` / `advance_to_next()`: group-scoped via `next_in_group`; `advance_to_next()` returns `false` and leaves the current id unchanged at group end.
- `request_level_select()` / `consume_level_select_request() -> bool`: one-shot in-memory flag.

## UI behavior

- **Level Select**: three group sections (header label + buttons). Button text `"<group_position>. <title>"`. Headers are not focusable; all buttons form one focus chain; pointer, keyboard and gamepad activation all emit `puzzle_selected(id)`.
- **In-game label and Results title**: `"<group_position>. <title>"` (Reference Puzzle reads `1. <title>`).
- **Results buttons**: Replay always; Next Puzzle when `next_in_group` exists, otherwise Level Select; Main Menu always. Level Select returns to the main menu with Level Select open.
- **Main-menu Play (New Game)**: starts `reference_knot`; no `GlobalState.reset()` / `GameState.start_game()`.

## Invariants

- Group has no effect on rules, solver, analyzer, scoring, Open Move, `PuzzleState` or viewport.
- No persistence; no telemetry; stable ids never change.
