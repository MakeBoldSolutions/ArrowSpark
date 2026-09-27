# Save and Input Regression Checks

Run `python tests/run_regressions.py` (Python 3 and Godot on PATH), or use
`python tests/run_regressions.py --godot C:/path/to/godot.exe`.

The runner copies the relevant production scripts into a temporary project and
isolates player data. Expected engine errors exercise failure handling; success
requires exit code zero and `REGRESSION_FAILURES=0`. Each Godot process has a
45-second timeout. This suite also asserts that opening the arrow puzzle from
Play/New Game does not call `GlobalState.reset()` or `GameState.start_game()`
(the no-reset guarantee for existing saved progress).

Before releasing, manually check recovery-dialog layout and both choices,
keyboard/gamepad menu navigation, remapping across restart, and level progress
persistence on the supported Godot version. Headless regression checks do not
replace those interactive checks.

# Arrow Puzzle Regression Checks

Run `python tests/run_puzzle_regressions.py` (Python 3 and Godot on PATH), or
use `python tests/run_puzzle_regressions.py --godot C:/path/to/godot.exe`.

This runs four independent headless checks:

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
2. Pure route-geometry regressions (`tests/arrow_departure_geometry_check.gd`)
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
3. A scene-based HUD/board layout and feedback-duration check
   (`tests/puzzle_layout_check.gd`) against the real project — so the full
   scene/addon dependency graph is available — with `APPDATA`/`XDG_DATA_HOME`
   redirected to an isolated temporary directory so no player save/settings
   data is read or written. Asserts the HUD and board rects never overlap and
   both stay visible at 1280x720 and 960x540, exercises synthetic head/tail
   clicks and multi-departure draining, resize at 960x540/1280x720/800x800,
   resize and zero-extent recovery while paused, a combined concurrent-
   departure/pause/resize/resume scenario, setup-replacement disposal of
   in-flight departures, and that the blocked-cue duration constant does not
   exceed its coded cap. Success requires exit code zero and
   `PUZZLE_LAYOUT_FAILURES=0`.
4. Real-scene presentation checks (`tests/puzzle_presentation_check.gd`):
   ordered continuous geometry, cardinal heads, defensive copying, whole-cell
   GUI events, owner hover, interrupted red pulses, immediate normalized
   departures (including duplicate-start guards and exactly-once completion),
   path-following departure geometry (initial silhouette equivalence,
   head/body overlap, cardinal orientation in all four directions,
   equal-delta-partition speed and full-tail finish), fonts, tabular numerics
   and scoped themes. Text/control bounds and visible focus styles are
   checked at both supported sizes. Requires exit zero and
   `PUZZLE_PRESENTATION_FAILURES=0`.

The launcher imports the real project before both scene checks, sharing one
temporary APPDATA/XDG_DATA_HOME root across import and scene processes. The
pure-rule copy list remains independent of scenes and fonts. Each real-project
process has a 90-second timeout; missing markers, script errors and nonzero
exit codes fail the run. No test reads or writes personal player data.

Geometry assertions do not establish rendered seam/antialias quality. Inspect
straight, bent and single-cell silhouettes, negative space, typography, hover,
red feedback and results on a desktop display. Synthetic events do not replace
physical keyboard/gamepad navigation, remapping, pause/Restart/Replay and menu
roundtrips. Record the actual Godot version; testing on a newer engine alone
does not establish compatibility with the declared 4.4 baseline.

Before releasing, manually perform the full desktop smoke matrix (window
resizing, rapid head/tail clicks, 100 mistakes, all-departures completion,
Replay, pause, and menu transitions with mouse/keyboard/gamepad) on the
supported Godot version — the headless checks above are the automated proxy
for the feedback-duration and HUD/board layout constraints, not a replacement
for interactive verification.

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
