---

devspark_version: "9.2.0"

plan_semantic_hash: "sem1:8320b896b4927e1fa5879b7a298daa69ef39a73f3623b93521c2464ae82fc2dd"

participants:

  owner: human

  planner: ai

  implementer: ai

  reviewer: human

  critic: ai

  scribe: ai

---



# Tasks: Maximize Mobile Web Portrait Gameplay



**Branch**: `017-spec-mobile-portrait-play`

**Created**: 2026-10-18

**Input directory**: `C:/GitHub/MakeBoldSolutions/ArrowGame/.devspark.work/specs/017-spec-mobile-portrait-play`

**Repository root**: `C:/GitHub/MakeBoldSolutions/ArrowGame`

**Inputs**: [spec.md](spec.md), [plan.md](plan.md), [research.md](research.md), [UI contract](contracts/portrait-ui.md), [quickstart.md](quickstart.md), [qa-acceptance.md](qa-acceptance.md); constitution version 2.3.0.



All file paths below resolve against the absolute repository root above. Tasks are a projection of the current Plan, not permission to redesign it. Implementation progress and remaining verification are recorded below. `[P]` identifies independent file work only, not an instruction to spawn agents.



**Execution**: Complete phase prerequisites before story implementation. Tests marked update/add come from QA regression dispositions; retain rule, catalog, scoring and settings expectations. Write the focused checks before their corresponding production change and verify them after integration. An intermediate failing check is not final verification evidence.



**Linkage**: Each task starts with pending linkage. Before marking it complete, populate every actual production/test path in code_ref and every affected current-knowledge path in knowledge_ref. Use n/a only with a reason when that category was not changed. Related documentation tasks finish in the same story increment; do not mark a behavior item complete while its necessary knowledge update is still pending. Durable files must never link back to this bundle.



## Phase 1: Setup



- [X] T001 Record the candidate commit, pinned-engine/tool availability, isolated manual-test data location, current layout captures and HTTPS phone-origin status (no longer a pre-merge blocker) in `.devspark.work/specs/017-spec-mobile-portrait-play/evidence/baseline.md`, following Plan Verification Strategy and `quickstart.md`; do not deploy or provision a public service (code_ref: n/a baseline environment record only | knowledge_ref: n/a no behavior changed)


**Checkpoint**: Phase complete — 2026-10-18



## Phase 2: Foundational



- [X] T002 Update `tests/app_theme_check.gd` for mobile CSS-equivalent logical sizing, DPR projection, narrow/native fixtures, unchanged wide desktop scaling and paused/zero-size recovery per Plan Logical units and responsive ownership and QA-09 (Implements: FR-009, FR-010) (code_ref: tests/app_theme_check.gd | knowledge_ref: .knowledge/architecture/game-visual-system.md)

- [X] T003 Add the pure sizing helper in `scripts/presentation/responsive_layout.gd` and integrate startup/coalesced resize policy into `scripts/app_theme.gd`; keep updates active while paused and retain the last usable dimensions on invalid input (Implements: FR-009, FR-010, FR-013) (code_ref: scripts/app_theme.gd, scripts/presentation/responsive_layout.gd, tests/app_theme_check.gd | knowledge_ref: .knowledge/architecture/game-visual-system.md)



**Checkpoint**: T002 passes against T003; existing desktop theme checks remain intact. Scene reflow belongs to the story phases, not the sizing helper.


**Checkpoint**: Phase complete — 2026-10-18



## Phase 3: User Story 1 â€” Play upright (Priority: P1)



**Goal**: Implement the portrait entry and viewport/gesture lifecycle from US1.

**Independent Test**: SC-001 admission/frame checks and SC-003 board gestures; a direct First Knot scene fixture may isolate board behavior before US3 menu reflow.



### Tests for User Story 1



- [X] T004 [P] [US1] Update `web/tests/play-admission.test.ts` for the portrait/landscape/desktop floors, below-floor boundaries, hybrid capabilities and visible-viewport resizing, retiring rotate-only expectations per QA-01 (Implements: FR-001) (code_ref: web/tests/play-admission.test.ts | knowledge_ref: .knowledge/architecture/web-showcase.md)

- [X] T005 [P] [US1] Update `tests/puzzle_canvas_check.gd` for cancelled-release, resize during tap/pinch, pause/focus interruption and scaled corner-reach behavior per QA-04 and QA-05 (Implements: FR-005, FR-006, FR-010) (code_ref: tests/puzzle_canvas_check.gd | knowledge_ref: .knowledge/reference/touch-gestures.md)



### Implementation for User Story 1



- [X] T006 [US1] Update `web/src/scripts/play-admission.ts` for orientation-specific touch floors and normalized visible-viewport measurement while retaining fine-pointer admission (Implements: FR-001) (code_ref: web/src/scripts/play-admission.ts, web/tests/play-admission.test.ts | knowledge_ref: .knowledge/architecture/web-showcase.md)

- [X] T007 [US1] Update `web/src/components/play/GameFrame.astro` and `web/src/styles/arrowspark.css` for coalesced viewport admission, src-once retention, touch-height grid, scroll-away header, safe areas and optional host fullscreen; retain touch-action: none on stage and `web/game-shell/shell.css` and add overscroll-behavior: none at both surfaces to prevent pull-to-refresh/scroll chaining (Implements: FR-002, FR-005, FR-010) (code_ref: web/src/components/play/GameFrame.astro, web/src/styles/arrowspark.css, web/game-shell/shell.css | knowledge_ref: .knowledge/architecture/web-showcase.md, .knowledge/reference/touch-gestures.md)

- [X] T008 [US1] Update admission notices in `web/src/components/play/PlayUnavailableNotice.astro` and portrait/direct-gesture copy in `web/src/pages/play.astro`, removing rotate-only and removed-toolbar instructions and requiring play.astro copy to state support is unverified outside Pixel/Chrome, including potentially admitted iPhone Safari (Implements: FR-001, FR-014) (code_ref: web/src/pages/play.astro, web/src/components/play/PlayUnavailableNotice.astro | knowledge_ref: .knowledge/architecture/web-showcase.md)

- [X] T009 [US1] Add `web/scripts/check-portrait-play.mjs` using existing browser tooling to exercise the real export's admission, frame bounds, overflow, screenshot/density fixtures and iframe/src retention per QA-02 and QA-10 (Implements: FR-001, FR-002, FR-010) (code_ref: web/scripts/check-portrait-play.mjs | knowledge_ref: .knowledge/architecture/web-showcase.md)

- [X] T010 [US1] Update `scenes/puzzle/puzzle_board.gd` to clear gestures before all resize reprojections and handle explicit cancellation before tap release; retain `_touch_slop`, the existing transform and Fit/manual behavior (Implements: FR-005, FR-006, FR-010) (code_ref: scenes/puzzle/puzzle_board.gd, tests/puzzle_canvas_check.gd | knowledge_ref: .knowledge/reference/touch-gestures.md)

- [X] T011 [US1] Update `.knowledge/architecture/web-showcase.md` and `.knowledge/reference/touch-gestures.md` for the implemented admission/frame/cancellation delta and `.knowledge/architecture/game-visual-system.md` for logical sizing; extend appliesTo ownership to new responsive code where needed, without claiming physical verification not yet obtained (Implements: FR-014) (code_ref: scripts/app_theme.gd, scripts/presentation/responsive_layout.gd, scenes/puzzle/puzzle_board.gd, web/src/scripts/play-admission.ts, web/src/components/play/GameFrame.astro, web/src/styles/arrowspark.css, web/game-shell/shell.css, tests/app_theme_check.gd, tests/puzzle_canvas_check.gd, web/tests/play-admission.test.ts | knowledge_ref: .knowledge/architecture/web-showcase.md, .knowledge/reference/touch-gestures.md, .knowledge/architecture/game-visual-system.md)



**Checkpoint**: QA-01/02/05 automated portions pass; browser fixtures exercise the candidate export. Full owner journey remains required after all stories.


**Checkpoint**: Phase complete - 2026-10-18



## Phase 4: User Story 2 â€” Give the puzzle space (Priority: P1)



**Goal**: Implement the minimal active surface and shared pause/menu integration from US2.

**Independent Test**: SC-002 geometry/action count plus QA-06/07/11 on direct puzzle fixtures; menu presentation completeness is finished in US3.



### Tests for User Story 2



- [X] T012 [US2] Update `tests/puzzle_layout_check.gd` for the portrait bottom three-action strip within safe areas, top status, unchanged landscape/desktop header, board-area fraction and visual-order focus graph, duplicate-menu guard, nested Options pause/focus restoration and deliberate navigation per QA-03/06/07/11 (Implements: FR-003, FR-004, FR-007, FR-011) (code_ref: tests/puzzle_layout_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)



### Implementation for User Story 2



- [X] T013 [US2] Rebuild the HUD/actions in `scenes/puzzle/arrow_puzzle.tscn` and its bindings in `scenes/puzzle/arrow_puzzle.gd` as Menu/Open Move/Fit in a portrait-touch safe-area bottom strip with top status (landscape/desktop retain the header) and an expanding board; record the board-area ratio at 360x640 immediately when that layout exists as an early signal against the 112-unit chrome budget, retaining T030 as the full matrix; remove redundant nodes, persistent help and stale Zoom/Pan/Back references (Implements: FR-003, FR-004) (code_ref: scenes/puzzle/arrow_puzzle.tscn, scenes/puzzle/arrow_puzzle.gd, tests/puzzle_layout_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/game-visual-system.md)

- [X] T014 [US2] Add `scripts/presentation/puzzle_pause_controller.gd` as the planned PauseMenuController extension and wire its single guarded Menu/cancel entry in `scenes/puzzle/arrow_puzzle.tscn` and `scenes/puzzle/arrow_puzzle.gd`, respecting draining/Results eligibility (Implements: FR-007, FR-011, FR-013) (code_ref: scripts/presentation/puzzle_pause_controller.gd, scenes/puzzle/arrow_puzzle.tscn, scenes/puzzle/arrow_puzzle.gd, tests/puzzle_layout_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

- [X] T015 [US2] Extend `scenes/overlaid_menus/pause_menu.gd` and `scenes/overlaid_menus/pause_menu.tscn` with Level Select, control help and the retained optional mouse Pan capability through the existing pause/confirmation flow; keep nested Options ownership intact (Implements: FR-007, FR-011, FR-012) (code_ref: scenes/overlaid_menus/pause_menu.gd, tests/puzzle_layout_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/save-progression.md)

- [X] T016 [US2] Rebuild visual-order focus (portrait board -> Menu -> Open Move -> Fit -> board; landscape/desktop Menu -> Open Move -> Fit -> board) and remap-derived input help in `scenes/puzzle/arrow_puzzle.gd`, `scenes/puzzle/puzzle_board.gd` and `scenes/overlaid_menus/pause_menu.gd`; retain wheel/middle-drag and bound keyboard/gamepad canvas actions (Implements: FR-005, FR-011) (code_ref: scenes/puzzle/arrow_puzzle.gd, scenes/overlaid_menus/pause_menu.gd, tests/puzzle_canvas_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md, .knowledge/reference/touch-gestures.md)

- [X] T017 [US2] Update changed scene-path/control assertions in `tests/puzzle_presentation_check.gd` and affected assertions in `tests/puzzle_layout_check.gd`/`tests/puzzle_canvas_check.gd`, preserving all score, result, departure and state-retention expectations per QA-12 (Implements: FR-012, FR-013) (code_ref: tests/puzzle_canvas_check.gd, tests/puzzle_layout_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md)

- [X] T018 [US2] Update `.knowledge/architecture/arrow-puzzle.md`, `.knowledge/reference/touch-gestures.md`, `.knowledge/architecture/game-visual-system.md` and `.knowledge/architecture/save-progression.md` for resulting active controls, focus, pause navigation and optional mouse Pan location; extend new controller ownership without changing the gameplay contract (Implements: FR-014) (code_ref: scenes/puzzle/arrow_puzzle.gd, scenes/puzzle/arrow_puzzle.tscn, scenes/overlaid_menus/pause_menu.gd, scripts/presentation/puzzle_pause_controller.gd, tests/puzzle_canvas_check.gd, tests/puzzle_layout_check.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/game-visual-system.md, .knowledge/reference/touch-gestures.md, .knowledge/architecture/save-progression.md)



**Checkpoint**: Three actions remain; compact area checks and menu lifecycle checks pass. Mouse/keyboard/gamepad actions remain available without hidden focus targets.


**Checkpoint**: Phase complete - 2026-10-18



## Phase 5: User Story 3 â€” Finish the portrait journey (Priority: P2)



**Goal**: Implement the responsive menu and Results journey from US3.

**Independent Test**: SC-004 and SC-005 using QA-07/08/09/10; use the completed US1 host and US2 active surface for final integration.



### Tests for User Story 3



- [X] T019 [US3] Update `tests/app_theme_check.gd` and `tests/puzzle_layout_check.gd` for narrow menu/dialog/Results bounds, long content, focus-follow scrolling, target/text projections, resize while paused and attempt/score retention across size cycles per QA-08/09/10 (Implements: FR-008, FR-009, FR-010) (code_ref: tests/app_theme_check.gd, tests/puzzle_layout_check.gd, tests/portrait_menu_check.gd, tests/run_puzzle_regressions.py | knowledge_ref: .knowledge/architecture/game-visual-system.md)



### Implementation for User Story 3



- [X] T020 [US3] Add required compact display-heading variations in `scripts/presentation/game_visual_style.gd`, preserving the palette, body-text floor, target floors and expanded desktop roles (Implements: FR-008, FR-009) (code_ref: scripts/presentation/game_visual_style.gd, scenes/menus/main_menu/main_menu_with_animations.gd | knowledge_ref: .knowledge/architecture/game-visual-system.md)

- [X] T021 [P] [US3] Reflow `scenes/menus/main_menu/main_menu_with_animations.tscn` and `.gd` for compact stacked hero/actions and full-width submenus, retaining stable animation paths and existing Play/Level Select semantics (Implements: FR-008, FR-009) (code_ref: scenes/menus/main_menu/main_menu_with_animations.gd, scenes/menus/main_menu/main_menu_with_animations.tscn, tests/run_regressions.py | knowledge_ref: .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/game-visual-system.md, .knowledge/architecture/save-progression.md)

- [X] T022 [P] [US3] Reflow `scenes/menus/main_menu/puzzle_select_menu.gd` and `.tscn` to fitting card columns, wrapping and focus-follow vertical scrolling without changing ids/group order or accordion behavior (Implements: FR-008, FR-009, FR-011, FR-012) (code_ref: scenes/menus/main_menu/puzzle_select_menu.gd | knowledge_ref: .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/save-progression.md)

- [X] T023 [P] [US3] Adapt the project master Options shell in `scenes/menus/options_menu/master_options_menu.gd` and `master_options_menu_with_tabs.tscn` for narrow-safe tab navigation and bounded scrolling per Plan Main Menu, Level Select, Options and Results (Implements: FR-008, FR-009, FR-011) (code_ref: scenes/menus/options_menu/master_options_menu.gd, scripts/presentation/responsive_layout.gd | knowledge_ref: .knowledge/architecture/save-progression.md, .knowledge/architecture/game-visual-system.md)

- [X] T024 [P] [US3] Adapt inherited input/remap rows through project files `scenes/menus/options_menu/input/input_options_menu.gd`, `input_options_menu.tscn` and `input_extras_menu.tscn`, retaining capture, mixed bindings and focus navigation per QA-08/11 (Implements: FR-008, FR-009, FR-011, FR-012) (code_ref: scenes/menus/options_menu/input/input_options_menu.gd, scripts/presentation/responsive_layout.gd | knowledge_ref: .knowledge/architecture/save-progression.md)

- [X] T025 [P] [US3] Reflow project audio/video/game option controls under `scenes/menus/options_menu/audio/`, `video/` and `game/`, including the hard game-menu minimum and reset dialog bounds; preserve current settings values and confirmation semantics (Implements: FR-008, FR-009, FR-012) (code_ref: scripts/presentation/responsive_layout.gd, scenes/menus/options_menu/master_options_menu.gd, scenes/menus/options_menu/mini_options_menu_with_reset.gd | knowledge_ref: .knowledge/architecture/save-progression.md, .knowledge/architecture/game-visual-system.md)

- [X] T026 [US3] Complete narrow/short pause, help, nested mini-options and dialog presentation in `scenes/overlaid_menus/pause_menu.gd`, `pause_menu.tscn`, `mini_options_overlaid_menu.tscn` and `scenes/menus/options_menu/mini_options_menu_with_reset.tscn`, preserving the integrated lifecycle (Implements: FR-007, FR-008, FR-009, FR-011) (code_ref: scenes/overlaid_menus/pause_menu.gd, scenes/overlaid_menus/mini_options_overlaid_menu.gd, scenes/overlaid_menus/mini_options_overlaid_menu.tscn, scenes/menus/options_menu/mini_options_menu_with_reset.gd, tests/puzzle_layout_check.gd | knowledge_ref: .knowledge/architecture/save-progression.md, .knowledge/architecture/arrow-puzzle.md)

- [X] T027 [US3] Adapt `scenes/puzzle/puzzle_results.tscn` and `.gd` to bounded scrolling and compact stacked actions with live resize, preserving every metric, signal and replay/group-transition outcome (Implements: FR-008, FR-009, FR-010, FR-012) (code_ref: scenes/puzzle/puzzle_results.gd, scenes/puzzle/puzzle_results.tscn | knowledge_ref: .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/game-visual-system.md)

- [X] T028 [US3] Update `.knowledge/architecture/game-visual-system.md`, `.knowledge/architecture/arrow-puzzle.md`, `.knowledge/architecture/save-progression.md` and `tests/README.md` for resulting responsive scenes and regression procedures, including the explicit limits of simulated device/input evidence (Implements: FR-014) (code_ref: tests/README.md, tests/app_theme_check.gd, tests/puzzle_layout_check.gd, tests/puzzle_canvas_check.gd, tests/run_regressions.py | knowledge_ref: .knowledge/architecture/game-visual-system.md, .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/save-progression.md)



**Checkpoint**: All portrait menu families and Results fit/reflow; current expanded layouts and state/settings invariants pass focused tests. Remaining pre-merge work is candidate verification; real-phone owner acceptance remains outstanding post-deploy, not passed.


**Checkpoint**: Phase complete - 2026-10-18



## Final Phase: Verification and Current-Knowledge Consistency

**Checkpoint**: Pre-merge phase complete — 2026-10-19. T032 remains unchecked as the explicitly deferred post-deploy owner acceptance obligation.



- [X] T029 Run pinned Godot validation, `tests/run_puzzle_regressions.py`, `tests/run_regressions.py`, and `npm run check`/`npm run build` from `web/`; export the changed game with `web/scripts/export-game.mjs`, bind its actual PUBLIC_GAME_BUILD and rebuild the candidate site per `quickstart.md`; record results in `.devspark.work/specs/017-spec-mobile-portrait-play/evidence/automated.md` (Implements: FR-012, FR-013, FR-014) (code_ref: tests/run_puzzle_regressions.py, tests/run_regressions.py, tests/portrait_menu_check.gd, tests/puzzle_presentation_check.gd, web/scripts/export-game.mjs | knowledge_ref: .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/game-visual-system.md, .knowledge/architecture/save-progression.md, .knowledge/architecture/web-showcase.md)

- [X] T030 Run `web/scripts/check-portrait-play.mjs` and the rendered scene checks against the real candidate export for the full Plan size/DPR matrix, then smoke the changed browser flows in Chrome and Firefox; record CSS/scene geometry, screenshots, versions, iframe retention and explicitly untested Chromium-derived browsers in `.devspark.work/specs/017-spec-mobile-portrait-play/evidence/browser.md` per SC-001/002/004/005/006 (Implements: FR-001, FR-002, FR-003, FR-004, FR-008, FR-009, FR-010, FR-014) (code_ref: web/scripts/check-portrait-play.mjs, tests/puzzle_layout_check.gd, tests/puzzle_presentation_check.gd, tests/portrait_menu_check.gd | knowledge_ref: .knowledge/architecture/game-visual-system.md, .knowledge/architecture/web-showcase.md)

- [X] T031 Perform physical mouse, keyboard and gamepad desktop smoke of affected play/menu/pause/restart/transition/remap paths and record actual results in `.devspark.work/specs/017-spec-mobile-portrait-play/evidence/desktop-input.md` per constitution III/V and QA-11; leave missing hardware evidence outstanding (Implements: FR-007, FR-011, FR-012) (code_ref: tests/puzzle_layout_check.gd, tests/puzzle_canvas_check.gd, tests/run_regressions.py | knowledge_ref: .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/save-progression.md)

- [ ] T032 Post-deploy, non-blocking for merge: run the owner's published-build Pixel 7 Pro Chrome portrait journey from `quickstart.md` and QA-04/05/08/10/14; record deployed evidence for SC-003/SC-007 under the existing published-phone obligation in `.devspark.work/intake/future-mobile-ui-scaling-verification-owner-2026-10-17.md`, grouped there without duplicating the record; retain this item open/outstanding, not passed, until actual device acceptance (Implements: FR-001, FR-005, FR-006, FR-007, FR-008, FR-009, FR-010, FR-014) (code_ref: n/a deferred post-deploy physical acceptance; not performed | knowledge_ref: .knowledge/architecture/web-showcase.md, .knowledge/reference/touch-gestures.md)

- [X] T033 Reconcile `.knowledge/architecture/web-showcase.md`, `.knowledge/reference/touch-gestures.md` and the remaining path-derived affected owners against actual pre-merge T029â€“T031 evidence and any subsequently available T032 deployed evidence; record support limitations accurately, cite only durable code/tests as Knowledge source-of-truth and retain the existing published-phone obligation separately (Implements: FR-014) (code_ref: n/a current-knowledge consistency review only; behavior paths are linked on completed implementation tasks | knowledge_ref: .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/game-visual-system.md, .knowledge/architecture/save-progression.md, .knowledge/architecture/web-showcase.md, .knowledge/reference/touch-gestures.md)

- [X] T034 Check the resulting code/test/Knowledge delta for unchanged rule/persistence boundaries, complete per-task linkage for completed work and zero references back to temporary planning identifiers; record SC-003/SC-007, T032 and QA-04/QA-14 as deferred post-deploy, not complete, under the existing intake record; assemble actual end-to-end evidence and closeout under `.devspark.work/specs/017-spec-mobile-portrait-play/gates/verify.md` and `gates/closeout.md`, following the declared verification/closeout contracts, and retain the completed feature bundle for release archival (Implements: FR-012, FR-013, FR-014) (code_ref: n/a existing empirical evidence and final linkage/closeout accounting only | knowledge_ref: .knowledge/architecture/arrow-puzzle.md, .knowledge/architecture/game-visual-system.md, .knowledge/architecture/save-progression.md, .knowledge/architecture/web-showcase.md, .knowledge/reference/touch-gestures.md)



## Dependencies and Parallel Opportunities



Phase order supplies the main dependency edges. No new implementation design is introduced here.



- T004 and T005 can be prepared independently after foundational sizing; different test files.

- T006 consumes T004; T010 consumes T005. T009's host checks become executable after T006â€“T008 and a candidate export. Final full-flow runs wait for all story implementations.

- T014 depends on T013's Menu node. T015/T016 finish that controller integration; do not treat their shared scene/controller files as parallel work.

- T021/T022/T023 can proceed independently after T019/T020. T024/T025 can proceed independently after T023's Options shell is in place; they touch separate child families. T026 waits for the mini-options changes and earlier pause flow.

- Documentation tasks can be finalized with each story's resulting delta; behavior task checkboxes wait for their associated documentation as noted under Linkage.

- T029 prepares the real export for T030; T031 runs on the same final code state. T033/T034 require green automated, rendered size/DPR, Chrome/Firefox and desktop input checks, not T032. T032 remains post-deploy and non-blocking for merge.



## Coverage and Acceptance Boundaries



The functional coverage is explicit in each Implements directive. All QA-01 through QA-14 scenarios map to story tests/implementation or final verification. Constitution I/II/IV govern each production task's naming, local-template integration and event-driven behavior; III/V runtime obligations are T002/T005/T012/T019 and T029â€“T032. VI is protected by T024â€“T027 plus the unchanged settings/no-reset suite in T029. No Constitution Waiver exists.



MVP increment: US1 + US2 provides portrait board play with minimal controls; US3 remains required for this spec's complete start-to-Results objective. No public deployment, new content, outside-player study or wider phone certification is an implementation task. T032 is retained by owner instruction solely as a post-deploy acceptance obligation, not pre-merge executable work.



SC-003/SC-007, QA-04/QA-14 and retained T032 are grouped with the existing **post-deploy** obligation (T032 is explicitly outside pre-merge work): owner = project owner; evidence_class = deployed; captured_as = `.devspark.work/intake/future-mobile-ui-scaling-verification-owner-2026-10-17.md`. Local/preview phone evidence cannot satisfy its published-site check. Emulation never counts as device evidence. Deferred real-phone acceptance remains outstanding, not passed. Merge may proceed once T029â€“T031 checks are green and closeout records this deferral.



Knowledge ownership was derived from the Plan file surface with `explain-context.ps1 --json --files`: 31 of 32 queried paths had owners. `tests/README.md` is an unowned guide, not a behavior owner requiring a new entity. New presentation scripts receive appliesTo coverage in existing relevant architecture nodes. Constitution ownership does not authorize a governance rewrite.



Owner-ratified planning amendments preserve all ids and unchecked states; FR-011 remains pending owner confirmation. The requirements checklist is not execution evidence; new planning-review gate artifacts must reflect these amendments.
