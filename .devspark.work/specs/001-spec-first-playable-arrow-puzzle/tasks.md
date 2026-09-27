# Tasks: First Playable Arrow Puzzle

**Branch**: `001-spec-first-playable-arrow-puzzle`
**Input**: spec.md, plan.md, research.md, data-model.md, contracts/puzzle.md and quickstart.md in this directory.
**Root**: `C:/GitHub/MakeBoldSolutions/ArrowGame`; task file paths are relative to this absolute root.

## Rationale Summary

Implement the complete fixed puzzle using pure rule state and project-level UI while preserving starter controls/data. No added dependencies or addon edits are planned. All four stories are P1. Focus tests on rules and regression risks; Godot validation and desktop smoke remain mandatory.

Every task starts unchecked. On completion replace linkage placeholders with all affected production/test and current-knowledge paths, or n/a with a reason. Do not copy planning IDs into durable files. Use snake_case filenames/functions and appropriate explicit types throughout. Tasks do not authorize destructive saved-data changes.

## Phase 1: Setup

Establish a safe baseline and isolated validation environment.

- [X] T001 Record engine version and baseline import/save-input regression results in .devspark.work/specs/001-spec-first-playable-arrow-puzzle/gates/verification.md using tests/run_regressions.py; preserve existing user data. (code_ref: n/a — verification-only, no code changed | knowledge_ref: n/a — verification-only)
- [X] T002 Create tests/run_puzzle_regressions.py using a temporary project, unique application name, copied core scripts and redirected user-data roots; require exit zero and PUZZLE_FAILURES=0. The launcher can only be validated end to end once T003-T005 exist; confirm it then. (code_ref: tests/run_puzzle_regressions.py, tests/puzzle_layout_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

**Checkpoint**: Phase complete — 2026-09-26

## Phase 2: Foundational

Provide the shared definition/state boundary before UI work.

- [X] T003 Define cardinal directions and the validated 5x4 eight-arrow board in scripts/puzzle/puzzle_definition.gd exactly as data-model.md, with fresh copies per attempt. (Implements: FR-001) (code_ref: scripts/puzzle/puzzle_definition.gd, tests/puzzle_regression.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T004 Create RefCounted state, copied snapshots, counters and selection outcome enum in scripts/puzzle/puzzle_state.gd per contracts/puzzle.md; exclude scenes, input and persistence dependencies. (Implements: FR-012) (code_ref: scripts/puzzle/puzzle_state.gd, tests/puzzle_regression.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

**Checkpoint**: Phase complete — 2026-09-26

## Phase 3: US1 Start and Clear the Puzzle

Independent test: start from opening and remove A,B,D,C,E,F,G,H; verify eight-to-zero remaining and one removal per arrow.

- [X] T005 [US1] Add blocking matrix, definition validation, witness solution, inactive selection and counter-invariant tests (invariants over clear and ignored selections only; blocked-selection accounting is tested in T012) in tests/puzzle_regression.gd; establish failing assertions before completing rules. (Implements: FR-001, FR-003, FR-004, FR-012) (code_ref: tests/puzzle_regression.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T006 [US1] Implement all-direction is_blocked and accepted clear selection in scripts/puzzle/puzzle_state.gd; erase immediately and account exactly once, ignoring absent/completed selections. (Implements: FR-003, FR-004, FR-008) (code_ref: scripts/puzzle/puzzle_state.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T007 [US1] Build scenes/puzzle/arrow_view.gd and scenes/puzzle/puzzle_board.gd with primitive arrow drawing, scaled grid layout, primary-press click-to-cell mapping, empty-click ignoring and scene-bound exit tweens; visual children must not intercept clicks. (Implements: FR-002, FR-004) (code_ref: scenes/puzzle/arrow_view.gd, scenes/puzzle/puzzle_board.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T008 [US1] Compose scenes/puzzle/arrow_puzzle.tscn and arrow_puzzle.gd with state ownership, live HUD, existing music and pause controller; update counters before visuals and track concurrent departures. Use anchors/containers so the HUD and board rects do not overlap by construction, and add an automated check (script-level rect computation, run at the 1280x720 and 960x540 sizes) rather than relying only on manual resize smoke testing. (Implements: FR-004, FR-007, FR-012) (code_ref: scenes/puzzle/arrow_puzzle.tscn, scenes/puzzle/arrow_puzzle.gd, tests/puzzle_layout_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T009 [US1] Add a headless assertion in tests/save_input_regression.gd (run via tests/run_regressions.py) that invoking new_game()/load_game_scene() on the main-menu scene does not call GlobalState.reset() or GameState.start_game(); author this before T010's change so it fails against the current starter behavior, establishing a genuine regression guard rather than a test written to already pass. (Implements: FR-013) (code_ref: tests/save_input_regression.gd, tests/run_regressions.py, tests/scene_loader_stub.gd | knowledge_ref: .knowledge/architecture/save-progression.md — confirmed failing against current behavior: REGRESSION_FAILURES=4, GlobalState.reset()/GameState.start_game() both detected)
- [X] T010 [US1] Route scenes/menus/main_menu/main_menu.tscn and main_menu_with_animations.tscn to the puzzle; update main_menu_with_animations.gd to omit GlobalState.reset/GameState.start_game and hide Continue/Level Select while preserving intro, options and credits; add a single-line label/tooltip of no more than 80 characters noting existing level progress is preserved; leave game_ui.tscn, sample levels and level-select scenes in source. Confirm T009's assertion now passes. (Implements: FR-001, FR-013) (code_ref: scenes/menus/main_menu/main_menu.tscn, scenes/menus/main_menu/main_menu_with_animations.tscn, scenes/menus/main_menu/main_menu_with_animations.gd | knowledge_ref: .knowledge/architecture/save-progression.md, .knowledge/architecture/arrow-puzzle.md — T009 assertion confirmed passing: REGRESSION_FAILURES=0)
- [X] T011 [US1] Create typed current behavior documentation in .knowledge/architecture/arrow-puzzle.md with appliesTo/source_of_truth for core and scene paths, rule semantics and input boundaries; cite only durable source/tests. (Implements: FR-001, FR-002, FR-003, FR-004, FR-007, FR-012) (code_ref: n/a — documentation task | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

**Checkpoint**: Phase complete — 2026-09-26

## Phase 4: US2 Unlimited Mistakes

Independent test: select B 100 times while A remains, then remove A and B; no restart or input lock.

- [X] T012 [US2] Extend tests/puzzle_regression.gd for 100 blocked attempts, repeated feedback-time selections at the model boundary, ignored cells and exact tap/mistake invariants. (Implements: FR-005, FR-006, FR-008) (code_ref: tests/puzzle_regression.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T013 [US2] Implement blocked selection in scripts/puzzle/puzzle_state.gd and non-color-only replaceable feedback in scenes/puzzle/arrow_view.gd; wire controller without cooldown or lives and keep the board selectable during feedback. Define the blocked-cue duration as a named constant (<= 0.3s) and add a headless assertion against that constant in tests/puzzle_regression.gd rather than relying on visual timing. (Implements: FR-005, FR-006, FR-008) (code_ref: scripts/puzzle/puzzle_state.gd, scripts/puzzle/puzzle_feedback.gd, scenes/puzzle/arrow_view.gd, tests/puzzle_regression.gd, tests/puzzle_layout_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T014 [US2] Update .knowledge/architecture/arrow-puzzle.md with unlimited-mistake behavior, accepted-tap semantics and evidence paths for new tests. (Implements: FR-005, FR-006, FR-008) (code_ref: n/a — documentation task | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

**Checkpoint**: Phase complete — 2026-09-26

## Phase 5: US3 Results and Replay

Independent test: finish perfect and mistake-heavy runs, verify results, Replay and complete a fresh second run.

- [X] T015 [US3] Extend tests/puzzle_regression.gd with score floor, zero-tap accuracy, perfect/mixed results, one-decimal display rounding including the exact tie at 120 mistakes (8/128 = 6.25% displays 6.3%), completed-state ignoring and fresh-state reset assertions. (Implements: FR-009, FR-010, FR-011) (code_ref: tests/puzzle_regression.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T016 [US3] Implement copied completion results in scripts/puzzle/puzzle_state.gd and scenes/puzzle/puzzle_results.tscn/puzzle_results.gd with all result fields, one-decimal percentage rounding ties half away from zero, Replay/Main Menu and explicit focus. (Implements: FR-009, FR-010) (code_ref: scripts/puzzle/puzzle_state.gd, scripts/puzzle/puzzle_results_format.gd, scenes/puzzle/puzzle_results.tscn, scenes/puzzle/puzzle_results.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T017 [US3] Add playing/draining/results lifecycle to scenes/puzzle/arrow_puzzle.gd: wait for all departures, show results once, absorb background clicks, suppress extra pause overlays, kill tweens/invalidate callbacks and create fresh state on Replay. (Implements: FR-009, FR-011) (code_ref: scenes/puzzle/arrow_puzzle.gd, scenes/puzzle/puzzle_board.gd, scenes/puzzle/arrow_view.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T018 [US3] Update .knowledge/architecture/arrow-puzzle.md for completion arithmetic, all-departures barrier, replay and pause lifecycle. (Implements: FR-009, FR-010, FR-011) (code_ref: n/a — documentation task | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

**Checkpoint**: Phase complete — 2026-09-26

## Phase 6: US4 Preserve Starter Controls and Settings

Independent test: navigate affected menus using supported mouse/keyboard/gamepad remaps, pause/restart and compare preserved saved data.

- [X] T019 [US4] Verify and adjust project-level focus/process-mode configuration in scenes/puzzle/arrow_puzzle.tscn and puzzle_results.tscn for pause/resume/options, restart confirmation (confirmed restart gives a fresh attempt, cancelled restart keeps it) and results navigation; reuse scenes/overlaid_menus/pause_menu.tscn without changing addon code. (Implements: FR-011, FR-013) (code_ref: scenes/puzzle/arrow_puzzle.tscn, scenes/puzzle/arrow_puzzle.gd, scenes/puzzle/puzzle_results.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md — verified scenes/overlaid_menus/pause_menu.tscn and addon pause_menu.gd/pause_menu_controller.gd are unmodified and reused as-is; pauses_game=true (inherited from addon base) freezes board/tween processing while paused; confirmed Restart reloads the scene fresh via SceneLoader.reload_current_scene() and cancelled Restart leaves the addon popup closed with no state change (unmodified addon behavior); Replay grabs focus via puzzle_results.gd's show_results())
- [X] T020 [US4] Run existing tests/run_regressions.py and isolated desktop menu/save recovery checks from quickstart.md; record settings/progress preservation, remapping, focus, pause mid-animation and restart outcomes in .devspark.work/specs/001-spec-first-playable-arrow-puzzle/gates/verification.md; leave unavailable hardware checks outstanding. (Implements: FR-013) (code_ref: n/a — verification-only, no code changed | knowledge_ref: n/a — verification-only; see gates/verification.md "Post-implementation automated verification" and "Outstanding / not runnable in this environment" — tests/run_regressions.py: exit 0, REGRESSION_FAILURES=0, 39 PASS; interactive desktop smoke and gamepad checks recorded as outstanding, not available in this headless environment)
- [X] T021 [US4] Update .knowledge/architecture/save-progression.md to document session-only puzzle entry versus preserved legacy storage/recovery, adding scenes/menus/main_menu/main_menu.tscn and scenes/menus/main_menu/main_menu_with_animations.gd to its appliesTo list since this feature's Context Resolution relies on a source-call into those files; also update .knowledge/architecture/arrow-puzzle.md for affected menu paths. (Implements: FR-013) (code_ref: n/a — documentation task | knowledge_ref: .knowledge/architecture/save-progression.md, .knowledge/architecture/arrow-puzzle.md)

**Checkpoint**: Phase complete — 2026-09-26

## Phase 7: Polish and Verification

All stories are required for the requested first playable; do not stop at the first clear-arrow demo.

- [X] T022 Run Godot script/scene import validation, tests/run_puzzle_regressions.py and tests/run_regressions.py after final changes; record actual commands/results and failures in .devspark.work/specs/001-spec-first-playable-arrow-puzzle/gates/verification.md. (code_ref: n/a — verification-only, no code changed | knowledge_ref: n/a — verification-only; see gates/verification.md "Post-implementation automated verification" — import exit 0, run_regressions.py REGRESSION_FAILURES=0 (39 PASS), run_puzzle_regressions.py PUZZLE_FAILURES=0 + PUZZLE_LAYOUT_FAILURES=0 (189 PASS))
- [X] T023 Perform the full desktop quickstart.md smoke matrix including window resizing, rapid clicks, 100 mistakes, all-departures completion, Replay, pause and menu transitions; record results in .devspark.work/specs/001-spec-first-playable-arrow-puzzle/gates/verification.md and update tests/README.md with reproducible commands. (code_ref: n/a — verification/docs only | knowledge_ref: n/a — verification-only; tests/README.md updated with reproducible commands for both launchers. Interactive acceptance is now closed by later integrated verification and the user report; see gates/verification.md current completion status for evidence and hardware-reporting limitations)
- [X] T024 Rebuild .knowledge/index.json using the repository knowledge-index tool after validating .knowledge/architecture/arrow-puzzle.md and save-progression.md against implemented code/tests; inspect index output for unrelated churn. (code_ref: n/a — index-only | knowledge_ref: .knowledge/index.json, .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/save-progression.md — rebuilt via .devspark/scripts/build_knowledge_index.py; 3 nodes, 0 edges, 0 dangling references, no unrelated churn)
- [X] T025 Audit changed durable files for forbidden planning backlinks, complete every code_ref/knowledge_ref in .devspark.work/specs/001-spec-first-playable-arrow-puzzle/tasks.md with actual changed paths or justified n/a, and leave the bundle in place for release archival. (code_ref: n/a — audit-only | knowledge_ref: n/a — audit-only; see gates/verification.md "Planning-reference audit" — two leaks found and fixed (tests/README.md branch-path reference, an FR-013 citation in a main_menu_with_animations.gd comment); re-run reports "No planning-artifact references found.", exit 0)

**Checkpoint**: Phase complete — 2026-09-26

## Dependencies and Parallel Execution

T001 -> T002 -> T003 -> T004. US1: T005 -> T006 -> T007 -> T008 -> T009 -> T010 -> T011. US2: T012 -> T013 -> T014 after US1. US3: T015 -> T016 -> T017 -> T018 after US2. US4: T019 -> T020 -> T021 after US3. Final: T022 -> T023 -> T024 -> T025. Test-authoring tasks may initially fail as intended; each story must pass its relevant suite before completion.

Story order: foundation -> US1 -> US2 -> US3 -> US4 -> final verification. Shared state/controller/knowledge files make sequential execution the safe default, so no task is marked unconditionally [P]. Conditional opportunities: US1 board/view authoring can proceed beside core rule implementation once the contract/definition are stable; US2 regression authoring and view-only feedback work can proceed in separate files; US3 results-panel layout can proceed beside core arithmetic tests; US4 manual navigation checking can proceed beside knowledge drafting after UI changes settle. Avoid concurrent edits to state, controller, tests, or the shared knowledge node. These are scheduling options, not instructions to launch agents.

## Implementation Strategy

US1 is the first demonstrable increment. The deliverable MVP requires all four stories: unlimited mistakes, results/replay and preserved controls are explicit acceptance conditions. Maintain current knowledge alongside each behavior increment, then run final verification. Never mark checks complete when unavailable; record blockers and leave tasks outstanding.

## Review Gates and Retention

The requirements checklist is complete (23/23). Required analyze and critic gates have passed (see gates/analyze.md and gates/critic.md); one LOW analyze finding (task-ordering) was resolved by splitting the former T009 into T009 (test-first) and T010 (implementation) below. No unresolved gate finding was bypassed during task generation. Runtime verification is complete: see gates/verification.md for automated headless results (import validation, run_regressions.py, run_puzzle_regressions.py) and the later integrated verification/user acceptance recorded in its current completion status.

Retain the completed bundle under .devspark.work for linkage checking and release archival. The shared preamble's explicit retention policy overrides the command outline's stale deletion instruction. No automatic archive reading or planning-bundle deletion is authorized.
