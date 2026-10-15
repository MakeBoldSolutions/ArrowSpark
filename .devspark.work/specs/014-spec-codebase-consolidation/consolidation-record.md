# Consolidation Record

The before/after evidence, deferred work and left-alone decisions for this spec. It stays with the
spec bundle in `.devspark.work/` until release archival, and durable code and knowledge never
reference it.

All commands used Godot `4.4.1.stable.official.49a5bc7b6` (Git Bash
`/tmp/ArrowGame-Godot-4.4.1/bin/Godot_v4.4.1-stable_win64_console.exe`).

## Pre-change gate baseline (T001)

Run on 2026-10-15 at `e424388`, whose production code is identical to `58a8bec`.

| Gate | Result |
|---|---|
| `run_puzzle_regressions.py` | exit 0; PUZZLE, ANALYZER, CATALOG, SCOREBOARD, ARROW_DEPARTURE_GEOMETRY, VIEWPORT, LAYOUT, CANVAS and PRESENTATION `_FAILURES=0` |
| `run_regressions.py` | exit 0; `REGRESSION_FAILURES=0` |
| `--headless --editor --quit` | exit 0; no errors |
| `git status --short` | no engine-written changes |

## Behavior baseline (T002–T003)

`gates/behavior_probe.gd` was run at `e424388` into `gates/baseline-before.txt`: 30 entry blocks
(195,273 bytes); all 30 `valid=true solvable=true`; all 30 Open Move trails end `completed=true`.

## Before measures (T004)

| Measure | Before |
|---|---|
| Production GDScript (scripts/ + scenes/) | 48 files, 4,427 lines |
| Largest five | catalog 1,145 · board 548 · analyzer 513 · arrow view 315 · puzzle scene 250 |
| Head-ordering definitions (production) | 4 |
| Direction-to-step mappings (production) | 2 |
| Shape-to-board loops (catalog) | 9 (one helper + 8 inline) |
| Catalog lines | 1,145 |
| Catalog entries with an exact-geometry pin | 24 of 30 (14 fingerprints, 1 canvas fingerprint, 9 content versions) |
| Unreachable template example content (FR-011 set) | 23 files plus 11 `.uid` sidecars; 11 of them GDScript (226 lines) |

## C1: all-entry pins (T005–T007)

- `tests/puzzle_catalog_check.gd` gains `CATALOG_PINS` (30 rows copied from `baseline-before.txt`)
  and `_check_catalog_pins()`, run first in `_initialize()`. The existing fingerprint checks are
  unchanged.
- Puzzle gate: exit 0, every marker `=0`; 90 per-entry title, group and geometry checks pass, plus
  30 position checks. Committed as `a25849f`.
- **Mutation demonstration (SC-001)**, using the safe procedure from quickstart steps 1–6:
  1. `git diff --quiet` on the catalog printed `CLEAN`.
  2. Line 541 (`_build_knot_regions`, first shape) was changed from
     `Vector2i(12, 12), Vector2i(12, 5)]],` to `Vector2i(12, 12), Vector2i(12, 6)]],`.
  3. Puzzle gate: **exit 1**. The catalog check run directly
     (`<godot> --headless --path . --script tests/puzzle_catalog_check.gd`) printed exactly one
     failure:
     `FAIL: entry `knot_regions` keeps its geometry g1-d2398acdb422 (got g1-3b9bb8570e77)` and
     `PUZZLE_CATALOG_FAILURES=1`.
  4. The single edit was undone by reversing it on line 541.
  5. `git diff --quiet` printed `RESTORED`. Puzzle gate: exit 0, `PUZZLE_CATALOG_FAILURES=0`.
- **Observed limitation (pre-existing, not changed):** `tests/run_puzzle_regressions.py` runs each
  check with `subprocess.run(check=True, capture_output=True)` and prints the output only after
  success. A failing check therefore exits non-zero but shows a traceback instead of the `FAIL:`
  line naming the entry. The failing entry's name was taken from a direct run of the same check.
  This is recorded under Deferred, because fixing the runner is an adjacent improvement and not
  part of this spec.

## C2: head ordering (T008–T014)

- `PuzzleDefinition.head_less_than` holds the expression unchanged
  (`a.y < b.y or (a.y == b.y and a.x < b.x)`). `PuzzleState.find_open_move`, `PuzzleSolver.analyze`
  and `PuzzleContentVersion.canonical_text` now pass it to `sort_custom`. `PuzzleAnalyzer._head_less_than`
  is removed, and its four uses, including `_chain_less_than`, call the shared definition. The one
  test reference (`tests/puzzle_analyzer_check.gd`) follows it.
- `grep 'a.y < b.y or (a.y == b.y and a.x < b.x)' scripts scenes` finds 1 definition (was 4).
- Puzzle gate: exit 0, all 9 markers `=0`. Probe rerun versus `baseline-before.txt`:
  `PROBE_DIFF=EMPTY` (195,273 bytes, identical).

## C3: direction step (T015–T016)

- `ArrowView._direction_vector()` returns `Vector2(PuzzleDefinition.direction_vector(direction))`.
  The four-branch `match` is gone, and an unknown value still maps to the zero vector.
- Direction-to-step mappings in production code: 1 (was 2).
- Puzzle gate: exit 0, all 9 markers `=0`. That includes the real-project canvas, presentation and
  departure checks, which instantiate `ArrowView`. The PASS count is 7,511 against 7,390 at T001;
  the +121 are exactly the C1 pin checks.

## C4: catalog shapes (T017–T018)

- The 8 builders (`canvas_validation`, the six `knot_*` boards, `reference_knot`) end with
  `return _from_shapes(<w>, <h>, shapes)`. Diff: +8 / −64, and only the loop and return lines
  changed; literals, their order and comments are untouched.
- Shape-to-board loops: 1 (was 9). Catalog: 1,089 lines (was 1,145).
- Puzzle gate: exit 0, all 9 markers `=0`, including all 30 C1 pins. Probe:
  `PROBE_DIFF=EMPTY`.

## C5: template example removal (T020–T023)

- Reachability walk (follows `res://`, `uid://` and `class_name` from `project.godot`):
  `gates/reachable-before.txt` has 127 files; none of the 23 removal files is reached;
  `scripts/game_state.gd` and `scripts/level_state.gd` are reached and are not in the list.
- `git rm` of 34 paths (23 files plus 11 `.uid`): `scenes/game_scene/`, `scenes/end_credits/`,
  `scenes/menus/level_select_menu/`, `scenes/loading_screen/`,
  `scenes/overlaid_menus/{game_won,level_lost,level_won}_menu.*`,
  `scripts/level_list_state_manager.gd*`.
- `gates/reachable-after.txt` is identical to the before file (`REACHED_SET_UNCHANGED`). The
  dangling-reference `git grep` finds nothing outside the addon, the archive and this bundle once
  `index.json` is regenerated.
- Full gates: puzzle exit 0 (9 markers `=0`), save exit 0 (`REGRESSION_FAILURES=0`, so seeded saved
  progress and remaps are preserved), and editor validation exit 0 with no missing-dependency or
  parse errors.
- `save-progression.md`: `appliesTo` no longer lists the level-list manager; it states why
  GameState/LevelState stay, and where the example came from. It also fixes a stale claim: New Game
  selects `first_knot` (per `main_menu_with_animations.gd:76`), not `reference_knot`.
- **Found, left unchanged (out of scope):**
  - `web/scripts/check-content.mjs` still lists `scenes/loading_screen` among the folders it scans
    for pre-play words. Its `walk()` returns `[]` for a missing folder, so it still passes
    (`check-content: ok`, exit 0). The shipped loading screen is the addon's, which it never
    scanned. `web-showcase.md` describes that scan list.
  - The New Game button's tooltip (`main_menu_with_animations.tscn:389`) says "Starts the
    Reference Knot", but New Game starts `first_knot`. This is player-visible text, and the spec
    allows no UI changes.

## C6–C7: stale docs and the responsibility map (T024–T027)

- `tests/run_puzzle_regressions.py` docstring: "all 22 catalog entries" corrected to 30. It now
  includes the eight progression levels and the all-entry pins.
- `scripts/puzzle/puzzle_catalog.gd` comments: two claims that every builder uses
  `create_fixed()`'s dictionary style now name the three literal styles (dictionaries; computed
  loops in `dense_unravel` and `composed_shaped`; vertex-path shapes through `_from_shapes`).
  Comment-only.
- `.knowledge/architecture/arrow-puzzle.md` gains `## Code Responsibilities`. A scripted check
  confirms that every one of the 37 remaining production scripts is named in the map.
- `.knowledge/index.json` regenerated (exit 0).
- **SC-005 self-check.** Each of the six US3 questions, answered from the map alone, for the
  reviewer to confirm at PR review (Judge J-001):
  1. Blocking rule: `PuzzleState._is_head_blocked`, over `PuzzleDefinition.forward_ray_cells`.
  2. Open Move choice: `PuzzleState.find_open_move`, first legal head by
     `PuzzleDefinition.head_less_than`.
  3. Score formula: `PuzzleState.get_results`.
  4. Group-scoped Next Puzzle: `PuzzleSession.advance_to_next`, through
     `PuzzleCatalog.next_in_group`.
  5. Pinch zoom: `PuzzleBoard` touch handling, applied through `PuzzleViewportTransform`.
  6. Persisted saved-game state: the template's `GlobalState`, holding `GameState`/`LevelState`;
     puzzle play never writes to it. Unreachable scenes are listed under "Template copies,
     unreferenced", and the removed examples under the restore note.
