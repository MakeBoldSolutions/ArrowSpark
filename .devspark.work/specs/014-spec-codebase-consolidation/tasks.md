---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
description: "Task list for Codebase Organization and Consolidation"
devspark_version: "undetermined"
plan_semantic_hash: "sem1:97f7c17ef1d3ac883f475a34e5351844ac588df5c74eb7cddd20d8246cab040f"
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Tasks: Codebase Organization and Consolidation

**Input**: Design documents from `/.devspark.work/specs/014-spec-codebase-consolidation/`
**Prerequisites**: plan.md, spec.md, research.md, quickstart.md

**Tests**: Delta is `add` for the all-entry catalog pins (US1), `update` for one analyzer test reference (US2), and `none` elsewhere. Behavior preservation is proven by the existing gates plus the temporary probe diff (`verify:snapshot-neutral`).

**Pre-PR only**: Every task below finishes before the PR. No release, version or deployment work.

**Conventions**: `<godot>` and the gate commands are as defined in [quickstart.md](quickstart.md); use only the 4.4.1 executable. "Full gates" means both headless runners plus editor validation, with every failure marker at 0, followed by `git status --short`; "puzzle gate" means `run_puzzle_regressions.py` plus `git status --short`. Full gates run at T001, T023 and T032. Every other checkpoint uses the targeted check named in its task (plan.md, checkpoint table). Commit boundaries follow plan.md's C0–C8. The tasks under one checkpoint may be implemented and committed as one unit. Evidence is recorded once per checkpoint in `FD/consolidation-record.md`, and that unit's tasks may share one `code_ref`/`knowledge_ref` entry; no separate record per task is needed. `FD` = `.devspark.work/specs/014-spec-codebase-consolidation`.

## Phase 1: Setup

- [X] T001 Confirm `<godot> --version` prints 4.4.1, then run full gates on the unmodified tree and record the results as the pre-change gate baseline in `FD/consolidation-record.md` (plan C0; research R-02) (code_ref: n/a: baseline evidence only, no durable code changed (probe and record live in the spec bundle) | knowledge_ref: n/a: no knowledge changed)

## Phase 2: Foundational (behavior baseline; blocks every production change)

- [X] T002 Write the temporary probe `FD/gates/behavior_probe.gd` exactly as specified in quickstart.md "Behavior probe" (per entry: identity fields, content version, solver result, Open Move trail, analyzer report) (plan C0; FR-014) (code_ref: n/a: baseline evidence only, no durable code changed (probe and record live in the spec bundle) | knowledge_ref: n/a: no knowledge changed)
- [X] T003 Run the probe on the unmodified tree into `FD/gates/baseline-before.txt`. Confirm it has 30 entry blocks and record the commit it ran on (plan C0; FR-014) (code_ref: n/a: baseline evidence only, no durable code changed (probe and record live in the spec bundle) | knowledge_ref: n/a: no knowledge changed)
- [X] T004 Record the "Before" measures in `FD/consolidation-record.md`: production file and line counts, the five largest files, duplication counts (ordering 4, direction 2, shape loop 9), pin coverage 24/30, the unreachable-template count from research R-01, and catalog lines (plan C0; SC-006) (code_ref: n/a: baseline evidence only, no durable code changed (probe and record live in the spec bundle) | knowledge_ref: n/a: no knowledge changed)

**Checkpoint**: Baseline captured; no repository file outside `FD/` has changed.

## Phase 3: User Story 1 — Catalog changes are caught before they ship (Priority: P1)

**Goal**: All 30 entries pinned by id, title, group, position and content version (plan C1).

**Independent Test**: Spec US1 scenarios 1–3; SC-001.

- [X] T005 [US1] Add a `CATALOG_PINS` table (30 rows in catalog order: id, title, group, content version, values copied from `FD/gates/baseline-before.txt`) and a `_check_catalog_pins()` check, called from `_initialize()`, in `tests/puzzle_catalog_check.gd`. It asserts count equality, and per index the id, title, group and `PuzzleContentVersion.of`. An entry without a pin fails with "entry `<id>` has no recorded pin". Leave the existing fingerprint checks unchanged (Implements: FR-004) (code_ref: tests/puzzle_catalog_check.gd::CATALOG_PINS, tests/puzzle_catalog_check.gd::_check_catalog_pins | knowledge_ref: .knowledge/architecture/arrow-puzzle.md (all-entry pin described, via T019))
- [X] T006 [US1] Run the puzzle gate; it must pass with the new check (Implements: FR-004) (code_ref: tests/puzzle_catalog_check.gd::CATALOG_PINS, tests/puzzle_catalog_check.gd::_check_catalog_pins | knowledge_ref: .knowledge/architecture/arrow-puzzle.md (all-entry pin described, via T019))
- [X] T007 [US1] Mutation demonstration per quickstart.md: move one tail vertex of `_build_knot_regions` in `scripts/puzzle/puzzle_catalog.gd`, confirm the puzzle gate fails naming `knot_regions`, then restore by undoing that single edit and prove the file matches the committed version with `git diff --quiet` (quickstart.md steps 1–6; no `git checkout`, `restore` or `stash`) and confirm the gate passes. Paste both outputs into `FD/consolidation-record.md` (Implements: FR-004) (code_ref: tests/puzzle_catalog_check.gd::CATALOG_PINS, tests/puzzle_catalog_check.gd::_check_catalog_pins | knowledge_ref: .knowledge/architecture/arrow-puzzle.md (all-entry pin described, via T019))

**Checkpoint**: Commit C1 (test only). SC-001 evidence recorded.

## Phase 4: User Story 2 — One definition for each behavior-defining rule (Priority: P2)

**Goal**: Head ordering, direction step and shape-to-board each defined once (plan C2, C3, C4).

**Independent Test**: Spec US2 scenarios 1–4; SC-002; probe diff empty after C2 and C4.

### C2: head ordering

- [X] T008 [US2] Add `static func head_less_than(a: Vector2i, b: Vector2i) -> bool` returning `a.y < b.y or (a.y == b.y and a.x < b.x)`, with a one-line doc comment naming its users, in `scripts/puzzle/puzzle_definition.gd` (Implements: FR-005) (code_ref: scripts/puzzle/puzzle_definition.gd::head_less_than, scripts/puzzle/puzzle_state.gd::find_open_move, scripts/puzzle/puzzle_solver.gd::analyze, scripts/puzzle/puzzle_content_version.gd::canonical_text, scripts/puzzle/puzzle_analyzer.gd (_head_less_than removed; _compute_dependency_graph, _chain_less_than, _compute_blocker_distance), tests/puzzle_analyzer_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md (ordering prose, via T019))
- [X] T009 [US2] Replace the `find_open_move()` sort lambda with `sort_custom(PuzzleDefinition.head_less_than)` in `scripts/puzzle/puzzle_state.gd` (Implements: FR-005) (code_ref: scripts/puzzle/puzzle_definition.gd::head_less_than, scripts/puzzle/puzzle_state.gd::find_open_move, scripts/puzzle/puzzle_solver.gd::analyze, scripts/puzzle/puzzle_content_version.gd::canonical_text, scripts/puzzle/puzzle_analyzer.gd (_head_less_than removed; _compute_dependency_graph, _chain_less_than, _compute_blocker_distance), tests/puzzle_analyzer_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md (ordering prose, via T019))
- [X] T010 [US2] Replace the `analyze()` sort lambda with `sort_custom(PuzzleDefinition.head_less_than)` in `scripts/puzzle/puzzle_solver.gd` (Implements: FR-005) (code_ref: scripts/puzzle/puzzle_definition.gd::head_less_than, scripts/puzzle/puzzle_state.gd::find_open_move, scripts/puzzle/puzzle_solver.gd::analyze, scripts/puzzle/puzzle_content_version.gd::canonical_text, scripts/puzzle/puzzle_analyzer.gd (_head_less_than removed; _compute_dependency_graph, _chain_less_than, _compute_blocker_distance), tests/puzzle_analyzer_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md (ordering prose, via T019))
- [X] T011 [US2] Replace the `canonical_text()` sort lambda with `sort_custom(PuzzleDefinition.head_less_than)` in `scripts/puzzle/puzzle_content_version.gd` (Implements: FR-005, FR-008) (code_ref: scripts/puzzle/puzzle_definition.gd::head_less_than, scripts/puzzle/puzzle_state.gd::find_open_move, scripts/puzzle/puzzle_solver.gd::analyze, scripts/puzzle/puzzle_content_version.gd::canonical_text, scripts/puzzle/puzzle_analyzer.gd (_head_less_than removed; _compute_dependency_graph, _chain_less_than, _compute_blocker_distance), tests/puzzle_analyzer_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md (ordering prose, via T019))
- [X] T012 [US2] Remove `_head_less_than` from `scripts/puzzle/puzzle_analyzer.gd`. Point its four uses (lines ~175, 342, 360, 378, including `_chain_less_than`) at `PuzzleDefinition.head_less_than`, and reword the comment that says "the same comparator PuzzleSolver uses" to name the shared definition (Implements: FR-005, FR-008) (code_ref: scripts/puzzle/puzzle_definition.gd::head_less_than, scripts/puzzle/puzzle_state.gd::find_open_move, scripts/puzzle/puzzle_solver.gd::analyze, scripts/puzzle/puzzle_content_version.gd::canonical_text, scripts/puzzle/puzzle_analyzer.gd (_head_less_than removed; _compute_dependency_graph, _chain_less_than, _compute_blocker_distance), tests/puzzle_analyzer_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md (ordering prose, via T019))
- [X] T013 [US2] Change `PuzzleAnalyzer._head_less_than` to `PuzzleDefinition.head_less_than` at `tests/puzzle_analyzer_check.gd:413` (Implements: FR-005) (code_ref: scripts/puzzle/puzzle_definition.gd::head_less_than, scripts/puzzle/puzzle_state.gd::find_open_move, scripts/puzzle/puzzle_solver.gd::analyze, scripts/puzzle/puzzle_content_version.gd::canonical_text, scripts/puzzle/puzzle_analyzer.gd (_head_less_than removed; _compute_dependency_graph, _chain_less_than, _compute_blocker_distance), tests/puzzle_analyzer_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md (ordering prose, via T019))
- [X] T014 [US2] Run the puzzle gate, re-run the probe, and diff against `FD/gates/baseline-before.txt` (must be empty); grep confirms one ordering definition in `scripts/` (Implements: FR-005, FR-014) (code_ref: scripts/puzzle/puzzle_definition.gd::head_less_than, scripts/puzzle/puzzle_state.gd::find_open_move, scripts/puzzle/puzzle_solver.gd::analyze, scripts/puzzle/puzzle_content_version.gd::canonical_text, scripts/puzzle/puzzle_analyzer.gd (_head_less_than removed; _compute_dependency_graph, _chain_less_than, _compute_blocker_distance), tests/puzzle_analyzer_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md (ordering prose, via T019))

**Checkpoint**: Commit C2.

### C3: direction step

- [X] T015 [US2] Make `_direction_vector()` return `Vector2(PuzzleDefinition.direction_vector(direction))` and remove its `match` in `scenes/puzzle/arrow_view.gd` (Implements: FR-006) (code_ref: scenes/puzzle/arrow_view.gd::_direction_vector | knowledge_ref: n/a: game-visual-system.md and arrow-puzzle.md do not describe the direction mapping (checked in T019))
- [X] T016 [US2] Run the puzzle gate (canvas, presentation and departure checks run in the real project); grep confirms one direction-to-step mapping in production code (Implements: FR-006) (code_ref: scenes/puzzle/arrow_view.gd::_direction_vector | knowledge_ref: n/a: game-visual-system.md and arrow-puzzle.md do not describe the direction mapping (checked in T019))

**Checkpoint**: Commit C3.

### C4: catalog shapes

- [X] T017 [US2] In `scripts/puzzle/puzzle_catalog.gd`, end each of `_build_canvas_validation`, `_build_knot_long_geometry`, `_build_knot_interwoven_paths`, `_build_knot_dense_core`, `_build_knot_regions`, `_build_knot_single_release`, `_build_knot_boundary` and `_build_reference_knot` with `return _from_shapes(<width>, <height>, shapes)`, deleting the inline loop. Board literals, their order and comments are untouched (Implements: FR-007) (code_ref: scripts/puzzle/puzzle_catalog.gd (8 builders -> _from_shapes) | knowledge_ref: .knowledge/architecture/arrow-puzzle.md (canvas_validation build prose, via T019))
- [X] T018 [US2] Run the puzzle gate (C1 pins all green); re-run the probe and diff it (must be empty); `git diff --stat` and `git diff` on the catalog show only loop deletions and the 8 return lines (Implements: FR-007, FR-014) (code_ref: scripts/puzzle/puzzle_catalog.gd (8 builders -> _from_shapes) | knowledge_ref: .knowledge/architecture/arrow-puzzle.md (canvas_validation build prose, via T019))

**Checkpoint**: Commit C4.

### Knowledge for US2

- [X] T019 [US2] Update `.knowledge/architecture/arrow-puzzle.md` prose that describes the consolidated rules: the (y, x) ordering mentions (~lines 121, 163, 472, 569) name `PuzzleDefinition.head_less_than` as the single definition, and the canvas-validation description (~289–291) says it is built by `_from_shapes` like the other vertex-path boards. Review `.knowledge/architecture/game-visual-system.md` (owner of `scenes/puzzle/**`) and change it only if it describes arrow direction mapping (Implements: FR-005, FR-006, FR-007) (code_ref: .knowledge/architecture/arrow-puzzle.md (no code) | knowledge_ref: .knowledge/architecture/arrow-puzzle.md (Open Move ordering, canvas_validation build, all-entry pins, analyzer tie-break), .knowledge/index.json; game-visual-system.md reviewed: no direction-mapping prose, unchanged)

## Phase 5: User Story 4 — Template example content no longer misleads (Priority: P3)

**Goal**: Remove exactly research R-01's removal set (plan C5). Done before US3 so the map describes the final tree.

**Independent Test**: Spec US4 scenarios 1–2; reachability walk unchanged for the shipped set.

- [X] T020 [US4] Re-run the R-01 reachability walk on the current tree, save the reached set to `FD/gates/reachable-before.txt`, and confirm every R-01 removal-list path is still unreached and that `scripts/game_state.gd` and `scripts/level_state.gd` are not in the list (Implements: FR-009, FR-010, FR-011) (code_ref: removed: scenes/game_scene/ (game_ui.tscn, configurable_sub_viewport.gd, input_display_label.gd, levels/level.gd, level_1..3.tscn), scenes/end_credits/, scenes/menus/level_select_menu/, scenes/loading_screen/, scenes/overlaid_menus/{game_won,level_lost,level_won}_menu.{gd,tscn}, scripts/level_list_state_manager.gd (+ .uid sidecars); kept: scripts/game_state.gd, scripts/level_state.gd | knowledge_ref: .knowledge/architecture/save-progression.md, .knowledge/index.json)
- [X] T021 [US4] `git rm` the R-01 removal list with its `.uid` sidecars: `scenes/game_scene/`, `scenes/end_credits/`, `scenes/menus/level_select_menu/`, `scenes/loading_screen/`, `scenes/overlaid_menus/{game_won_menu,level_lost_menu,level_won_menu}.{gd,tscn}`, `scripts/level_list_state_manager.gd` (Implements: FR-011) (code_ref: removed: scenes/game_scene/ (game_ui.tscn, configurable_sub_viewport.gd, input_display_label.gd, levels/level.gd, level_1..3.tscn), scenes/end_credits/, scenes/menus/level_select_menu/, scenes/loading_screen/, scenes/overlaid_menus/{game_won,level_lost,level_won}_menu.{gd,tscn}, scripts/level_list_state_manager.gd (+ .uid sidecars); kept: scripts/game_state.gd, scripts/level_state.gd | knowledge_ref: .knowledge/architecture/save-progression.md, .knowledge/index.json)
- [X] T022 [US4] In `.knowledge/architecture/save-progression.md`, remove `scripts/level_list_state_manager.gd` from `appliesTo` and add one sentence stating that GameState/LevelState stay for saved-data compatibility although no live gameplay path uses them (Implements: FR-010, FR-011) (code_ref: removed: scenes/game_scene/ (game_ui.tscn, configurable_sub_viewport.gd, input_display_label.gd, levels/level.gd, level_1..3.tscn), scenes/end_credits/, scenes/menus/level_select_menu/, scenes/loading_screen/, scenes/overlaid_menus/{game_won,level_lost,level_won}_menu.{gd,tscn}, scripts/level_list_state_manager.gd (+ .uid sidecars); kept: scripts/game_state.gd, scripts/level_state.gd | knowledge_ref: .knowledge/architecture/save-progression.md, .knowledge/index.json)
- [X] T023 [US4] Re-run the reachability walk into `FD/gates/reachable-after.txt` (the reached set must equal `reachable-before.txt`) and the dangling-reference `git grep` from quickstart.md (no matches). Run full gates; editor validation must show no missing-dependency errors, and `run_regressions.py` must be green for save preservation (Implements: FR-009, FR-010, FR-011) (code_ref: removed: scenes/game_scene/ (game_ui.tscn, configurable_sub_viewport.gd, input_display_label.gd, levels/level.gd, level_1..3.tscn), scenes/end_credits/, scenes/menus/level_select_menu/, scenes/loading_screen/, scenes/overlaid_menus/{game_won,level_lost,level_won}_menu.{gd,tscn}, scripts/level_list_state_manager.gd (+ .uid sidecars); kept: scripts/game_state.gd, scripts/level_state.gd | knowledge_ref: .knowledge/architecture/save-progression.md, .knowledge/index.json)

**Checkpoint**: Commit C5.

## Phase 6: User Story 3 — A newcomer can tell what each part of the code is for (Priority: P3)

**Goal**: Current responsibility map and corrected stale docs (plan C6, C7).

**Independent Test**: Spec US3 scenarios 1–2; SC-005 (six ownership questions).

- [ ] T024 [P] [US3] Fix the stale docstring (22 → 30 entries; current group and pin description) in `tests/run_puzzle_regressions.py` (Implements: FR-002) (code_ref: pending | knowledge_ref: pending)
- [ ] T025 [P] [US3] Correct the builder-style comments (header ~lines 14–18 and the "Puzzle builders" note ~157–158, which claim every builder uses `create_fixed()`'s dictionary style) to describe the three styles accurately in `scripts/puzzle/puzzle_catalog.gd`. Comment-only (Implements: FR-002) (code_ref: pending | knowledge_ref: pending)
- [ ] T026 [US3] Add a `## Code Responsibilities` section near the top of `.knowledge/architecture/arrow-puzzle.md`. It assigns every remaining production script in `scripts/` and `scenes/` to exactly one responsibility (rules and model, content, session state, presentation, input, scene flow, template integration, template copies unreferenced, saved-data compatibility). It states the rules-boundary rule, says why GameState/LevelState stay, says the removed examples can be restored from `addons/maaacks_game_template/examples/`, and lists the R-01 retained unreferenced copies. It must not reference this spec (Implements: FR-001, FR-003) (code_ref: pending | knowledge_ref: pending)
- [ ] T027 [US3] Self-check SC-005: using only the new section, answer the six US3 ownership questions in `FD/consolidation-record.md`, then regenerate `.knowledge/index.json` with the DevSpark knowledge index generator (Implements: FR-001) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: Commit C6 and C7. Puzzle gate green after T024; knowledge index regenerated.

## Phase 7: User Story 5 — Larger improvements are queued, not lost (Priority: P4)

**Goal**: Deferred-work and left-alone records (plan C8 outline sections 2–3).

**Independent Test**: Spec US5 scenario 1; SC-007.

- [ ] T028 [US5] Write the "Deferred" section of `FD/consolidation-record.md` with evidence, reason, trigger and seam for each of: data files or resources, generator, board input separation, unifying the three authoring styles, the remaining unreferenced template copies, and folding the legacy pin mechanisms (Implements: FR-012) (code_ref: pending | knowledge_ref: pending)
- [ ] T029 [US5] Write the "Left alone" section of `FD/consolidation-record.md`, with a reason for each FR-013 item plus `create_fixed()`; confirm none of the deferred or left-alone items were changed in the branch diff (Implements: FR-013, FR-016) (code_ref: pending | knowledge_ref: pending)

## Final Phase: Verification & Cross-Cutting

- [ ] T030 Re-run the probe into `FD/gates/baseline-after.txt`, diff it against `baseline-before.txt` (must be empty), and record `PROBE_DIFF=EMPTY` (verify:snapshot-neutral) (Implements: FR-014) (code_ref: pending | knowledge_ref: pending)
- [ ] T031 Record the "After" measures in `FD/consolidation-record.md` (same measures as T004), with SC-002 counts 1/1/1 and pins 30/30 (SC-002, SC-006) (code_ref: pending | knowledge_ref: pending)
- [ ] T032 Run final full gates on the branch head and record the full output markers (SC-004; Principle V) (Implements: FR-015) (code_ref: pending | knowledge_ref: pending)
- [ ] T033 Manual desktop smoke in the 4.4.1 editor per plan.md Verification (Simple Introduction, Large Canvas Validation, Reference Knot; departures in all four directions, Open Move, zoom, pan, Fit, results, Next, Replay, Level Select, Back, pause and restart, remap then help text); record the results (Principles III, V) (Implements: FR-015) (code_ref: pending | knowledge_ref: pending)
- [ ] T034 Build the web export with 4.4.1 and the site per quickstart.md; manual browser smoke in Firefox and Chrome; record results, with other Chromium browsers as not tested (Principle V) (Implements: FR-015) (code_ref: pending | knowledge_ref: pending)
- [ ] T035 Conditional manual mobile-beta smoke: when a real Android phone is available, run tap, drag pan, pinch and results, and record the device and browser. Otherwise record "mobile beta not re-verified on this build" (no input or touch code changed; the beta claim is not extended). Record iPhone as not tested. Not a completion blocker (Principle V) (Implements: FR-015) (code_ref: pending | knowledge_ref: pending)
- [ ] T036 No-planning-reference check: `git grep -n -E "014-spec|\.devspark\.work|consolidation-record|R-0[1-3]"` over `scripts/ scenes/ tests/ .knowledge/ CLAUDE.md AGENTS.md` returns no matches introduced by this branch (spec retention rule) (code_ref: pending | knowledge_ref: pending)
- [ ] T037 Fill every task's `code_ref`/`knowledge_ref` (one shared entry per checkpoint unit is allowed). In `FD/consolidation-record.md`, record **Technical completion** (T030–T032, T036 passed) separately from **Manual acceptance** (T033, T034 required; T035 conditional). Set spec Status to Complete only when both pass; if T033 or T034 is outstanding, leave it In Progress and list what is outstanding. Retain the complete `FD` (probe, outputs, record) for release archival (code_ref: pending | knowledge_ref: pending)

## Dependencies

- T001 → T002–T004 → US1 (T005–T007) → US2. C2 (T008–T014), C3 (T015–T016) and C4 (T017–T018) may run in any order after US1, but each must reach its checkpoint before the next starts. T019 after C2–C4.
- US4 (T020–T023) after US1; independent of US2. US3 (T024–T027) after US4, so the map describes the final tree. T024 ∥ T025.
- US5 (T028–T029) any time after T004. Final phase after all stories.
