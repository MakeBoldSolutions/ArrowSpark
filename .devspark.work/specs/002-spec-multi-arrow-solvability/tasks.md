# Tasks: Rich Arrow Model and Solvability Foundation

**Input**: C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/002-spec-multi-arrow-solvability/

All listed source paths resolve against C:/GitHub/MakeBoldSolutions/ArrowGame. Prerequisites: spec.md, plan.md, research.md, data-model.md, contracts/puzzle.md and quickstart.md.

## Rationale Summary

Extend shape ownership and presentation while preserving accounting and saved data; prove content solvable with monotone elimination. Review whole-shape atomicity, ownership, witness replay and lifecycle regressions. Automated tests requested by the spec and constitution-mandated Godot/desktop checks are required.

## Phase 1: Setup

Capture the baseline and retain existing regression entrypoints.

- [X] T001 Record Godot version and baseline puzzle/save regression commands, results and limitations in .devspark.work/specs/002-spec-multi-arrow-solvability/gates/verification.md; use tests/run_puzzle_regressions.py and tests/run_regressions.py with isolated user data. (code_ref: n/a - record-only task | knowledge_ref: n/a - record-only task)
- [X] T002 Document rich-shape verification entrypoints and isolation requirements in tests/README.md without adding dependencies. (code_ref: tests/README.md | knowledge_ref: n/a - test-runner docs, not covered by an appliesTo entry)

**Checkpoint**: Phase complete — 2026-09-26

## Phase 2: Foundational

Shared shape and ownership contracts must work before player-facing stories.

- [X] T003 Add optional copied tail map, shape/ownership accessors and validation diagnostics to scripts/puzzle/puzzle_definition.gd; retain three-argument constructors and head-direction map semantics. Validation MUST reject a first tail cell that is not immediately behind the head opposite its direction, any tail cell outside board bounds, and any own tail cell lying on that arrow's own forward escape ray; adjacency between different arrows' cells MUST NOT be rejected. (Implements: FR-001, FR-002, FR-003) (code_ref: scripts/puzzle/puzzle_definition.gd | knowledge_ref: n/a - .knowledge/architecture/arrow-puzzle.md consolidated once at T010, per the plan note on serialized knowledge edits)
- [X] T004 Implement copied active geometry, cell-to-head lookup, own-cell-excluding head-ray blocking and atomic whole-shape removal in scripts/puzzle/puzzle_state.gd; retain ignored outcomes and arrow-based counters. (Implements: FR-004, FR-005, FR-006, FR-016) (code_ref: scripts/puzzle/puzzle_state.gd | knowledge_ref: n/a - consolidated at T010)
- [X] T005 Extend tests/puzzle_regression.gd with malformed/overlapping/disconnected/repeated/out-of-bounds shapes, straight/multi-turn/empty tails, mutation isolation and head/tail atomic-selection fixtures; add invalid-definition fixtures for a tail whose first cell is not immediately behind its head (opposite direction of travel) and for a tail whose right-angle turns would place one of its own cells on its own forward escape ray, asserting both are rejected by validation rather than tolerated at runtime; add a valid fixture where two different arrows' cells are orthogonally adjacent without overlap and confirm it validates cleanly. Require regression pass before scene integration. (Implements: FR-001, FR-002, FR-005) (code_ref: tests/puzzle_regression.gd | knowledge_ref: n/a - consolidated at T010)

**Checkpoint**: Phase complete — 2026-09-26

## Phase 3: US1 - Play multi-cell arrows (P1)

Independent test: remove straight and bent shapes by head or tail; entire shape exits in head direction; single-cell arrows retain behavior.

- [X] T006 [US1] Implement whole-shape drawing, local cell offsets, oriented head, bounded blocked pulse and whole-view directional exit with one signal in scenes/puzzle/arrow_view.gd. (Implements: FR-001, FR-003, FR-005) (code_ref: scenes/puzzle/arrow_view.gd | knowledge_ref: n/a - consolidated at T010)
- [X] T007 [US1] Lay out one head-keyed shape view per arrow in scenes/puzzle/puzzle_board.gd; preserve coordinate-only click events and resize behavior, and dispatch effects by canonical head. (Implements: FR-001, FR-003, FR-005) (code_ref: scenes/puzzle/puzzle_board.gd | knowledge_ref: n/a - consolidated at T010)
- [X] T008 [US1] Resolve selected owner before state mutation in scenes/puzzle/arrow_puzzle.gd and retain one pending departure per accepted removal, immediate HUD counters and results after all exits. (Implements: FR-005, FR-016) (code_ref: scenes/puzzle/arrow_puzzle.gd | knowledge_ref: n/a - consolidated at T010)
- [X] T009 [US1] Add synthetic head/tail selection, shape bounds at both window sizes, multiple departures, completed-input ignoring and replay reconstruction assertions to tests/puzzle_layout_check.gd. (Implements: FR-003, FR-005, FR-016) (code_ref: tests/puzzle_layout_check.gd | knowledge_ref: n/a - consolidated at T010)
- [X] T010 [US1] Update .knowledge/architecture/arrow-puzzle.md with current shape ownership, drawing and lifecycle behavior and durable code/test evidence; remove obsolete temporary references in touched files. (Implements: FR-001, FR-003, FR-005, FR-016) (code_ref: scenes/puzzle/arrow_view.gd, scenes/puzzle/puzzle_board.gd, scenes/puzzle/arrow_puzzle.gd, tests/puzzle_layout_check.gd, scripts/puzzle/puzzle_definition.gd, scripts/puzzle/puzzle_state.gd, tests/puzzle_regression.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

**Checkpoint**: Phase complete — 2026-09-26

## Phase 4: US2 - Tails block and unblock (P1)

Independent test: a tail-only blocker causes one mistake/cue per press; removing its owner clears the dependent arrow.

- [X] T011 [P] [US2] Expand tests/puzzle_regression.gd to head/tail blockers in four directions and straight/bent shapes, tail-only blocks, own-cell nonblocks for every valid own-tail cell position behind the head, off-axis nonblocks, boundary heads, newly legal dependents and at least 100 repeated blocks. Own-tail-on-own-forward-ray is out of scope here as a runtime non-block case — per FR-001, that geometry is invalid and is covered as a validation-rejection fixture in T005, not as a blocking-check exclusion. (Implements: FR-004, FR-006) (code_ref: tests/puzzle_regression.gd | knowledge_ref: n/a - consolidated at T015)
- [X] T012 [P] [US2] Adapt create_fixed in scripts/puzzle/puzzle_definition.gd to the data-model candidate with straight and multi-turn tails, all directions and removal dependencies; reword tests/puzzle_regression.gd's existing _test_blocking_matrix and WITNESS_ORDER comments to match the tailed geometry rather than the prior single-cell rationale. (Implements: FR-015) (code_ref: scripts/puzzle/puzzle_definition.gd, tests/puzzle_regression.gd | knowledge_ref: n/a - consolidated at T015)
- [X] T013 [US2] Integrate repeatable whole-shape blocked feedback through scenes/puzzle/puzzle_board.gd and scenes/puzzle/arrow_puzzle.gd; test rapid repeated head/tail clicks during feedback in tests/puzzle_layout_check.gd. (Implements: FR-006, FR-016) (code_ref: tests/puzzle_layout_check.gd | knowledge_ref: n/a - consolidated at T015; whole-shape blocked feedback was already generic from T006-T008, the delta here is the rapid-tail-click regression)
- [X] T014 [US2] Assert actual create_fixed content contains straight/bent tails, all directions, tail blocking and a dependent arrow that clears after removal in tests/puzzle_regression.gd; retain formula/rounding/unlimited-mistake cases. (Implements: FR-015, FR-016) (code_ref: tests/puzzle_regression.gd | knowledge_ref: n/a - consolidated at T015)
- [X] T015 [US2] Update .knowledge/architecture/arrow-puzzle.md with actual blocking semantics, authored layout and test evidence without temporary requirement identifiers. (Implements: FR-004, FR-006, FR-015) (code_ref: scripts/puzzle/puzzle_definition.gd, scripts/puzzle/puzzle_state.gd, tests/puzzle_regression.gd, tests/puzzle_layout_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

**Checkpoint**: Phase complete — 2026-09-26

## Phase 5: US3 - Prove solvability (P2)

Independent test: isolated analysis returns a complete replayable witness for shipped content and empty witness for valid-unsolvable boards.

- [X] T016 [P] [US3] Add scripts/puzzle/puzzle_solver.gd with validation-first result, fresh-state deterministic legal elimination ordered by y/x, complete witness on success and empty witness on valid-unsolvable; document monotonicity in domain terms. (Implements: FR-007, FR-008, FR-009, FR-010, FR-012, FR-014) (code_ref: scripts/puzzle/puzzle_solver.gd | knowledge_ref: n/a - consolidated at T019)
- [X] T017 [P] [US3] Add scripts/puzzle/puzzle_solver.gd to isolated copy setup in tests/run_puzzle_regressions.py while preserving scene separation, timeout/error reporting and success markers. (Implements: FR-008, FR-011) (code_ref: tests/run_puzzle_regressions.py | knowledge_ref: n/a - consolidated at T019)
- [X] T018 [US3] Add solver regressions in tests/puzzle_regression.gd for shipped witness execution, uniqueness/completeness, invalid input, two-arrow cycle, removable prefix then residual cycle, deterministic repeated calls, unchanged input/live attempt, and order-independence (a branching fixture where solving from every legal first move, not only the sorted-first choice, still completes). (Implements: FR-007, FR-008, FR-009, FR-010, FR-011, FR-014, FR-015) (code_ref: tests/puzzle_regression.gd | knowledge_ref: n/a - consolidated at T019)
- [X] T019 [US3] Update .knowledge/architecture/arrow-puzzle.md with solver contract, proof assumptions and test invocation; extend appliesTo to scripts/puzzle/puzzle_solver.gd. (Implements: FR-007, FR-008, FR-009, FR-010, FR-011, FR-014) (code_ref: scripts/puzzle/puzzle_solver.gd, tests/run_puzzle_regressions.py, tests/puzzle_regression.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

**Checkpoint**: Phase complete — 2026-09-26

## Phase 6: US4 - Structural counts (P3)

Independent test: exact counts match forced/branching/stuck fixtures, repeat deterministically, and result contains no difficulty fields.

- [X] T020 [P] [US4] Populate additive metrics in scripts/puzzle/puzzle_solver.gd: states, active/legal choice sums, forced, branching and no-move counts; include nonempty stuck terminal, exclude cleared terminal, zero metrics for invalid input. (Implements: FR-012, FR-013) (code_ref: scripts/puzzle/puzzle_solver.gd | knowledge_ref: n/a - consolidated at T022)
- [X] T021 [P] [US4] Add exact single-arrow, two-independent-arrow and cycle metric fixtures to tests/puzzle_regression.gd; assert state-count identity, nonnegative fields, stable witness/outcome and absence of difficulty labels. (Implements: FR-012, FR-013) (code_ref: tests/puzzle_regression.gd | knowledge_ref: n/a - consolidated at T022)
- [X] T022 [US4] Document metric field semantics, deterministic-path scope and extensibility in .knowledge/architecture/arrow-puzzle.md with durable test references. (Implements: FR-012, FR-013) (code_ref: scripts/puzzle/puzzle_solver.gd, tests/puzzle_regression.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

**Checkpoint**: Phase complete — 2026-09-26

## Phase 7: Polish and cross-cutting verification

All required checks must pass or remain explicitly outstanding. No implementation work is performed by this task-authoring command.

- [X] T023 Extend tests/save_input_regression.gd to verify seeded progress/settings and keyboard/gamepad remaps survive puzzle entry/menu routing; preserve tests/run_regressions.py isolation and no-reset checks. (Implements: FR-016) (code_ref: tests/save_input_regression.gd | knowledge_ref: n/a - no behavior change; puzzle entry already never touched the input-remap system, this only adds regression coverage proving it)
- [X] T024 Run Godot import/validation for project.godot and affected scripts/scenes plus both Python regression launchers; record commands, version, markers and outstanding failures in .devspark.work/specs/002-spec-multi-arrow-solvability/gates/verification.md. (code_ref: n/a - verification-only | knowledge_ref: n/a - verification-only)
- [X] T025 Smoke-test actual desktop opening/start/play/completion/Replay/Main Menu, head/tail clicks, rapid departures, resize, pause/resume, Restart cancel/confirm and options using scenes/puzzle/arrow_puzzle.tscn; record evidence in .devspark.work/specs/002-spec-multi-arrow-solvability/gates/verification.md. (code_ref: n/a - verification-only | knowledge_ref: n/a - verification-only; closed by later integrated evidence and user-reported acceptance; see gates/verification.md current completion status)
- [X] T026 Verify keyboard/gamepad navigation and remapping across menus/pause/results and saved progress/settings before/after play in project.godot; record hardware limitations and results in .devspark.work/specs/002-spec-multi-arrow-solvability/gates/verification.md without claiming unavailable checks passed. (code_ref: n/a - verification-only | knowledge_ref: n/a - verification-only; closed by later integrated evidence and user-reported acceptance; see gates/verification.md current completion status)
- [X] T027 Reconcile .knowledge/architecture/arrow-puzzle.md and .knowledge/architecture/save-progression.md with implemented behavior and verification; refresh .knowledge/index.json and .knowledge/ontology/coverage.json using repository knowledge tooling if ownership paths changed. (code_ref: n/a - documentation/tooling only | knowledge_ref: .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/save-progression.md, .knowledge/index.json)
- [X] T028 Scan affected scripts/puzzle/, scenes/puzzle/, tests/ and .knowledge/architecture/arrow-puzzle.md for obsolete behavior and temporary spec/task/requirement references; remove those references and fill every task linkage in .devspark.work/specs/002-spec-multi-arrow-solvability/tasks.md with all affected production/test and current-knowledge paths or justified n/a. (code_ref: scripts/puzzle/puzzle_feedback.gd, scripts/puzzle/puzzle_results_format.gd, scenes/puzzle/puzzle_results.gd, tests/puzzle_regression.gd, tests/run_puzzle_regressions.py, .github/workflows/godot-regression-tests.yml | knowledge_ref: n/a - comment cleanup and CI hardening only; `check-planning-references.sh --include-tests` reports zero findings)
- [X] T029 Confirm all required review and verification findings are resolved in .devspark.work/specs/002-spec-multi-arrow-solvability/gates/ and retain the complete bundle for /devspark.release; do not delete or archive it during implementation. (code_ref: .github/workflows/godot-regression-tests.yml | knowledge_ref: n/a - gate-finding resolution only; fixed analyze-D1, critic-005, critic-006 in gates/analyze.md and gates/critic.md, plan.md, and tasks.md. T025/T026 are now closed by later integrated verification and user-reported acceptance.)

**Checkpoint**: Phase complete — 2026-09-26; manual acceptance reconciled with the later integrated verification and user report.

## Dependencies and Parallel Execution

T001-T005 precede player-story integration. US1 follows foundation; US2 follows US1 for UI integration, while its isolated rule fixtures/content can be prepared after foundation. US3 depends on foundation, with shipped-content assertions after US2. US4 depends on US3. Final verification follows all stories; knowledge edits are serialized because they share a file.

- US1: view -> board -> controller -> scene tests -> knowledge. No safe parallel task marked within this tightly coupled sequence.
- US2: T011 rule matrix and T012 authored definition can run in parallel after foundation; wait for both before content assertions and integration validation.
- US3: T016 solver and T017 launcher changes can run in parallel after agreeing the solver filename/contract; execute tests only after both are complete.
- US4: T020 metrics and T021 expected-value fixtures can be authored in parallel against the documented contract; execute tests after integration.

[P] means independent file work once phase prerequisites are satisfied, not permission to execute a dependent test suite prematurely. Parallel opportunities describe future implementation; no agent delegation is required.

## Implementation Strategy

Deliver US1 as the smallest playable preview, then US2's complete mechanics/content. US3 is mandatory before shipping; US4 completes the requested feature. Preserve old single-cell fixtures as regression cases. Complete all four stories and required checks before declaring delivery complete.

Every task has completed traceability: actual production/test paths in code_ref and current knowledge paths in knowledge_ref, or n/a with a reason for verification-only work. Durable artifacts never link back to this bundle.

## Gate Status and Retention

Specification checklist: 19/19 complete. Analyze and critic have each run (see gates/analyze.md, gates/critic.md); their reviewed_artifacts hashes are the source of truth for whether a given review is still current — re-run either gate after further edits to spec.md, plan.md, or tasks.md rather than trusting this sentence. No unresolved findings have been waived. Constitution design check passes without waivers.

The shared preamble explicitly reserves archival for /devspark.release and requires retention after implementation. This overrides the older task-outline deletion instruction; T029 retains the complete bundle for release review.
