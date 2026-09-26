# Implementation Verification Guide

Working directory: `C:/GitHub/MakeBoldSolutions/ArrowGame`.

## Automated verification after implementation

1. Record `godot_console --version` (4.4 is the project baseline).
2. Run `godot_console --headless --path C:/GitHub/MakeBoldSolutions/ArrowGame --editor --quit`; inspect script/import errors, not exit status alone.
3. Run `python tests/run_puzzle_regressions.py --godot godot_console`; require exit zero and PUZZLE_FAILURES=0. The new launcher copies only core scripts and tests to a unique temporary project without autoloads.
4. Run `python tests/run_regressions.py --godot godot_console`; require exit zero and REGRESSION_FAILURES=0. This existing launcher isolates saved data.

Core matrix: all four directions, adjacent/distant blockers across gaps, behind/off-axis cells, blocker directions, edge exits, inactive blockers, repeated/ignored selections, 100 blocked selections, zero taps, score floor, rounding, witness solution and reset. Check total_taps=successful_removals+mistakes at every step. Example fixed board: perfect score 8/100.0%; three mistakes score 5/72.7%; eight mistakes score 0/50.0%; nine mistakes score 0/47.1%.

## Desktop smoke

Use an isolated test copy/user-data location, not the player's live saves. Seed valid settings/progress through the existing test fixtures when testing preservation; compare before/after content. Start from opening, not directly from the puzzle scene.

- Launch, skip/finish intro, open Play; verify eight arrows, all directions and HUD 8/0.
- Click B 100 times before removing A; remaining stays eight, mistakes becomes 100, and play continues. Click empty space/hold mouse; no extra taps.
- Replay/start a fresh run; remove witness sequence A,B,D,C,E,F,G,H. Try rapid clicks and selecting B while A departs. Verify no duplicate counts; all departures finish before one results view.
- Verify result arithmetic for perfect and mistake-heavy runs, Replay layout reset, and a second completion.
- Resize the window; check arrow hit targets, HUD/results visibility and correct coordinates.
- Pause during feedback/departure; resume without state changes. Test options/back, cancelled and confirmed restart, Main Menu, then Play. Confirm no legacy progression or failure UI is reachable from puzzle play.
- Test affected menus with mouse, keyboard and an available gamepad, including remapped bindings, focus restoration and results Replay/Main Menu. If hardware is unavailable, record the gamepad check as outstanding rather than passed.
- Verify existing valid/corrupt-save and settings recovery paths, preserving data and settings. Starting/replaying the puzzle must not reset or save legacy progress.

Record commands, actual engine version, results and unavailable checks in gates/verification.md within this temporary bundle. Headless import is not a substitute for interactive smoke. Required checklist/analyze/critic reviews remain separate; no implementation completeness claim until mandatory verification passes.
