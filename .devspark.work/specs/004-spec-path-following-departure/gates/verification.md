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

## T025 — Manual Visual Matrix (CLOSED — agent-observed evidence + user acceptance, 2026-09-27)

**Agent-observed evidence (2026-09-27), distinct from user-reported acceptance per quickstart.md's evidence-distinction requirement.** This session drove the actual Godot window non-headlessly (screenshot + simulated mouse input via Win32 APIs, window-client-area captures only) and directly observed real rendered behavior, rather than inferring it from code:

- Launched `scenes/puzzle/arrow_puzzle.tscn` (the real shipped board) windowed. Clicked arrow A (bent, two-turn tail) and arrow B (straight tail) in sequence. Observed: `Remaining` HUD decremented instantly on click (atomic logical removal before animation, per FR-001); A's bent tail visibly fed through and consumed its corner, leaving a shrinking straight stub before fully clipping at the grid edge with no leftover artifact; B's head disappeared past the edge before its body/tail cap fully cleared (progressive clipping, full-tail — not head-exit — completion, per FR-006/FR-007); no crash, no HUD spill, process stayed responsive throughout.
- Launched `tests/arrow_departure_visual_check.gd` non-headless and captured a frame showing **all four shape categories departing concurrently** (single-cell, straight, one-bend, long multi-bend), each correctly retaining its still-unconsumed bend(s) and dropping consumed ones as its tail passed them — direct visual confirmation of FR-002/FR-003 (fixed bends, corner retention, no diagonal shortcuts) for shapes the shipped board doesn't exercise.
- **Two real bugs were found and fixed in the fixture itself** while doing this (not in production departure code): (1) `_initialize()`'s coroutine returning after the staggered sequence caused the bare `--script` SceneTree process to exit immediately instead of staying open for review — fixed by looping on `create_timer` indefinitely after the sequence, with `close_requested.connect(quit)` so the window's own close button still ends it cleanly; (2) the fixture never set a background `ColorRect`, so the near-black arrows (`ARROW_NORMAL` #1E1E1E) were invisible against Godot's default dark clear color — fixed by adding a `GameVisualStyle.GAME_BACKGROUND` background, matching `arrow_puzzle.tscn`'s own pattern. Both fixes are test-only (`tests/arrow_departure_visual_check.gd`); no production code changed. Full regression suite reran green after the fix (`PUZZLE_FAILURES=0`, `ARROW_DEPARTURE_GEOMETRY_FAILURES=0`, `PUZZLE_LAYOUT_FAILURES=0`, `PUZZLE_PRESENTATION_FAILURES=0`).

The remaining items this session could not itself judge — subjective seam/antialias rendering quality at native resolution, pause/resume and resize observed live by eye rather than only through the automated suite, the final results-panel transition after a full multi-arrow clear, and a human's own reading of "readable feeding motion" — were **accepted directly by the user on 2026-09-27**, on top of the agent-observed structural evidence above. Distinguishing the two per quickstart.md: the corner-retention, atomic-removal-ordering, full-tail-completion and no-crash findings above are agent-observed; the remaining subjective/interactive items are user-reported acceptance, not independently re-verified by this session.

## T026 — Hardware Navigation and Saved-Data Smoke (CLOSED — user acceptance, 2026-09-27)

Physical keyboard/gamepad navigation and remapping, restart cancel/confirm, Replay/Main Menu/options transitions, and seeded saved-progress/settings preservation require actual input hardware and interactive observation this session does not have. The automated save/input regression (`REGRESSION_FAILURES=0` above) covers the no-reset guarantee synthetically. The interactive hardware smoke pass itself was **accepted directly by the user on 2026-09-27** (user-reported acceptance, not agent-observed).

## T028 — Gate Finding Resolution

- `analyze-` findings: none open (analyze gate PASS with zero critical/high findings; one LOW hygiene note on T002's missing `Implements:` directive was not a blocking finding and is left as-is since T002 is a process/preflight task, not a requirement-implementing one).
- `critic-001` (HIGH, non-blocking): T005's `assert()` for the tail-cap-dominance invariant is stripped from exported Godot release templates. **Resolved via documentation**, not a code workaround: `.knowledge/architecture/game-visual-system.md`'s "Feedback precedence and departures" section now states explicitly that "this assert is stripped from exported release templates, so it is a dev/test-time guard, not a production safety net," matching the critic's recommended mitigation of documenting the guard's dev-only scope. This is recorded as `outcome` in `gates/critic.md`.

## Summary

Automated verification (geometry unit tests, scene/lifecycle tests, presentation tests, save/input regression, Godot import validation) is complete and green on the only available engine build (v4.7.2). T025 and T026 are closed via a combination of this session's own agent-observed live-app evidence and direct user acceptance on 2026-09-27 for the remaining subjective/hardware-only portions. Godot 4.4-specific engine validation on this exact declared baseline remains the one item this session could not produce any evidence for at all (no 4.4 executable was available) and is noted here for the record, though it did not block closing the spec.
