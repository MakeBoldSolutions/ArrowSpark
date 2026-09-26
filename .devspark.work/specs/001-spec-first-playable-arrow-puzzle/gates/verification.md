# Implementation Verification Record

Working directory: `C:/GitHub/MakeBoldSolutions/ArrowGame`.

## Baseline (before implementation)

- Engine version: `godot_console --version` -> `4.7.2.stable.official.ed1daf0bf` (project baseline is 4.4; recorded actual version per plan.md instruction).
- `godot_console --headless --path . --editor --quit` -> exit 0, no script/import errors.
- `python tests/run_regressions.py --godot godot_console` -> exit 0, `REGRESSION_FAILURES=0`, 34 PASS lines. Expected negative-case engine errors (corrupt save/settings, backup failures) appear in output per tests/README.md and are not failures.

## T001 baseline record

Recorded above. No user data was touched; the launcher uses an isolated temp project/user-data root.

## Post-implementation automated verification (T009, T020, T022)

- `godot_console --headless --path . --editor --quit` -> exit 0, no script/import errors, after all puzzle scripts/scenes and menu changes.
- `python tests/run_regressions.py --godot godot_console` -> exit 0, `REGRESSION_FAILURES=0`, 39 PASS lines (34 pre-existing + 5 new FR-013 no-reset assertions). Before the T010 fix, the same suite failed with `REGRESSION_FAILURES=4` (GlobalState.reset()/GameState.start_game() both detected on Play/New Game), confirming the new test is a genuine test-first regression guard, not one written to already pass.
- `python tests/run_puzzle_regressions.py --godot godot_console` -> exit 0. Two independent checks:
  - Pure rule regressions (tests/puzzle_regression.gd, isolated temp project): `PUZZLE_FAILURES=0`, covering the blocking matrix in all four directions, off-axis/behind/diagonal non-blocking, the full A,B,D,C,E,F,G,H witness solution, ignored/inactive selections, counter invariants, 100 consecutive blocked selections (mistakes +100, board unchanged), the blocked-cue duration cap, results arithmetic/rounding for 0/3/8/9/120 mistakes (including the exact 6.25% -> 6.3% tie), zero-tap accuracy, completed-state ignoring, and fresh-state Replay reset.
  - Scene-based layout/timing check (tests/puzzle_layout_check.gd, real project with APPDATA/XDG_DATA_HOME redirected): `PUZZLE_LAYOUT_FAILURES=0` — HUD/board rects do not overlap and both remain visible at 1280x720 and 960x540; the blocked-cue duration constant is asserted against the FR-005 0.3s cap.
  - 189 total PASS lines across both checks.

## Planning-reference audit (T025 / Finalize Every Route)

`bash .devspark/scripts/bash/check-planning-references.sh` initially found two
leaks, both fixed in place: a branch-name path reference in tests/README.md
(rewritten to describe the smoke matrix without a `.devspark.work/` path) and
an `FR-013` requirement-ID citation in a code comment in
scenes/menus/main_menu/main_menu_with_animations.gd (removed; the comment now
states the behavioral rule without the planning identifier). Re-run after
both fixes: `No planning-artifact references found.`, exit 0. Every task's
`code_ref`/`knowledge_ref` marker in tasks.md is populated (real path(s) or an
explained `n/a`); none left `pending`.

## Outstanding / not runnable in this environment

- Interactive desktop smoke (mouse clicks on a rendered window, physical window resize, gamepad input, visual confirmation of the blocked-cue color/scale pulse) per quickstart.md's Desktop Smoke section: this session has no display/input-injection capability, only headless `--headless`/`--script` execution. The headless checks above are the automated proxies quickstart.md itself calls out as the primary evidence for the numeric FR-005/FR-007 constraints; the interactive pass remains outstanding and should be performed by a human on a desktop with Godot before this feature is considered fully verified end-to-end.
- Gamepad-specific navigation/remap checks: no gamepad hardware is available in this environment; recorded as outstanding per constitution Principle V rather than claimed as passed.
