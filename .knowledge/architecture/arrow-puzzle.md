---
id: arrow-puzzle
type: architecture
title: Arrow Puzzle Rules, Presentation and Menu Integration
appliesTo:
  - scripts/puzzle/puzzle_definition.gd
  - scripts/puzzle/puzzle_state.gd
  - scripts/puzzle/puzzle_feedback.gd
  - scripts/puzzle/puzzle_results_format.gd
  - scenes/puzzle/arrow_puzzle.tscn
  - scenes/puzzle/arrow_puzzle.gd
  - scenes/puzzle/puzzle_board.gd
  - scenes/puzzle/arrow_view.gd
  - scenes/puzzle/puzzle_results.tscn
  - scenes/puzzle/puzzle_results.gd
  - scenes/menus/main_menu/main_menu.tscn
  - scenes/menus/main_menu/main_menu_with_animations.tscn
  - scenes/menus/main_menu/main_menu_with_animations.gd
  - tests/puzzle_regression.gd
  - tests/run_puzzle_regressions.py
  - tests/puzzle_layout_check.gd
  - tests/scene_loader_stub.gd
---

# Arrow Puzzle Rules, Presentation and Menu Integration

## Rule Layer (Core Boundary)

`PuzzleDefinition` (scripts/puzzle/puzzle_definition.gd) is an immutable
RefCounted holding fixed dimensions and a cell-to-direction map. The one
authored board is `PuzzleDefinition.create_fixed()`: a 5x4 grid with eight
arrows in all four cardinal directions. `is_valid()` checks structural
constraints only (positive dimensions, nonempty map, in-bounds cells,
cardinal directions); cell uniqueness is guaranteed by Dictionary keys.

`PuzzleState` (scripts/puzzle/puzzle_state.gd) is a RefCounted rule/state
authority with no Node, mouse, tween or persistence dependency. It owns a
private copy of the active arrows and four counters: `total_arrows`,
`successful_removals`, `mistakes`, `total_taps`. `select_arrow(cell)`:

- Returns `IGNORED` without changing any counter for an absent cell or once
  `completed` is true (including re-selecting an already-departed arrow).
- Otherwise increments `total_taps` exactly once, then either increments
  `mistakes` and returns `BLOCKED`, or erases the cell, increments
  `successful_removals`, returns `REMOVED`, and sets `completed` once the
  active map becomes empty.

`is_blocked(cell)` returns false for any cell with no active arrow (including
an absent cell). For an active cell, it scans strictly-ahead cells on the
travel axis implied by the arrow's own direction (LEFT/RIGHT scan the row
toward decreasing/increasing x; UP/DOWN scan the column toward
decreasing/increasing y), from the cell to the board boundary. Any active
arrow found there blocks, regardless of its own direction; arrows behind,
diagonal, or on a different row/column never block. Invariants:
`total_arrows = remaining + successful_removals` and
`total_taps = successful_removals + mistakes` hold at every step.

`get_results()` returns `score = max(total_arrows - mistakes, 0)` and
`accuracy = successful_removals / total_taps` (0.0 at zero taps).
`PuzzleResultsFormat.format_accuracy_percent()` (puzzle_results_format.gd)
renders that ratio as a one-decimal percentage, rounding an exact tie half
away from zero (e.g. 6.25% -> "6.3%").

`PuzzleFeedback` (puzzle_feedback.gd) holds the named animation-duration
constants shared by the view layer and headless tests:
`BLOCKED_CUE_DURATION_SECONDS` (0.15s, capped at `BLOCKED_CUE_DURATION_CAP_SECONDS`
= 0.3s) and `EXIT_TWEEN_DURATION_SECONDS` (0.25s).

Source of truth: tests/puzzle_regression.gd (blocking matrix in all four
directions, off-axis/behind non-blocking, the full A,B,D,C,E,F,G,H witness
solution, ignored/inactive selections, counter invariants, 100 consecutive
blocked selections, the blocked-cue duration cap, results arithmetic and
rounding for five mistake counts including the 120-mistake exact tie,
zero-tap accuracy, completed-state ignoring, and fresh-state Replay reset).
Run via `python tests/run_puzzle_regressions.py --godot <godot>`; requires
exit zero and `PUZZLE_FAILURES=0`.

## Presentation Layer

`ArrowView` (scenes/puzzle/arrow_view.gd) draws one cell (a background tile
plus a directional triangle via `_draw()`) and owns no rule state; its
`mouse_filter` is `MOUSE_FILTER_IGNORE` so a departing view can never
intercept a click meant for another cell. `play_blocked_feedback()` is a
non-color-only scale pulse capped at `PuzzleFeedback.BLOCKED_CUE_DURATION_SECONDS`
and never disables further input. `play_exit_animation()` tweens the view
beyond the board edge along its direction.

`PuzzleBoard` (scenes/puzzle/puzzle_board.gd) lays out views in a
centered, uniformly scaled grid recomputed on `NOTIFICATION_RESIZED`, maps a
primary mouse-button press (not release, and `not event.is_echo()`, so a
held button cannot repeat) to a cell via `_gui_input`, and emits
`cell_clicked`. It has no rule dependency: it always emits the clicked cell
and lets `PuzzleState.select_arrow` decide the outcome, including for empty
cells. `departure_finished` fires once each queued exit tween completes.

`ArrowPuzzle` (scenes/puzzle/arrow_puzzle.gd) owns the `PuzzleState`,
applies state before starting any visual effect, and updates the HUD
(`RemainingLabel`, `MistakesLabel`) immediately after every accepted
selection. It tracks `_pending_departures` and only shows results once
`_state.completed` is true AND every pending departure tween has finished
(`_awaiting_completion` + `_on_departure_finished`), so multiple in-flight
departures are all awaited, not just the most recently clicked arrow.
Showing results disables the `PauseMenuController`'s unhandled input
(`set_process_unhandled_input(false)`) so a pause overlay cannot appear
behind the results panel; a fresh attempt re-enables it.

`arrow_puzzle.tscn`'s `Layout` is a `VBoxContainer` with the HUD
(`HUDMargin`) stacked above `BoardArea`/`PuzzleBoard`; a container stack
cannot overlap its children by construction, satisfying FR-007 at every
size. `PuzzleResults` is `mouse_filter = MOUSE_FILTER_STOP` and covers the
full rect as the last child (so it draws above the board), absorbing
background input while shown.

**Replay and pause-menu Restart both call `SceneLoader.reload_current_scene()`**
rather than resetting counters in place: reloading the scene reconstructs a
fresh `PuzzleState`, fresh views and fresh tweens from `_ready()`, which
trivially guarantees no stale callback or pending tween from the finished
attempt can affect the next one. Cancelling Restart leaves the current
attempt unchanged (unmodified addon behavior). Options/back and Main Menu
reuse the existing `scenes/overlaid_menus/pause_menu.tscn` and background
music player unmodified.

Source of truth: tests/puzzle_layout_check.gd (HUD/board rect non-overlap
and nonzero visibility at 1280x720 and 960x540; the blocked-cue duration
cap), run via the same `run_puzzle_regressions.py` launcher against the
real project with APPDATA/XDG_DATA_HOME redirected so no player save data
is touched; requires `PUZZLE_LAYOUT_FAILURES=0`. Interactive smoke coverage
(resize, rapid clicks, pause mid-feedback, restart) is recorded in
gates/verification.md within the (temporary) planning bundle, not here.

## Menu Integration and the No-Reset Guarantee

`scenes/menus/main_menu/main_menu.tscn` and `main_menu_with_animations.tscn`
both point `game_scene_path` at `res://scenes/puzzle/arrow_puzzle.tscn`.
`main_menu_with_animations.gd` no longer overrides `new_game()` or
`load_game_scene()`; both now use the addon base `MainMenu`'s
default implementation (`SceneLoader.load_scene(game_scene_path)` only), so
opening the puzzle from Play/New Game never calls `GlobalState.reset()` or
`GameState.start_game()`. Continue and Level Select stay hidden (the scene's
default `visible = false`, no longer overridden to conditionally show them);
their scenes/scripts remain in source, unreachable from this menu, so they
can be restored later. The `NewGameButton` carries a tooltip
("Existing level progress is preserved even though it's hidden here.")
stating this, per FR-013. Intro, options and credits are unaffected.

Source of truth: tests/save_input_regression.gd's
`_test_no_reset_on_puzzle_entry()` (run via `tests/run_regressions.py`),
which loads the real `main_menu_with_animations.gd`, seeds a `GameState`
with known `times_played`/`max_level_reached`/`level_states`, calls
`new_game()` then `load_game_scene()` directly, and asserts none of those
values changed while `SceneLoader.load_scene` was still invoked. The
isolated test project registers `tests/scene_loader_stub.gd` as the
`SceneLoader` autoload so the check needs no real scene-loading pipeline;
`game_state.gd` is copied to `scripts/game_state.gd` in that isolated
project because `GlobalState.get_state()` loads it by that hardcoded path.
Requires exit zero and `REGRESSION_FAILURES=0`.
