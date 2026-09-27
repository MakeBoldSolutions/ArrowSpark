---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Tasks: Puzzle Structure, Challenge, and Character

**Input**: Design documents from `.devspark.work/specs/006-spec-puzzle-structure-analysis/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Verification**: Constitution-mandated checks are required (Principle V). This feature's
gameplay-visible surface is limited to six new playable puzzles reached through existing
navigation (Level Select), so Godot validation and an affected-gameplay smoke test cover those;
`PuzzleAnalyzer` and the developer report are headless dev/test-time-only and are verified by the
automated gates instead. Synthetic-puzzle unit tests for `PuzzleAnalyzer` are **not optional** —
spec FR-024 requires them explicitly.

**Organization**: Tasks are grouped by user story (US1–US3, priorities P1/P1/P2 per spec.md), in
build order. US2 and US3 depend on US1's `PuzzleAnalyzer` existing (see Dependencies below) — this
is a real dependency, not an artificial one, so it is stated rather than forced into
false independence.

## Rationale Summary

### Core Problem

Translate plan.md's design (a `PuzzleAnalyzer` sibling to `PuzzleSolver`, six new `PuzzleCatalog`
entries, an extended regression gate, a non-gating developer report, and a plain-markdown
calibration bundle) into an ordered, independently-checkable task list.

### Decision Summary

Order tasks so `PuzzleAnalyzer` (US1) is fully implemented and unit-tested against synthetic
puzzles *before* any of the six new experimental puzzles (US2) are verified against it, and before
the developer report or calibration work (US3) begins — matching the spec's own stated priority
reasoning (User Story 1's Why-this-priority: "every other outcome... depends on this measurement
capability existing and being trustworthy first").

### Key Drivers

- FR-004 forbids a second, independently-implemented rules engine — every dependency/legality
  computation task must route through `PuzzleState.is_blocked`/`get_arrow_head` or
  `PuzzleDefinition.forward_ray_cells`/`get_cell_owners`, never a fresh reimplementation.
- FR-012 explicitly allows (and treats as desirable) a single puzzle satisfying more than one
  named experiment — task-level "verify property" steps check for *at least* the named property,
  never treat overlap as a bug.
- The existing `tests/run_puzzle_regressions.py` bare-isolated-project pattern already fits
  `PuzzleAnalyzer`'s dependency footprint exactly (research.md) — tasks extend it rather than
  build a new harness.

### Reviewer Guidance

Confirm every US1 implementation task's dependency/cascade logic is traceable to
`PuzzleState.is_blocked`; confirm no US2 puzzle-authoring task edits `PuzzleDefinition`,
`PuzzleState`, or `PuzzleSolver`; confirm the six new puzzles' "verify property" tasks each cite
the specific `PuzzleAnalyzer` field checked (per data-model.md); confirm the developer report task
produces no pass/fail marker; confirm the Polish phase's negative-requirement verification task
(FR-009/010/011/023) is not skipped even though it produces no new code.

## Format: `[ID] [P?] [Story] Description (Implements: FR-###[, FR-###])`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1, US2, or US3 (maps to spec.md's three user stories)
- **Implements**: functional requirement ID(s) from spec.md
- **Linkage**: every task ends with `(code_ref: pending | knowledge_ref: pending)`; `/devspark.implement` fills these as each task completes

## Path Conventions

Single Godot project (per plan.md's Project Structure): `scripts/puzzle/`, `scripts/`, `tests/` at
repository root; this feature's own working documents under
`.devspark.work/specs/006-spec-puzzle-structure-analysis/`.

---

## Phase 1: Setup

**Purpose**: Establish a clean baseline before any change.

- [ ] T001 Run `python tests/run_puzzle_regressions.py --godot <executable>` and `python tests/run_regressions.py --godot <executable>` and record the clean baseline (markers, engine version) in `.devspark.work/specs/006-spec-puzzle-structure-analysis/gates/verification.md` before any code change (code_ref: pending | knowledge_ref: pending)

---

## Phase 2: Foundational

**Purpose**: Blocking prerequisites shared by all user stories.

No separate foundational phase is needed: `PuzzleAnalyzer` — the shared prerequisite every other
story depends on — **is** User Story 1's own deliverable, not infrastructure ahead of it. Proceed
directly to Phase 3.

**Checkpoint**: Baseline recorded (T001) — User Story 1 implementation can begin.

---

## Phase 3: User Story 1 - Measure any puzzle's objective structure (Priority: P1) 🎯 MVP

**Goal**: A headless, deterministic `PuzzleAnalyzer.analyze(definition)` returning board-scale,
arrow-geometry, legal-move-structure, dependency-graph, cascade, and blocker-distance metrics,
verified against synthetic puzzles with hand-computed expected values.

**Independent Test**: Feed the analyzer each of the eight existing catalog puzzles plus the
synthetic test puzzles below; confirm every returned metric matches expected values exactly, with
zero mutation of the input definition (spec User Story 1's own Independent Test).

### Implementation for User Story 1

- [ ] T002 [US1] Create `scripts/puzzle/puzzle_analyzer.gd`: `class_name PuzzleAnalyzer extends RefCounted`, static `analyze(definition: PuzzleDefinition) -> Dictionary` entry point returning the invalid-input shape (all-zero/empty per data-model.md) so later tasks can build up the valid-input path incrementally (Implements: FR-008) (code_ref: pending | knowledge_ref: pending)
- [ ] T003 [US1] Implement board-scale metrics (`width, height, total_cells, arrow_count, occupied_cell_count, density`) in `scripts/puzzle/puzzle_analyzer.gd`, computed directly from `PuzzleDefinition` fields/`get_cell_owners()` (Implements: FR-001) (code_ref: pending | knowledge_ref: pending)
- [ ] T004 [US1] Implement arrow-geometry metrics (`single_cell_count, multi_cell_count, average_length, max_length, bent_arrow_count, total_bends, average_bends_per_arrow, max_bends_on_one_arrow`) in `scripts/puzzle/puzzle_analyzer.gd`, deriving bend count from direction changes along each arrow's tail path (Implements: FR-002) (code_ref: pending | knowledge_ref: pending)
- [ ] T005 [US1] Implement legal-move-structure metrics (`initial_legal_count/ratio, min/max/average_legal, forced_state_count/ratio, branching_state_count/ratio, longest_forced_run, legal_choice_sequence`) in `scripts/puzzle/puzzle_analyzer.gd` by walking a disposable internal `PuzzleState` step-by-step through `PuzzleSolver.analyze(definition).witness`, querying `is_blocked` at each step exactly as `PuzzleSolver` itself does (Implements: FR-003) (code_ref: pending | knowledge_ref: pending)
- [ ] T006 [US1] Implement dependency-graph construction (`edge_count, depth, longest_chain, max_in_degree, max_out_degree, component_count`) in `scripts/puzzle/puzzle_analyzer.gd` at the *initial* state, deriving every edge from `PuzzleState.is_blocked`'s exact check (or equivalently `PuzzleDefinition.forward_ray_cells`/`get_cell_owners`) — never an independent reimplementation of blocking (Implements: FR-004, FR-005) (code_ref: pending | knowledge_ref: pending)
- [ ] T007 [US1] Guard `depth`/`longest_chain` traversal against geometric dependency cycles (visited-path tracking, no unbounded recursion) in `scripts/puzzle/puzzle_analyzer.gd` (Implements: FR-004) (code_ref: pending | knowledge_ref: pending)
- [ ] T008 [US1] Implement `unlock_sequence`/`max_unlock_fan_out` in `scripts/puzzle/puzzle_analyzer.gd` by diffing the legal-arrow set immediately before/after each witness removal step (empirical, never derived from static `max_out_degree` per FR-005's explicit warning) (Implements: FR-006) (code_ref: pending | knowledge_ref: pending)
- [ ] T009 [US1] Implement `blocker_distance` (`max_distance, average_distance, edges` with 1-based ray-index distance) in `scripts/puzzle/puzzle_analyzer.gd`, computed at the initial state and labeled in a code comment as a geometric proxy, not a perceptual measurement (Implements: FR-007) (code_ref: pending | knowledge_ref: pending)
- [ ] T010 [US1] Implement the developer-only occupancy/grid visualization helper (`PuzzleAnalyzer.occupancy_grid(definition) -> Array[String]`, one row per board row using an occupied/empty marker) in `scripts/puzzle/puzzle_analyzer.gd`, kept separate from `PuzzleDefinition` and introducing no second authoring format (Implements: FR-019) (code_ref: pending | knowledge_ref: pending)
- [ ] T011 [US1] Wire the unsolvable-input path in `scripts/puzzle/puzzle_analyzer.gd`: when `PuzzleSolver.analyze(definition).solvable` is `false`, populate the static dependency-graph fields but leave `legal_choice_sequence`, `longest_forced_run`, `unlock_sequence`, and `max_unlock_fan_out` empty/zero per data-model.md's Unsolvable Input note (Implements: FR-008) (code_ref: pending | knowledge_ref: pending)

### Tests for User Story 1 (mandatory per FR-024, not optional)

- [ ] T012 [P] [US1] Add synthetic-puzzle cases to `tests/puzzle_analyzer_check.gd` for an independent/no-dependency puzzle and a simple two/three-arrow chain, asserting exact hand-computed `dependency_graph`/`legal_move_structure` values (Implements: FR-024) (code_ref: pending | knowledge_ref: pending)
- [ ] T013 [US1] Add synthetic-puzzle cases to `tests/puzzle_analyzer_check.gd` for a deep chain and a branching/open puzzle, asserting exact `depth`, `longest_chain`, `branching_state_count` values; **also add a multi-component case** — a board with two fully independent dependency chains (e.g. one two-arrow chain plus a separate, disconnected two-arrow chain, no edge between the two groups) — asserting the exact expected `dependency_graph.component_count` (2), distinct from and alongside `depth` (resolves: critic-004) (Implements: FR-005, FR-024) (code_ref: pending | knowledge_ref: pending)
- [ ] T014 [US1] Add a synthetic cascade puzzle (one removal unlocking exactly two others) and a multiple-blockers-on-one-arrow puzzle to `tests/puzzle_analyzer_check.gd`, asserting exact `max_unlock_fan_out`/`unlock_sequence` and `max_in_degree` values (Implements: FR-024) (code_ref: pending | knowledge_ref: pending)
- [ ] T015 [US1] Add a bent-arrow dependency puzzle (edge whose blocking cell is a tail cell) and a long-range-blocker puzzle to `tests/puzzle_analyzer_check.gd`, asserting exact `blocker_distance` values (Implements: FR-024) (code_ref: pending | knowledge_ref: pending)
- [ ] T016 [US1] Add invalid-input, valid-but-unsolvable (two-arrow cycle), determinism (two calls, deep-equal result), non-mutation (definition/gameplay-state/session-state unchanged), and **null-definition** (`analyze(null)` triggers the documented `assert(definition != null, ...)` precondition failure rather than returning a `valid: false`-shaped result — resolves: critic-005) assertions to `tests/puzzle_analyzer_check.gd`. **Also add the mixed acyclic+cyclic synthetic case** documented in data-model.md's "Depth / Longest-Chain Semantics" (three-arrow simple chain A→B→C plus a disconnected two-arrow cycle D↔E), asserting the exact expected `depth` (2), `longest_chain` (`[A, B, C]`), and `component_count` (2) — proving termination and the exact documented value, not just "does not hang" (resolves: critic-001) (Implements: FR-004, FR-008, FR-024) (code_ref: pending | knowledge_ref: pending)
- [ ] T017 [US1] Extend `tests/run_puzzle_regressions.py`'s `run_rule_regressions()` to copy `scripts/puzzle/puzzle_analyzer.gd` into the existing bare isolated temp project (alongside the files already copied for `puzzle_regression.gd`/`puzzle_catalog_check.gd`) and run `tests/puzzle_analyzer_check.gd`, requiring a new `PUZZLE_ANALYZER_FAILURES=0` marker. **After the full Spec 006 expansion is implemented** (14 catalog puzzles instead of 8, plus the new `puzzle_analyzer_check.gd` suite added to the same process step), **measure the actual wall-clock runtime** of `run_rule_regressions()` — do not assume the existing hardcoded `timeout=45` (seconds) constant still has headroom. If the measured runtime leaves less than roughly 50% headroom under 45s, increase the timeout constant with a generous multiplier over the measured value (e.g. ~2x measured runtime, not a value tuned tightly to one local measurement) so ordinary CI/environment variance (slower disk, cold cache, a loaded CI runner) doesn't turn timing margin into a flaky failure (resolves: critic-002) (Implements: FR-024) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: `PuzzleAnalyzer` is fully implemented, unit-tested, and gated in
`run_puzzle_regressions.py` — independently verifiable via T001's baseline commands re-run with
the new marker present.

---

## Phase 4: User Story 2 - Play six new experiments that combine what the old eight never did (Priority: P1)

**Goal**: Six new `PuzzleCatalog` entries (8 → 14), each satisfying at least one named experiment
(Nested Chain, Cascade/Key Arrow, Dense Unravel, Bent Network, Long-Range Blocker,
Composed/Shaped), confirmed via `PuzzleAnalyzer` output and the extended catalog regression gate.

**Independent Test**: Play each of the six new puzzles start to finish through the existing puzzle
scene; confirm each is completable with the existing rules, and confirm via `PuzzleAnalyzer`'s own
output that each puzzle's defining structural claim actually holds (spec User Story 2's own
Independent Test).

**Depends on**: Phase 3 (US1) — the "verify property" tasks below call `PuzzleAnalyzer`, so they
cannot complete until T002–T011 exist; the six puzzles' *authoring* (geometry only) may proceed in
parallel with US1 since it edits a different file (`puzzle_catalog.gd`), but is listed after US1
here for a clean single-threaded execution order. **Exception**: unlike T018–T022, **T023
specifically depends on T010** (`PuzzleAnalyzer.occupancy_grid()`) being complete first, since its
own description instructs verifying the macro shape visually through that helper — it is not part
of the general "authoring may run alongside Phase 3" claim above.

### Implementation for User Story 2

- [ ] T018 [P] [US2] Author the "Nested Chain" `PuzzleCatalog` entry (new `_build_*` literal builder + catalog registration) in `scripts/puzzle/puzzle_catalog.gd`: a multi-step dependency chain spatially distributed across board regions with bends and cross-region blockers (Implements: FR-013) (code_ref: pending | knowledge_ref: pending)
- [ ] T019 [US2] Author the "Cascade / Key Arrow" entry in `scripts/puzzle/puzzle_catalog.gd`: a single removal that drops two or more other arrows' blockers simultaneously (Implements: FR-014) (code_ref: pending | knowledge_ref: pending)
- [ ] T020 [US2] Author the "Dense Unravel" entry in `scripts/puzzle/puzzle_catalog.gd`: target `board.density >= 0.55` and `legal_move_structure.initial_legal_ratio <= 0.50` per data-model.md's Operational Acceptance Thresholds (FR-015), explicitly not an "almost-all-legal" dense board like the existing `dense_board` puzzle (Implements: FR-015) (code_ref: pending | knowledge_ref: pending)
- [ ] T021 [US2] Author the "Bent Network" entry in `scripts/puzzle/puzzle_catalog.gd`: multiple bent arrows where at least one dependency edge's blocking cell is a bent arrow's tail cell (Implements: FR-016) (code_ref: pending | knowledge_ref: pending)
- [ ] T022 [US2] Author the "Long-Range Blocker" entry in `scripts/puzzle/puzzle_catalog.gd`: target at least one `blocker_distance.edges[].distance >= 4` on a board with `width >= 5` or `height >= 5` along the relevant axis per data-model.md's Operational Acceptance Thresholds (FR-017), preferably belonging to a multi-cell arrow (Implements: FR-017) (code_ref: pending | knowledge_ref: pending)
- [ ] T023 [US2] (depends on: T010, resolves: analyze-003) Author the "Composed / Shaped" entry in `scripts/puzzle/puzzle_catalog.gd`: a board of at least `board.total_cells >= 49` (7x7) whose occupied cells form a recognizable macro shape (verify visually via T010's `occupancy_grid` helper, which MUST exist before this task can complete) while its arrows still form at least one genuine dependency edge (Implements: FR-018) (code_ref: pending | knowledge_ref: pending)
- [ ] T024 [US2] Register all six new entries in `PuzzleCatalog._ensure_entries()` in `scripts/puzzle/puzzle_catalog.gd` with stable ids independent of array position/title, bringing the catalog to 14 entries (Implements: FR-012) (code_ref: pending | knowledge_ref: pending)

### Verification for User Story 2

- [ ] T025 [US2] For each of the six new entries, run `PuzzleAnalyzer.analyze()` and confirm it meets its entry's named property against the exact numeric thresholds in data-model.md's **Operational Acceptance Thresholds** subsection (Nested Chain: `dependency_graph.depth >= 3` and a non-collinear `longest_chain`; Cascade: `max_unlock_fan_out >= 2`; Dense Unravel: `density >= 0.55` and `initial_legal_ratio <= 0.50`; Bent Network: a dependency edge involving a bent arrow's tail cell; Long-Range Blocker: `blocker_distance.edges[].distance >= 4` on a `>= 5`-wide/tall board; Composed/Shaped: `board.total_cells >= 49` and `edge_count >= 1`); revise the puzzle's geometry in `scripts/puzzle/puzzle_catalog.gd` and re-check if any threshold is not met, per spec's Edge Cases (do not ship a mislabeled experiment) (Implements: FR-013, FR-014, FR-015, FR-016, FR-017, FR-018) (code_ref: pending | knowledge_ref: pending)
- [ ] T026 [US2] Extend `tests/puzzle_catalog_check.gd`'s `_check_full_catalog_solvable()`-style coverage to assert the catalog contains exactly 14 entries, all unique-id/valid/solver-confirmed-solvable/zero-mistake-witness (existing coverage generalized from 8 to 14, not duplicated) (Implements: FR-020) (code_ref: pending | knowledge_ref: pending)
- [ ] T027 [US2] Add per-experiment structural assertions for the six new entries to `tests/puzzle_catalog_check.gd`, calling `PuzzleAnalyzer.analyze()` on each and asserting the same exact numeric thresholds from data-model.md's Operational Acceptance Thresholds verified manually in T025, so the property check is enforced automatically on every future regression run, not only during authoring (Implements: FR-013, FR-014, FR-015, FR-016, FR-017, FR-018) (code_ref: pending | knowledge_ref: pending)
- [ ] T028 [US2] Godot validation of `scripts/puzzle/puzzle_catalog.gd` (`--headless --editor --quit`) and a desktop smoke test playing all six new puzzles start-to-finish via Level Select, confirming continuous-arrow rendering and path-following departure behave correctly on the new geometry and that Level Select/keyboard/gamepad navigation still work at 14 entries (constitution Principles III, V) (Implements: FR-024) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: All 14 catalog puzzles are solver-confirmed solvable and gated; all six new
puzzles are confirmed (by `PuzzleAnalyzer`, not just claimed) to satisfy their named experiment;
playable end-to-end through existing navigation.

---

## Phase 5: User Story 3 - Compare puzzles and record what actually felt interesting (Priority: P2)

**Goal**: A deterministic developer-facing structural comparison report across all 14 puzzles, and
a completed human-calibration bundle (records + findings summary) for the six new puzzles.

**Independent Test**: Run the developer report against the full 14-puzzle catalog and confirm it
answers all nine FR-021 comparison questions; play each of the six new puzzles once and fill out
the calibration worksheet for each (spec User Story 3's own Independent Test).

**Depends on**: Phase 3 (US1, for `PuzzleAnalyzer`) and Phase 4 (US2, for the full 14-puzzle
catalog and playable content to calibrate against).

### Implementation for User Story 3

- [ ] T029 [US3] Create `tests/puzzle_structural_report.gd` (`extends SceneTree`, no `check()`/failure counter): enumerate `PuzzleCatalog` in order, call `PuzzleAnalyzer.analyze()` per entry, and print the per-puzzle block and the nine-question Catalog Comparison section exactly per [contracts/developer-report-format.md](contracts/developer-report-format.md) (Implements: FR-021) (code_ref: pending | knowledge_ref: pending)
- [ ] T030 [US3] Create `tests/run_puzzle_structural_report.py`: a small, non-gating launcher (no `PUZZLE_*_FAILURES` marker) that runs `puzzle_structural_report.gd` in the same bare isolated project pattern as the other launchers and prints its output (Implements: FR-021) (code_ref: pending | knowledge_ref: pending)
- [ ] T031 [US3] Run `python tests/run_puzzle_structural_report.py --godot <executable>` twice and confirm byte-identical output (modulo the Godot engine banner), confirming determinism and that no difficulty label/tier/composite score line appears (Implements: FR-021, FR-009) (code_ref: pending | knowledge_ref: pending)
- [ ] T032 [US3] Play each of the six new puzzles once via Level Select and fill out one [calibration/worksheet-template.md](calibration/worksheet-template.md) block per puzzle into [calibration/records.md](calibration/records.md), recording actual play results (score/mistakes/accuracy) plus human observations — never backfilled from `PuzzleAnalyzer` output (Implements: FR-022) (code_ref: pending | knowledge_ref: pending)
- [ ] T033 [US3] Once all six records exist, write [calibration/findings-summary.md](calibration/findings-summary.md): a Supported/Contradicted/Inconclusive verdict per named experiment against its targeted hypothesis, plus a closing list of characteristics for further investigation — no composite score, no generator design (Implements: FR-026) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: A developer can answer all nine FR-021 comparison questions from the report alone;
all six calibration records and the findings summary are complete.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final verification, negative-requirement checks, and durable-knowledge updates that
span all three stories.

- [ ] T034 Re-run `python tests/run_puzzle_regressions.py --godot <executable>` and `python tests/run_regressions.py --godot <executable>` end-to-end and confirm all markers pass, including the new `PUZZLE_ANALYZER_FAILURES=0`, alongside every pre-existing marker unchanged in meaning (Implements: FR-024) (code_ref: pending | knowledge_ref: pending)
- [ ] T035 Verify by inspection (not new code) that no composite difficulty score/formula, player-facing difficulty rating, or Easy/Medium/Hard-style label exists anywhere in `scripts/puzzle/puzzle_analyzer.gd`, `scripts/puzzle/puzzle_catalog.gd`, or the developer report output, and that `PuzzleSolver`'s existing return contract/metrics are byte-for-byte unchanged; record this check explicitly in `gates/verification.md` (Implements: FR-009, FR-010, FR-011, FR-023) (code_ref: pending | knowledge_ref: pending)
- [ ] T036 [P] Update `.knowledge/architecture/arrow-puzzle.md` to describe `PuzzleAnalyzer`'s boundaries and exact metric definitions, the dependency-graph orientation/interpretation (including the depth/longest_chain simple-path semantics for cyclic candidate graphs), the distinction between objective metrics and explicitly-labeled perceptual hypotheses (dependency discoverability, false affordance, unlock rhythm, reasoning span, composition), and the enlarged 14-puzzle catalog — without any backlink to this spec/plan/tasks. **Also update this same file's `appliesTo:` frontmatter array** to add the four new/changed files this feature introduces: `scripts/puzzle/puzzle_analyzer.gd`, `tests/puzzle_analyzer_check.gd`, `tests/puzzle_structural_report.gd`, `tests/run_puzzle_structural_report.py` (resolves: analyze-004) (Implements: FR-025) (code_ref: pending | knowledge_ref: pending)
- [ ] T037 Run `python .devspark/scripts/build_knowledge_index.py --repo-root . --check` and resolve any reported gap introduced by T036's edit (code_ref: pending | knowledge_ref: pending)
- [ ] T038 [P] Update `tests/README.md`'s "Arrow Puzzle Regression Checks" section: change "Enumerates all 8 authored catalog entries" to 14, and its "runs five independent headless checks" enumeration to add the sixth (`tests/puzzle_analyzer_check.gd`'s synthetic-puzzle suite, `PUZZLE_ANALYZER_FAILURES=0`), plus a short mention of the separate non-gating `tests/run_puzzle_structural_report.py` developer report launcher so neither hardcoded figure goes stale on merge (resolves: critic-003) (code_ref: pending | knowledge_ref: pending)
- [ ] T039 Run [quickstart.md](quickstart.md) end-to-end and record commands, engine/version, markers, puzzle IDs exercised, and any outstanding/disclosed-not-skipped checks in `gates/verification.md` (code_ref: pending | knowledge_ref: pending)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Empty by design (see Phase 2 note) — proceed directly to Phase 3.
- **User Story 1 (Phase 3)**: Depends on Setup only. **Blocks** User Stories 2 and 3 (both need `PuzzleAnalyzer` to verify their work).
- **User Story 2 (Phase 4)**: Puzzle *authoring* (T018–T024) needs only Setup and can proceed alongside Phase 3; *verification* (T025–T028) needs Phase 3 complete.
- **User Story 3 (Phase 5)**: Needs Phase 3 (`PuzzleAnalyzer`) and Phase 4 (the full 14-entry catalog and playable content) complete.
- **Polish (Phase 6)**: Depends on Phases 3–5 all complete.

### Parallel Opportunities

- T018–T023 (the six puzzle-authoring tasks) are all in the same file (`puzzle_catalog.gd`) and so are sequential relative to each other, but as a group may proceed in parallel with Phase 3's analyzer-implementation tasks (different file) if staffed separately — held sequential-after here for a clean single-agent execution order.
- T012–T016 (analyzer synthetic tests) are grouped by scenario but all edit `tests/puzzle_analyzer_check.gd`, so are sequential relative to each other despite the `[P]` marker on T012 only denoting no dependency on an *incomplete implementation task* at that point in the sequence.
- T036 (`knowledge` update) and T038 (`tests/README.md` update) can proceed in parallel with each other and with T037/T039 once T034–T035 confirm the implementation is complete and correct.

---

## Gate Acknowledgements

None outstanding. The initial `/devspark.analyze` + `/devspark.critic` FULL run (against the
first-draft plan.md/tasks.md) surfaced 9 findings (1 CRITICAL from analyze, 2 CRITICAL + 1 HIGH +
2 MEDIUM + 1 LOW from critic, plus 2 more MEDIUM/LOW from analyze). A gate remediation pass
addressed all 9 directly in plan.md, data-model.md, contracts/, and this file (no product-scope
change, no new features/metrics):

| Finding | Resolution |
| --- | --- |
| analyze-001 (CRITICAL) | plan.md Context Resolution ids corrected to bare frontmatter ids `arrow-puzzle`/`arrowgame-constitution` |
| critic-001 (CRITICAL) | data-model.md now precisely defines `depth`/`longest_chain` as the longest *simple* directed path (deterministic tie-break, finite even for cycles); T016 adds the exact-value cyclic test |
| critic-002 (CRITICAL) | T017 now requires measuring actual post-expansion runtime and sizing the timeout with generous margin rather than assuming the existing 45s constant holds |
| critic-003 (HIGH) | New T038 updates `tests/README.md`'s hardcoded 8-entry/five-check figures |
| analyze-002 (MEDIUM) | data-model.md's new "Operational Acceptance Thresholds" subsection gives FR-015/017/018 exact numeric criteria; T020/T022/T025/T027 reference them (spec.md's product wording is unchanged) |
| analyze-003 (MEDIUM) | Phase 4's Dependencies note and T023 itself now state T023's specific dependency on T010 |
| critic-004 (MEDIUM) | T013 extended with a multi-component synthetic case asserting exact `component_count` |
| analyze-004 (LOW) | T036 now explicitly includes updating arrow-puzzle.md's `appliesTo:` frontmatter |
| critic-005 (LOW) | data-model.md/contracts/puzzle-analyzer-api.md now define the null-`definition` caller contract (assertion, matching `PuzzleState._init`'s style); T016 tests it |

The requirements checklist (`checklists/requirements.md`) passed 21/21 at generation time and is
unaffected by this remediation (no spec.md change). See `gates/analyze.md`/`gates/critic.md` for
the re-run confirming no CRITICAL findings remain.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup).
2. Complete Phase 3 (User Story 1 — `PuzzleAnalyzer`, fully unit-tested and gated).
3. **STOP and VALIDATE**: `PuzzleAnalyzer` is independently useful evidence-gathering
   infrastructure even before any new puzzle exists — it can already be run against the eight
   existing catalog puzzles.

### Incremental Delivery

1. Setup → Phase 3 (US1) → validate independently (MVP).
2. Add Phase 4 (US2) → six new playable puzzles, each analyzer-confirmed → validate independently.
3. Add Phase 5 (US3) → developer report + human calibration + findings summary → validate.
4. Phase 6 (Polish) → full regression re-run, negative-requirement check, durable knowledge update.

---

## Notes

- `[P]` tasks touch different files with no dependency on an incomplete task; most of this
  feature's work concentrates in a small number of shared files (`puzzle_analyzer.gd`,
  `puzzle_catalog.gd`, `puzzle_analyzer_check.gd`, `puzzle_catalog_check.gd`), so `[P]` is used
  sparingly and honestly rather than marking same-file edits as parallel-safe.
- Every task's `code_ref`/`knowledge_ref` starts `pending`; `/devspark.implement` fills them in as
  each task completes.
- Commit after each task or logical group (per existing repo practice from specs 001–005).
- Stop at each phase checkpoint to validate that story's independent test before continuing.
