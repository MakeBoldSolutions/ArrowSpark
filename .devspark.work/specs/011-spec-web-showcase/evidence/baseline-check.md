# Truthful baseline check (2026-10-02)

Changes: Play tooltip in `scenes/menus/main_menu/main_menu_with_animations.tscn` ("Starts the Reference Knot. …"); `.knowledge/architecture/save-progression.md` (Play target `reference_knot`, tooltip text, twenty-two entries in a three-group accordion, Web storage note); `.knowledge/architecture/arrow-puzzle.md` (order-independence sampled every sixth branching state for `reference_knot`, others exhaustive; Back first in the HUD tab-order sentence); `tests/README.md` (Play/New Game sets the Reference Knot; order independence with the sampling; content-version pin). `tests/save_input_regression.gd` already asserted the Reference Knot ("new_game() starts the Reference Knot regardless of a prior Level Select selection"); no change needed.

## Gates on 4.4-stable (fresh mirror without `.godot`)

| Command | Result |
|---|---|
| `python tests/run_puzzle_regressions.py --godot <4.4>` | exit 0 (first attempt); all nine markers `=0` (PUZZLE, ANALYZER, CATALOG, SCOREBOARD, ARROW_DEPARTURE_GEOMETRY, VIEWPORT, LAYOUT, CANVAS, PRESENTATION) |
| `python tests/run_regressions.py --godot <4.4>` | exit 0; `REGRESSION_FAILURES=0` |
| `<4.4> --headless --editor --quit` | exit 0; 0 script/parse errors |

## Grep for stale claims

`grep -rni "first catalog puzzle\|catalog position 0\|twenty-one entries" scenes scripts tests .knowledge web/src`:
- none of the Play-target claims remain;
- `.knowledge/architecture/arrow-puzzle.md` keeps two accurate mentions of "catalog position 0" / `id_at(0)`: `PuzzleSession`'s fallback when its id is unset or invalid, and Replay never falling back to it. These describe real behavior, not the Play target;
- `tests/puzzle_layout_check.gd` "a non-first catalog puzzle loads correctly" is an unrelated test description.

No unsampled "every branching state" claim for `reference_knot` remains in `.knowledge/` or `tests/README.md`.
