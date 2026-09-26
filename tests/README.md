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

This runs two independent headless checks:

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
2. A scene-based HUD/board layout and feedback-duration check
   (`tests/puzzle_layout_check.gd`) against the real project — so the full
   scene/addon dependency graph is available — with `APPDATA`/`XDG_DATA_HOME`
   redirected to an isolated temporary directory so no player save/settings
   data is read or written. Asserts the HUD and board rects never overlap and
   both stay visible at 1280x720 and 960x540, exercises synthetic head/tail
   clicks and multi-departure draining, and that the blocked-cue duration
   constant does not exceed its coded cap. Success requires exit code zero and
   `PUZZLE_LAYOUT_FAILURES=0`.

Before releasing, manually perform the full desktop smoke matrix (window
resizing, rapid head/tail clicks, 100 mistakes, all-departures completion,
Replay, pause, and menu transitions with mouse/keyboard/gamepad) on the
supported Godot version — the headless checks above are the automated proxy
for the feedback-duration and HUD/board layout constraints, not a replacement
for interactive verification.
