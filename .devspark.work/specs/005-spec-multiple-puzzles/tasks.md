# Tasks: Multiple Authored Puzzles and Session-Only Puzzle Selection

**Input**: C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/005-spec-multiple-puzzles/
**Path base**: Every repository-relative path below resolves against C:/GitHub/MakeBoldSolutions/ArrowGame.
**Prerequisites**: spec.md, plan.md, research.md, data-model.md, contracts/catalog-and-selection.md, quickstart.md.

## Rationale Summary

Replace the controller's hardcoded single-puzzle dependency with a small, plain-GDScript, 8-entry puzzle catalog and a process-lifetime session holder, then build Level Select and Results' Next Puzzle directly against that catalog. Every behavior change includes relevant tests and current-knowledge updates. No implementation has started.

## Format and Verification

All tasks have pending code_ref/knowledge_ref fields; populate all affected production/test paths and durable knowledge paths before checking a task, or justify n/a. Required desktop/hardware checks cannot be replaced by synthetic evidence. Required analyze/critic gates have not yet run; requirements checklist passes 19/19. No existing findings were waived.

## Phase 1: Setup

Record baseline and review existing requirements before changing behavior.

- [ ] T001 Record engine version, both baseline regression launcher results, and working-tree/domain-source baseline in .devspark.work/specs/005-spec-multiple-puzzles/gates/verification.md; isolate user data as quickstart.md specifies. (Implements: FR-019) (code_ref: pending | knowledge_ref: pending)
- [ ] T002 Review spec.md, plan.md, contracts/catalog-and-selection.md, data-model.md and resolved knowledge; record implementation preflight and any existing required-gate blockers in .devspark.work/specs/005-spec-multiple-puzzles/gates/verification.md. (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: Pending.

## Phase 2: Foundational catalog and session

Pure content/session layer must exist and be solver-validated before any presentation code depends on it.

- [ ] T003 Create tests/puzzle_catalog_check.gd covering PuzzleCatalog (unique/valid stable IDs, deterministic id_at/index_of/ids ordering, fresh-and-isolated get_definition per call, every entry structurally valid via PuzzleDefinition.is_valid(), every entry solver-confirmed solvable via PuzzleSolver.analyze(), the returned witness replayed against a fresh PuzzleState clearing with zero mistakes) and PuzzleSession (defaults to id_at(0) when unset/invalid, set_current_id, advance_to_next true/false at boundaries, has_next); tests initially fail until both classes exist. (Implements: FR-002, FR-014, FR-015) (code_ref: pending | knowledge_ref: pending)
- [ ] T004 Implement scripts/puzzle/puzzle_catalog.gd as a static-registry RefCounted class (count, id_at, title_at, index_of, ids, get_title, get_definition) with an ordered {id, title, build} entry array; stable IDs independent of array position/title/filesystem paths; no Resource/JSON/scene-per-puzzle representation. (Implements: FR-001, FR-002, FR-004) (code_ref: pending | knowledge_ref: pending)
- [ ] T005 Author the 8 catalog builder functions in scripts/puzzle/puzzle_catalog.gd per research.md's design brief (intro, first_bend, multi_bend, dependency_chain, forced_sequence, multiple_choices, dense_board, subtle_blockers), each constructing a fresh PuzzleDefinition exactly like create_fixed()'s existing literal-construction pattern; no difficulty labels. (Implements: FR-003, FR-005) (code_ref: pending | knowledge_ref: pending)
- [ ] T006 Implement scripts/puzzle_session.gd as a process-lifetime static-var RefCounted class (get_current_id, set_current_id, advance_to_next, has_next) matching GameVisualStyle's existing static-var precedent; never references GlobalState/GameState/LevelState/user://global_state.tres. (Implements: FR-007) (code_ref: pending | knowledge_ref: pending)
- [ ] T007 Integrate tests/puzzle_catalog_check.gd into tests/run_puzzle_regressions.py's existing bare-project pure-rule-isolation run: add scripts/puzzle/puzzle_catalog.gd and scripts/puzzle_session.gd to the copied-script list, add a second --script invocation with explicit PUZZLE_CATALOG_FAILURES marker, timeout and failure propagation. (Implements: FR-014) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: Pending.

## Phase 3: US1 — Play any authored puzzle through the same engine

Independent test: select each of the eight catalog puzzles in turn and confirm each plays start-to-finish with correct rules, scoring, and departure behavior.

- [ ] T008 [US1] Add tests/puzzle_layout_check.gd coverage looping over all 8 PuzzleCatalog IDs: set PuzzleSession's current id, load the real puzzle scene, assert the board's active view count matches the definition's arrow count, the HUD puzzle label matches the catalog title, and the same witness-replay sequence used by the catalog gate completes through the real scene with unchanged scoring/mistakes/accuracy — proving engine-generality end-to-end, not only via the pure solver gate. (Implements: FR-016, FR-017) (code_ref: pending | knowledge_ref: pending)
- [ ] T009 [US1] Replace scenes/puzzle/arrow_puzzle.gd::_start_new_attempt()'s PuzzleDefinition.create_fixed() call with PuzzleCatalog.get_definition(PuzzleSession.get_current_id()); keep all other attempt-construction logic (state reset, board setup, HUD update) unchanged. (Implements: FR-006) (code_ref: pending | knowledge_ref: pending)
- [ ] T010 [US1] Add a %PuzzleLabel to scenes/puzzle/arrow_puzzle.tscn's HUD row (existing RemainingLabel/MistakesLabel HBoxContainer) and set its text in _start_new_attempt() from the resolved PuzzleSession id's 1-based catalog position and PuzzleCatalog.get_title(); verify no reduction of board space or responsive-layout regression at supported window sizes. (Implements: FR-013) (code_ref: pending | knowledge_ref: pending)
- [ ] T011 [US1] Update .knowledge/architecture/arrow-puzzle.md with a new subsection describing PuzzleCatalog/PuzzleSession, the anonymous-PuzzleDefinition boundary, and the controller's selection wiring; add scripts/puzzle/puzzle_catalog.gd, scripts/puzzle_session.gd, tests/puzzle_catalog_check.gd to appliesTo. (Implements: FR-020) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: Pending.

## Phase 4: US2 — Browse and choose a puzzle

Independent test: open Level Select from the main menu, confirm all eight puzzles appear in order with distinguishing identity, select one that isn't first, and confirm that exact puzzle loads with its identity shown in the HUD.

- [ ] T012 [US2] Add tests/puzzle_layout_check.gd scenarios: Level Select lists all 8 entries in deterministic catalog order with correct 1-based number and title, none locked/hidden; selecting a non-first entry sets PuzzleSession and loads that exact puzzle with the matching HUD label; New Game always starts catalog position 0 regardless of any prior Level Select selection in the same session. (Implements: FR-008, FR-009) (code_ref: pending | knowledge_ref: pending)
- [ ] T013 [US2] Create scenes/menus/main_menu/puzzle_select_menu.gd and puzzle_select_menu.tscn: a minimal, keyboard/gamepad focus-navigable list bound to PuzzleCatalog.ids()/title_at(), emitting puzzle_selected(id: String) on selection; no locked/unlocked states. (Implements: FR-009) (code_ref: pending | knowledge_ref: pending)
- [ ] T014 [US2] In scenes/menus/main_menu/main_menu_with_animations.tscn, set the existing LevelSelectButton's visible property to true and point level_select_packed_scene at the new puzzle_select_menu.tscn (currently null). (Implements: FR-009) (code_ref: pending | knowledge_ref: pending)
- [ ] T015 [US2] In scenes/menus/main_menu/main_menu_with_animations.gd, change _setup_level_select()'s signal connection from the addon example's no-argument level_selected to the new puzzle_selected(id) signal with a handler that calls PuzzleSession.set_current_id(id) then the existing load_game_scene(); add a new_game() override that calls PuzzleSession.set_current_id(PuzzleCatalog.id_at(0)) before delegating to super.new_game(), preserving the existing no-GlobalState.reset()/no-GameState.start_game() guarantee. (Implements: FR-008, FR-009) (code_ref: pending | knowledge_ref: pending)
- [ ] T016 [US2] Extend tests/save_input_regression.gd (or an isolated-user-data scene assertion) to confirm Level Select selection and New Game still never call GlobalState.reset() or GameState.start_game(), and never write to user://global_state.tres, under the new PuzzleSession-driven code paths. (Implements: FR-007, FR-008) (code_ref: pending | knowledge_ref: pending)
- [ ] T017 [US2] Update .knowledge/architecture/save-progression.md's "Session-Only Puzzle Entry" section to describe Level Select's and New Game's PuzzleSession wiring while confirming the documented no-reset contract is unchanged; add scenes/menus/main_menu/puzzle_select_menu.gd to appliesTo where relevant. (Implements: FR-020) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: Pending.

## Phase 5: US3 — Move between puzzles after completion

Independent test: complete a non-last puzzle; confirm Replay and pause-menu Restart both restart that same puzzle with fresh state, and Next Puzzle advances to the following catalog entry with fresh state. Complete the last puzzle and confirm no Next Puzzle action is shown.

- [ ] T018 [US3] Add tests/puzzle_layout_check.gd coverage: Replay reloads the currently selected non-first puzzle with a completely fresh PuzzleState; pause-menu Restart also reloads that same non-first puzzle (not puzzle 1), proving PuzzleSession's static var survives SceneLoader.reload_current_scene() for both entry points; Next Puzzle advances to the following catalog entry with fresh state and correct HUD/results identity; the last catalog puzzle's results omit/disable Next Puzzle; switching puzzles disposes any prior attempt's departing views and callbacks (extends the existing spec-004 setup-replacement-disposal pattern). (Implements: FR-010, FR-011, FR-017) (code_ref: pending | knowledge_ref: pending)
- [ ] T019 [US3] Add a %NextPuzzleButton, a next_puzzle_requested signal, and a puzzle-identity label to scenes/puzzle/puzzle_results.gd and puzzle_results.tscn; extend show_results() to accept whether Next Puzzle should be shown/enabled and which puzzle was completed, without altering the existing total-arrows/mistakes/score/accuracy metrics or Replay/Main Menu behavior; keep all buttons keyboard/gamepad focus-traversable. (Implements: FR-011, FR-012) (code_ref: pending | knowledge_ref: pending)
- [ ] T020 [US3] In scenes/puzzle/arrow_puzzle.gd, connect puzzle_results.gd's next_puzzle_requested to a new _on_results_next_puzzle_requested() that calls PuzzleSession.advance_to_next() then SceneLoader.reload_current_scene(); pass PuzzleSession.has_next() and the completed puzzle's identity into show_results(). (Implements: FR-011, FR-012) (code_ref: pending | knowledge_ref: pending)
- [ ] T021 [US3] Update .knowledge/architecture/arrow-puzzle.md's Results/controller sections to describe Replay, pause-menu Restart, and Next Puzzle semantics, and the process-lifetime PuzzleSession mechanism that makes Restart correctness fall out of the existing reload path with no separate code. (Implements: FR-020) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: Pending.

## Phase 6: Polish and required verification

All required checks pass or remain openly outstanding; no implementation completion while mandatory checks remain.

- [ ] T022 Update tests/README.md documenting the new isolated PuzzleCatalog/PuzzleSession gate, its PUZZLE_CATALOG_FAILURES marker, and the extended scene-test coverage added in US1–US3. (Implements: FR-019) (code_ref: pending | knowledge_ref: pending)
- [ ] T023 Run final Godot import validation and both regression launchers on the declared 4.4 baseline; record exact commands, versions, markers and failures in .devspark.work/specs/005-spec-multiple-puzzles/gates/verification.md. (Implements: FR-019) (code_ref: pending | knowledge_ref: pending)
- [ ] T024 Perform the full manual desktop matrix in quickstart.md: play all 8 puzzles via both New Game and Level Select entry points, exercise at least one Replay, one pause-menu Restart, and one full Next Puzzle chain through the last puzzle, and verify keyboard-only and (if available) gamepad-only navigation of Level Select and the Next Puzzle action; record results in gates/verification.md, distinguishing agent-observed evidence from user-reported acceptance per the established convention. (Implements: FR-009, FR-011, FR-019) (code_ref: pending | knowledge_ref: pending)
- [ ] T025 Regenerate .knowledge/index.json and .knowledge/ontology/coverage.json after appliesTo updates; run the schema/index consistency check, the repository planning-reference scanner, and git diff whitespace check; document results in gates/verification.md. (Implements: FR-020) (code_ref: pending | knowledge_ref: pending)
- [ ] T026 Reconcile every task linkage in .devspark.work/specs/005-spec-multiple-puzzles/tasks.md with actual changed code/tests/current knowledge; resolve required analyze/critic findings; verify scripts/puzzle/puzzle_definition.gd, puzzle_state.gd and puzzle_solver.gd remain unchanged; retain complete bundle for release archival. (Implements: FR-003, FR-016, FR-020) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: Pending.

## Dependencies and Parallel Execution

T001–T002 precede T003–T007; catalog/session tests precede their implementation and launcher integration. US1 (T008–T011) precedes US2 (T012–T017), then US3 (T018–T021), then final verification (T022–T026). Test-writing tasks may initially fail; each story checkpoint requires its completed suite to pass.

T004 and T006 touch different files and may run in parallel once T003 exists; T005 depends on T004's entry-array shape. US1's controller/HUD tasks (T009–T010) share `arrow_puzzle.gd`/`.tscn` and must run sequentially with each other, but can run in parallel with US2's independent menu files (T013–T014) once both stories' Foundational prerequisites are met — however, per the Implementation Strategy below, stories are still delivered in priority order. No unconditional `[P]` marker is assigned beyond T004/T006 because most tasks share code/test ownership within their story; no agent delegation is required.

## Implementation Strategy

US1 is the smallest demonstrable preview: any catalog puzzle plays correctly through the unmodified engine. Shipping requires US1, US2 and US3 plus all final checks, because a catalog nobody can reach (no US2) and a catalog you can't move between (no US3) are each individually incomplete experiences per the spec's Player Experience section. Avoid domain/addon changes — `PuzzleDefinition`, `PuzzleState`, `PuzzleSolver`, `ArrowView`, `PuzzleBoard` are all reused unmodified. Each story includes its own test and knowledge step.

## Constitution and Retention

I/II: `PuzzleCatalog`/`PuzzleSession` follow existing static-registry/static-var precedent; no addon edits; the addon's own example Level Select script is explicitly not reused. III: T013/T015/T019 build Level Select and Next Puzzle on the existing keyboard/gamepad-navigable `_open_sub_menu`/focus mechanism; T024 requires manual keyboard/gamepad verification. IV: T009/T020 reuse existing non-blocking reload/attempt-construction paths; no new synchronous heavy work. V: T001/T023–T024 require engine and desktop evidence. VI: T006/T016/T017 preserve the no-persistent-write guarantee. No waivers. Shared preamble retention policy overrides the older task-template deletion instruction: do not delete or archive this feature directory during implementation.
