# Verification Log — Spec 005 (Multiple Authored Puzzles and Session-Only Puzzle Selection)

## T001 — Baseline (2026-09-27)

**Engine**: `godot --version` → `4.7.2.stable.official.ed1daf0bf`. Declared baseline is Godot 4.4;
only 4.7.2 is available in this environment, matching the same disclosed (not silently skipped)
limitation spec 004 recorded. All commands below were run with this 4.7.2 executable.

**Working-tree/domain-source baseline**: `scripts/puzzle/puzzle_definition.gd`,
`scripts/puzzle/puzzle_state.gd`, `scripts/puzzle/puzzle_solver.gd` reviewed and recorded as the
pre-change baseline; these three files must remain byte-for-byte unchanged through this spec
(FR-003, FR-016) — verified again at T026.

**Baseline regression launcher results** (isolated user data per each launcher's own isolation):

- `python tests/run_puzzle_regressions.py --godot godot`: exit 0. All four checks (`PUZZLE_FAILURES=0`,
  `ARROW_DEPARTURE_GEOMETRY_FAILURES=0`, `PUZZLE_LAYOUT_FAILURES=0`, `PUZZLE_PRESENTATION_FAILURES=0`)
  passed cleanly, no unexpected FAIL lines.
- `python tests/run_regressions.py --godot godot`: exit 0, `REGRESSION_FAILURES=0`. Several `ERROR:`/
  `push_error` lines appear in stdout/stderr from the suite's own intentional corrupt-save/
  incompatible-resource/backup-failure negative-path tests (expected engine error noise per the
  script's own documented pattern) — zero `FAIL:` lines were emitted.

## T002 — Implementation Preflight (2026-09-27)

Reviewed spec.md, plan.md, research.md, data-model.md, contracts/catalog-and-selection.md,
quickstart.md, tasks.md, and the resolved `.knowledge/` nodes (`arrow-puzzle.md`,
`game-visual-system.md`, `save-progression.md`, `governance/constitution.md`). Gate results:

- `checklists/requirements.md`: 19/19 PASS.
- `gates/analyze.md`: status `pass`, 0 open findings (analyze-001, analyze-002 both resolved).
- `gates/critic.md`: status `pass`, 0 open findings (critic-001 resolved), VERDICT: PROCEED.
- Gate freshness: `git hash-object` on spec.md/plan.md/tasks.md/research.md/
  contracts/catalog-and-selection.md/data-model.md/quickstart.md all match the hashes recorded in
  `gates/critic.md` (the most recent gate run) — no staleness.
- No `## Constitution Waivers` in plan.md (none required).
- No blockers found. Proceeding to Phase 2 (Foundational catalog and session).

## T023 — Final Regression Run (2026-09-27)

**Engine**: `godot --version` → `4.7.2.stable.official.ed1daf0bf` (same disclosed 4.4-vs-4.7 gap
noted at T001 — not silently skipped).

- `python tests/run_puzzle_regressions.py --godot godot`: exit 0. All five checks passed:
  `PUZZLE_FAILURES=0`, `PUZZLE_CATALOG_FAILURES=0` (new — all 8 catalog entries unique/valid/
  solver-confirmed-solvable with a replayed zero-mistake witness), `ARROW_DEPARTURE_GEOMETRY_FAILURES=0`,
  `PUZZLE_LAYOUT_FAILURES=0` (includes the new all-8-catalog-puzzles real-scene playthrough, Level
  Select listing/ordering/focus-placement, and Replay/pause-menu-Restart/Next-Puzzle/last-puzzle-
  suppression driven through the real `SceneLoader.reload_current_scene()`/`change_scene_to_packed()`
  path), `PUZZLE_PRESENTATION_FAILURES=0`.
- `python tests/run_regressions.py --godot godot`: exit 0, `REGRESSION_FAILURES=0`. Includes the
  extended `_test_no_reset_on_puzzle_entry()` (Level Select selection sets `PuzzleSession`, opens via
  `SceneLoader.load_scene`, disturbs no `GlobalState`/`GameState`/settings/remap state; `new_game()`
  resets to catalog position 0 regardless of a prior Level Select choice). Expected engine `ERROR:`
  noise from the suite's own intentional corrupt-save/incompatible-resource/backup-failure negative
  paths appears in stdout/stderr as before; zero `FAIL:` lines.

No regressions introduced against the T001 baseline.

## T024 — Manual Desktop Matrix (2026-09-27)

**Agent-observed partial evidence** (via `godot --path .` windowed launch + screenshots +
OS-level `SendKeys` keystroke injection, not a substitute for deliberate manual play):

- Main Menu: `Level Select` button renders visible (previously hidden), alongside New Game/
  Options/Credits/Exit, confirming FR-009's visibility change in a real rendered window.
- After a keyboard `Down`/`Enter` sequence reached a completed attempt, the Results panel
  correctly rendered `4. Dependency Chain` as the puzzle identity, `Total Arrows: 3` (matching
  the authored `dependency_chain` catalog entry's exact arrow count), `Mistakes: 0`, `Score: 3`,
  `Accuracy: 100.0%`, a focused `Replay` button (orange focus border), and a visible `Next Puzzle`
  button (correct — Dependency Chain is neither first nor last) — confirming FR-011/FR-012/FR-013
  render correctly end-to-end in a live window, not only in headless tests.
- Pressing `Right` then `Enter` (targeting `Next Puzzle`) triggered a scene reload as expected,
  but this session's screenshot/`SendKeys` automation lost reliable window targeting immediately
  afterward: this machine has multiple monitors and several unrelated VS Code windows across
  virtual desktops, and a subsequent screenshot captured an unrelated window instead of the game.
  The godot process was killed cleanly once this was noticed; no further automated interaction
  was attempted rather than risk sending keystrokes to the wrong (unrelated, user-owned) window.

**Outstanding — requires human execution, disclosed rather than skipped or fabricated:**
the full quickstart.md desktop matrix — playing all 8 puzzles via both New Game and Level
Select, at least one Replay, one pause-menu Restart, one full Next Puzzle chain through the
last puzzle, and deliberate **keyboard-only** and (if available) **gamepad-only** navigation of
Level Select and the Next Puzzle action (constitution Principle III) — was not completed in
this autonomous session. This is a genuinely unavailable check in this environment (no reliable
GUI automation harness, multi-monitor/multi-window desktop), not a corner cut; it must be run by
the developer on the supported Godot version before release, per AGENTS.md's "gameplay changes
also require Godot validation and desktop smoke testing."

## T025 — Knowledge Index / Planning-Reference / Whitespace Checks (2026-09-27)

- `python .devspark/scripts/build_knowledge_index.py --repo-root .`: regenerated
  `.knowledge/index.json` cleanly (no errors), reflecting the updated `appliesTo` lists in
  `arrow-puzzle.md`/`save-progression.md`. `.knowledge/ontology/coverage.json` unchanged (no new
  knowledge nodes were added, only appliesTo entries on existing nodes).
- `python .devspark/scripts/build_knowledge_index.py --repo-root . --check`: exit 0.
- `bash .devspark/scripts/bash/check-planning-references.sh`: "No planning-artifact references
  found." — exit 0. Confirms no spec/task/quickfix identifier leaked into durable code, tests, or
  `.knowledge/`, and no completed-linkage marker was left `pending`.
- `git diff --check`: exit 0 (one benign CRLF/LF line-ending notice on `.knowledge/index.json`,
  not a whitespace error).

## T026 — Reconciliation and FR-018 Exclusion Review (2026-09-27)

- `git diff --stat scripts/puzzle/puzzle_definition.gd scripts/puzzle/puzzle_state.gd scripts/puzzle/puzzle_solver.gd`
  reports no changes — the three domain files remain byte-for-byte unchanged (FR-003, FR-016).
- Full changed-file set (`git status --short`) matches plan.md's Project Structure section
  exactly: new `scripts/puzzle/puzzle_catalog.gd`, `scripts/puzzle_session.gd`,
  `scenes/menus/main_menu/puzzle_select_menu.gd`/`.tscn`, `tests/puzzle_catalog_check.gd`; modified
  `scenes/puzzle/arrow_puzzle.gd`/`.tscn`, `scenes/puzzle/puzzle_results.gd`/`.tscn`,
  `scenes/menus/main_menu/main_menu_with_animations.gd`/`.tscn`, `tests/puzzle_layout_check.gd`,
  `tests/puzzle_presentation_check.gd`, `tests/run_puzzle_regressions.py`, `tests/run_regressions.py`,
  `tests/save_input_regression.gd`, `tests/README.md`, and the two `.knowledge/architecture/*.md`
  nodes plus `.knowledge/index.json`.
- FR-018 exclusion review against the full diff and new files:
  - No difficulty tier/label anywhere in catalog titles or UI (asserted by an automated check in
    `puzzle_catalog_check.gd`; also confirmed by direct grep review of all new/changed files).
  - No persistent completion/current-level/unlock/best-score/stars/achievement/campaign state or
    writes — `PuzzleSession` is a process-lifetime static var only, never referencing
    `GlobalState`/`GameState`/`LevelState`/`user://global_state.tres` (grep-confirmed; also
    asserted by `save_input_regression.gd`'s extended no-reset test). The words "unlock(s)"/"locked"
    appear only in code comments describing in-attempt blocking-rule mechanics (an arrow becoming
    legal once a blocker departs) and Level Select's "no locked/unlocked states" guarantee — not
    progression-unlock state.
  - No procedural/random/daily puzzle selection — `grep -i rand` across every new/changed
    gameplay file returns no matches; `PuzzleCatalog`'s eight entries are a fixed, deterministic,
    authoring-time-ordered array with no runtime sort/shuffle.
  - No puzzle authoring tooling was added.
  - No scene-per-level architecture — a single reusable `scenes/puzzle/arrow_puzzle.tscn` plays
    every catalog entry; no new gameplay scene was introduced.
  - No solver/scoring-rule changes (verified above: the three domain files are unchanged).
  - No Main Menu/Results changes beyond this spec's Level Select entry point and Next Puzzle
    action — `main_menu_with_animations.gd`'s only changes are the `_setup_level_select()` signal
    rewiring, the `new_game()` override, and the new `_on_puzzle_selected()` handler; Options,
    Credits, Continue, and Exit are untouched. `puzzle_results.gd`'s only changes are the
    `%NextPuzzleButton`/`next_puzzle_requested` signal and the puzzle-identity label; the existing
    total-arrows/mistakes/score/accuracy metrics and Replay/Main Menu behavior are unchanged.
- All `Implements:` directives in tasks.md are populated with real `code_ref`/`knowledge_ref`
  paths (or an explained `n/a`); none left `pending`. `gates/analyze.md` and `gates/critic.md`
  both remain `status: pass` with 0 open findings — no new findings were raised during
  implementation, and no existing finding required re-opening.
- **Outstanding item carried forward**: T024's full manual keyboard-only/gamepad-only desktop
  matrix remains incomplete (see T024 above) — this is the only unmet Definition-of-Done item.
  Everything else (all tasks' code/tests/knowledge, both automated regression launchers, the
  knowledge index/planning-reference/whitespace checks, and the FR-018 exclusion review) is
  complete and passing.
