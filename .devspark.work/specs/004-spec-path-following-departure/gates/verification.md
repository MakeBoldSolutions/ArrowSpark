# Verification Record: Path-Following Arrow Departure

## T001/T002 — Baseline and Preflight (2026-09-26/27)

- Engine: only `C:/Users/markh/AppData/Local/Microsoft/WinGet/Links/godot.exe` v4.7.2.stable.official.ed1daf0bf is available in this environment. Declared baseline is Godot **4.4** (`project.godot` `config/features=PackedStringArray("4.4")`). No 4.4 executable was available to install/run in this session, so **4.4-specific verification is left explicitly outstanding**; all evidence below is v4.7.2.
- Baseline commit before implementation: `4a8a28d` (`chore(gates): refresh analyze/critic gate reports after spec/tasks revision`), branch `004-spec-path-following-departure`.
- Baseline regression run (pre-implementation, same v4.7.2 executable): `python tests/run_puzzle_regressions.py` and `python tests/run_regressions.py` were run against the pre-existing rigid-departure implementation before any code in this feature changed, both green (`PUZZLE_FAILURES=0`, `PUZZLE_LAYOUT_FAILURES=0`, `PUZZLE_PRESENTATION_FAILURES=0`, `REGRESSION_FAILURES=0`).
- Preflight review: read spec.md, plan.md, contracts/presentation.md, data-model.md, research.md, quickstart.md and the resolved knowledge (`arrow-puzzle.md`, `game-visual-system.md`, `save-progression.md`, `arrowgame-constitution.md`). No existing required-gate blockers: analyze gate PASS, critic gate WARN (one non-blocking HIGH finding, `critic-001`, addressed below in T028).

## T006/T024 — Automated Regression and Import Validation (2026-09-27, post-implementation)

Commands (Godot v4.7.2, isolated user-data root, no player save/settings touched):

```
godot --headless --path . --import
python tests/run_puzzle_regressions.py --godot C:/Users/markh/AppData/Local/Microsoft/WinGet/Links/godot.exe
python tests/run_regressions.py --godot C:/Users/markh/AppData/Local/Microsoft/WinGet/Links/godot.exe
```

Results:

- Real-project `--headless --import`: clean pass, exit 0, no script/parse errors.
- `run_puzzle_regressions.py`: exit 0. Markers: `PUZZLE_FAILURES=0` (pure rule suite, isolated temp project), `ARROW_DEPARTURE_GEOMETRY_FAILURES=0` (pure route-geometry suite, second isolated temp project containing only `arrow_departure_geometry.gd`), `PUZZLE_LAYOUT_FAILURES=0` (real-project scene/lifecycle suite), `PUZZLE_PRESENTATION_FAILURES=0` (real-project presentation suite).
- `run_regressions.py`: exit 0. Marker: `REGRESSION_FAILURES=0` (save/input suite; expected `ERROR:`-level engine diagnostics from the suite's own negative-case config-corruption/no-space tests were observed and are the suite's documented intended behavior, not new failures).
- `git diff --check`: only CRLF line-ending normalization notices on two files (pre-existing repo convention); no trailing-whitespace or conflict-marker errors.
- `python .devspark/scripts/build_knowledge_index.py --repo-root . --check`: clean (no output).
- `bash .devspark/scripts/bash/check-planning-references.sh`: "No planning-artifact references found."

No 4.4-specific engine validation was possible in this environment; this remains explicitly outstanding per the policy above (disclosed, not silently skipped).

## T025 — Manual Visual Matrix (OUTSTANDING — requires human observation)

Not performed by the implementing agent: this session has no way to visually observe rendered motion, seam/antialias quality, or subjective feeding-motion readability. `tests/arrow_departure_visual_check.gd` is ready to launch (`godot --path . --script res://tests/arrow_departure_visual_check.gd`, non-headless) and covers single-cell, straight, one-bend and long multi-bend shapes across all four directions with staggered concurrent departures, per tests/README.md. **A human reviewer must run this fixture and the shipped board in real play** and record: readable feeding motion/speed, fixed-bend/no-diagonal-cut behavior, tail-cap corner traversal quality, head/body seam continuity, progressive grid clipping without UI spill, simultaneous-departure behavior, pause/resume, resize, and the final results transition — before this spec can be marked Complete per FR-016/SC-007.

## T026 — Hardware Navigation and Saved-Data Smoke (OUTSTANDING — requires human/hardware)

Not performed by the implementing agent for the same reason: physical keyboard/gamepad navigation and remapping, restart cancel/confirm, Replay/Main Menu/options transitions, and seeded saved-progress/settings preservation require actual input hardware and interactive observation. The automated save/input regression (`REGRESSION_FAILURES=0` above) covers the no-reset guarantee synthetically but is not a substitute for this interactive pass. **A human reviewer must perform this smoke pass** and record results, or explicitly note any hardware limitation, before the spec is marked Complete.

## T028 — Gate Finding Resolution

- `analyze-` findings: none open (analyze gate PASS with zero critical/high findings; one LOW hygiene note on T002's missing `Implements:` directive was not a blocking finding and is left as-is since T002 is a process/preflight task, not a requirement-implementing one).
- `critic-001` (HIGH, non-blocking): T005's `assert()` for the tail-cap-dominance invariant is stripped from exported Godot release templates. **Resolved via documentation**, not a code workaround: `.knowledge/architecture/game-visual-system.md`'s "Feedback precedence and departures" section now states explicitly that "this assert is stripped from exported release templates, so it is a dev/test-time guard, not a production safety net," matching the critic's recommended mitigation of documenting the guard's dev-only scope. This is recorded as `outcome` in `gates/critic.md`.

## Summary

Automated verification (geometry unit tests, scene/lifecycle tests, presentation tests, save/input regression, Godot import validation) is complete and green on the only available engine build (v4.7.2). Godot 4.4-specific validation, the full manual visual matrix, and hardware-based navigation/saved-data smoke testing remain explicitly outstanding pending a human reviewer with a 4.4 executable and physical input devices.
