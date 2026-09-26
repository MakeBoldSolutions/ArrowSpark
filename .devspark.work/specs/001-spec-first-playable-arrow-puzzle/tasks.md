# Tasks: First Playable Arrow Puzzle

**Branch**: `001-spec-first-playable-arrow-puzzle`
**Input**: spec.md, plan.md, research.md, data-model.md, contracts/puzzle.md and quickstart.md in this directory.
**Root**: `C:/GitHub/MakeBoldSolutions/ArrowGame`; task file paths are relative to this absolute root.

## Rationale Summary

Implement the complete fixed puzzle using pure rule state and project-level UI while preserving starter controls/data. No added dependencies or addon edits are planned. All four stories are P1. Focus tests on rules and regression risks; Godot validation and desktop smoke remain mandatory.

Every task starts unchecked. On completion replace linkage placeholders with all affected production/test and current-knowledge paths, or n/a with a reason. Do not copy planning IDs into durable files. Use snake_case filenames/functions and appropriate explicit types throughout. Tasks do not authorize destructive saved-data changes.

## Phase 1: Setup

Establish a safe baseline and isolated validation environment.

- [ ] T001 Record engine version and baseline import/save-input regression results in .devspark.work/specs/001-spec-first-playable-arrow-puzzle/gates/verification.md using tests/run_regressions.py; preserve existing user data. (code_ref: pending | knowledge_ref: pending)
- [ ] T002 Create tests/run_puzzle_regressions.py using a temporary project, unique application name, copied core scripts and redirected user-data roots; require exit zero and PUZZLE_FAILURES=0. The launcher can only be validated end to end once T003-T005 exist; confirm it then. (code_ref: pending | knowledge_ref: pending)

## Phase 2: Foundational

Provide the shared definition/state boundary before UI work.

- [ ] T003 Define cardinal directions and the validated 5x4 eight-arrow board in scripts/puzzle/puzzle_definition.gd exactly as data-model.md, with fresh copies per attempt. (Implements: FR-001) (code_ref: pending | knowledge_ref: pending)
- [ ] T004 Create RefCounted state, copied snapshots, counters and selection outcome enum in scripts/puzzle/puzzle_state.gd per contracts/puzzle.md; exclude scenes, input and persistence dependencies. (Implements: FR-012) (code_ref: pending | knowledge_ref: pending)

## Phase 3: US1 Start and Clear the Puzzle

Independent test: start from opening and remove A,B,D,C,E,F,G,H; verify eight-to-zero remaining and one removal per arrow.

- [ ] T005 [US1] Add blocking matrix, definition validation, witness solution, inactive selection and counter-invariant tests (invariants over clear and ignored selections only; blocked-selection accounting is tested in T011) in tests/puzzle_regression.gd; establish failing assertions before completing rules. (Implements: FR-001, FR-003, FR-004, FR-012) (code_ref: pending | knowledge_ref: pending)
- [ ] T006 [US1] Implement all-direction is_blocked and accepted clear selection in scripts/puzzle/puzzle_state.gd; erase immediately and account exactly once, ignoring absent/completed selections. (Implements: FR-003, FR-004, FR-008) (code_ref: pending | knowledge_ref: pending)
- [ ] T007 [US1] Build scenes/puzzle/arrow_view.gd and scenes/puzzle/puzzle_board.gd with primitive arrow drawing, scaled grid layout, primary-press click-to-cell mapping, empty-click ignoring and scene-bound exit tweens; visual children must not intercept clicks. (Implements: FR-002, FR-004) (code_ref: pending | knowledge_ref: pending)
- [ ] T008 [US1] Compose scenes/puzzle/arrow_puzzle.tscn and arrow_puzzle.gd with state ownership, live HUD, existing music and pause controller; update counters before visuals and track concurrent departures. (Implements: FR-004, FR-007, FR-012) (code_ref: pending | knowledge_ref: pending)
- [ ] T009 [US1] Route scenes/menus/main_menu/main_menu.tscn and main_menu_with_animations.tscn to the puzzle; update main_menu_with_animations.gd to omit GlobalState.reset/GameState.start_game and hide Continue/Level Select while preserving intro, options and credits; leave game_ui.tscn, sample levels and level-select scenes in source. (Implements: FR-001, FR-013) (code_ref: pending | knowledge_ref: pending)
- [ ] T010 [US1] Create typed current behavior documentation in .knowledge/architecture/arrow-puzzle.md with appliesTo/source_of_truth for core and scene paths, rule semantics and input boundaries; cite only durable source/tests. (Implements: FR-001, FR-002, FR-003, FR-004, FR-007, FR-012) (code_ref: pending | knowledge_ref: pending)

## Phase 4: US2 Unlimited Mistakes

Independent test: select B 100 times while A remains, then remove A and B; no restart or input lock.

- [ ] T011 [US2] Extend tests/puzzle_regression.gd for 100 blocked attempts, repeated feedback-time selections at the model boundary, ignored cells and exact tap/mistake invariants. (Implements: FR-005, FR-006, FR-008) (code_ref: pending | knowledge_ref: pending)
- [ ] T012 [US2] Implement blocked selection in scripts/puzzle/puzzle_state.gd and non-color-only replaceable feedback in scenes/puzzle/arrow_view.gd; wire controller without cooldown or lives and keep the board selectable during feedback. (Implements: FR-005, FR-006, FR-008) (code_ref: pending | knowledge_ref: pending)
- [ ] T013 [US2] Update .knowledge/architecture/arrow-puzzle.md with unlimited-mistake behavior, accepted-tap semantics and evidence paths for new tests. (Implements: FR-005, FR-006, FR-008) (code_ref: pending | knowledge_ref: pending)

## Phase 5: US3 Results and Replay

Independent test: finish perfect and mistake-heavy runs, verify results, Replay and complete a fresh second run.

- [ ] T014 [US3] Extend tests/puzzle_regression.gd with score floor, zero-tap accuracy, perfect/mixed results, one-decimal display rounding including the exact tie at 120 mistakes (8/128 = 6.25% displays 6.3%), completed-state ignoring and fresh-state reset assertions. (Implements: FR-009, FR-010, FR-011) (code_ref: pending | knowledge_ref: pending)
- [ ] T015 [US3] Implement copied completion results in scripts/puzzle/puzzle_state.gd and scenes/puzzle/puzzle_results.tscn/puzzle_results.gd with all result fields, one-decimal percentage rounding ties half away from zero, Replay/Main Menu and explicit focus. (Implements: FR-009, FR-010) (code_ref: pending | knowledge_ref: pending)
- [ ] T016 [US3] Add playing/draining/results lifecycle to scenes/puzzle/arrow_puzzle.gd: wait for all departures, show results once, absorb background clicks, suppress extra pause overlays, kill tweens/invalidate callbacks and create fresh state on Replay. (Implements: FR-009, FR-011) (code_ref: pending | knowledge_ref: pending)
- [ ] T017 [US3] Update .knowledge/architecture/arrow-puzzle.md for completion arithmetic, all-departures barrier, replay and pause lifecycle. (Implements: FR-009, FR-010, FR-011) (code_ref: pending | knowledge_ref: pending)

## Phase 6: US4 Preserve Starter Controls and Settings

Independent test: navigate affected menus using supported mouse/keyboard/gamepad remaps, pause/restart and compare preserved saved data.

- [ ] T018 [US4] Verify and adjust project-level focus/process-mode configuration in scenes/puzzle/arrow_puzzle.tscn and puzzle_results.tscn for pause/resume/options, restart confirmation (confirmed restart gives a fresh attempt, cancelled restart keeps it) and results navigation; reuse scenes/overlaid_menus/pause_menu.tscn without changing addon code. (Implements: FR-011, FR-013) (code_ref: pending | knowledge_ref: pending)
- [ ] T019 [US4] Run existing tests/run_regressions.py and isolated desktop menu/save recovery checks from quickstart.md; record settings/progress preservation, remapping, focus, pause mid-animation and restart outcomes in .devspark.work/specs/001-spec-first-playable-arrow-puzzle/gates/verification.md; leave unavailable hardware checks outstanding. (Implements: FR-013) (code_ref: pending | knowledge_ref: pending)
- [ ] T020 [US4] Update .knowledge/architecture/save-progression.md to document session-only puzzle entry versus preserved legacy storage/recovery, and .knowledge/architecture/arrow-puzzle.md for affected menu paths. (Implements: FR-013) (code_ref: pending | knowledge_ref: pending)

## Phase 7: Polish and Verification

All stories are required for the requested first playable; do not stop at the first clear-arrow demo.

- [ ] T021 Run Godot script/scene import validation, tests/run_puzzle_regressions.py and tests/run_regressions.py after final changes; record actual commands/results and failures in .devspark.work/specs/001-spec-first-playable-arrow-puzzle/gates/verification.md. (code_ref: pending | knowledge_ref: pending)
- [ ] T022 Perform the full desktop quickstart.md smoke matrix including window resizing, rapid clicks, 100 mistakes, all-departures completion, Replay, pause and menu transitions; record results in .devspark.work/specs/001-spec-first-playable-arrow-puzzle/gates/verification.md and update tests/README.md with reproducible commands. (code_ref: pending | knowledge_ref: pending)
- [ ] T023 Rebuild .knowledge/index.json using the repository knowledge-index tool after validating .knowledge/architecture/arrow-puzzle.md and save-progression.md against implemented code/tests; inspect index output for unrelated churn. (code_ref: pending | knowledge_ref: pending)
- [ ] T024 Audit changed durable files for forbidden planning backlinks, complete every code_ref/knowledge_ref in .devspark.work/specs/001-spec-first-playable-arrow-puzzle/tasks.md with actual changed paths or justified n/a, and leave the bundle in place for release archival. (code_ref: pending | knowledge_ref: pending)

## Dependencies and Parallel Execution

T001 -> T002 -> T003 -> T004. US1: T005 -> T006 -> T007 -> T008 -> T009 -> T010. US2: T011 -> T012 -> T013 after US1. US3: T014 -> T015 -> T016 -> T017 after US2. US4: T018 -> T019 -> T020 after US3. Final: T021 -> T022 -> T023 -> T024. Test-authoring tasks may initially fail as intended; each story must pass its relevant suite before completion.

Story order: foundation -> US1 -> US2 -> US3 -> US4 -> final verification. Shared state/controller/knowledge files make sequential execution the safe default, so no task is marked unconditionally [P]. Conditional opportunities: US1 board/view authoring can proceed beside core rule implementation once the contract/definition are stable; US2 regression authoring and view-only feedback work can proceed in separate files; US3 results-panel layout can proceed beside core arithmetic tests; US4 manual navigation checking can proceed beside knowledge drafting after UI changes settle. Avoid concurrent edits to state, controller, tests, or the shared knowledge node. These are scheduling options, not instructions to launch agents.

## Implementation Strategy

US1 is the first demonstrable increment. The deliverable MVP requires all four stories: unlimited mistakes, results/replay and preserved controls are explicit acceptance conditions. Maintain current knowledge alongside each behavior increment, then run final verification. Never mark checks complete when unavailable; record blockers and leave tasks outstanding.

## Review Gates and Retention

The requirements checklist is complete (23/23). Required analyze and critic gates have not yet been run; run /devspark.analyze and /devspark.critic before implementation and address findings. No unresolved gate finding was bypassed during task generation. Runtime verification remains pending.

Retain the completed bundle under .devspark.work for linkage checking and release archival. The shared preamble's explicit retention policy overrides the command outline's stale deletion instruction. No automatic archive reading or planning-bundle deletion is authorized.
