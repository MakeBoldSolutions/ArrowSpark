# Save and Input Regression Checks

Run `python tests/run_regressions.py` (Python 3 and Godot on PATH), or use
`python tests/run_regressions.py --godot C:/path/to/godot.exe`.

The runner copies the relevant production scripts into a temporary project and
isolates player data. Expected engine errors exercise failure handling; success
requires exit code zero and `REGRESSION_FAILURES=0`. Each Godot process has a
45-second timeout. This suite also asserts that opening the arrow puzzle from
Play/New Game, or selecting a puzzle from Level Select, does not call
`GlobalState.reset()` or `GameState.start_game()` (the no-reset guarantee for
existing saved progress), and that New Game always resets `PuzzleSession` to
catalog position 0 regardless of a prior Level Select choice earlier in the
same session. The isolated project also carries `scripts/puzzle/puzzle_definition.gd`,
`scripts/puzzle/puzzle_catalog.gd` and `scripts/puzzle_session.gd`, since
`main_menu_with_animations.gd`'s `new_game()`/Level Select handler now
reference `PuzzleCatalog`/`PuzzleSession` directly. The launcher also copies the
project's real `[input]` section into the isolated project so custom actions
(the canvas zoom/fit actions and movement) exist: the suite checks that the
additive zoom/fit actions appear in the inherited remap list, that a remapped
key, a gamepad-only remap and a mixed keyboard-plus-gamepad remap restore from
disk without duplicates, that reset-to-default restores them, that the
inherited options scenes do not hide them, that the `move_*` bindings are
unchanged, and that no viewport/camera field ever appears in saved settings.

Before releasing, manually check recovery-dialog layout and both choices,
keyboard/gamepad menu navigation, remapping across restart, and level progress
persistence on the supported Godot version. Headless regression checks do not
replace those interactive checks.

# Arrow Puzzle Regression Checks

Run `python tests/run_puzzle_regressions.py` (Python 3 and Godot on PATH), or
use `python tests/run_puzzle_regressions.py --godot C:/path/to/godot.exe`.

This runs nine independent headless checks, in execution order:

1. Pure rule regressions (`tests/puzzle_regression.gd`) against an isolated,
   unique temporary project containing only the puzzle's core scripts
   (`scripts/puzzle/*.gd`, including `puzzle_solver.gd`) — no scenes, addons or
   autoloads. Covers geometry validation for single-cell, straight-tailed and
   multi-turn-tailed arrows; the blocking matrix (head- and tail-caused, all
   four directions, off-axis/behind/diagonal non-blocking, own-cell exclusion);
   whole-shape atomic removal; the shipped puzzle's witness solution and
   solvability analysis (including a deliberately unsolvable fixture and an
   order-independence check across every legal first move); ignored/inactive
   selections; counter invariants; 100 consecutive blocked selections; the
   blocked-cue duration cap; results arithmetic and one-decimal rounding
   (including the exact 6.25% -> 6.3% tie); zero-tap accuracy; completed-state
   ignoring; and fresh-state Replay reset. Success requires exit code zero and
   `PUZZLE_FAILURES=0`.
2. Pure structural-analysis regressions (`tests/puzzle_analyzer_check.gd`)
   against the same bare temporary project as (1) (no scenes, fonts or
   `GameVisualStyle` dependency — `PuzzleAnalyzer` depends only on
   `PuzzleDefinition`/`PuzzleState`/`PuzzleSolver`). Fourteen hand-constructed
   synthetic fixtures with hand-computed expected values: an independent pair,
   a simple three-arrow chain, a deep four-arrow total-order chain, a
   branching/open puzzle, a three-way cascade, a two-blocker-on-one-arrow
   puzzle, a bent-tail dependency, a long-range blocker, a structurally
   invalid definition, a valid-but-unsolvable two-arrow cycle, a mixed
   acyclic-chain-plus-cyclic-component graph (proving the longest-simple-path
   search terminates and returns the exact documented value), determinism and
   non-mutation (including interleaved live gameplay), the null-definition
   precondition, and the occupancy-grid visualization helper; it also analyzes the
   `canvas_validation` catalog fixture (solvable, fifty-two-arrow witness, bent
   arrows counted). Success requires
   exit code zero and `PUZZLE_ANALYZER_FAILURES=0`.
3. Pure catalog/session regressions (`tests/puzzle_catalog_check.gd`) against
   the same bare temporary project as (1), extended with
   `scripts/puzzle/puzzle_catalog.gd`, `scripts/puzzle/puzzle_analyzer.gd` and
   `scripts/puzzle_session.gd` (no scenes, fonts or `GameVisualStyle`
   dependency — `PuzzleCatalog` depends only on `PuzzleDefinition`). Pins the
   original 14 entries' ids, order, dimensions and exact arrow/tail content by
   fingerprint, checks the appended `canvas_validation` fixture (40x30, fifty-two
   arrows, long bent arrows, all four directions, a tail-caused dependency, a
   top-left open move, occupied corners) and the Next flow from puzzle 14, and
   enumerates all 22 authored catalog entries (eight baseline puzzles, six
   structural experiments, one large-canvas fixture, six Gordian Knot
   experiments and the Reference Knot) in three purpose groups asserting, for each: a unique, non-empty stable id
   independent of array position; structural validity via
   `PuzzleDefinition.is_valid()`; solver-confirmed solvability via
   `PuzzleSolver.analyze()`; the returned witness replays against a fresh
   `PuzzleState` clearing with zero mistakes; and no difficulty-tier wording in
   any title. Also asserts each of the six structural experimental entries meets
   its own exact `PuzzleAnalyzer`-derived threshold (dependency depth, cascade
   fan-out, density, bent-tail dependency, blocker distance, board/edge count
   — see `.knowledge/architecture/arrow-puzzle.md`'s "Structural Analysis"
   section). Also covers `PuzzleCatalog.ids()/index_of()/get_definition()`
   independent-copy and unknown-id sentinel behavior, fresh-and-isolated
   `get_definition()` per call (including cross-id independence), and
   `PuzzleSession`'s default/set/advance/has-next behavior including the
   last-entry no-op and the invalid-id fallback. Fails loudly (never partially
   skips a malformed entry) if any authored puzzle is malformed or unsolvable.
   Success requires exit code zero and `PUZZLE_CATALOG_FAILURES=0`.
4. Pure scoreboard checks (`tests/puzzle_scoreboard_check.gd`) against the
   same bare temporary project: first completions establish session bests,
   higher scores replace them, and tied or lower scores preserve them. Checks
   also cover stored result fields, overall session score and independent
   result copies. No scene, font or puzzle-rule dependency is required.
   Success requires exit code zero and `PUZZLE_SCOREBOARD_FAILURES=0`.
5. Pure route-geometry regressions (`tests/arrow_departure_geometry_check.gd`)
   against a second isolated, unique temporary project containing only
   `scripts/presentation/arrow_departure_geometry.gd` — no scenes, addons,
   fonts or GameVisualStyle dependency, since the helper takes its style-ratio
   constants (head base offset, tail cap radius) as constructor arguments
   rather than referencing a presentation resource directly. Covers all four
   directions, the synthetic single-cell shaft, straight/one-bend/multi-bend
   routes, cumulative length, exact-vertex and corner-adjacent sampling, the
   analytic forward-ray extension beyond the head, coincident-point and
   short-residual-segment safety, explicit invalid-construction reporting,
   equal/reversed interval-endpoint handling, the constant unclipped
   centerline length invariant across departure distances, forward-grid
   clearance in all four directions, and the tail-cap-dominance style-ratio
   guard. Success requires exit code zero and
   `ARROW_DEPARTURE_GEOMETRY_FAILURES=0`.
6. Pure viewport-transform regressions (`tests/puzzle_viewport_transform_check.gd`)
   against another isolated, unique temporary project containing only
   `scripts/presentation/puzzle_viewport_transform.gd`: fit margins and
   containment, logical/local inverse round trips, cell hit resolution, focal
   zoom anchors and 1.2x steps, saturation at the fit and 192-pixel bounds,
   no-op bounds never leaving fit mode, per-axis pan clamps, fit/manual resize
   policy, invalid/non-finite areas, padded head reveal and the World
   projection. Success requires exit code zero and `PUZZLE_VIEWPORT_FAILURES=0`.
7. A scene-based HUD/board layout and feedback-duration check
   (`tests/puzzle_layout_check.gd`) against the real project — so the full
   scene/addon dependency graph is available — with `APPDATA`/`XDG_DATA_HOME`
   redirected to an isolated temporary directory so no player save/settings
   data is read or written. Asserts the HUD and board rects never overlap and
   both stay visible at 1280x720 and 960x540, exercises synthetic head/tail
   clicks and multi-departure draining, resize at 960x540/1280x720/800x800,
   resize and zero-extent recovery while paused, a combined concurrent-
   departure/pause/resize/resume scenario, setup-replacement disposal of
   in-flight departures, and that the blocked-cue duration constant does not
   exceed its coded cap. Also covers every one of the 22 `PuzzleCatalog`
   entries played start-to-finish through the real scene (active view count,
   HUD puzzle label, unchanged scoring for a zero-mistake witness); Level
   Select's listing/ordering/titles, its initial keyboard/gamepad focus
   placement on the first entry, and selecting a non-first entry
   loading that exact puzzle; and, driving the real
   `SceneLoader.reload_current_scene()`/`change_scene_to_packed()` path
   directly, that Replay/pause-menu Restart reload the currently selected
   non-first puzzle with fresh state and no carried-over departing views,
   that Next Puzzle advances to the following catalog entry with fresh
   state, and that the last catalog puzzle's results omit `%NextPuzzleButton`.
   Success requires exit code zero and `PUZZLE_LAYOUT_FAILURES=0`.
8. Integrated canvas checks (`tests/puzzle_canvas_check.gd`) against the real
   project and the same isolated user-data root: fit and layout of the large
   fixture and all original puzzles at 1280x720, 960x540, 800x800 and 1920x1080
   (no overlap, readable without navigation), wheel/middle-drag/button
   navigation and limits, corner reachability at the working scale, invariance
   of rule state and view identity, the toolbar focus loop and D-pad exits,
   focused zoom/fit/pan actions and their remap safety, drag cancellation on
   pause/focus loss/results, transformed head/tail/empty/departed hits with
   blocked and removed selections, pan gestures that never select, Open Move
   reveal (overview, off-screen, long arrow, pending during an invalid area),
   state/results/solver/analyzer/scoreboard parity across navigation, concurrent
   long departures under navigation/resize/pause/zero-area/replacement with
   exactly-once completion, results gating, per-attempt view reset and
   unchanged saved bytes. Success requires exit code zero and
   `PUZZLE_CANVAS_FAILURES=0`.
9. Real-scene presentation checks (`tests/puzzle_presentation_check.gd`):
   ordered continuous geometry, cardinal heads, defensive copying, whole-cell
   GUI events, owner hover, interrupted red pulses, immediate normalized
   departures (including duplicate-start guards and exactly-once completion),
   path-following departure geometry (initial silhouette equivalence,
   head/body overlap, cardinal orientation in all four directions,
   equal-delta-partition speed and full-tail finish), fonts, tabular numerics
   and scoped themes. Text/control bounds and visible focus styles are
   checked at both supported sizes. Its hover/input mechanics check
   explicitly loads `PuzzleDefinition.create_fixed()` into the instantiated
   real scene's board/state (rather than whichever catalog entry
   `PuzzleSession` defaults to), so its exact-cell-position assertions stay
   independent of the authored catalog content — the layout check above is the
   catalog-generality coverage instead. Requires exit zero and
   `PUZZLE_PRESENTATION_FAILURES=0`.

The launcher imports the real project before all three scene checks, sharing one
temporary APPDATA/XDG_DATA_HOME root across import and scene processes. The
pure-rule copy list remains independent of scenes and fonts. Each real-project
process has a 180-second timeout (the canvas check alone takes about 35 seconds on an idle workstation and longer under load); missing markers, script errors and nonzero
exit codes fail the run. No test reads or writes personal player data.

## Developer Structural Report (non-gating)

`python tests/run_puzzle_structural_report.py --godot C:/path/to/godot.exe`
runs `tests/puzzle_structural_report.gd` in the same bare-isolated-project
pattern as the pure checks above, and prints a deterministic per-puzzle
structural breakdown (board scale, geometry, dependency graph, cascade,
blocker distance) plus a nine-question catalog-comparison summary (deepest
chain, fewest initial legal arrows, widest branching, largest cascade,
longest forced run, highest density, most bends, longest blocker distance,
largest board). Unlike the checks above, this is **not a pass/fail
gate** — it has no `check()`/failure counter and no `PUZZLE_*_FAILURES=0`
marker, and always exits 0 on successful completion. It exists for
developers comparing puzzles during authoring/review, never as an in-game
screen, and its output contains no difficulty label, tier, or composite
score.

Geometry assertions do not establish rendered seam/antialias quality. Inspect
straight, bent and single-cell silhouettes, negative space, typography, hover,
red feedback and results on a desktop display. Synthetic events do not replace
physical keyboard/gamepad navigation, remapping, pause/Restart/Replay and menu
roundtrips. Record the actual Godot version; testing on a newer engine alone
does not establish compatibility with the declared 4.4 baseline.

Before releasing, manually perform the full desktop smoke matrix (window
resizing, rapid head/tail clicks, 100 mistakes, all-departures completion,
Replay, pause-menu Restart, Next Puzzle through the last catalog puzzle,
Level Select, and menu transitions with mouse/keyboard/gamepad) on the
supported Godot version — the headless checks above are the automated proxy
for the feedback-duration, HUD/board layout, and reload-selection constraints,
not a replacement for interactive verification. In particular, exercise Level
Select and Next Puzzle with keyboard-only and (if available) gamepad-only
navigation per constitution Principle III.

## Manual Visual Fixture: Path-Following Arrow Departure

The shipped board (`PuzzleDefinition.create_fixed()`) does not include a
one-bend shape or a long multi-bend path, so `tests/arrow_departure_visual_check.gd`
loads a separate, synthetic fixture definition — single-cell, straight,
one-bend and long multi-bend shapes, one of each cardinal direction — into a
bare `PuzzleBoard`, without altering shipped `PuzzleDefinition` content.

Launch it non-headless so the window is visible:

```
godot --path . --script res://tests/arrow_departure_visual_check.gd
```

Each fixture arrow departs in a staggered sequence a half-second apart so
several departures overlap onscreen. While it runs, visually confirm:
readable feeding motion and speed (continuous forward progress, no visible
stutter, freeze or backward step); fixed bends with no diagonal cuts; the
tail cap traversing each bend with no visible skip or jump; connected
head/body with no initial jump; progressive clipping at the grid edge with
no spill; and simultaneous departures overlapping without visual corruption.
Close the window when done. This fixture writes no player save/settings
data and never touches the isolated headless-check temporary directories
above.

## Manual Visual Fixture: Canvas Navigation Performance and Captures

`tests/puzzle_canvas_visual_check.gd` is a non-headless desktop driver, not a gate.
It loads the 40x30 `canvas_validation` puzzle at 1280x720, starts eight overlapping
departures, waits 2 seconds, then drives 10 seconds of
continuous wheel zoom and middle-drag pan through the board's real input handler,
recording navigation-handler time and frame time (budgets: handler p95 <= 2 ms,
frame p95 <= 33.3 ms, no frame >= 100 ms). It repeats the measurement,
informationally, on a synthetic 600-arrow dense board that is never added to the
catalog, and saves rendered PNG captures at overview, the 64-pixel working scale
and maximum zoom for a human antialiasing/readability review.

```
godot --path . --script res://tests/puzzle_canvas_visual_check.gd -- <output-directory>
```

Run it with `APPDATA`/`XDG_DATA_HOME` redirected to a temporary directory (it
writes no player data itself, but the project autoloads may) and record the
machine, engine version and viewport with the numbers.
