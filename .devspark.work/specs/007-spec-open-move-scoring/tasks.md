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

# Tasks: Core Gameplay Contract, Open Move Assistance, and Session Scoring

**Input**: Design documents from `.devspark.work/specs/007-spec-open-move-scoring/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all present)

**Verification**: Constitution-mandated checks are required for every phase below: Godot
headless validation (`--headless --editor --quit`), the two existing regression gates
(`python tests/run_puzzle_regressions.py --godot <godot>` and
`python tests/run_regressions.py --godot <godot>`), and a desktop smoke test covering
affected gameplay, input/navigation, and save/settings compatibility (constitution
Principle V). Automated tests below are added where they provide real regression
protection for this change, not as a blanket requirement for every function.

**Organization**: Tasks are grouped by user story (spec.md's priorities) to enable
independent implementation and testing of each story.

## Rationale Summary

### Core Problem

The spec establishes ArrowSpark's basic player contract (mistakes cost score not play,
an Open Move assist when stuck, session-only score memory) but none of the Open Move
assist, extended scoring, or session-best/overall-score tracking exist in code yet, and
the "every unfinished state has a legal move" invariant needs stronger automated proof
than today's single hand-built case.

### Decision Summary

Extend the existing `PuzzleState` rules authority in place (Foundational phase), then
build each user story on top of it independently: US1 hardens/proves the existing
no-fail-state guarantee, US2 adds the Open Move control, US3 extends the Results
display, and US4 adds session-best/overall-score tracking via one new sibling static
class (`PuzzleScoreboard`).

### Key Drivers

- Spec's explicit constraint against a second rules engine or duplicated blocking logic.
- Constitution Principle III (keyboard/gamepad accessibility) and Principle VI
  (zero new persistence) apply directly to US2 and US4 respectively.
- research.md's monotonicity-based strategy for FR-017/SC-001 replaces exhaustive
  reachable-state enumeration with a bounded, targeted extension of an existing check.

### Reviewer Guidance

Confirm the Foundational phase (T002-T005) introduces no duplicated blocking logic;
confirm US2's Open Move control (T013-T017) is genuinely keyboard/gamepad reachable in
the real scene, not just logically wired; confirm US4's `PuzzleScoreboard` (T024-T031)
never touches `GlobalState`/`GameState`/`user://`; confirm every `FR-###` below is
implemented, not just referenced.

## Format: `[ID] [P?] [Story] Description (Implements: FR-###[, FR-###])`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1-US4, per spec.md)
- **Implements**: Names the functional requirement ID(s) from spec.md this task satisfies.
- **Linkage**: Every task ends with `(code_ref: pending | knowledge_ref: pending)`. `/devspark.implement` fills these with real paths (or `n/a` + reason) as each task completes.

## Path Conventions

Single existing Godot project — `scripts/`, `scenes/`, `tests/` at repository root, per
plan.md's Project Structure. No `src/`/`backend/`/`frontend/` split applies.

---

## Phase 1: Setup

**Purpose**: Confirm a clean starting baseline before making any change.

- [X] T001 Run the existing baseline regression suites (`python tests/run_puzzle_regressions.py --godot <godot>` and `python tests/run_regressions.py --godot <godot>`) and confirm both currently pass with zero failures before any change in this feature begins (code_ref: n/a — verification only, no code changed | knowledge_ref: n/a — verification only, no code changed)

**Checkpoint**: Phase complete — 2026-09-27

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: `PuzzleState` extensions every downstream user story depends on, plus the
durable product-contract documentation the spec explicitly requires.

**⚠️ CRITICAL**: No user story work below can begin until this phase is complete.

- [X] T002 [P] Add `open_move_assists: int = 0`, `find_open_move() -> Variant`, and `request_open_move() -> Variant` to `scripts/puzzle/puzzle_state.gd`, reusing the existing `_is_head_blocked`/`_active_arrows` (y, x)-ascending ordering with zero duplicated blocking logic; `request_open_move()` never increments `total_taps` (Implements: FR-003, FR-004, FR-005, FR-006, FR-007, FR-020, FR-021) (code_ref: scripts/puzzle/puzzle_state.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T003 Update `PuzzleState.get_results()` in `scripts/puzzle/puzzle_state.gd` to add `open_move_assists` to the returned dictionary and compute `score = max(total_arrows - (mistakes + open_move_assists * 5), 0)` (depends on T002) (Implements: FR-008, FR-009) (code_ref: scripts/puzzle/puzzle_state.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T004 [P] Create `.knowledge/product/gameplay-contract.md` (type: authoritative-reference — see plan.md Implementation Notes; `"product"` is not in the knowledge-index builder's current `ALLOWED_TYPES`) documenting the durable behavioral contract: mistakes cost score not play, hard-is-good/unsolvable-is-not, the session as the sole gameplay-memory boundary, and replay-improves-session-best; set its `appliesTo` frontmatter to at least `scripts/puzzle/puzzle_state.gd`, `scripts/puzzle_scoreboard.gd`, `scenes/puzzle/puzzle_results.gd`, `scenes/puzzle/puzzle_results.tscn` so it is discoverable from every file this contract governs (Implements: FR-001, FR-002, FR-010, FR-011, FR-012, FR-013, FR-014, FR-015, FR-016, FR-019) (code_ref: n/a — knowledge-only task | knowledge_ref: .knowledge/product/gameplay-contract.md)
- [X] T005 Extend `.knowledge/architecture/arrow-puzzle.md`'s Rule Layer section to document the new `PuzzleState` members and the revised `get_results()` formula (depends on T002, T003) (Implements: FR-003, FR-004, FR-005, FR-006, FR-007, FR-008, FR-009) (code_ref: n/a — knowledge-only task | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

**Checkpoint**: Phase complete — 2026-09-27. Foundation ready — every user story below can now proceed.

---

## Phase 3: User Story 1 - Mistakes never block completion (Priority: P1) 🎯 MVP

**Goal**: Prove and protect, with expanded automated coverage, that blocked attempts
never remove the arrow, never end the attempt, and never impose a limit — and that
every catalog puzzle's unfinished reachable states always have a legal move.

**Independent Test**: Run the extended regression/catalog checks below, then manually
click a blocked arrow repeatedly on several catalog puzzles and confirm each still
completes normally.

### Tests for User Story 1

- [X] T006 [P] [US1] Extend `tests/puzzle_regression.gd`'s order-independence check to force each alternative legal choice at every branching state along a witness walk (not only the existing single two-arrow case), asserting the resulting state remains solvable (Implements: FR-017) (code_ref: tests/puzzle_regression.gd | knowledge_ref: n/a — test-only, no behavior/documentation change)
- [X] T007 [P] [US1] Extend `tests/puzzle_catalog_check.gd` to run the T006 branching-state check across all fourteen catalog puzzles' witnesses, confirming "every unfinished state reached through legal play has ≥1 legal move" for each (Implements: FR-017) (code_ref: tests/puzzle_catalog_check.gd | knowledge_ref: n/a — test-only, no behavior/documentation change)
- [X] T008 [P] [US1] Add a `tests/puzzle_regression.gd` assertion that a long run of consecutive blocked selections (extending the existing 100-consecutive-blocked case) still allows full completion afterward, unaffected by T002/T003's additions (Implements: FR-001, FR-002) (code_ref: tests/puzzle_regression.gd | knowledge_ref: n/a — test-only, no behavior/documentation change)

### Implementation for User Story 1

- [ ] T009 [US1] Manual smoke test: repeatedly select a blocked arrow across at least three catalog puzzles of varying size, confirm no forced restart/limit occurs, then complete each puzzle; record results per constitution Principle V (Implements: FR-001, FR-002) (code_ref: pending | knowledge_ref: pending) <!-- WIP: requires an interactive desktop session; cannot be performed by the implementing agent. Left for human execution per quickstart.md. -->

**Checkpoint**: US1 automated coverage complete (T006-T008); T009 (manual smoke test)
requires a human desktop session and is intentionally left open — see Final Report.

---

## Phase 4: User Story 2 - Show Me an Open Move (Priority: P1) 🎯 MVP

**Goal**: A player-triggered, keyboard/gamepad-accessible action that visually
identifies exactly one currently legal arrow without removing it or revealing more.

**Independent Test**: Trigger the control via mouse, keyboard, and gamepad on an
in-progress puzzle; confirm one arrow is indicated, no arrow is removed automatically,
and a repeated request (no intervening move) indicates the same arrow again.

### Tests for User Story 2

- [X] T010 [P] [US2] Add `tests/puzzle_regression.gd` cases for `find_open_move()`/`request_open_move()`: deterministic same-arrow-on-repeat, a forced-state (single-legal-arrow) case, independent mistake/assist counters, a case reaching 100% accuracy alongside a nonzero assist count, and — mirroring `select_arrow()`'s existing completed-state coverage — a case calling both methods after `completed` is already true, asserting both return `null` and `open_move_assists` is unchanged (Implements: FR-003, FR-005, FR-006, FR-020) (code_ref: tests/puzzle_regression.gd | knowledge_ref: n/a — test-only, no behavior/documentation change)
- [X] T011 [P] [US2] Add a `tests/puzzle_layout_check.gd` case driving the real scene: trigger the Open Move control while an earlier removal's departure animation is still in flight, confirming an immediate response against the current logical state with no suppression or queuing (Implements: FR-021) (code_ref: tests/puzzle_layout_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T012 [P] [US2] Add a `tests/puzzle_layout_check.gd` case confirming the new Open Move control is reachable via keyboard/gamepad focus (deterministic focus-state + signal-wiring check; see plan.md Implementation Notes for why literal simulated key/gamepad event dispatch was dropped as nondeterministic in this headless environment) (Implements: FR-018) (code_ref: tests/puzzle_layout_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

### Implementation for User Story 2

- [X] T013 [US2] Add a focusable `%OpenMoveButton` to `scenes/puzzle/arrow_puzzle.tscn`'s HUD row (`HUDMargin`), styled per existing HUD button conventions (Implements: FR-003, FR-018) (code_ref: scenes/puzzle/arrow_puzzle.tscn | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T014 [US2] Add an Open Move handler in `scenes/puzzle/arrow_puzzle.gd` that calls `_state.request_open_move()` on button press and, on a non-null result, passes the returned head to a new `PuzzleBoard` suggestion method; never gated on `_pending_departures` (depends on T002, T013) (Implements: FR-003, FR-007, FR-021) (code_ref: scenes/puzzle/arrow_puzzle.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T015 [US2] Add a `suggest_open_move(head)` method and a new "suggested" presentation precedence tier (`departing > blocked > suggested > hover > normal`) to `scenes/puzzle/puzzle_board.gd`/`scenes/puzzle/arrow_view.gd`, reusing the existing ember (`arrow_hover`) accent token; clear the suggestion on any accepted selection (played or blocked) or a fresh attempt — see plan.md Implementation Notes for why "clear on hover" was dropped as unnecessary (depends on T014) (Implements: FR-003) (code_ref: scenes/puzzle/puzzle_board.gd, scenes/puzzle/arrow_view.gd, scenes/puzzle/arrow_puzzle.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T016 [US2] Extend `.knowledge/architecture/arrow-puzzle.md`'s Presentation Layer / Feedback precedence section to document the new "suggested" tier and its clearing rules (depends on T015) (Implements: FR-003) (code_ref: n/a — knowledge-only task | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [ ] T017 [US2] Manual smoke test: trigger Show Me an Open Move via mouse, keyboard, and gamepad on multiple catalog puzzles including a forced-state puzzle; confirm exactly one arrow is indicated, no auto-removal occurs, and repeated requests are consistent (Implements: FR-003, FR-005, FR-007, FR-018) (code_ref: pending | knowledge_ref: pending) <!-- WIP: requires an interactive desktop session; cannot be performed by the implementing agent. Left for human execution per quickstart.md. -->

**Checkpoint**: US2 automated coverage complete (T010-T016); T017 (manual smoke test)
requires a human desktop session and is intentionally left open — see Final Report.

---

## Phase 5: User Story 3 - Understandable attempt results (Priority: P2)

**Goal**: The Results screen shows total arrows, mistakes, open-move assists, score,
and accuracy as five distinct, consistent values.

**Independent Test**: Complete a puzzle with a mix of mistakes and Open Move uses;
confirm all five values are shown and match `get_results()`'s output by hand.

### Tests for User Story 3

- [X] T018 [P] [US3] Add `tests/puzzle_regression.gd` cases asserting `get_results()`'s new dictionary shape and score formula across representative mistake/assist combinations, including the zero-mistake/zero-assist perfect case and a case reaching the zero floor (Implements: FR-008, FR-009) (code_ref: tests/puzzle_regression.gd | knowledge_ref: n/a — test-only, no behavior/documentation change)
- [X] T019 [P] [US3] Add a `tests/puzzle_layout_check.gd` case completing a real-scene puzzle with a mix of mistakes and Open Move uses, confirming the Results screen displays all five values consistent with `get_results()` (Implements: FR-009) (code_ref: tests/puzzle_layout_check.gd | knowledge_ref: n/a — test-only, no behavior/documentation change)

### Implementation for User Story 3

- [X] T020 [US3] Add an assist-count label (e.g. `%OpenMoveAssistsLabel`) to `scenes/puzzle/puzzle_results.tscn` beside the existing four metric labels (Implements: FR-009) (code_ref: scenes/puzzle/puzzle_results.tscn | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T021 [US3] Extend `scenes/puzzle/puzzle_results.gd`'s `show_results()` to accept and display the `open_move_assists` value from the results dictionary (depends on T003, T020) (Implements: FR-009) (code_ref: scenes/puzzle/puzzle_results.gd, tests/puzzle_presentation_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md) — also required a fix to tests/puzzle_presentation_check.gd's pre-existing raw results-dict fixture (missing the new key) and extended its resize/bounds loop to cover the new label
- [X] T022 [US3] Update `.knowledge/architecture/arrow-puzzle.md`'s Presentation Layer description of `puzzle_results.gd`'s displayed fields to include the new assist count (depends on T021) (Implements: FR-009) (code_ref: n/a — knowledge-only task | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [ ] T023 [US3] Manual smoke test: complete puzzles with zero mistakes/assists, and with a mix of both, confirming the Results screen's five values are legible and match hand-computed expectations (Implements: FR-008, FR-009) (code_ref: pending | knowledge_ref: pending) <!-- WIP: requires an interactive desktop session; cannot be performed by the implementing agent. Left for human execution per quickstart.md. -->

**Checkpoint**: US3 automated coverage complete (T018-T022); T023 (manual smoke test)
requires a human desktop session and is intentionally left open — see Final Report.

---

## Phase 6: User Story 4 - Replay to improve this session's best score (Priority: P2)

**Goal**: Session-scoped best score per puzzle, a derived overall session score, and a
Results-screen comparison (established/improved/tied/not improved).

**Independent Test**: Complete a puzzle, note its session-best and overall score,
replay it worse (unchanged), better (both increase by the improvement), and tied
(unchanged); confirm a fresh session starts with nothing remembered.

### Tests for User Story 4

- [X] T024 [P] [US4] Create `tests/puzzle_scoreboard_check.gd` unit-checking `PuzzleScoreboard.record_attempt`/`get_best`/`get_overall_score`: established/improved/tied/not-improved outcomes, overall-score summation, a never-completed puzzle contributing zero, and independence from `PuzzleSession`. `PuzzleScoreboard`'s static `_best_results` persists for the whole process this check file runs in and exposes no reset method by design (see contracts/puzzle-state-and-scoreboard.md) — give every test case its own distinct, synthetic `puzzle_id` string (never a real `PuzzleCatalog` id) so no case's assertions can be affected by state an earlier case in this same file left behind (Implements: FR-011, FR-012, FR-013, FR-014) (code_ref: tests/puzzle_scoreboard_check.gd, tests/run_puzzle_regressions.py | knowledge_ref: n/a — test-only, no behavior/documentation change)
- [X] T025 [P] [US4] Add a `tests/puzzle_layout_check.gd` case driving a real replay (via `SceneLoader.reload_current_scene()`) confirming a fresh attempt's `mistakes`/`open_move_assists`/`score` reset to zero regardless of the prior attempt's values (Implements: FR-010) (code_ref: tests/puzzle_layout_check.gd | knowledge_ref: n/a — test-only, no behavior/documentation change)
- [X] T026 [P] [US4] Add a `tests/save_input_regression.gd` case (isolated project, matching its existing no-reset-on-puzzle-entry pattern) confirming `PuzzleScoreboard` never reads/writes `GlobalState`, `GameState`, or `user://global_state.tres`, and that a freshly started test process begins with zero session-best entries and zero overall score (Implements: FR-015, FR-016) (code_ref: tests/save_input_regression.gd, tests/run_regressions.py | knowledge_ref: n/a — test-only, no behavior/documentation change)

### Implementation for User Story 4

- [X] T027 [US4] Create `scripts/puzzle_scoreboard.gd` (`PuzzleScoreboard` class) per `contracts/puzzle-state-and-scoreboard.md`: a static `_best_results` Dictionary plus `record_attempt`, `get_best`, and `get_overall_score`. `record_attempt` MUST assert its `result` argument has the five expected keys (`total_arrows`, `mistakes`, `open_move_assists`, `score`, `accuracy`) and that `score` is a nonnegative int no greater than `total_arrows`, matching this codebase's existing precondition-assert style (`PuzzleState._init()`'s `assert(definition.is_valid(), ...)`); this is a shape/range sanity check on the contract only — it MUST NOT re-derive or re-validate whether the attempt is actually completed, recompute the score formula, or otherwise duplicate `PuzzleState`'s scoring/completion authority (Implements: FR-011, FR-012, FR-014, FR-015, FR-016) (code_ref: scripts/puzzle_scoreboard.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T028 [US4] In `scenes/puzzle/arrow_puzzle.gd`'s `_show_results()`, call `PuzzleScoreboard.record_attempt(PuzzleSession.get_current_id(), _state.get_results())` and pass its outcome plus `PuzzleScoreboard.get_overall_score()` into `_results.show_results(...)` (depends on T027) (Implements: FR-013, FR-014) (code_ref: scenes/puzzle/arrow_puzzle.gd, tests/puzzle_layout_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md) — verified with a new end-to-end real-scene test (established/improved/tied/not_improved + overall score) added alongside; see plan.md Implementation Notes for a test-ordering bug (viewport never sized) found and fixed during that verification
- [X] T029 [US4] Add a comparison label (established/improved/tied/not improved) and an overall-session-score label to `scenes/puzzle/puzzle_results.tscn`, kept to one short line each per the spec's "no progression dashboard" constraint (Implements: FR-013, FR-014) (code_ref: scenes/puzzle/puzzle_results.tscn | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T030 [US4] Extend `scenes/puzzle/puzzle_results.gd`'s `show_results()` to accept and display the comparison outcome and overall session score (depends on T028, T029) (Implements: FR-013, FR-014) (code_ref: scenes/puzzle/puzzle_results.gd, tests/puzzle_presentation_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [X] T031 [US4] Add a new "Open Move Assistance and Session Scoring" section to `.knowledge/architecture/arrow-puzzle.md` documenting `PuzzleScoreboard`'s contract, its independence from `PuzzleSession`, and the Results-screen comparison/overall-score display, cross-referencing `.knowledge/product/gameplay-contract.md`; add `scripts/puzzle_scoreboard.gd` and `tests/puzzle_scoreboard_check.gd` to this document's existing `appliesTo` frontmatter list (depends on T027, T030) (Implements: FR-010, FR-011, FR-012, FR-013, FR-014, FR-015, FR-016) (code_ref: n/a — knowledge-only task | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)
- [ ] T032 [US4] Manual smoke test: complete a puzzle, note session-best/overall score; replay worse (unchanged), better (both increase by exactly the improvement), and tied (unchanged); fully relaunch the application and confirm no prior session-best/overall score remains (Implements: FR-010, FR-011, FR-012, FR-013, FR-014, FR-016) (code_ref: pending | knowledge_ref: pending) <!-- WIP: requires an interactive desktop session; cannot be performed by the implementing agent. Left for human execution per quickstart.md. -->

**Checkpoint**: US4 automated coverage complete (T024-T031); T032 (manual smoke test)
requires a human desktop session and is intentionally left open — see Final Report.

---

## Final Phase: Polish & Verification

**Purpose**: Cross-cutting confirmation that no scope creep occurred and every gate
required by the constitution and spec has actually been run.

- [X] T033 [P] Manual/documentation check confirming no lives, fail states, forced restarts, timers, waiting mechanics, or monetization were introduced anywhere in this feature's UI/code (Implements: FR-019) (code_ref: n/a — verification only, confirms absence rather than changing code | knowledge_ref: n/a — verification only) — verified via full diff review and targeted grep across all changed production files (scenes/puzzle/*.gd, scenes/puzzle/*.tscn, scripts/puzzle/puzzle_state.gd, scripts/puzzle_scoreboard.gd) for lives/fail-state/game-over/forced-restart/timer/wait/monetization/ad/pay-or-watch-to-continue patterns and for any mistake/attempt limit; zero matches beyond the pre-existing, unrelated `BLOCKED` outcome enum and the `max()` score-floor math function
- [X] T034 Run the full regression suites (`python tests/run_puzzle_regressions.py --godot <godot>` and `python tests/run_regressions.py --godot <godot>`) plus Godot headless validation (`--headless --editor --quit`), confirming all existing and new checks pass with zero failures (code_ref: n/a — verification only | knowledge_ref: n/a — verification only) — all 6 puzzle-suite markers (PUZZLE_FAILURES, PUZZLE_ANALYZER_FAILURES, PUZZLE_CATALOG_FAILURES, PUZZLE_SCOREBOARD_FAILURES, ARROW_DEPARTURE_GEOMETRY_FAILURES, PUZZLE_LAYOUT_FAILURES, PUZZLE_PRESENTATION_FAILURES) and REGRESSION_FAILURES report 0; Godot headless editor validation exits 0 with no errors
- [ ] T035 Execute quickstart.md's full manual verification script end-to-end on a desktop build; record results and any outstanding checks per constitution Principle V (code_ref: pending | knowledge_ref: pending) <!-- WIP: requires an interactive desktop session; cannot be performed by the implementing agent. Left for human execution. -->
- [ ] T036 Confirm every task above has its `code_ref`/`knowledge_ref` populated (or `n/a` with a one-line reason) and that no durable code or `.knowledge/` file references this spec/plan/tasks record, per the no-back-reference contract (code_ref: pending | knowledge_ref: pending) <!-- WIP: no-back-reference half verified (check-planning-references reports clean; planning identifiers I introduced in comments were removed). Linkage half is complete for every automatable task; it cannot be fully closed until the five manual tasks (T009, T017, T023, T032, T035) are performed by a human and their refs recorded. -->

**Checkpoint**: Final phase partially complete (T033, T034 done; T035/T036 pending human manual verification).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories.
- **User Stories (Phase 3-6)**: All depend on Foundational completion.
  - US1 and US2 (both P1) form the MVP and have no dependency on each other.
  - US3 depends on Foundational's `get_results()` change (T003) but not on US1/US2.
  - US4 depends on Foundational (for the results dictionary shape T027 consumes) but
    not on US1/US2/US3; its Results-label additions (T029/T030) sit beside, not on
    top of, US3's (T020/T021) — both extend the same file independently.
- **Final Phase**: Depends on all four user stories being complete.

### User Story Dependencies

- **US1 (P1)**: No dependency on US2/US3/US4.
- **US2 (P1)**: No dependency on US1/US3/US4.
- **US3 (P2)**: No dependency on US1/US2/US4 beyond the shared Foundational change.
- **US4 (P2)**: No dependency on US1/US2/US3 beyond the shared Foundational change.

### Within Each User Story

- Tests are written to exercise the target behavior before/alongside implementation.
- `PuzzleState`/`PuzzleScoreboard` changes precede the scene-controller/UI wiring that
  consumes them.
- Manual smoke test comes last in each story, after its automated checks pass.

### Parallel Opportunities

- T002 and T004 (Foundational) can run in parallel — different files.
- T006, T007, T008 (US1 tests) can all run in parallel — different test files/sections.
- T010, T011, T012 (US2 tests) can all run in parallel.
- T018, T019 (US3 tests) can run in parallel.
- T024, T025, T026 (US4 tests) can all run in parallel.
- Once Foundational (Phase 2) completes, US1, US2, US3, and US4 can all proceed in
  parallel if staffed — none depends on another's implementation tasks.

---

## Parallel Example: User Story 2

```bash
# Launch all tests for User Story 2 together:
Task: "find_open_move()/request_open_move() cases in tests/puzzle_regression.gd"
Task: "In-flight-departure Open Move case in tests/puzzle_layout_check.gd"
Task: "Keyboard/gamepad reachability case in tests/puzzle_layout_check.gd"
```

---

## Implementation Strategy

### MVP First (User Story 1 + User Story 2)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories).
3. Complete Phase 3 (US1) and Phase 4 (US2) — both P1, together the MVP: the
   no-fail-state guarantee is proven, and a stuck player can always ask for an
   Open Move.
4. **STOP and VALIDATE**: run US1/US2's tests and manual smoke tests independently.
5. Demo if ready.

### Incremental Delivery

1. Setup + Foundational → foundation ready.
2. Add US1 → validate independently (no-fail-state guarantee, catalog-wide).
3. Add US2 → validate independently (Open Move assist) → MVP complete.
4. Add US3 → validate independently (Results screen fully explains an attempt).
5. Add US4 → validate independently (session-best/overall score, replay purpose).
6. Final Phase: full regression + quickstart + traceability confirmation.

---

## Notes

- [P] tasks touch different files with no dependency on an incomplete task.
- Every FR-001 through FR-021 in spec.md is referenced by at least one task above.
- Avoid: duplicating `_is_head_blocked`/blocking logic anywhere outside `PuzzleState`;
  routing any new state through `GlobalState`/`GameState`/`user://`; turning the
  Results screen into a progression dashboard.
