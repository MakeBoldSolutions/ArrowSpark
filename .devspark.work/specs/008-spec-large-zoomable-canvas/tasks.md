# Tasks: Large Zoomable Puzzle Canvas

**Input**: C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/008-spec-large-zoomable-canvas/
**Prerequisites**: spec.md, plan.md, research.md, data-model.md, contracts/canvas-interaction.md, quickstart.md.
**Route**: full-spec / high risk. Required gates: checklist, analyze, critic, verify:end-to-end.
**Status**: Generated; no implementation tasks executed.

## Rationale Summary

The fit-only board needs a presentation transform without changing rule/scoring authority. Deliver the smallest transform/control/reveal/animation integration, verified against original content and one authored large fixture. Review inverse mapping, input eligibility, departure barriers, saved settings, and real device evidence.

## Execution Rules

All paths are absolute. Every task has pending code_ref/knowledge_ref linkage; fill each with all affected production/test/current-knowledge paths when completed, or n/a with a reason when genuinely unchanged. No durable file may point back to this temporary bundle or its identifiers. All four user stories are P1 and required for release. Tests are included because the spec explicitly requires them. Tests-first: a new suite is registered in the launcher with its authoring task, but its required zero-failure marker is enforced only from the last implementation task of its story onward; all markers must be green at T029.

Required document gates are not claimed passed: requirements checklist passes (26/26); analyze and critic have not run. End-to-end evidence must follow implementation and actual flows. Do not create a fictitious pass to bypass a pre-flight. Follow plan.md's workflow-conflict handling if that pre-flight blocks staged work.

## Phase 1: Setup

Goal: Establish reproducible baselines and validate environment before behavior changes.
- [ ] T001 Record engine path/version and isolated baseline results for both existing launchers in C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/008-spec-large-zoomable-canvas/evidence/baseline.md; identify a Godot 4.4 executable or explicitly record target-engine validation outstanding. Preserve existing user changes. (Implements: FR-022) (code_ref: pending | knowledge_ref: pending)

- [ ] T002 Capture original fourteen catalog IDs/order/dimensions/arrows/tails and existing scene selection/departure invariants in C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_catalog_check.gd and C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_layout_check.gd; preserve behavior assertions before changing presentation. (Implements: FR-016) (code_ref: pending | knowledge_ref: pending)


## Phase 2: Foundational

Goal: Establish one pure transform and stable visual hierarchy. Must finish before story integration.

- [ ] T003 Add pure numeric tests in C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_viewport_transform_check.gd for fit margin, bounds, inverse round trips, zoom anchors, per-axis clamp, manual versus fit resize, invalid size and padded reveal using the contract tolerances. (Implements: FR-002, FR-003, FR-005, FR-014, FR-020) (code_ref: pending | knowledge_ref: pending)

- [ ] T004 Implement PuzzleViewportTransform in C:/GitHub/MakeBoldSolutions/ArrowGame/scripts/presentation/puzzle_viewport_transform.gd with the documented canonical scale, focal/fit state, conversions and bounds; reject invalid/nonfinite inputs and keep it independent of puzzle-rule classes. (Implements: FR-002, FR-003, FR-005, FR-014, FR-020, FR-021) (code_ref: pending | knowledge_ref: pending)

- [ ] T005 Register the helper test in an isolated pure temporary project in C:/GitHub/MakeBoldSolutions/ArrowGame/tests/run_puzzle_regressions.py, with PUZZLE_VIEWPORT_FAILURES=0 required; retain separate rule/core isolation and existing markers. (Implements: FR-020, FR-022) (code_ref: pending | knowledge_ref: pending)

- [ ] T006 Introduce passive World and nested logical DepartureClip in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/puzzle_board.gd; build views at canonical 64-pixel extent once and project via helper; include a minimal guard so non-positive or non-finite viewport area suspends transform, hit-testing and hover instead of producing invalid values (T024 completes ArrowView validity and recovery). Migrate layout/presentation checks in C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_layout_check.gd and C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_presentation_check.gd to world-space assertions without weakening outcomes. (Implements: FR-001, FR-002, FR-008, FR-012, FR-019, FR-020) (code_ref: pending | knowledge_ref: pending)


## Phase 3: US1 — Inspect the Large Board (P1)

Goal: Usable mouse canvas and overview. Independent test: visit all corners at 64 pixels/cell, fit once, and verify unchanged state and all original small-puzzle layouts.

- [ ] T007 [US1] Add integrated canvas cases in C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_canvas_check.gd for initial fit, manual zoom/pan, all corner reachability, original bounds after removal, limit saturation and state/view-identity invariance; register scene suite in C:/GitHub/MakeBoldSolutions/ArrowGame/tests/run_puzzle_regressions.py with PUZZLE_CANVAS_FAILURES=0. (Implements: FR-001, FR-003, FR-004, FR-005, FR-006, FR-009, FR-019, FR-022) (code_ref: pending | knowledge_ref: pending)

- [ ] T008 [US1] (must complete before T007's fixture cases) Append canvas_validation (40x30, 12 arrows, three 20–60-cell bent paths and tail dependency) in C:/GitHub/MakeBoldSolutions/ArrowGame/scripts/puzzle/puzzle_catalog.gd. Update intentional count/last-entry expectations in C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_catalog_check.gd and C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_analyzer_check.gd, checking original snapshots and solver witness. (Implements: FR-001, FR-016, FR-018) (code_ref: pending | knowledge_ref: pending)

- [ ] T009 [US1] Implement pointer-anchored wheel zoom, middle drag and explicit Pan-mode primary drag in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/puzzle_board.gd; retain ordinary Select-mode press behavior, accept wheel events and cancel captured drag on all lifecycle exits. (Implements: FR-003, FR-004, FR-008, FR-017) (code_ref: pending | knowledge_ref: pending)

- [ ] T010 [US1] Add Zoom Out, Zoom In, Fit Puzzle and Pan toggle toolbar plus mode help in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_puzzle.tscn and wire it in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_puzzle.gd; fit setup/replay and keep HUD/toolbar outside World. (Implements: FR-003, FR-004, FR-005, FR-006, FR-007) (code_ref: pending | knowledge_ref: pending)

- [ ] T011 [US1] Validate the four planned window sizes, fit margins, working-scale readability and small-board layout in C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_canvas_check.gd and C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_presentation_check.gd; ensure no unnecessary navigation or HUD overlap for original puzzles. (Implements: FR-005, FR-006, FR-007, FR-016) (code_ref: pending | knowledge_ref: pending)

- [ ] T012 [US1] Update viewport geometry, bounds, fit/manual modes and catalog ownership in C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/arrow-puzzle.md and fixed canonical rendering in C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/game-visual-system.md, citing durable implementation/tests only. (Implements: FR-001, FR-002, FR-005, FR-006, FR-018, FR-020) (code_ref: pending | knowledge_ref: pending)


## Phase 4: US2 — Inspect Without a Pointing Device (P1)

Goal: Accessible configurable inspection. Independent test: keyboard and gamepad event flows zoom/pan/fit and exit board focus without a mouse; real-device verification follows in Polish.

- [ ] T013 [US2] Add keyboard/gamepad event-dispatch and focus-loop cases in C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_canvas_check.gd for board focus, zoom/fit, movement, D-pad return, overlays and window loss; ensure GUI focus cannot also pan after transfer. (Implements: FR-003, FR-004, FR-017, FR-022) (code_ref: pending | knowledge_ref: pending)

- [ ] T014 [US2] Add canvas_zoom_in/out/fit custom InputMap actions in C:/GitHub/MakeBoldSolutions/ArrowGame/project.godot with Equal/Minus/F and shoulder/Y defaults. Preserve move_* mappings and implement focused action handling/600-screen-pixel-per-second normalized pan in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/puzzle_board.gd. (Implements: FR-003, FR-004, FR-017, FR-021) (code_ref: pending | knowledge_ref: pending)

- [ ] T015 [US2] Set explicit Tab/D-pad focus neighbors, board focus indication and InputMap-derived help in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_puzzle.tscn, C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_puzzle.gd and C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/puzzle_board.gd; respect menu/results eligibility and make every control escapable. (Implements: FR-003, FR-004, FR-007, FR-017) (code_ref: pending | knowledge_ref: pending)

- [ ] T016 [US2] Extend C:/GitHub/MakeBoldSolutions/ArrowGame/tests/save_input_regression.gd to verify additive actions in inherited remap UI, mixed keyboard/gamepad restoration, existing bindings and reset-default behavior; inspect C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/menus/options_menu/input/input_options_menu.tscn without modifying addons. (Implements: FR-015, FR-017, FR-022) (code_ref: pending | knowledge_ref: pending)

- [ ] T017 [US2] Document supported focused controls and remapping boundaries in C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/arrow-puzzle.md and C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/save-progression.md; do not claim a new non-mouse arrow-selection system. (Implements: FR-003, FR-004, FR-015, FR-017) (code_ref: pending | knowledge_ref: pending)


## Phase 5: US3 — Select and Request Help Locally (P1)

Goal: Trustworthy transformed hits and visible assistance. Independent test: head/tail/empty targets, cancelled pan, blocked selection and off-screen help all retain exact rule/scoring outcomes.

- [ ] T018 [US3] Add transformed head/tail/empty/departed hit tests, actual pan press/motion/release/cancel events, blocked counter checks and off-screen/repeated/completed assist accounting cases in C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_canvas_check.gd. (Implements: FR-008, FR-009, FR-010, FR-011, FR-017, FR-022) (code_ref: pending | knowledge_ref: pending)

- [ ] T019 [US3] Route all hit/hover samples through the helper in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/puzzle_board.gd, including stationary-pointer refresh after navigation and focus/overlay invalidation; ensure pan and simultaneous-button sequences emit no cell_clicked. (Implements: FR-004, FR-008, FR-009, FR-017, FR-020) (code_ref: pending | knowledge_ref: pending)

- [ ] T020 [US3] Implement minimal padded-head reveal at >=48 pixels/cell before existing suggestion pulse in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/puzzle_board.gd; handle pending invalid-area reveal and cancellation. Keep C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_puzzle.gd at exactly one request_open_move call. (Implements: FR-007, FR-010, FR-011) (code_ref: pending | knowledge_ref: pending)

- [ ] T021 [US3] Compare state, results, scoreboard and solver/analyzer outputs across navigation/assistance flows in C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_canvas_check.gd; include long target, visible target, active departure and invalid-area recovery without extra assist charge. (Implements: FR-009, FR-010, FR-011, FR-016) (code_ref: pending | knowledge_ref: pending)

- [ ] T022 [US3] Update reveal, suggestion lifecycle, inverse hit mapping and feedback precedence in C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/arrow-puzzle.md and C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/game-visual-system.md with durable sources. (Implements: FR-007, FR-008, FR-010, FR-011, FR-020) (code_ref: pending | knowledge_ref: pending)


## Phase 6: US4 — Preserve Departures and Attempts (P1)

Goal: Stable animation, resizing and session lifecycle. Independent test: navigate/resize during concurrent long departures, drain results once, replay to a fresh view, compare state and persisted settings.

- [ ] T023 [US4] Add concurrent long-departure cases under zoom/pan/resize/pause/zero-area/replacement in C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_canvas_check.gd and C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_layout_check.gd; assert canonical routes/progress, full logical clearance and exactly-once completion even off-screen. (Implements: FR-012, FR-013, FR-014, FR-022) (code_ref: pending | knowledge_ref: pending)

- [ ] T024 [US4] Add explicit presentation-layout-validity guard in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_view.gd and propagate only validity changes from C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/puzzle_board.gd; retain canonical extent, route and progress, and never suspend merely off-screen views. (Implements: FR-012, FR-013, FR-014) (code_ref: pending | knowledge_ref: pending)

- [ ] T025 [US4] Complete fit/manual resize recovery, gesture cancellation and results navigation gating in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/puzzle_board.gd and C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_puzzle.gd; preserve pending-departure barrier, replay disposal and fresh overview. (Implements: FR-006, FR-012, FR-013, FR-014, FR-017) (code_ref: pending | knowledge_ref: pending)

- [ ] T026 [US4] Add replay/Next/new-entry view-reset, results/session-best equivalence and no-viewport-storage cases in C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_canvas_check.gd and C:/GitHub/MakeBoldSolutions/ArrowGame/tests/save_input_regression.gd, checking saved bytes/settings around navigation under isolated storage. (Implements: FR-006, FR-009, FR-013, FR-015, FR-016) (code_ref: pending | knowledge_ref: pending)

- [ ] T027 [US4] Update projected departure, zero-area/manual-resize behavior and cancellation authority in C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/arrow-puzzle.md and C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/game-visual-system.md; document no-camera-persistence in C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/save-progression.md. (Implements: FR-012, FR-013, FR-014, FR-015) (code_ref: pending | knowledge_ref: pending)


## Phase 7: Polish and Cross-Cutting Verification

Goal: Measured runtime evidence and current-knowledge consistency. No implementation-time deletion or archival of this bundle.

- [ ] T028 Create deterministic desktop fixture/performance driver C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_canvas_visual_check.gd using catalog validation content, with 2-second warmup and 10-second capture; record 2 ms handler/33.3 ms frame p95 thresholds and no >=100 ms attributable input stall results in C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/008-spec-large-zoomable-canvas/evidence/performance.md. (Implements: FR-007, FR-018, FR-019, FR-022) (code_ref: pending | knowledge_ref: pending)

- [ ] T029 Run target-engine Godot validation and both isolated launchers C:/GitHub/MakeBoldSolutions/ArrowGame/tests/run_puzzle_regressions.py and C:/GitHub/MakeBoldSolutions/ArrowGame/tests/run_regressions.py; record versions, commands, markers and actual outcomes in C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/008-spec-large-zoomable-canvas/evidence/regressions.md, leaving missing target-version validation outstanding. (Implements: FR-016, FR-022) (code_ref: pending | knowledge_ref: pending)

- [ ] T030 Execute every desktop scenario in C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/008-spec-large-zoomable-canvas/quickstart.md across mouse/keyboard and available gamepad, including remaps, long departures, resize, pause, overlays, replay and original small puzzles; record device/window-specific observations, with an explicit "outstanding: gamepad" line if no gamepad is available, in C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/008-spec-large-zoomable-canvas/evidence/desktop.md. (Implements: FR-003, FR-004, FR-005, FR-007, FR-011, FR-012, FR-013, FR-014, FR-017, FR-022) (code_ref: pending | knowledge_ref: pending)

- [ ] T031 Check durable delta/current-knowledge consistency and no new planning references across C:/GitHub/MakeBoldSolutions/ArrowGame/scripts, C:/GitHub/MakeBoldSolutions/ArrowGame/scenes, C:/GitHub/MakeBoldSolutions/ArrowGame/tests and C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge; populate every completed linkage in C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/008-spec-large-zoomable-canvas/tasks.md, record n/a reasons where appropriate, and retain the bundle for release archival. (Implements: FR-015, FR-016, FR-020, FR-022) (code_ref: pending | knowledge_ref: pending)

- [ ] T032 Assemble actual end-to-end evidence in C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/008-spec-large-zoomable-canvas/gates/verify.md, referencing executed regression/desktop/performance records; report missing hardware/version checks explicitly and do not mark pass without required evidence. Retain checklist/analyze/critic gate results for subsequent release review. (Implements: FR-019, FR-022) (code_ref: pending | knowledge_ref: pending)

## Dependencies and Parallel Execution

Execution graph: Setup T001–T002 -> Foundation T003–T006 -> US1 T008, T007, T009–T012 -> US2 T013–T017 -> US3 T018–T022 -> US4 T023–T027 -> Polish T028–T032. This ordering avoids concurrent edits to the shared board/controller/tests/knowledge files. Each story has its own independently repeatable acceptance flow but consumes the shared foundation and completed canvas increment.

- Foundation: T003 specifies numeric behavior before T004; T005 registers/runs it; T006 uses that helper. Do not integrate stories before the foundation passes.
- US1: T008 (fixture, catalog and catalog/analyzer tests) runs first after T006, because T007's large-board and corner-reachability cases need the fixture; then T007, then T009–T012. No task is [P]-marked.
- US2: test authoring and input implementation both touch shared canvas code; keep T013–T017 sequential. Manual remap verification can later run alongside documentation review on a stable build, not concurrently with file edits.
- US3: hit/hover/reveal share the board and canvas tests; keep T018–T022 sequential. Independent scenario execution can use separate isolated processes after this phase.
- US4: lifecycle tests, ArrowView changes and board/controller recovery have ordered dependencies; keep T023–T027 sequential. Later different-device smoke runs may be parallel against the same frozen build, with separate evidence files merged deliberately.
- Polish: run baseline-comparable performance after code stabilizes. Run regression and desktop checks after final behavior changes; repeat only affected checks if new changes invalidate evidence. T032 depends on actual outputs of T028–T031.

## Implementation Strategy

First demonstrable increment: Foundation + US1, including safe pan and usable small-puzzle fit. It is an MVP inspection demonstration, not a release that omits accessibility, assistance or departure guarantees. Complete US2–US4 and all verification before feature acceptance. Author requested regression cases before their implementation where practical; no broad unrelated test expansion.

Do not alter rules/scoreboard to repair a viewport bug. Keep fixture difficulty untuned. If measurements fail, investigate the parent-transform path before adding rendering complexity. No mobile-specific implementation is scheduled.

## Requirement Coverage

Every FR-001 through FR-022 is named by at least one task. Coordinate/research decisions FR-020/021 are already designed; tasks implement and validate those boundaries. The spec's 20 automated coverage rows are distributed across numeric, canvas, catalog, layout/presentation and saved-input suites, with all suites registered in the launcher.

## Lifecycle and Gate Notes

Checklist passed at task generation; no existing analyze/critic findings or remediation tasks were present. No approval to waive a required gate is inferred. End-to-end remains pending real execution. The command template's deletion sentence conflicts with the shared preamble and release-only ownership; this list deliberately retains the completed bundle and linkage until /devspark.release archives it.
