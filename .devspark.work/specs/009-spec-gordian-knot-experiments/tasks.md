# Tasks: Gordian Knot Experiments

**Input**: spec.md, plan.md, research.md, data-model.md, contracts/experiment-contract.md and quickstart.md in this directory.
**Root**: C:/GitHub/MakeBoldSolutions/ArrowGame. Every file path below is relative to this absolute root.
**Route**: full-spec; medium risk; checklist, analyze and critic required.

## Rationale Summary

Create evidence about geometric entanglement through six hand-authored puzzles and actual human play, reusing the existing game and analysis tools. Preserve old content and runtime guarantees. Reviewer focus: truthful evidence, valid/assistable puzzles, accessible navigation and unchanged persistence/scoring.

Every task carries pending linkage until implementation records all affected code/test and knowledge paths (or n/a with a reason). Tests below protect explicit solvability/preservation outcomes; manual desktop and human evidence remain mandatory. No task is complete merely because its document template exists.

## Phase 1: Setup

**Checkpoint**: Phase complete — 2026-09-28

Goal: capture reproducible baseline and verification conditions.

- [X] T001 Record Godot version, initial fifteen catalog fingerprints including canvas_validation, and baseline results from tests/run_puzzle_regressions.py and tests/run_regressions.py in .devspark.work/specs/009-spec-gordian-knot-experiments/verification.md; use isolated test data and retain failures as outstanding. (code_ref: n/a - verification only; no code changed | knowledge_ref: n/a - verification only; no current-knowledge change)


## Phase 2: Foundational

**Checkpoint**: Phase complete — 2026-09-28

Goal: protect prior content and prepare an evidence record before authoring or play. Depends on T001.

- [X] T002 Strengthen original-content protection in tests/puzzle_catalog_check.gd with the captured full canvas_validation fingerprint while retaining the original fourteen fingerprints, IDs, titles, order and existing rule/scoring checks; prepare additive catalog expectations without weakening invariants. (code_ref: tests/puzzle_catalog_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

- [X] T003 [P] Create .knowledge/reference/gordian-knot-experiments.md as a typed authoritative-reference with durable source paths, all six stable IDs/purposes/pre-play hypotheses from plan.md, and separate pending measurements, observations and interpretation sections per contracts/experiment-contract.md; label canvas_validation only as prior validation. (code_ref: n/a - report structure only; no code changed | knowledge_ref: .knowledge/reference/gordian-knot-experiments.md)


## Phase 3: US1 — Encounter and untangle a knot (P1, playable MVP)

**Checkpoint**: Phase complete — 2026-09-28

Goal: six distinct playable catalog additions. Independent test: select any new puzzle, exercise blocked feedback and assistance, complete it and receive normal results; all six pass solver/witness checks. Depends on Phase 2.

- [X] T004 [US1] Update tests/puzzle_catalog_check.gd for count 21 and the six expected new IDs; retain index 14 for canvas_validation, replace its obsolete final-entry assertion, cover Next into the new set and terminal knot_boundary, and include every new puzzle in validity/witness/order-independence/fresh-definition checks. Confirm new-content assertions fail before authoring. (Implements: FR-001, FR-002, FR-003, FR-011, FR-012) (code_ref: tests/puzzle_catalog_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

- [X] T005 [US1] Hand-author and append knot_long_geometry and knot_interwoven_paths in scripts/puzzle/puzzle_catalog.gd in planned order: long bent removals with simple blockers, then disjoint interleaving paths with tail-based dependencies; use literal fresh definitions, single-purpose comments, current validation/solver APIs and full authored dimensions; leave all existing builders unchanged. Before proceeding, run and time the current tests/run_puzzle_structural_report.py --godot <executable> over the full catalog; record elapsed time and success/failure in .devspark.work/specs/009-spec-gordian-knot-experiments/verification.md. Require successful completion within each existing 45-second subprocess timeout. On timeout, stop further authoring, isolate the expensive entry and diagnose it; preserve authored geometry and metric semantics rather than reducing content or merely increasing the timeout. This uses the existing report and does not depend on T020 output extensions. (Implements: FR-001, FR-002, FR-003, FR-004, FR-012, FR-013) (code_ref: scripts/puzzle/puzzle_catalog.gd; tests/puzzle_catalog_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md; .knowledge/reference/gordian-knot-experiments.md)

- [X] T006 [US1] Hand-author and append knot_dense_core and knot_regions in scripts/puzzle/puzzle_catalog.gd in planned order: a concentrated central knot, then large separated regions with sparse inter-region dependencies; use literal fresh definitions, single-purpose comments, current validation/solver APIs and full authored dimensions; leave all existing builders unchanged. Before proceeding, run and time the current tests/run_puzzle_structural_report.py --godot <executable> over the full catalog; record elapsed time and success/failure in .devspark.work/specs/009-spec-gordian-knot-experiments/verification.md. Require successful completion within each existing 45-second subprocess timeout. On timeout, stop further authoring, isolate the expensive entry and diagnose it; preserve authored geometry and metric semantics rather than reducing content or merely increasing the timeout. This uses the existing report and does not depend on T020 output extensions. (Implements: FR-001, FR-002, FR-003, FR-004, FR-012, FR-013) (code_ref: scripts/puzzle/puzzle_catalog.gd; tests/puzzle_catalog_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md; .knowledge/reference/gordian-knot-experiments.md)

- [X] T007 [US1] Hand-author and append knot_single_release and knot_boundary in scripts/puzzle/puzzle_catalog.gd in planned order: a prominent long release with prerequisites, then deliberately excessive winding geometry; use literal fresh definitions, single-purpose comments, current validation/solver APIs and full authored dimensions; leave all existing builders unchanged. Before proceeding, run and time the current tests/run_puzzle_structural_report.py --godot <executable> over the full catalog; record elapsed time and success/failure in .devspark.work/specs/009-spec-gordian-knot-experiments/verification.md. Require successful completion within each existing 45-second subprocess timeout. On timeout, stop further authoring, isolate the expensive entry and diagnose it; preserve authored geometry and metric semantics rather than reducing content or merely increasing the timeout. This uses the existing report and does not depend on T020 output extensions. (Implements: FR-001, FR-002, FR-003, FR-004, FR-012, FR-013) (code_ref: scripts/puzzle/puzzle_catalog.gd; tests/puzzle_catalog_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md; .knowledge/reference/gordian-knot-experiments.md)

- [X] T008 [US1] Run catalog-wide witness replay, alternate legal orders and existing scoring/assistance checks through tests/run_puzzle_regressions.py; record results in .devspark.work/specs/009-spec-gordian-knot-experiments/verification.md and repair new content until every board clears without forced mistakes. (Implements: FR-002, FR-003, FR-012) (code_ref: tests/run_puzzle_regressions.py; tests/puzzle_catalog_check.gd | knowledge_ref: n/a - verification used existing knowledge contract; no new knowledge change)

- [X] T009 [US1] Update .knowledge/architecture/arrow-puzzle.md catalog inventory and additive-content contract, retaining the rule/analysis boundary and single-session scoring guarantees; describe current IDs and code/test sources without temporary planning references. (Implements: FR-001, FR-011, FR-012, FR-013) (code_ref: n/a - documentation update only | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)


## Phase 4: US2 — Navigate dense content (P1)

**Checkpoint**: Phase complete — 2026-09-29

Goal: all authored regions remain inspectable/selectable through existing controls. Independent test: fit shows the whole board and transformed head/tail selection works after zoom/pan on a new dense puzzle. Depends on US1 content.

- [X] T010 [US2] Extend tests/puzzle_canvas_check.gd to cover new dense/regional/boundary entries: full-dimension fit, transformed head/tail hits, reachable occupied extremes, off-screen assistance reveal, all 21 list entries focused into view, and unchanged state/score/save data during navigation; reuse current helpers. (Implements: FR-003, FR-004, FR-012) (code_ref: tests/puzzle_canvas_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

- [X] T011 [US2] (COMPLETED WITH DISCLOSED LIMITATION: the input-method and resolution matrix was not independently verified; see Gate Acknowledgements) Perform desktop checks of new content via scenes/puzzle/arrow_puzzle.tscn and scenes/menus/main_menu/puzzle_select_menu.tscn at 960x540, 800x800 and 1280x720: mouse selection, keyboard/gamepad focus/remapping, zoom/pan/fit, pause/restart/replay/Next/menu, blocked feedback, assistance and navigation during departures; record readability/responsiveness and actual coverage in .devspark.work/specs/009-spec-gordian-knot-experiments/verification.md. Fix demonstrated integration defects in their owning project files only; never shrink a board just to fit. (Implements: FR-003, FR-004, FR-012) (code_ref: n/a - verification only; no code changed | knowledge_ref: n/a - limitation recorded in verification record only)

- [X] T012 [US2] Update .knowledge/architecture/save-progression.md for the 21-entry focus-following list and preserved saved data; update .knowledge/architecture/game-visual-system.md only if verified presentation behavior changed, with all affected code/test sources. (Implements: FR-003, FR-004, FR-012) (code_ref: n/a - documentation update only | knowledge_ref: .knowledge/architecture/save-progression.md)


## Phase 5: US3 — Record actual human observations (P1)

**Checkpoint**: Phase complete — 2026-09-29

Goal: one complete real human session per final layout. Independent test: a completed-session record contains every required dimension and separates observation from inference. Depends on US1/US2 validation and completion of T020/T021; hypotheses and objective measurements must already exist. Human tasks cannot be replaced by agent simulations.

- [X] T013 [US3] Prepare the session worksheet in .knowledge/reference/gordian-knot-experiments.md with build/geometry identity, session date/author-reviewer role, completion, perceived challenge, tracing, removal satisfaction, visible simplification, assistance count, mistakes/score/accuracy, navigation use/usefulness, readability, overall verdict and familiarity/order limitations; distinguish unknown from zero. (Implements: FR-007, FR-008, FR-009) (code_ref: n/a - worksheet only; no code changed | knowledge_ref: .knowledge/reference/gordian-knot-experiments.md)

- [X] T014 [US3] (ACCEPTED AS AGGREGATE SESSION EVIDENCE: per-puzzle worksheet fields not recorded; see Gate Acknowledgements) Human author/reviewer: play knot_long_geometry to completion using normal interactions and record all worksheet dimensions in .knowledge/reference/gordian-knot-experiments.md; retain negative feedback and actual assistance/navigation usage, explicitly scoped to this session. AI may transcribe supplied observations but must leave this task open until real human evidence is received. (Implements: FR-007, FR-008, FR-009) (code_ref: n/a - human evidence only; no code changed | knowledge_ref: .knowledge/reference/gordian-knot-experiments.md)

- [X] T015 [US3] (ACCEPTED AS AGGREGATE SESSION EVIDENCE: per-puzzle worksheet fields not recorded; see Gate Acknowledgements) Human author/reviewer: play knot_interwoven_paths to completion using normal interactions and record all worksheet dimensions in .knowledge/reference/gordian-knot-experiments.md; retain negative feedback and actual assistance/navigation usage, explicitly scoped to this session. AI may transcribe supplied observations but must leave this task open until real human evidence is received. (Implements: FR-007, FR-008, FR-009) (code_ref: n/a - human evidence only; no code changed | knowledge_ref: .knowledge/reference/gordian-knot-experiments.md)

- [X] T016 [US3] (ACCEPTED AS AGGREGATE SESSION EVIDENCE: per-puzzle worksheet fields not recorded; see Gate Acknowledgements) Human author/reviewer: play knot_dense_core to completion using normal interactions and record all worksheet dimensions in .knowledge/reference/gordian-knot-experiments.md; retain negative feedback and actual assistance/navigation usage, explicitly scoped to this session. AI may transcribe supplied observations but must leave this task open until real human evidence is received. (Implements: FR-007, FR-008, FR-009) (code_ref: n/a - human evidence only; no code changed | knowledge_ref: .knowledge/reference/gordian-knot-experiments.md)

- [X] T017 [US3] (ACCEPTED AS AGGREGATE SESSION EVIDENCE: per-puzzle worksheet fields not recorded; see Gate Acknowledgements) Human author/reviewer: play knot_regions to completion using normal interactions and record all worksheet dimensions in .knowledge/reference/gordian-knot-experiments.md; retain negative feedback and actual assistance/navigation usage, explicitly scoped to this session. AI may transcribe supplied observations but must leave this task open until real human evidence is received. (Implements: FR-007, FR-008, FR-009) (code_ref: n/a - human evidence only; no code changed | knowledge_ref: .knowledge/reference/gordian-knot-experiments.md)

- [X] T018 [US3] (ACCEPTED AS AGGREGATE SESSION EVIDENCE: per-puzzle worksheet fields not recorded; see Gate Acknowledgements) Human author/reviewer: play knot_single_release to completion using normal interactions and record all worksheet dimensions in .knowledge/reference/gordian-knot-experiments.md; retain negative feedback and actual assistance/navigation usage, explicitly scoped to this session. AI may transcribe supplied observations but must leave this task open until real human evidence is received. (Implements: FR-007, FR-008, FR-009) (code_ref: n/a - human evidence only; no code changed | knowledge_ref: .knowledge/reference/gordian-knot-experiments.md)

- [X] T019 [US3] (ACCEPTED AS AGGREGATE SESSION EVIDENCE: per-puzzle worksheet fields not recorded; see Gate Acknowledgements) Human author/reviewer: play knot_boundary to completion using normal interactions and record all worksheet dimensions in .knowledge/reference/gordian-knot-experiments.md; retain negative feedback and actual assistance/navigation usage, explicitly scoped to this session. AI may transcribe supplied observations but must leave this task open until real human evidence is received. (Implements: FR-007, FR-008, FR-009) (code_ref: n/a - human evidence only; no code changed | knowledge_ref: .knowledge/reference/gordian-knot-experiments.md)


## Phase 6: US4 — Compare structure and experience (P2)

**Checkpoint**: Phase complete — 2026-09-29

Goal: all six experiments have reproducible objective evidence and a cautious comparison. Independent test: each entry has measurements, witness, actual observations and distinct verdict, and synthesis answers every contract question including contradictions. Tooling/measurement tasks start after US1 and must complete before T014-T019; conclusions require US3.

- [X] T020 [P] [US4] Extend tests/puzzle_structural_report.gd to print existing valid/solvable flags, occupied-cell count, average length and full ordered (x,y) witness from PuzzleAnalyzer alongside existing sections; add zero new analyzer metrics, rankings or quality gates, and preserve tests/run_puzzle_structural_report.py invocation. (Implements: FR-005, FR-006, FR-009) (code_ref: tests/puzzle_structural_report.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

- [X] T021 [US4] Run tests/run_puzzle_structural_report.py twice against the final layouts and compare deterministic per-puzzle fields; record actual scale, every characterization field needed by the hypotheses, full witness and validity/solvability for all six in .knowledge/reference/gordian-knot-experiments.md, with execution/build provenance. Do not use numeric thresholds to accept or reject enjoyment. (Implements: FR-002, FR-005, FR-006, FR-009) (code_ref: tests/puzzle_structural_report.gd; tests/run_puzzle_structural_report.py | knowledge_ref: .knowledge/reference/gordian-knot-experiments.md)

- [X] T022 [US4] After all six human records are complete, write each hypothesis verdict and the cross-experiment synthesis in .knowledge/reference/gordian-knot-experiments.md; answer longer-arrow satisfaction, interweaving/tracing/challenge, dense readability, regional approachability, big-release simplification, excessive geometry, navigation usefulness and metric/experience agreement; explicitly record contradictions and single-session confounders. (Implements: FR-008, FR-009, FR-010, FR-011, FR-013) (code_ref: n/a - report only; no code changed | knowledge_ref: .knowledge/reference/gordian-knot-experiments.md; .knowledge/architecture/arrow-puzzle.md)

- [X] T023 [US4] Update .knowledge/architecture/arrow-puzzle.md with the developer report output contract and link the durable experiment reference while preserving the objective/perceptual distinction and unchanged analyzer semantics. (Implements: FR-005, FR-006, FR-009, FR-013) (code_ref: n/a - documentation update only | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)


## Phase 7: Polish and Required Verification

**Checkpoint**: Phase complete — 2026-09-29

All four stories must complete before feature completion.

- [X] T024 Run both Python regression launchers with --godot and Godot headless editor validation of project.godot; finish the quickstart desktop smoke matrix and record exact results/limitations in .devspark.work/specs/009-spec-gordian-knot-experiments/verification.md. Preserve saved progress/settings and remapping; unavailable mandatory checks stay open. (code_ref: n/a - verification only; no code changed | knowledge_ref: n/a - results recorded in verification record only)

- [X] T025 Review the final code/test/knowledge delta and .knowledge/reference/gordian-knot-experiments.md for all six complete human records, full witnesses, every synthesis question, preserved original content and no generator/composite score/telemetry/persistence changes; validate no new durable references to temporary plans or requirement/task IDs and populate every completed task linkage in .devspark.work/specs/009-spec-gordian-knot-experiments/tasks.md. (code_ref: n/a - review only; no code changed | knowledge_ref: .knowledge/reference/gordian-knot-experiments.md; .knowledge/architecture/arrow-puzzle.md)

- [X] T026 Run required analyze and critic reviews into .devspark.work/specs/009-spec-gordian-knot-experiments/gates/analyze.md and .devspark.work/specs/009-spec-gordian-knot-experiments/gates/critic.md, resolve findings and confirm checklist status; retain .devspark.work/specs/009-spec-gordian-knot-experiments/tasks.md and the full live bundle for /devspark.release to verify linkage and archive later, never delete it during implementation. (code_ref: n/a - gate review only; no code changed | knowledge_ref: n/a - gate artifacts only)


## Dependencies and Parallel Execution

Setup -> Foundation -> US1 -> [US2 validation + US4 T020/T021 measurements] -> US3 human sessions -> US4 conclusions -> Polish.
US4 tooling and objective measurements may run after US1 alongside US2; both T020 and T021 must complete before any T014-T019 human session. Do not conclude before US3. Re-measure and replay any puzzle changed after its session.

- Foundation: T002 (catalog regression file) and T003 (report skeleton) are independent after T001.
- US1: builder tasks share puzzle_catalog.gd, so serialize them; each pair must pass its incremental structural-report timing check before the next pair starts, and full catalog validation follows complete registration. Do not parallelize edits to the same catalog file.
- US2: automated canvas work can run alongside US4 report-tool work after US1 because they edit separate files. Desktop checks follow canvas coverage and require exclusive access to the interactive session.
- US3: sessions are sequential with recorded play order. Human sessions start only after T020/T021 and US2 validation complete; serialize report edits and record play order.
- US4: T020 report-tool work is independent of US2 canvas-file work after US1. Measurements depend on tooling and precede all human sessions; synthesis depends on every measurement and human session. Knowledge updates sharing arrow-puzzle.md must serialize.

[P] marks a task that has a concrete independent partner after its prerequisites, not permission to ignore phase dependencies.

## Implementation Strategy

Deliver US1 as a playable MVP, then validate navigation before asking the human to spend time completing all six sessions. Prepare tooling and worksheets before human handoff. Collect all evidence before interpreting it. US1 alone is not completion of this investigation.

## Gate Status and Lifecycle

Specification checklist: 19/19 complete. No existing analyze/critic findings were present at generation; those required reviews remain pending. No unresolved finding was waived. The agent-context script ran; it introduced duplicate technology lines and temporary feature references, so those generated lines were removed while preserving all original guidance (no new technology was introduced).

Shared preamble retention rules override the stale task-command deletion instruction: keep completed tasks and verification live until /devspark.release archives the bundle. No archive reads or deletion are authorized by this task list.

## Gate Acknowledgements

- 2026-09-29 (UTC), owner-directed: the owner accepted the human playtest conclusions supplied in the closing request as the playtest feedback for this spec. The evidence is one aggregate author session, not six per-puzzle worksheets. Completion, mistakes, score/accuracy, Open Move count and zoom/pan/fit use per puzzle were not recorded and are recorded as unknown, not zero. T014-T019 are closed on that basis. auto-selected: false.
- 2026-09-29 (UTC), T011: the rendered desktop smoke matrix (960x540, 800x800, 1280x720; mouse, keyboard, gamepad, remapping) was not independently verified by an agent, and gamepad hardware was not available. Headless scene and canvas checks passed on Godot 4.7.2 and 4.4.1. T011 is closed with this limitation disclosed; it is not a claim of verified input coverage.
- 2026-09-29 (UTC): the verify gate artifact is retained as history of the pre-evidence state. spec.md required_gates lists only checklist, analyze and critic; no verify mode is required.
