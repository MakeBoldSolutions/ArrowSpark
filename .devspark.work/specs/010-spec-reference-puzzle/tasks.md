---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
description: "Task list for The ArrowSpark Reference Puzzle and Level Groups"
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Tasks: The ArrowSpark Reference Puzzle and Level Groups

**Input**: Design documents from `/.devspark.work/specs/010-spec-reference-puzzle/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/level-groups.md, quickstart.md

**Tests**: Requested by the spec (FR-030): extended catalog checks and both regression gates. Test tasks are included.

**Organization**: Grouped by user story. US1's authoring loop is human-gated (playtests); AI tasks prepare candidates and diagnostics but cannot self-certify the human bar (FR-016).

## Rationale Summary

### Core Problem

A flat 21-puzzle catalog has no exemplar of the intended ArrowSpark experience and no way to tell foundations, experiments and player-facing levels apart.

### Decision Summary

Add one hand-authored, playtest-iterated Reference Puzzle and metadata-only purpose groups that drive Level Select sections, group-scoped progression/numbering and the Play target — with no gameplay-rule change.

### Key Drivers

- Constitution III/V: keyboard/gamepad menu navigation and recorded validation + smoke test.
- FR-010/027/029: no new mechanics, groups are metadata, no generator or scoring formula.
- FR-016: completion requires genuine human endorsement.

### Reviewer Guidance

Check playtest honesty, classification rationale, no regression in results/Next/Replay/Open Move/scoring, and unedited observations in the design report.

## Format: `- [ ] [ID] [P?] [Story] Description (Implements: FR-###)`

Every task ends with `(code_ref: pending | knowledge_ref: pending)`.

---

## Phase 1: Setup

- [ ] T001 Record baseline: run `python tests/run_puzzle_regressions.py --godot <godot>` and `python tests/run_regressions.py --godot <godot>` and `<godot> --headless --editor --quit` on the untouched branch; note results in the working verification notes `.devspark.work/specs/010-spec-reference-puzzle/verification.md` (code_ref: pending | knowledge_ref: pending)
- [ ] T002 [P] Create working design-report draft `.devspark.work/specs/010-spec-reference-puzzle/design-report-draft.md` with the fourteen FR-015 headings, the fifteen-question playtest template (session date, candidate version, tester, familiarity, input method, Open Move use, unedited answers) and an empty iteration log (Implements: FR-011, FR-013, FR-015) (code_ref: pending | knowledge_ref: pending)

---

## Phase 2: Foundational (blocks all stories)

**Purpose**: group metadata, queries and a placeholder catalog entry that every story builds on.

- [ ] T003 Add a `"group"` key to all 21 entries in `scripts/puzzle/puzzle_catalog.gd` per plan classification (8 foundations / 13 puzzle_lab) and add group constants (ids, titles, presentation order `arrowspark_levels`, `foundations`, `puzzle_lab`); do not change ids, titles, builders or array order (Implements: FR-022, FR-023, FR-024, FR-027) (code_ref: pending | knowledge_ref: pending)
- [ ] T004 Add static helpers `group_ids()`, `group_title()`, `group_of()`, `ids_in_group()`, `group_position()`, `next_in_group()` to `scripts/puzzle/puzzle_catalog.gd` per `contracts/level-groups.md` (no wrap, no cross-group; unknown ids safe) (Implements: FR-022, FR-031, FR-033) (code_ref: pending | knowledge_ref: pending)
- [ ] T005 Append catalog entry `reference_knot` (index 21, group `arrowspark_levels`, provisional title) with a minimal valid, solver-confirmed provisional `_build_reference_knot()` board in `scripts/puzzle/puzzle_catalog.gd`; update the file's header doc comment count/description (Implements: FR-001, FR-026) (code_ref: pending | knowledge_ref: pending)
- [ ] T006 Extend `tests/puzzle_catalog_check.gd`: 22 entries; every entry has exactly one valid group; group sizes 8/13/1; `canvas_validation` is in `puzzle_lab`; existing ids/fingerprints unchanged; `group_position`/`next_in_group` semantics (including group end, unknown id, no wrap/cross-group); `reference_knot` validates, is solvable, witness replays and is order-independent; update stale "twenty-one"/"fourteenth" wording only where counts changed (Implements: FR-017, FR-021, FR-022, FR-024, FR-030, SC-008) (code_ref: pending | knowledge_ref: pending)
- [ ] T007 Run `python tests/run_puzzle_regressions.py --godot <godot>`; fix any launcher/test doc counts in `tests/run_puzzle_regressions.py`, `tests/README.md` and `tests/puzzle_structural_report.gd` that are hard-coded to 21, updating them to 22 entries / three groups in this task so docs are never stale after the entry lands (Implements: FR-021, FR-030) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: catalog answers group queries; placeholder entry exists; gates green.

---

## Phase 3: User Story 1 — Play the Reference Puzzle and feel the rhythm (P1) 🎯 MVP

**Goal**: one readable, composed knot with several discovery beats, cross-region dependencies, a visible bridge-arrow release and a satisfying collapse.

**Independent test**: automated checks confirm load/solvable/completes through Results; a human plays the final candidate start to finish and answers all fifteen questions supporting "a level I want someone else to play".

- [ ] T008 [US1] Author candidate v1 of the knot in `_build_reference_knot()` in `scripts/puzzle/puzzle_catalog.gd` using the existing shape-list/`_tail_along` style: mixed long/medium/bent/multi-bend/simple arrows, several implicit neighborhoods, ≥1 bridge arrow, tail-based cross-region blockers, sparing single-cell arrows; record intended neighborhoods, dependencies, beats, releases and experience curve in the draft report; no new mechanics or encoded solve order (Implements: FR-002, FR-003, FR-004, FR-005, FR-006, FR-007, FR-008, FR-009, FR-010) (code_ref: pending | knowledge_ref: pending)
- [ ] T009 [US1] Validate candidate: definition validation, solver-confirmed solvable, witness replays, solvable from every reachable state (extend/run `tests/puzzle_catalog_check.gd` fixtures for `reference_knot`) (Implements: FR-014, FR-017) (code_ref: pending | knowledge_ref: pending)
- [ ] T010 [US1] Measure candidate with `python tests/run_puzzle_structural_report.py --godot <godot>`; paste diagnostics (dimensions, arrows, occupancy, dependency edges/depth, initial legal moves, forced moves, blocker distance, arrow lengths/bends) into the draft report iteration log; create no quality/fun/difficulty score and do not tune to the witness (Implements: FR-012, FR-014) (code_ref: pending | knowledge_ref: pending)
- [ ] T011 [US1] **HUMAN GATE** Playtest the candidate (author is primary; ask questions after play so discoveries are not revealed); record session context and unedited answers to Q1–Q15 in the draft report; record what felt wrong, what changes, why (Implements: FR-011, FR-013) (code_ref: pending | knowledge_ref: pending)
- [ ] T012 [US1] Revise `_build_reference_knot()` from playtest evidence; repeat T009–T011 for each serious candidate until the human bar is met. Iteration versions stay in the draft report, never as catalog entries (Implements: FR-001, FR-011, FR-016) (code_ref: pending | knowledge_ref: pending)
- [ ] T013 [US1] Finalize the entry title in `scripts/puzzle/puzzle_catalog.gd` (id stays `reference_knot`) and confirm on the real board scene that arrows are traceable at a recorded on-screen cell size inside the supported zoom range (record the pixel size and zoom in the draft report), plus zoom/pan/Fit Puzzle readability (Implements: FR-008, FR-019) (code_ref: pending | knowledge_ref: pending)
- [ ] T014 [US1] **HUMAN GATE** Final playtest of the final candidate with all fifteen answers written and unedited; confirm SC-002–SC-006 against them, and confirm the FR-009 evidence (at most five consecutive single-cell removals without a new decision after the final barrier). If the answer to Q15 is not "yes, I want someone else to play it", record why, keep spec status below Complete and return to T012 (Implements: FR-013, FR-016) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: Reference Puzzle is playable, validated, and human-endorsed (or documented as not yet).

---

## Phase 4: User Story 2 — Find mature levels separately from foundations and experiments (P1)

**Goal**: grouped Level Select, group-relative numbering, group-scoped Next/Level Select, Play → Reference Puzzle.

**Independent test**: open Level Select; three groups visible, each entry launches its original id, keyboard/gamepad reach everything; Play starts the Reference Puzzle.

- [ ] T015 [US2] Make `PuzzleSession.has_next()`/`advance_to_next()` group-scoped via `PuzzleCatalog.next_in_group` and add one-shot in-memory `request_level_select()` / `consume_level_select_request()` in `scripts/puzzle_session.gd`; update its doc comments (Implements: FR-020, FR-031) (code_ref: pending | knowledge_ref: pending)
- [ ] T016 [P] [US2] Render grouped sections in `scenes/menus/main_menu/puzzle_select_menu.gd`: non-focusable group header `Label` per group in `PuzzleCatalog.group_ids()` order, buttons `"<group_position>. <title>"` in one focus chain, initial focus on the first button; no tabs/sub-menus (Implements: FR-025, FR-028, FR-033) (code_ref: pending | knowledge_ref: pending)
- [ ] T017 [P] [US2] Use `PuzzleCatalog.group_position(id)` for the in-game puzzle label in `scenes/puzzle/arrow_puzzle.gd` and the results title in `scenes/puzzle/puzzle_results.gd` (Implements: FR-033) (code_ref: pending | knowledge_ref: pending)
- [ ] T018 [US2] Add a `LevelSelectButton` (styled `PrimaryButton`) to the results `ButtonRow` in `scenes/puzzle/puzzle_results.tscn`; in `scenes/puzzle/puzzle_results.gd` add `level_select_requested` signal, show Next Puzzle when `has_next` else Level Select, preserve focus grabbing on Replay and keyboard/gamepad navigation (Implements: FR-031) (code_ref: pending | knowledge_ref: pending)
- [ ] T019 [US2] Handle `level_select_requested` in `scenes/puzzle/arrow_puzzle.gd` (set `PuzzleSession.request_level_select()`, load `main_menu_scene_path`) and honor the request in `scenes/menus/main_menu/main_menu_with_animations.gd` (after `_setup_level_select()` and intro handling, open Level Select via `_open_sub_menu`, deferred); leave Replay/Main Menu untouched (Implements: FR-031) (code_ref: pending | knowledge_ref: pending)
- [ ] T020 [US2] Change `new_game()` in `scenes/menus/main_menu/main_menu_with_animations.gd` to start `reference_knot`; keep the no-`GlobalState.reset()`/no-`GameState.start_game()` behavior; update the doc comment (Implements: FR-032) (code_ref: pending | knowledge_ref: pending)
- [ ] T021 [US2] Update `tests/save_input_regression.gd` (and its launcher copy list in `tests/run_regressions.py` if it needs a new script) so New Game asserts the reference id regardless of prior Level Select, Level Select still does not reset progress, and the level-select request is one-shot and consumed once (Implements: FR-020, FR-032, FR-030) (code_ref: pending | knowledge_ref: pending)
- [ ] T022 [US2] Extend `tests/puzzle_catalog_check.gd` session checks: group-scoped `has_next`/`advance_to_next` (last Foundations, last Puzzle Lab and the Reference Puzzle's group all end without crossing/wrapping and leave id unchanged); update the old "Next from fourteenth reaches canvas_validation" expectations that assumed a flat order (Implements: FR-031, FR-030) (code_ref: pending | knowledge_ref: pending)
- [ ] T023 [US2] Review each existing entry's original purpose and current gameplay role and record the classification rationale (including `canvas_validation` → Puzzle Lab as an experimental validation board) in the draft report; adjust T003 memberships only if the review disagrees, and update T006/T022 expectations to match (Implements: FR-023, FR-028) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: grouped menus and progression work end to end.

---

## Phase 5: User Story 3 — Durable design report and honest playtest record (P2)

**Goal**: a durable, honest design report.

**Independent test**: reviewer checks all fourteen items and that every serious played iteration has dated, attributed observations.

- [ ] T024 [US3] Publish `.knowledge/reference/reference-puzzle-design-report.md` (frontmatter `type: authoritative-reference`, `appliesTo` catalog + catalog check) from the draft: structural profile, intended neighborhoods, cross-neighborhood dependencies, bridge arrows, expected discovery beats, insight chains, major releases, intended experience curve, iteration history, unedited human observations (all fifteen answers for the final), intent-vs-actual differences, useful and less-useful analyzer and knot-experiment concepts (named by concept, never by spec number), remaining weaknesses, group classification rationale, and candidate design principles labeled level-specific; no invented scores/formulas, no back-references to spec/plan/tasks (Implements: FR-013, FR-015, FR-023, SC-007) (code_ref: pending | knowledge_ref: pending)

---

## Phase 6: User Story 4 — Existing gameplay contracts are untouched (P2)

**Goal**: prove additive change.

**Independent test**: both gates + Godot validation + smoke test.

- [ ] T025 [US4] Run `python tests/run_puzzle_regressions.py --godot <godot>` and `python tests/run_regressions.py --godot <godot>`; both must report zero failures (Implements: FR-021, FR-030, SC-001) (code_ref: pending | knowledge_ref: pending)
- [ ] T026 [US4] Run `<godot> --headless --editor --quit` and confirm no script/scene errors (Implements: FR-030, SC-001) (code_ref: pending | knowledge_ref: pending)
- [ ] T027 [US4] Desktop smoke test per `quickstart.md`: Play → Reference Puzzle; Open Move; zoom/pan/Fit Puzzle/transformed selection; path-following departures; completion exactly once → Results; score/session best; Replay; group-end Level Select; in-group Next Puzzle; grouped Level Select by pointer and by keyboard-only traversal (every Level Select entry and every Results button must be reachable and activatable), and by gamepad (Constitution III: run it, or disclose it as an outstanding limitation); record each result or disclose any check not run in `verification.md` (Implements: FR-018, FR-019, FR-025, FR-030, FR-031, FR-032) (code_ref: pending | knowledge_ref: pending)
- [ ] T028 [US4] **HUMAN GATE** SC-009: one person other than the author opens Level Select unguided and finds the ArrowSpark Levels group; record the observation (Implements: FR-025, SC-009) (code_ref: pending | knowledge_ref: pending)

---

## Phase 7: Polish & Cross-Cutting

- [ ] T029 [P] Update `.knowledge/architecture/arrow-puzzle.md`: 22 entries, group metadata/queries, grouped Level Select, group-relative numbering, group-scoped Next Puzzle and results Level Select button, Play → Reference Puzzle, session level-select request; state current truth only (Implements: FR-022, FR-031, FR-032, FR-033) (code_ref: pending | knowledge_ref: pending)
- [ ] T030 [P] Update `.knowledge/reference/gordian-knot-experiments.md` with the Puzzle Lab classification of the six knot experiments (one short current-truth note) and `.knowledge/product/gameplay-contract.md` results-panel wording only if the Level Select button changes described behavior (Implements: FR-023, FR-028) (code_ref: pending | knowledge_ref: pending)
- [ ] T031 [P] Update `tests/README.md` and `tests/run_puzzle_regressions.py` docstring to describe the new group and reference-puzzle checks (entry counts are already updated in T007) (Implements: FR-030) (code_ref: pending | knowledge_ref: pending)
- [ ] T032 Regenerate `.knowledge/index.json` and `.knowledge/ontology/coverage.json` with the repo's knowledge-index tooling so the new report node is indexed (code_ref: pending | knowledge_ref: pending)
- [ ] T033 Update the "Recent Changes" summary in `CLAUDE.md` in one sentence (no spec/plan/task ids) (code_ref: pending | knowledge_ref: pending)
- [ ] T034 No-planning-reference validation: search `scripts/`, `scenes/`, `tests/`, `.knowledge/`, `CLAUDE.md` in files added or changed by this work (use `git diff --name-only main`) for `spec 0[0-9][0-9]` (case-insensitive), `010-spec`, `FR-0`, `SC-0`, `.devspark.work`, `tasks.md`, `plan.md`; fix any hits (pre-existing hits in untouched files, e.g. older Recent Changes lines or the repo-story guide, are out of scope) (durable files must not point back to planning) (code_ref: pending | knowledge_ref: pending)
- [ ] T035 Before completion, review the diff to confirm no new mechanic, generator, difficulty formula or automatic quality score was added and grouping stayed metadata-only (FR-010, FR-027, FR-029). Populate `code_ref`/`knowledge_ref` on every task above; only when every automated gate (T025, T026), the smoke test (T027) and human gates (T014, T028) are complete, set spec status Complete. If any human gate is unmet, leave status below Complete and disclose the outstanding limitation; leave the bundle under `.devspark.work/` for `/devspark.release` (Implements: FR-016, FR-030) (code_ref: pending | knowledge_ref: pending)

---

## Dependencies & Execution Order

- Phase 1 → Phase 2 (blocks all) → Phases 3 and 4 may proceed in parallel after Phase 2; Phase 5 needs Phase 3 evidence and T023; Phase 6 needs Phases 3–4 (T028 also needs T016–T019); Phase 7 last.
- Within US1: T008 → T009 → T010 → T011 → T012 (loop) → T013 → T014.
- Within US2: T015 before T017–T019 and T022; T016/T017 parallel (different files); T018 → T019; T020 independent of T018; T021 after T020; T023 before finalizing T006/T022 expectations.
- T029–T031 parallel; T032 after T024/T029/T030; T034/T035 last.
- The T011/T014/T028 human gates are blocking for completion, not for other phases' code work.

### Parallel Opportunities

- After Phase 2: US1 authoring loop (T008–T014) alongside US2 UI work (T015–T023).
- `puzzle_select_menu.gd` (T016) and label updates (T017) touch different files.
- T029, T030, T031 touch different documents.

## Implementation Strategy

**MVP** = Phase 1–2 plus US2 (grouped menus, Play target, progression), which is fully automatable and independently valuable, then US1's iterative loop. Ship nothing marked Complete until T014 and T028 pass. Deliver US1 in candidate increments: each candidate is playable via Play immediately, so playtests can start as soon as T008 lands and the US2 Play change (T020) is in.

## Constitution Coverage

- III Accessible controls: T016, T018, T027, T028.
- V Practical verification: T006, T007, T021, T022, T025–T027 (results recorded in `verification.md`).
- VI Preserve progress/settings: T015, T020, T021 (no persistence; no-reset guarantee retained).
- No waivers accepted in plan.md.

## Gate Acknowledgements

- `checklists/requirements.md`: 19/19 complete (PASS). `analyze` and `critic` gates have not been run yet; recommended before `/devspark.implement` (spec `required_gates`).
