---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
devspark_version: "undetermined"
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Tasks: ArrowSpark Progression Pack

**Input**: Design documents from `/.devspark.work/specs/013-spec-progression-pack/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/camera-bounds.md, quickstart.md

**Tests**: Requested by the spec (FR-010, FR-022): existing headless checks are updated and extended; no new test framework.

**Organization**: Two user stories. US1 (camera fix) is independent of US2 (levels) and ships first as the MVP. Both are P1.

## Rationale Summary

### Core Problem

The camera cannot center board corners, and the catalog jumps from tutorials to the 115-arrow Reference Knot.

### Decision Summary

Clamp the camera center to the board rectangle (departures unclipped with a longer exit margin), then author about eight literal-data levels proven by the existing solver and repoint Play.

### Key Drivers

- A showcase the owner is comfortable sending people to.
- Constitution Principle V: record checks, disclose what was not run, real phone for the mobile beta.
- No rule, scoring, persistence or site-contract change.

### Reviewer Guidance

Pan each corner to the middle on a small and a large puzzle; play the new levels in order; read the per-level notes. Do not review for metric targets.

## Format: `[ID] [P?] [Story] Description (Implements: FR-###[, FR-###])`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- Every task ends with `(code_ref: pending | knowledge_ref: pending)`; durable files never reference this record.
- `<godot>` is the Godot 4.4 executable. Shell: PowerShell 7 for DevSpark scripts.

## Gate Acknowledgements

- Planning review 2026-10-14: owner decided D-001 (keep the departure change, now FR-023) and D-002 (fold in the small fixes). Corrections applied to spec, plan, tasks and quickstart.

- Gate: requirements checklist. Unresolved: the item "analyze and critic gates not yet re-run on the updated spec" (25 of 26 items complete). Choice: proceed to tasks and run `/devspark.analyze` and `/devspark.critic` before or during implementation; findings merge via a tasks re-run. `auto-selected: false` (owner invoked tasks directly).

## Phase 1: Setup

- [X] T001 Locate the Godot 4.4 executable and record its path/version in the verification notes (no repo change) (code_ref: n/a (no repo change; Godot 4.7.2 found at the WinGet links path, pinned 4.4 executable not available on this machine) | knowledge_ref: n/a)
- [X] T002 Record the baseline: run `python tests/run_puzzle_regressions.py --godot <godot>`, `python tests/run_regressions.py --godot <godot>` and `<godot> --headless --editor --quit` on the untouched branch; note failure markers (expected all zero) (code_ref: n/a (verification only: puzzle gate all markers 0, regression gate REGRESSION_FAILURES=0 on Godot 4.7.2) | knowledge_ref: n/a)
- [X] T003 [P] Capture baseline structural report with `python tests/run_puzzle_structural_report.py --godot <godot>` for Reference Knot and Foundations rows, to compare levels against later (code_ref: n/a (verification only: structural baseline captured with run_puzzle_structural_report.py) | knowledge_ref: n/a)

## Phase 2: Foundational

No shared blocking prerequisites: US1 touches the presentation transform and departures, US2 touches the catalog and menu. They may proceed in either order; US1 first is the plan's order.

## Phase 3: User Story 1 - Any part of the board can be centered (Priority: P1) 🎯 MVP

**Goal**: every board point, including corners, can be centered at any zoom beyond Fit; Fit unchanged; anchor-stable zoom; departures read correctly.

**Independent Test**: on any existing puzzle, pan each corner to the viewport center; zoom near an edge; Fit and reveal still frame as before (quickstart Part A).

- [X] T004 [US1] Change `_clamped_center` in scripts/presentation/puzzle_viewport_transform.gd to clamp each axis to `[0, board_size]` above the Fit floor and lock to board center at the floor (re-lock when zoom returns to the floor); keep `zoom_at`, `pan_pixels`, `reveal_cell`, `resize_view` going through it (Implements: FR-018, FR-019, FR-020, FR-021) (code_ref: scripts/presentation/puzzle_viewport_transform.gd::_clamped_center | knowledge_ref: n/a (documented in T014))
- [X] T005 [US1] Update tests/puzzle_viewport_transform_check.gd: replace the assertions that a board corner sits on the fit margin at the pan extremes and the old per-axis clamp checks; keep inverse round-trip, mode-policy, invalid-area and projection checks (Implements: FR-022) (code_ref: tests/puzzle_viewport_transform_check.gd::_test_pan_clamping | knowledge_ref: n/a)
- [X] T006 [US1] Add to tests/puzzle_viewport_transform_check.gd: all four corners reach `center_cells` within 0.001 at several scales and board shapes (small, wide, tall, Reference Knot size); Fit floor locks pan; bounded pan keeps part of the board in view; resize re-clamps; `zoom_at` on edge/corner anchors moves the anchored point under one pixel; `reveal_cell` still pads the head inside the viewport (Implements: FR-018, FR-019, FR-020, FR-021, FR-022) (code_ref: tests/puzzle_viewport_transform_check.gd::_test_corner_reach, _test_fit_lock, _test_edge_anchor_stability | knowledge_ref: n/a)
- [X] T007 [P] [US1] Set `clip_contents` false on `DepartureClip` in scenes/puzzle/puzzle_board.gd (the board still clips to the viewport; keep the node and its sizing) (Implements: FR-023) (code_ref: scenes/puzzle/puzzle_board.gd::_init (DepartureClip clip_contents false) | knowledge_ref: n/a (documented in T014))
- [X] T008 [P] [US1] Raise `EXIT_CLEARANCE_MARGIN_CELLS` in scripts/puzzle/puzzle_feedback.gd from 0.001 to the smallest value that hides removal in the common zoomed-in view (start at 6.0) and note the added exit time at 10 cells/s (Implements: FR-023) (code_ref: scripts/puzzle/puzzle_feedback.gd::EXIT_CLEARANCE_MARGIN_CELLS (6.0) | knowledge_ref: n/a (documented in T014))
- [X] T009 [US1] Update tests/arrow_departure_geometry_check.gd, the departure/clip assertions and the `_worst_case_seconds` timing budget in tests/puzzle_canvas_check.gd, and the worst-case finish-distance/seconds constants and clip assertions in tests/puzzle_layout_check.gd for the unclipped departure and new margin; keep the "finish distance is a pure cell-unit function" check (Implements: FR-022, FR-023) (code_ref: tests/puzzle_presentation_check.gd (completion budget now derived from the finish distance), tests/puzzle_canvas_check.gd (unclipped departure assertion); arrow_departure_geometry_check.gd, puzzle_layout_check.gd and the canvas timing budget needed no change and pass | knowledge_ref: n/a)
- [X] T010 [US1] Extend tests/puzzle_canvas_check.gd corner reachability (`_pan_to_logical_corner`, `_check_zoom_pan_corners_and_invariants`) to assert each corner cell reaches the viewport center on the large board, and add checks that keyboard/gamepad pan (`move_*`), focused zoom/fit and Open Move reveal obey the bounds (Implements: FR-018, FR-019, FR-021, FR-022) (code_ref: tests/puzzle_canvas_check.gd::_check_zoom_pan_corners_and_invariants (corner to viewport center), held-key pan bounds in the focused-pan section | knowledge_ref: n/a)
- [X] T011 [US1] Run both regression gates and `<godot> --headless --editor --quit`; require `PUZZLE_VIEWPORT_FAILURES=0`, `PUZZLE_CANVAS_FAILURES=0` and all other markers zero; fix and re-run until clean (Implements: FR-022) (code_ref: n/a (verification: puzzle gate all 9 markers 0; run_regressions REGRESSION_FAILURES=0; editor validation on a project copy exit 0 with Godot 4.7.2) | knowledge_ref: n/a)
- [ ] T012 [US1] Desktop smoke per quickstart Part A on Simple Introduction and the Reference Knot: corners to center, edge zoom anchor, Fit, keyboard pan, gamepad stick pan and focused zoom/fit, Open Move, completion near an edge; judge the departure margin, measure the added time before Results on the Reference Knot, and set the final margin value; record results, any input method not available as not tested, and anything not run (Implements: FR-018, FR-019, FR-020, FR-021, FR-023) (code_ref: pending | knowledge_ref: pending)
- [ ] T013 [US1] First export the game (`node web/scripts/export-game.mjs --godot <godot>`) and build the site, record the build id tested, then browser-smoke the build via the showcase Play page in each supported desktop browser, then on the real Android phone (pinch near a corner, drag a corner to center, tap near the edge, Fit); record device/browser and untested devices (iPhone not claimed) (Implements: FR-018, FR-021) (code_ref: pending | knowledge_ref: pending)
- [X] T014 [US1] Update the Canvas Navigation section and the PuzzleFeedback constants paragraph (EXIT_CLEARANCE_MARGIN_CELLS is no longer a 0.001 tolerance) of .knowledge/architecture/arrow-puzzle.md (center clamp to the board rectangle, Fit lock, unclipped departures and exit margin, updated source-of-truth test descriptions) and review .knowledge/reference/touch-gestures.md for the "Bounds are the transform's own min/max" line (Implements: FR-016, FR-022, FR-023) (code_ref: n/a (knowledge only) | knowledge_ref: .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/game-visual-system.md, .knowledge/reference/touch-gestures.md)

**Checkpoint**: US1 complete and independently shippable; showcase may be rebuilt with the camera fix alone.

## Phase 4: User Story 2 - Hand-authored progression (Priority: P1)

**Goal**: about eight (six to ten) solver-proven levels in `arrowspark_levels` before the Reference Knot; Play starts the first; design learning recorded.

**Independent Test**: play the new levels in order to the Reference Knot; gates green; each has an intent note and a distinct primary challenge (quickstart Part B).

### Design

- [X] T015 [US2] Draft the progression outline as a working note in .devspark.work/specs/013-spec-progression-pack/level-outline.md: for each of about eight levels the working id, title, one-sentence design intent (distinct primary challenge), rough board size and arrow count, with a size ramp from just above Dense Board up to just below 46 × 32; use the spec's illustrative titles only as guidance (Implements: FR-004, FR-005, FR-006, FR-007) (code_ref: n/a (temporary outline only: level-outline.md in the working directory) | knowledge_ref: n/a)

### Authoring (sequential: all edit scripts/puzzle/puzzle_catalog.gd)

For each level: add a `_build_<id>` literal-data builder using the shape-list pattern of `_build_reference_knot` with a doc comment stating its design intent, add the entry to `_ensure_entries` in the `arrowspark_levels` group before `reference_knot`, run the solver/analyzer on it (valid and solvable with a witness), play it, and record the designer notes (where searched, insight, follow-ups, tedious or satisfying, rescan, best release). A candidate that is invalid, unsolvable or a chore of obvious clicks is fixed, revised or dropped, never shipped; if fewer than six survive, report the shortfall.

- [ ] T016 [US2] Author level 1 (working title First Knot): first step up from Foundations, long and bent arrows, small board (Implements: FR-001, FR-002, FR-003, FR-004, FR-005, FR-007, FR-012) (code_ref: pending | knowledge_ref: pending)
  <!-- WIP: level added to the catalog, solver-proven, intent comment written, structure measured. Not done: designer playtest notes (FR-012). -->
- [ ] T017 [US2] Author level 2 (Two Neighborhoods): two local clusters that depend on each other (Implements: FR-001, FR-002, FR-003, FR-004, FR-005, FR-007, FR-012) (code_ref: pending | knowledge_ref: pending)
  <!-- WIP: level added to the catalog, solver-proven, intent comment written, structure measured. Not done: designer playtest notes (FR-012). -->
- [ ] T018 [US2] Author level 3 (The Bridge): a single bridge arrow that gates two regions (Implements: FR-001, FR-002, FR-003, FR-004, FR-005, FR-007, FR-012) (code_ref: pending | knowledge_ref: pending)
  <!-- WIP: level added to the catalog, solver-proven, intent comment written, structure measured. Not done: designer playtest notes (FR-012). -->
- [ ] T019 [US2] Author level 4 (False Simplicity): apparent open moves that mislead, uncertainty then insight (Implements: FR-001, FR-002, FR-003, FR-004, FR-005, FR-007, FR-012) (code_ref: pending | knowledge_ref: pending)
  <!-- WIP: level added to the catalog, solver-proven, intent comment written, structure measured. Not done: designer playtest notes (FR-012). -->
- [ ] T020 [US2] Author level 5 (The Rescan): a release that forces a whole-board rescan (Implements: FR-001, FR-002, FR-003, FR-004, FR-005, FR-007, FR-012) (code_ref: pending | knowledge_ref: pending)
  <!-- WIP: level added to the catalog, solver-proven, intent comment written, structure measured. Not done: designer playtest notes (FR-012). -->
- [ ] T021 [US2] Author level 6 (Major Release): one move that opens several moves at once, then short follow-up chains (Implements: FR-001, FR-002, FR-003, FR-004, FR-005, FR-007, FR-012) (code_ref: pending | knowledge_ref: pending)
  <!-- WIP: level added to the catalog, solver-proven, intent comment written, structure measured. Not done: designer playtest notes (FR-012). -->
- [ ] T022 [US2] Author level 7 (Dense Weave): rising visual density from geometry, longer tails and more bends (Implements: FR-001, FR-002, FR-003, FR-004, FR-005, FR-007, FR-012) (code_ref: pending | knowledge_ref: pending)
  <!-- WIP: level added to the catalog, solver-proven, intent comment written, structure measured. Not done: designer playtest notes (FR-012). -->
- [ ] T023 [US2] Author level 8 (Almost a Knot): last lead-in to the Reference Knot, close to its scale and demand (Implements: FR-001, FR-002, FR-003, FR-004, FR-005, FR-006, FR-007, FR-012) (code_ref: pending | knowledge_ref: pending)
  <!-- WIP: level added to the catalog, solver-proven, intent comment written, structure measured. Not done: designer playtest notes (FR-012). -->
- [ ] T024 [US2] Review the set in order against the outline: each level names a different sole primary challenge, none relies on isolated single-cell arrows, no step is a cliff (including level 8 to the Reference Knot); record any judged cliff as a finding with its classification; adjust or drop levels and finalize ids and titles (ids are then stable) (Implements: FR-005, FR-006, FR-007, FR-014) (code_ref: pending | knowledge_ref: pending)

### Integration and tests

- [X] T025 [US2] Change `new_game()` in scenes/menus/main_menu/main_menu_with_animations.gd to start the first new level and update its comment; Reference Knot stays reachable as the last level (Implements: FR-017) (code_ref: scenes/menus/main_menu/main_menu_with_animations.gd::new_game | knowledge_ref: .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/save-progression.md)
- [X] T026 [US2] Update tests/puzzle_catalog_check.gd to the intended contents: total count, `arrowspark_levels` size, group positions, `reference_knot` position and `next_in_group` ending there, last-level-to-Knot Next Puzzle, `SAMPLED_BRANCH_ENTRY`, Play target, and per-level stable id/title/group checks (Implements: FR-001, FR-004, FR-010, FR-015, FR-017) (code_ref: tests/puzzle_catalog_check.gd (count, group sizes and positions, intended order, last level leads into the Reference Knot), tests/save_input_regression.gd (Play target) | knowledge_ref: tests/README.md)
- [X] T027 [P] [US2] Add per-level valid and solvable assertions with a witness order to tests/puzzle_analyzer_check.gd (following `_check_reference_knot_analyzes`), using the sampled-check precedent and recording the limitation if a solver run is too slow for the launcher limit (Implements: FR-002, FR-010) (code_ref: tests/puzzle_analyzer_check.gd::_check_progression_levels_analyze | knowledge_ref: n/a)
- [X] T028 [US2] Add content-version checks (after T026, same file) in tests/puzzle_catalog_check.gd: each new level has a distinct version, and every pre-existing puzzle (including `reference_knot`) keeps its current id, definition and version (Implements: FR-015) (code_ref: tests/puzzle_catalog_check.gd::_check_progression_levels (ids, titles, sizes, counts, pinned content versions, no singles), existing ORIGINAL_ENTRIES and the Reference Knot version pin | knowledge_ref: n/a)
- [X] T029 [US2] Run both regression gates and `<godot> --headless --editor --quit`; all failure markers zero (Implements: FR-002, FR-010) (code_ref: n/a (verification: puzzle gate all 9 markers 0 and run_regressions REGRESSION_FAILURES=0 with the eight levels; editor validation exit 0 on a project copy, Godot 4.7.2) | knowledge_ref: n/a)

### Evidence and learning

- [X] T030 [US2] Run `python tests/run_puzzle_structural_report.py --godot <godot>` and capture, for each new level where tooling reports them: arrow count, board size, density, initial legal moves, dependency depth and edges, components, longest chain, arrow length average and max, bends, single-cell count or share, with "unavailable" where not reported; record as descriptive data with no thresholds (Implements: FR-008, FR-009) (code_ref: n/a (verification: run_puzzle_structural_report.py output captured) | knowledge_ref: .knowledge/reference/progression-design-learning.md)
- [ ] T031 [US2] Create the design-learning record .knowledge/reference/progression-design-learning.md: per level the characteristics (T030), design intent and designer notes (FR-012); a short cross-level summary; separate sections for observed facts, designer judgments and open questions; acknowledge the single-tester limitation; make no generator commitment; contain no spec/plan/task identifiers (Implements: FR-004, FR-012, FR-013, FR-016) (code_ref: pending | knowledge_ref: pending)
  <!-- WIP: record written with per-level measured structure, cross-level observations and open questions. Not done: the designer's per-level playtest notes. -->
- [ ] T032 [US2] Desktop play-through of every new level to Results, Replay, Next Puzzle and Level Select, including starting Play and Level Select with mouse, keyboard and gamepad, and Next Puzzle from the last new level into the Reference Knot; record results and any input method not available as not tested (Implements: FR-011, FR-017) (code_ref: pending | knowledge_ref: pending)
- [ ] T033 [US2] Re-export the game and rebuild the site (as in T013) and record the build id; then browser smoke on the showcase build (each supported desktop browser) and on the real Android phone: open each new level, play a representative sample through, confirm completion hand-off and navigation incl. corner centering on a new level and the Reference Knot; anything not played is recorded as not tested (Implements: FR-011, FR-018) (code_ref: pending | knowledge_ref: pending)
- [X] T034 [US2] Update .knowledge/architecture/arrow-puzzle.md catalog and Play sections (new level ids/titles, group size, Play target, content-version note) and review .knowledge/architecture/web-showcase.md and .knowledge/reference/reference-puzzle-design-report.md for statements about "the only level" or "Play starts the Reference Knot" (Implements: FR-016) (code_ref: n/a (knowledge only) | knowledge_ref: .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/save-progression.md, CLAUDE.md)
- [X] T035 [P] [US2] Search web/src (content YAML, chapters, evidence, facts) for statements of puzzle counts, group sizes or "Play starts the Reference Knot"; update only wording that became untrue and, if any file changed, run `cd web && npm ci && npm run check && npm run build` (Implements: FR-016) (code_ref: n/a (no statement in web/src became untrue; no site file changed, so no site build was needed) | knowledge_ref: n/a)

**Checkpoint**: US2 complete; the showcase has the camera fix and the progression.

## Final Phase: Polish and Cross-Cutting

- [ ] T036 Classify every finding from verification as Blocking Defect, Accepted Limitation, Deferred Work or Learning / Changed Assumption in the verification notes; only Blocking Defects stop completion (Implements: FR-014) (code_ref: pending | knowledge_ref: pending)
- [X] T037 Confirm scope: `git diff` shows no change to puzzle rules, state, solver, scoring, hints, persistence, controls layout or site contracts beyond the camera/world clamp, departure clip and margin (Implements: FR-003, FR-022) (code_ref: n/a (git diff reviewed: only the camera clamp, departure clip and margin, catalog, Play target, tests and knowledge changed; no rules, state, solver, scoring, hint, persistence, controls layout or site code) | knowledge_ref: n/a)
- [X] T038 Run the knowledge index and integrity scripts (`.devspark/scripts/powershell/generate-knowledge-index.ps1`, `knowledge-integrity.ps1`) and `check-planning-references.ps1` to confirm no durable file references this spec, plan or tasks (code_ref: n/a (generate-knowledge-index and knowledge-integrity ran clean; check-planning-references reports only pre-existing binary and history.json matches in files this change did not touch) | knowledge_ref: .knowledge/index.json, .knowledge/ontology/coverage.json)
- [X] T039 Final run of both gates, Godot validation and (if web files changed) the site check and build; record the evidence and checks not run in the verification notes (code_ref: n/a (final run: both gates zero; editor validation clean on a fresh project copy; web unchanged so no site check) | knowledge_ref: n/a)
- [ ] T040 Populate `code_ref`/`knowledge_ref` on every completed task and leave this bundle in .devspark.work/ for `/devspark.release` to archive (code_ref: pending | knowledge_ref: pending)

## Dependencies and Execution Order

- Phase 1 first. US1 (T004 to T014) and US2 (T015 to T035) are independent; recommended order is US1 then US2.
- Within US1: T004 before T005, T006, T010; T007 and T008 [P] with each other and with T004; T009 after T007 and T008; T011 after T005, T006, T009, T010; T012 after T011; T013 after T012; T014 after T012 (final departure margin).
- Within US2: T015 before T016 to T023; T016 to T023 sequential (shared file); T024 after T023; T025 and T026 after T024; T027 after T024; T028 after T026; T029 after T026 to T028; T030 after T029; T031 after T030 and the designer notes; T032 to T033 after T029 (and after T012 if camera-dependent checks are combined); T034 and T035 after T024.
- Final Phase after both stories (or after US1 alone if shipping the camera fix first).

## Parallel Opportunities

- T003 beside T001 to T002; T007 beside T008; T035 beside T034.

## Implementation Strategy

1. MVP: Phase 1 then US1; rebuild and verify the showcase with the camera fix alone.
2. Then US2: outline, author levels one at a time with solver proof and play notes, integrate Play and tests, gather evidence, write the learning record.
3. Close with the Final Phase and hand off to `/devspark.verify` and `/devspark.release`.

## FR Coverage

FR-001 T016 to T023, T026 · FR-002 T016 to T023, T027, T029 · FR-003 T016 to T023, T037 · FR-004 T015 to T023, T026, T031 · FR-005 T015 to T024 · FR-006 T015, T023, T024 · FR-007 T015 to T024 · FR-008 T030 · FR-009 T030 · FR-010 T026, T027, T029 · FR-011 T032, T033 · FR-012 T016 to T023, T031 · FR-013 T031 · FR-014 T024, T036 · FR-015 T026, T028 · FR-016 T014, T031, T034, T035 · FR-017 T025, T026, T032 · FR-018 T004, T006, T010, T012, T013, T033 · FR-019 T004, T006, T010, T012 · FR-020 T004, T006, T007, T008, T012 · FR-021 T004, T006, T010, T012, T013 · FR-022 T005 to T011, T014, T037 · FR-023 T007, T008, T009, T012, T014
