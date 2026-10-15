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
