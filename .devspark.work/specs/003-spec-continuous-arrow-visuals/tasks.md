# Tasks: Continuous Arrow Visuals and Game Visual Foundation

**Input**: C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/003-spec-continuous-arrow-visuals
**Prerequisites**: spec.md (clarified Draft), plan.md, research.md, data-model.md, contracts/presentation.md, quickstart.md.
**Route**: full-spec, medium risk. Checklist passes; analyze and critic are required separate reviews and have not been run by task generation.
**Scope**: Future implementation tasks only. Every box starts unchecked; complete actual code/test/current-knowledge linkage before checking it.

## Rationale Summary

The delta replaces disconnected tiles with continuous arrows and durable semantic styling while preserving all rules. Implement ordered visual geometry, owner-wide hover, deterministic feedback normalization, then scoped UI styling. Review actual behaviors and rendered outcomes; do not weaken domain expectations.

## Format and path conventions

All task paths below are absolute. [P] denotes independent file work after stated prerequisites, not permission to race shared files. Story labels map to the five accepted user stories. Every task retains code_ref/knowledge_ref placeholders until implementation; use justified n/a only when no corresponding durable file changed. Knowledge and production files must never link back to these temporary artifacts.

## Phase 1 — Baseline

- [ ] T001 Record branch/diff baseline, actual Godot version, isolated import/validation and both existing regression-launcher results in C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/003-spec-continuous-arrow-visuals/gates/verification.md using C:/GitHub/MakeBoldSolutions/ArrowGame/tests/run_puzzle_regressions.py and C:/GitHub/MakeBoldSolutions/ArrowGame/tests/run_regressions.py; confirm the unchanged domain files and existing test expectations before edits. (Implements: FR-014, FR-017) (code_ref: pending | knowledge_ref: pending)

## Phase 2 — Foundation

T001 precedes this phase. T002 and T003 can run independently; T004 follows T002. Finish all foundation tasks before US1.

- [ ] T002 [P] Bundle the official BeVietnamPro-Bold.ttf/BeVietnamPro-ExtraBold.ttf under C:/GitHub/MakeBoldSolutions/ArrowGame/assets/fonts/be_vietnam_pro/ and upright InterTight[wght].ttf under C:/GitHub/MakeBoldSolutions/ArrowGame/assets/fonts/inter_tight/, retaining both OFL.txt notices; add 400/600/numeric FontVariation resources under C:/GitHub/MakeBoldSolutions/ArrowGame/resources/fonts/ and source revision/hashes/attribution to C:/GitHub/MakeBoldSolutions/ArrowGame/ATTRIBUTION.md. Query actual tnum support and digit advances; enable it when supported and record allowed fallback otherwise. Ensure licenses ship with exported assets. (Implements: FR-011, FR-016) (code_ref: pending | knowledge_ref: pending)
- [ ] T003 [P] Extend C:/GitHub/MakeBoldSolutions/ArrowGame/tests/run_puzzle_regressions.py to import the real project with isolated APPDATA/XDG_DATA_HOME before scene checks, and run new C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_presentation_check.gd with bounded timeout, exit-code and PUZZLE_PRESENTATION_FAILURES=0 enforcement; preserve the pure-rule copy list/expectations and existing markers. Add harness/bootstrap plus a real scene-instantiation smoke check; add behavioral cases in story tasks. (Implements: FR-017) (code_ref: pending | knowledge_ref: pending)
- [ ] T004 Create C:/GitHub/MakeBoldSolutions/ArrowGame/scripts/presentation/game_visual_style.gd with all exact semantic palette/spacing/shape/shadow roles, font references, initial geometry ratios, hover duration and 1.10 pulse amplitude from plan.md; keep blocked/exit duration authority in C:/GitHub/MakeBoldSolutions/ArrowGame/scripts/puzzle/puzzle_feedback.gd without adding any UI/font dependency to it. Reserve the local Theme factory interface for US4 and keep rule scripts independent. (Implements: FR-004, FR-007, FR-012) (code_ref: pending | knowledge_ref: pending)

## Phase 3 — US1: Read a Continuous Arrow (P1)

**Goal**: One connected arrow silhouette for every existing shape.
**Independent test**: Straight, single-cell, and multi-turn fixtures in all four directions at both supported sizes; inspect ordered points and rendered seams.
**Dependencies**: Foundation.

- [ ] T005 [US1] Add failing geometry cases to C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_presentation_check.gd for all four head directions, empty tails, variable lengths/multiple bends, the shipped A shape's nonconsecutive adjacency, body/head overlap, and two cell extents. Assert only ordered connections and no new domain occupancy; use isolated definitions without editing create_fixed. (Implements: FR-001, FR-002, FR-003) (code_ref: pending | knowledge_ref: pending)
- [ ] T006 [US1] Replace per-cell rectangles in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_view.gd with passive antialiased Line2D/Polygon2D children using the plan's ordered cell-center geometry, rounded joins/tail cap, same opaque semantic ink, explicit head draw order, and compact in-cell single-arrow shaft; keep public setup and departure interfaces intact. (Implements: FR-001, FR-002, FR-003) (code_ref: pending | knowledge_ref: pending)
- [ ] T007 [US1] Integrate cell-extent rebuilds and preserved whole-view bounds in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/puzzle_board.gd and C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_view.gd; keep parent scale ONE for layout, existing cell click mapping, and departing views excluded from active resize relayout. Do not add grid/cell backgrounds or adjacency-based connection discovery. (Implements: FR-001, FR-002, FR-003, FR-006) (code_ref: pending | knowledge_ref: pending)
- [ ] T008 [US1] Run the isolated launcher and validate geometry/layout checks in C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_presentation_check.gd and C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_layout_check.gd; record automated outcomes and rendered straight/bent/single-cell preview findings in C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/003-spec-continuous-arrow-visuals/gates/verification.md, leaving unavailable visual checks outstanding. (Implements: FR-001, FR-002, FR-003, FR-017) (code_ref: pending | knowledge_ref: pending)
- [ ] T009 [US1] Update current geometry/rendering descriptions in C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/arrow-puzzle.md and introduce typed C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/game-visual-system.md with implemented silhouette/spacing/ink decisions and appliesTo/source evidence. Describe only behavior implemented so far and omit all temporary planning backlinks. (Implements: FR-001, FR-002, FR-003, FR-016) (code_ref: pending | knowledge_ref: pending)

## Phase 4 — US2: Identify and Select the Whole Arrow (P1)

**Goal**: Owner-wide hover and unchanged generous clicking.
**Independent test**: Head/tail/blank-cell pointer events, same-owner continuity, owner changes/exit/removal; counters unchanged under hover alone.
**Dependencies**: US1; T010-T014 are sequential because board/controller/view/test integration shares contracts.

- [ ] T010 [US2] Add hover/event cases to C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_presentation_check.gd using InputEventMouseMotion/Button through GUI input or viewport dispatch, including same-owner cell changes, empty/outside cells, blank occupied-cell clicks, button release, and unchanged state snapshots under hover. Add clear-on-removal and focus/pause/overlay eligibility cases. (Implements: FR-005, FR-006) (code_ref: pending | knowledge_ref: pending)
- [ ] T011 [US2] Add hover_cell_changed and owner-based set_hovered_head handling to C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/puzzle_board.gd; sample raw board-local cells only, refresh stationary pointer after resize/resume, clear on pointer/window exit/focus loss/pause/setup/removal, and suppress hover beneath overlays using GUI eligibility. Preserve discrete left-press selection exactly. (Implements: FR-005, FR-006) (code_ref: pending | knowledge_ref: pending)
- [ ] T012 [US2] Wire board hover cells through existing PuzzleState.get_arrow_head in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_puzzle.gd and return canonical owner/null to the board; clear on results/new attempt. Never invoke select_arrow/is_blocked for hover or introduce a second active ownership map. (Implements: FR-005, FR-006, FR-014) (code_ref: pending | knowledge_ref: pending)
- [ ] T013 [US2] Implement idempotent set_hovered and owner-wide 120ms ease-out color transitions in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_view.gd, applying color to both children while retaining mouse-filter IGNORE; avoid transition restarts within one owner and prepare the departing guard. Run owner/event cases without altering domain expectations. (Implements: FR-005, FR-006, FR-012) (code_ref: pending | knowledge_ref: pending)
- [ ] T014 [US2] Document implemented hover routing, full-cell targets, lifecycle clearing, and semantic hover usage in C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/arrow-puzzle.md and C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/game-visual-system.md, citing actual production and presentation-test evidence. (Implements: FR-005, FR-006, FR-016) (code_ref: pending | knowledge_ref: pending)

## Phase 5 — US3: Clear Feedback and Clean Departures (P1)

**Goal**: Temporary red feedback, restrained pulse, guaranteed normalized departure.
**Independent test**: Rising/peak/falling pulse and hover-transition interruption; immediate ONE/ink assertion before a frame; stale requests ignored and exactly one completion.
**Dependencies**: US2; effects build on hover state.

- [ ] T015 [US3] Add failing interruption/precedence cases to C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_presentation_check.gd: repeated pulse replacement, hover moving during red, immediate eligible ember resumption, departure at rising/peak/falling/hover-transition phases, immediate normal properties, stale feedback rejection, and duplicate-exit prevention. Use deterministic tween progression for phase placement where useful. (Implements: FR-007, FR-008, FR-009, FR-010) (code_ref: pending | knowledge_ref: pending)
- [ ] T016 [US3] Implement explicit hover/blocked/departing flags and separate color/effect handles in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_view.gd; blocked overrides hover with red and 0.15s 1.10 pulse, ends at ONE and immediate eligible ember/ink. Departure marks terminal state first, kills both handles, restores normal ink/scale/transient properties synchronously, then performs the existing rigid 0.25s exit; ignore later requests. (Implements: FR-007, FR-008, FR-009, FR-010, FR-012) (code_ref: pending | knowledge_ref: pending)
- [ ] T017 [US3] Preserve exactly-once departure routing in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/puzzle_board.gd and pending completion behavior in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_puzzle.gd; connect completion before starting exit, erase active view/hover immediately, and extend C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_presentation_check.gd / C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_layout_check.gd with staggered concurrent exits, completed-input ignoring, resize/pause lifecycle, and fresh reconstruction checks. Keep immediate rule mutation unchanged. (Implements: FR-009, FR-010, FR-014) (code_ref: pending | knowledge_ref: pending)
- [ ] T018 [US3] Update effect precedence, interruption normalization, timings, pulse amplitude, and completion lifecycle in C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/arrow-puzzle.md and C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/game-visual-system.md; record test evidence and retained domain boundary. (Implements: FR-007, FR-008, FR-009, FR-010, FR-016) (code_ref: pending | knowledge_ref: pending)

## Phase 6 — US4: Coherent Light Visual System (P2)

**Goal**: Supplied palette/font roles in gameplay and current results, with preserved navigation and local theme scope.
**Independent test**: Both screen sizes, fonts/numerics/focus, success cue, no HUD overlap, and actual menu/pause/Replay/Restart roundtrips.
**Dependencies**: US3 and bundled font resources. T021 and T022 may be parallel after T020 because they touch different scenes/scripts; shared style changes stay serialized.

- [ ] T019 [US4] Add theme/font-role and layout acceptance cases to C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_presentation_check.gd and C:/GitHub/MakeBoldSolutions/ArrowGame/tests/puzzle_layout_check.gd; check real bundled family/weight resources, numeric capability/fallback, two sizes, visible focus, results fields/actions, and theme isolation from pause/options. Preserve existing expected labels/formulas or adapt only visual structural assertions with the same behavioral meaning. (Implements: FR-004, FR-011, FR-013, FR-015) (code_ref: pending | knowledge_ref: pending)
- [ ] T020 [US4] Complete the cached local Theme factory in C:/GitHub/MakeBoldSolutions/ArrowGame/scripts/presentation/game_visual_style.gd with semantic heading/supporting/label/numeric/button/surface roles and visible keyboard focus; use bundled font resources and exact palette/tokens, initial readable role sizes, and shared StyleBox values. Avoid global theme changes and per-arrow colors. (Implements: FR-004, FR-011, FR-012) (code_ref: pending | knowledge_ref: pending)
- [ ] T021 [P] [US4] Apply ignored-input light background and scoped Layout/HUD styling in C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_puzzle.tscn and C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_puzzle.gd, preserving unique node names and counter updates. Do not apply the theme to the root where inherited pause/options are attached. Verify no HUD/board overlap or cell/grid backgrounds. (Implements: FR-003, FR-004, FR-011, FR-015) (code_ref: pending | knowledge_ref: pending)
- [ ] T022 [P] [US4] Apply local light palette/fonts to C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/puzzle_results.tscn and C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/puzzle_results.gd; use success green on the existing score display, keep the four metrics/two actions and basic layout, preserve full-overlay input absorption and Replay focus, and avoid new result content or broad redesign. (Implements: FR-004, FR-011, FR-013, FR-015) (code_ref: pending | knowledge_ref: pending)
- [ ] T023 [US4] Run presentation/layout/save-input suites via C:/GitHub/MakeBoldSolutions/ArrowGame/tests/run_puzzle_regressions.py and C:/GitHub/MakeBoldSolutions/ArrowGame/tests/run_regressions.py; inspect localized theme and font/layout failures and record results in C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/003-spec-continuous-arrow-visuals/gates/verification.md. Confirm styling has not changed domain expectations or remap/no-reset behavior. (Implements: FR-011, FR-014, FR-015, FR-017) (code_ref: pending | knowledge_ref: pending)
- [ ] T024 [US4] Update implemented typography, theme scope, success cue, and HUD/results behavior in C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/game-visual-system.md and C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/arrow-puzzle.md; include actual font sources/licenses and tnum findings, retaining untouched save-progression contracts. (Implements: FR-004, FR-011, FR-012, FR-013, FR-015, FR-016) (code_ref: pending | knowledge_ref: pending)

## Phase 7 — US5: Reuse the Game Visual Language (P2)

**Goal**: Complete durable semantic vocabulary and discoverable evidence.
**Independent test**: Contributor can understand roles and reuse styling from current knowledge/source without the temporary bundle.
**Dependencies**: US1-US4, whose incremental knowledge edits are consolidated here.

- [ ] T025 [US5] Complete C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/game-visual-system.md with every supplied palette/font/spacing/radius/border/shadow/motion role, intended usage and rationale, actual tuned proportions/amplitude, unused-token guidance, owner-hover/effect precedence, theme scope, and durable code/test evidence; remove stale tile/pulse descriptions from C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/architecture/arrow-puzzle.md. (Implements: FR-016) (code_ref: pending | knowledge_ref: pending)
- [ ] T026 [US5] Run C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark/scripts/powershell/generate-knowledge-index.ps1 and C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark/scripts/powershell/validate-knowledge-coverage.ps1 using their documented parameters/override resolution after inspecting help; verify new appliesTo/source paths and refresh C:/GitHub/MakeBoldSolutions/ArrowGame/.knowledge/index.json and generated coverage outputs as appropriate. Do not add feature/requirement/task nodes to durable knowledge. (Implements: FR-016) (code_ref: pending | knowledge_ref: pending)
- [ ] T027 [US5] Update C:/GitHub/MakeBoldSolutions/ArrowGame/tests/README.md with the presentation marker, import/user-data isolation, and rendered/physical verification limits; audit C:/GitHub/MakeBoldSolutions/ArrowGame/scripts/presentation/game_visual_style.gd and current visual knowledge for consistent named tokens and absent temporary backlinks, with evidence recorded in C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/003-spec-continuous-arrow-visuals/gates/verification.md. (Implements: FR-016, FR-017) (code_ref: pending | knowledge_ref: pending)

## Phase 8 — Final Verification and Consistency

- [ ] T028 Run final isolated Godot import/validation and all puzzle/presentation/save-input checks via C:/GitHub/MakeBoldSolutions/ArrowGame/tests/run_puzzle_regressions.py and C:/GitHub/MakeBoldSolutions/ArrowGame/tests/run_regressions.py; require each marker plus exit zero and record actual engine/version, outcomes and baseline discrepancy in C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/003-spec-continuous-arrow-visuals/gates/verification.md. Keep unavailable baseline-version checks outstanding. (Implements: FR-014, FR-017) (code_ref: pending | knowledge_ref: pending)
- [ ] T029 Perform rendered desktop matrix in C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/003-spec-continuous-arrow-visuals/quickstart.md at 1280×720 and 960×540 and during resize; inspect all shapes/directions, seam/negative space/fonts, actual mouse targets, red/hover feedback, first-frame normalization, concurrent exits and results. Tune only presentation ratios/amplitude within accepted bounds in C:/GitHub/MakeBoldSolutions/ArrowGame/scripts/presentation/game_visual_style.gd, then synchronize current knowledge and rerun affected checks. Record captures/results under C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/003-spec-continuous-arrow-visuals/gates/; leave this task unchecked if rendered verification is unavailable. (Implements: FR-001, FR-002, FR-003, FR-005, FR-007, FR-008, FR-009, FR-010, FR-011, FR-017) (code_ref: pending | knowledge_ref: pending)
- [ ] T030 Perform physical keyboard/gamepad menu/pause/results focus and remap checks, pause/resume mid-effect, Restart cancel/confirm, Replay and Main Menu roundtrips using isolated seeded settings/progress; record evidence against C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/arrow_puzzle.tscn and C:/GitHub/MakeBoldSolutions/ArrowGame/scenes/puzzle/puzzle_results.tscn in C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/003-spec-continuous-arrow-visuals/gates/verification.md. Do not claim missing hardware checks passed or change persistence code to accommodate styling. (Implements: FR-014, FR-015, FR-017) (code_ref: pending | knowledge_ref: pending)
- [ ] T031 Audit final diff for unchanged domain authorities and behavioral expectations, run C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark/scripts/powershell/check-planning-references.ps1 plus git diff --check, and fill all completed task linkage in C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/003-spec-continuous-arrow-visuals/tasks.md with actual durable paths or justified n/a. Record remaining review/verification gates; retain the complete feature bundle for release archival, never delete it here. (Implements: FR-014, FR-016, FR-017) (code_ref: pending | knowledge_ref: pending)

## Dependencies and Parallel Execution

T001 -> {T002 fonts, T003 test harness} -> T004 style -> US1 (T005–T009) -> US2 (T010–T014) -> US3 (T015–T018) -> US4 (T019–T024) -> US5 (T025–T027) -> final verification (T028–T031).

T004 technically depends on T002, while US1 requires both the harness and styling. T002/T003 are the independent foundation opportunity. US4's T021/T022 may proceed together only after T020; any change to the shared factory or tests must be serialized. Other story work shares scripts/tests/knowledge and has no safe write-parallel task pair. Optional independent rendered review may run alongside read-only review once that story's code is stable, but it does not authorize simultaneous edits. All knowledge updates are serialized.

## Implementation Strategy

Foundation plus US1 is the smallest visual preview: continuous ink arrows with existing gameplay. It is not complete delivery. Add owner hover, then precedence/normalized feedback, then local palette/typography and consolidated knowledge. Run meaningful focused checks at each boundary; expand/repeat only after relevant changes or failures. Final acceptance requires all five stories, unchanged domain regressions, mandatory rendered/physical checks, and required review gates.

## Coverage and Gates

- US1: FR-001/002/003 and whole-cell preservation.
- US2: FR-005/006/012 and domain isolation.
- US3: FR-007/008/009/010/012 and completion preservation.
- US4: FR-004/011/012/013/015, with foundation assets/tokens.
- US5: FR-016; baseline/final verification plus story checks cover FR-014/017.
- Constitution I/II: focused snake_case project scripts and no addon edits throughout; III: T019/T021/T022/T030; IV: T011/T013/T016/T029; V: T001/T028–T030; VI: T023/T028/T030.
- Requirements checklist: 26/26 complete at task-generation prerequisite check. No existing analyze/critic findings or incomplete checklist was bypassed; no Gate Acknowledgements exception applies.
- Required analyze/critic reviews remain pending; task generation is not their execution.
- Shared preamble explicitly reserves archival for release and overrides the stale task-template instruction to delete the feature directory.

