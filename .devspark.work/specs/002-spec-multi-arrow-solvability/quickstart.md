# Verification Quickstart

Working directory: C:/GitHub/MakeBoldSolutions/ArrowGame. Replace <godot> with a Godot 4.4 executable. These checks are planned, not executed results.

## Automated

1. Run `<godot> --headless --path C:/GitHub/MakeBoldSolutions/ArrowGame --editor --quit`; inspect parser/resource errors as well as exit status. Use disposable APPDATA/XDG_DATA_HOME for validation and interactive runs.
2. Run `python tests/run_puzzle_regressions.py --godot <godot>`; require exit zero, PUZZLE_FAILURES=0 and PUZZLE_LAYOUT_FAILURES=0. Include puzzle_solver.gd in isolated script copying.
3. Run `python tests/run_regressions.py --godot <godot>`; require exit zero and REGRESSION_FAILURES=0. Preserve existing data isolation.
4. Record engine version, commands, markers and limitations in this bundle's gates/verification.md. Skipped checks remain outstanding.

## Rule fixtures

- Empty/straight/one-turn/multi-turn tails; reject overlap, repeated/disconnected/diagonal/out-of-bounds cells, orphan tails and invalid direction/types. Input/snapshot mutation isolation.
- Head and tail blockers across four directions and straight/bent tails; behind/off-axis nonblocking, own-cell exclusion, edge-facing head. Include tail-only blocker with head off ray.
- Head and every tail cell select same owner; all cells disappear logically at once and count once. Empty/departed/completed selections ignored. At least 100 repeated blocks preserve position and increment once each.
- Solver without scenes/addons: witness has unique heads, all steps REMOVED in a fresh state, ends empty. Test two-arrow facing cycle and initially removable independent arrow plus residual cycle; both unsolvable cases return empty witness. Invalid input has distinct diagnostic outcome.
- Shipped layout assertions for four directions, straight/bent tails, tail blocking and newly legal dependent arrow. Retain formulas, rounding, zero taps and many mistakes.
- Exact metrics: one arrow active/legal=1, forced=1; two independent arrows active/legal=3, branching=1, forced=1; two-arrow cycle active=2, legal=0, no_move=1. Exclude empty terminal. Repeated calls yield identical results; no difficulty fields.

## Desktop and scene checks

Use disposable seeded saves/settings. Launch actual opening/Main Menu, select head and tail cells, inspect connectivity, exit direction and blocked cue. Resize to both test sizes and during departure. Rapidly remove several arrows; results must await all exits. Pause/resume during feedback, cancel/confirm Restart, complete, Replay and return to Main Menu. Check zeroed counters, identical layout and no stale callbacks.

Verify keyboard/gamepad focus and activation in menus/pause/options/results including saved remaps. Compare progress/settings before/after entry/play/replay/menu. Board remains mouse-driven. Missing hardware or interactive access is an outstanding limitation.

Extend tests/puzzle_layout_check.gd for synthetic head/tail clicks, HUD bounds/counters, blocked cue, departure draining and replay reconstruction. Automated scene checks complement required desktop smoke testing.
