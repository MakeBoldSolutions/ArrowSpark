---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
description: "Task list for ArrowSpark Mobile Web Play — Touch + Responsive Landscape"
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Tasks: ArrowSpark Mobile Web Play — Touch + Responsive Landscape

**Input**: `/.devspark.work/specs/012-spec-mobile-web-play/` (spec.md, plan.md, research.md, data-model.md, contracts/, quickstart.md)
**Prerequisites**: plan.md, spec.md (checklist PASS, no open clarifications)

**Tests**: Requested by FR-017 (headless touch→transform check, minimum-size check, admission unit tests). Real-device checks are the authoritative verification (FR-015).

**Organization**: Phases 1–2 are the real-device spike (US1) and end at the **Matrix Freeze**. Phases 3–8 are implementation and are **BLOCKED until the freeze**: at the freeze, confirm, trim or drop each post-freeze task to match the frozen Support Matrix. A task whose premise the spike disproves is dropped, not worked around. This task list is temporary working state and remains in `.devspark.work/` until release archival.

## Rationale Summary

### Core Problem

The showcase site is already mobile-first, but phone visitors cannot play the game (the goal is a mobile-web-first game: a modern phone, touch, landscape, in the browser as the normal path); whether the existing Godot Web build can serve them is unproven on real hardware.

### Decision Summary

Spike on real devices, freeze an evidence-based support matrix, then implement only what the matrix supports, routing all gestures through `PuzzleViewportTransform`.

### Key Drivers

- No claim beyond tested hardware; emulation never substitutes.
- Single viewport authority; desktop unchanged.
- 44 × 44 CSS px for required controls; Reference Knot geometry untouched.

### Reviewer Guidance

Check the freeze task is a real human gate, post-freeze tasks match the frozen matrix, and no task adds a second transform path, persistence or analytics.

## Format: `[ID] [P?] [Story] Description (Implements: FR-###[, FR-###])`

- **[P]**: parallelizable (different files, no incomplete dependencies)
- **Linkage**: every task ends with `(code_ref: pending | knowledge_ref: pending)`; `/devspark.implement` fills these.

## Phase 1: Setup (spike scaffolding; nothing here ships)

**Purpose**: Make the spike runnable on real devices without touching the shipped gate.

- [X] T001 Run both regression gates and the site build on the unmodified branch to record the desktop baseline (`python tests/run_puzzle_regressions.py --godot <exe>`, `python tests/run_regressions.py --godot <exe>`, `cd web && npm ci && npm run check && npm run build`) and note results in the spike notes (Implements: FR-014) (code_ref: n/a (baseline run only, no files changed) | knowledge_ref: n/a)
- [X] T002 [P] Add a flag-gated spike mode to the Play page (admits any viewport only on an explicit spike URL; shipped gate untouched) in web/src/pages/play.astro and web/src/components/play/GameFrame.astro (Implements: FR-001) (code_ref: web/src/components/play/GameFrame.astro, web/src/pages/play.astro, web/src/components/play/DesktopOnlyNotice.astro | knowledge_ref: n/a (spike scaffolding; durable knowledge updated at Phase 8))
- [X] T003 [P] Add a spike-only probe overlay reporting innerWidth/innerHeight, devicePixelRatio, orientation, `pointer`/`hover` media features, touch availability and canvas-to-CSS scale, enabled only by the spike flag, in web/game-shell/shell.html (Implements: FR-001) (code_ref: web/game-shell/spike-probe.js, web/game-shell/shell.css, web/game-shell/shell.html, web/scripts/export-game.mjs | knowledge_ref: n/a (spike scaffolding; durable knowledge updated at Phase 8))
- [X] T004 Create the spike working folder with one copy of contracts/spike-record-template.md per device at .devspark.work/specs/012-spec-mobile-web-play/spike/ (Implements: FR-001, FR-015) (code_ref: n/a (working notes only; .devspark.work/specs/012-spec-mobile-web-play/spike/) | knowledge_ref: n/a (spike records are temporary working state))
- [ ] T005 Export the Web build and publish the spike build over HTTPS in the same-origin iframe shape used in production (human/hosting step; record the build id and URL in the spike notes) (Implements: FR-001) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: A spike URL loads the game in the iframe on a desktop browser with the probe overlay.

---

## Phase 2: User Story 1 — Real-device feasibility spike (Priority: P1) 🎯 MVP

**Goal**: Answer FR-001 R1–R7 empirically on real hardware and classify each device.

**Independent Test**: A Spike Record exists per tested device answering R1–R7 (or marking not-performed with reason) with a classification, and the Support Matrix is frozen.

All observation tasks are human-on-device work; Claude may prepare prototypes and record results the user reports. Emulation results go in a "supplemental" section only.

- [ ] T006 [US1] Record device identity (model, OS version, browser/version, landscape CSS viewport with and without browser chrome, devicePixelRatio) for one recent iPhone on current iOS Safari and one recent Android phone on current Chrome, plus an iPad on current iPadOS Safari if available, in spike/ (Implements: FR-001, FR-015) (code_ref: pending | knowledge_ref: pending)
- [ ] T007 [US1] R4 baseline: load the unmodified game in the iframe and directly; try tap, blocked tap, scroll, drag and pinch; record what the page and game each do, including whether the completion message still fires (Implements: FR-001) (code_ref: pending | knowledge_ref: pending)
- [ ] T008 [US1] R1: on each device, record whether Godot emits both touch and mouse events for one tap, any premature (press-time) selection and any double-fire (counts); then at a documented working zoom tap at least 20 distinct removable arrows and blocked arrows and record hit rate; separately report Fit-zoom tap usability as informational (Implements: FR-001, FR-006) (code_ref: pending | knowledge_ref: pending)
- [ ] T009 [US1] R2: record the canvas-to-CSS scale and readable text sizes per device; view the Reference Knot and HUD at each device viewport; try capability-conditioned runtime scaling options one at a time in a throwaway spike branch; confirm puzzle geometry unchanged and judge readability (Implements: FR-001, FR-005, FR-007) (code_ref: pending | knowledge_ref: pending)
- [ ] T010 [US1] R3: build a throwaway touch prototype in scenes/puzzle/puzzle_board.gd (spike branch only, not merged) calling the existing `zoom_at`, `pan_pixels` and `fit_puzzle`; record bounds, anchor behavior, drift and Fit (Implements: FR-001, FR-004) (code_ref: pending | knowledge_ref: pending)
- [ ] T011 [US1] R6: measure rendered CSS size of Back, Fit Puzzle, Open Move, Pan, zoom buttons, Results actions, Replay and Level Select/navigation on each device against 44 × 44; list menu/Results/Level Select layout blockers (Implements: FR-001, FR-007) (code_ref: pending | knowledge_ref: pending)
- [ ] T012 [US1] R5: find the smallest usable landscape CSS viewport per device, with browser chrome shown and hidden (Implements: FR-001) (code_ref: pending | knowledge_ref: pending)
- [ ] T013 [US1] R7: record fullscreen API result, first-tap audio unlock, gesture and viewport-meta effects, and iframe focus behavior per browser (Implements: FR-001, FR-003, FR-013) (code_ref: pending | knowledge_ref: pending)
- [ ] T014 [US1] Orientation and resize: rotate mid-puzzle and show/hide browser chrome; record whether the attempt survives (Implements: FR-001, FR-012) (code_ref: pending | knowledge_ref: pending)
- [ ] T015 [US1] Look for the smallest changes that make each phone usable before classifying it out; classify each device as Supported / Supported with documented limitation / Unsupported in Spec 012 with reasons, and finish the Spike Records (Implements: FR-001, FR-015, FR-018) (code_ref: pending | knowledge_ref: pending)
- [ ] T016 [US1] **MATRIX FREEZE (human gate)**: owner and reviewer review the Spike Records and freeze the Support Matrix (rows, minimum landscape CSS viewports, limitations, portrait decision); phone rows are primary and tablets alone are not sufficient. If no phone class is usable without material redesign, stop here and record the outcome and deferrals; do not proceed to Phase 3 (Implements: FR-010, FR-018) (code_ref: pending | knowledge_ref: pending)
- [ ] T017 [US1] After freeze (and only once the pre-freeze remediation tasks T056–T058 are recorded and the T061 recheck has passed; T059–T060 are scheduled post-freeze additions), revise this task list: confirm, trim or drop each Phase 3–8 task against the frozen matrix and write the frozen minimum viewport and the measured canvas-to-CSS scale into the affected tasks (Implements: FR-007, FR-010) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: Matrix frozen, or spec closed with deferrals. Nothing below starts earlier.

---

## Phase 3: Foundational (post-freeze, blocks Phases 4–7)

**Purpose**: Shared pieces every touch story needs.

- [ ] T018 Add static touch-capability, control-size and runtime-scale helpers to the existing scripts/presentation/game_visual_style.gd (no new script; touch availability is a plain query used only for sizing, scaling and help text) (Implements: FR-002, FR-007, FR-014) (code_ref: pending | knowledge_ref: pending)
- [ ] T019 Apply capability-conditioned runtime scaling for admitted touch-capable devices only (not a global project.godot stretch setting), at the single call site chosen at T017, using the helpers in scripts/presentation/game_visual_style.gd; depends on T018 (Implements: FR-005, FR-007, FR-014) (code_ref: pending | knowledge_ref: pending)
- [ ] T020 Add a desktop resize/scale regression check proving desktop scaling, window-resize behavior and 1280 x 720 presentation are unchanged, in tests/puzzle_desktop_resize_check.gd, registered in tests/run_puzzle_regressions.py; depends on T019 (Implements: FR-014, FR-017) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: Helpers exist; desktop layout untouched.

---

## Phase 4: User Story 2 — Play a puzzle with touch in landscape (Priority: P1)

**Goal**: Tap, Pan-mode drag, pinch, Fit and Open Move work on frozen devices through the existing viewport authority.

**Independent Test**: On each frozen device, complete the Reference Knot using touch only.

### Tests for User Story 2

- [ ] T021 [P] [US2] Add a headless check that release-time touch tap, one-finger pan, pinch, cancel cases (second finger, movement past threshold, Pan or pinch ownership, focus loss, pause, results) and emulated-mouse suppression yield the same transform and selection state as the equivalent mouse paths, with no selection before release and no double-fire, per contracts/touch-input-contract.md, in tests/puzzle_touch_input_check.gd (Implements: FR-004, FR-006, FR-017) (code_ref: pending | knowledge_ref: pending)
- [ ] T022 [US2] Register the new touch-input check with the headless launcher in tests/run_puzzle_regressions.py and describe it in tests/README.md; depends on T020 (same launcher file) (Implements: FR-017) (code_ref: pending | knowledge_ref: pending)

### Implementation for User Story 2

- [ ] T023 [US2] Implement release-time touch handling in scenes/puzzle/puzzle_board.gd: a touch is a pending tap that emits `cell_clicked` only on release when no second finger appeared, movement stayed below the tap/drag threshold, Pan mode and pinch did not take ownership and nothing cancelled it; one-finger Pan-mode drag -> `pan_pixels`; pinch -> `zoom_at` about the midpoint; cancel on focus loss, pause, visibility, results; real mouse branches unchanged; depends on T018 (Implements: FR-002, FR-004, FR-006, FR-014) (code_ref: pending | knowledge_ref: pending)
- [ ] T024 [US2] Only if T010/T015 proved a gap, add the minimal method to scripts/presentation/puzzle_viewport_transform.gd and extend tests/puzzle_viewport_transform_check.gd; otherwise record "no change" (Implements: FR-004) (code_ref: pending | knowledge_ref: pending)
- [ ] T025 [US2] Make Back, Open Move (HUD) and Fit, Pan, zoom buttons (toolbar) at least 44 x 44 CSS px on touch-capable frozen devices and replace blocking fixed minimums such as the HelpLabel 480 px width, in scenes/puzzle/arrow_puzzle.tscn and scenes/puzzle/arrow_puzzle.gd; depends on T019 (Implements: FR-002, FR-007, FR-008) (code_ref: pending | knowledge_ref: pending)
- [ ] T026 [US2] Add the minimum-size layout check for required puzzle controls at a representative scaled viewport, in tests/puzzle_touch_target_check.gd, registered in tests/run_puzzle_regressions.py; depends on T022 (same launcher file) and T025 (Implements: FR-007, FR-014, FR-017) (code_ref: pending | knowledge_ref: pending)
- [ ] T027 [US2] Handle safe-area/notch overlap and browser-chrome viewport changes in the HUD only where the spike showed a problem, in scenes/puzzle/arrow_puzzle.tscn and web/game-shell/shell.html ; depends on T025 (same files) (Implements: FR-012) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: A frozen device can solve the Reference Knot by touch in the spike build with the new code; regression gates pass.

---

## Phase 5: User Story 3 — Complete the session flow on touch (Priority: P2)

**Goal**: Menu, Level Select, play, Back, Results and Replay all work by touch at finger-sized targets.

**Independent Test**: Play → Level Select → puzzle → Back → puzzle → completion → Results → Replay, touch only, on each frozen device.

- [ ] T028 [P] [US3] Make Results actions and Replay at least 44 × 44 CSS px on touch-capable frozen devices in scenes/puzzle/puzzle_results.tscn and scenes/puzzle/puzzle_results.gd (Implements: FR-002, FR-007) (code_ref: pending | knowledge_ref: pending)
- [ ] T029 [P] [US3] Make Level Select and navigation controls at least 44 × 44 CSS px, fixing blockers listed in the spike audit, in the affected scenes under scenes/menus/ and scenes/overlaid_menus/ (justify and document any addon edit under addons/maaacks_game_template/ per constitution II) (Implements: FR-002, FR-007) (code_ref: pending | knowledge_ref: pending)
- [ ] T030 [US3] Ensure an on-screen control (not Esc) reaches Back/pause/menu from puzzle play, and that no required action needs keyboard, hover or fullscreen, in scenes/puzzle/arrow_puzzle.gd ; depends on T027 (same file) (Implements: FR-003, FR-008) (code_ref: pending | knowledge_ref: pending)
- [ ] T031 [US3] Extend tests/puzzle_touch_target_check.gd to cover Results, Replay and Level Select controls ; depends on T026 (same file) (Implements: FR-007, FR-017) (code_ref: pending | knowledge_ref: pending)
- [ ] T032 [US3] Verify the completion message to the page is unchanged (existing contract v1 check) by running the existing Web hand-off checks and the site bridge tests (Implements: FR-005) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: Full session flow works by touch on the spike build.

---

## Phase 6: User Story 4 — Honest gate and guidance (Priority: P2)

**Goal**: The page admits proven combinations, shows a concise message otherwise, and desktop is unchanged.

**Independent Test**: Load Play on desktop, a frozen touch landscape device, touch portrait and an undersized viewport; rotate during a session.

### Tests for User Story 4

- [ ] T033 [P] [US4] Add table-driven Vitest cases for the admission decision (desktop, tablet landscape, phone landscape, phone portrait, undersized, hybrid touch+pointer) filled from the frozen matrix in web/tests/play-admission.test.ts (Implements: FR-010, FR-017) (code_ref: pending | knowledge_ref: pending)

### Implementation for User Story 4

- [ ] T034 [US4] Replace `DESKTOP_QUERY` with a pure capability/viewport/orientation admission module per contracts/page-admission-contract.md, keeping the desktop floor (fine pointer, ≥ 960 × 540) admitted, in web/src/scripts/play-admission.ts and remove web/src/scripts/desktop-query.ts if unused (Implements: FR-010, FR-014) (code_ref: pending | knowledge_ref: pending)
- [ ] T035 [US4] Use the admission module in web/src/components/play/GameFrame.astro: load the engine only when admitted, re-evaluate on resize and orientation change, and avoid destroying an attempt where feasible ; depends on T034 (Implements: FR-010, FR-012) (code_ref: pending | knowledge_ref: pending)
- [ ] T036 [P] [US4] Rework web/src/components/play/DesktopOnlyNotice.astro (rename if appropriate) into a concise rotate-to-landscape / use-a-larger-screen message that keeps the story link and the copy/mail actions (Implements: FR-010) (code_ref: pending | knowledge_ref: pending)
- [ ] T037 [US4] Guard page scroll, zoom and navigation during in-game gestures on admitted devices without breaking page zoom elsewhere, as far as the spike showed necessary, in web/src/scripts/page-zoom-guard.ts and web/game-shell/shell.html (Implements: FR-011, FR-013) (code_ref: pending | knowledge_ref: pending)
- [ ] T038 [US4] Make first-tap audio start safe on touch devices without causing an unintended selection, per the R7 findings, in web/game-shell/shell.html and/or scenes/puzzle/puzzle_board.gd ; depends on T037 (same shell.html) (Implements: FR-013) (code_ref: pending | knowledge_ref: pending)
- [ ] T039 [US4] Update the Play page copy and meta description that currently say "desktop browsers" to match the frozen matrix in web/src/pages/play.astro ; depends on T035 (Implements: FR-010, FR-016) (code_ref: pending | knowledge_ref: pending)
- [ ] T040 [US4] Remove the spike flag and probe overlay from shipped paths (or confirm they are inert in production builds) in web/src/pages/play.astro, web/src/components/play/GameFrame.astro and web/game-shell/shell.html ; depends on T038 and T039 (same files) (Implements: FR-010) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: Gate and messages match the frozen matrix; desktop admission unchanged.

---

## Phase 7: User Story 5 — Touch-appropriate help text (Priority: P3)

**Goal**: Capability-appropriate help wording; desktop wording kept.

**Independent Test**: Help on desktop shows wheel/middle-drag/Esc wording; on a touch device it shows tap/drag/pinch wording with no impossible instruction.

- [ ] T041 [US5] Make the in-game help and tooltips capability-appropriate (touch: tap, Pan drag, pinch, on-screen Fit/Back; desktop wording retained) using the touch-capability helper in scripts/presentation/game_visual_style.gd, in scenes/puzzle/arrow_puzzle.gd; depends on T030 (same file) (Implements: FR-003, FR-009) (code_ref: pending | knowledge_ref: pending)
- [ ] T042 [US5] Update the Play page notes (wheel, middle button, "click once for the keyboard") to include touch wording alongside desktop wording, and do not rely on fullscreen, in web/src/pages/play.astro and web/src/components/play/GameFrame.astro ; depends on T040 (same files) (Implements: FR-003, FR-009) (code_ref: pending | knowledge_ref: pending)
- [ ] T043 [US5] Add a check that help text on a touch-capability profile contains no wheel, middle-drag, right-click, hover or keyboard-only instruction, and that the desktop profile still does, in tests/puzzle_presentation_check.gd ; depends on T041 (Implements: FR-009, FR-017) (code_ref: pending | knowledge_ref: pending)

**Checkpoint**: Help text matches input capabilities.

---

## Phase 8: Verification, Governance and Knowledge (Final)

**Purpose**: Prove it, then update durable guidance only to what was proven.

- [ ] T044 Run both regression gates, Godot validation (`<godot> --headless --editor --quit`) and the site check/build; all must pass with no desktop regression (Implements: FR-014, FR-017) (code_ref: pending | knowledge_ref: pending)
- [ ] T045 Desktop smoke test of menu, play, pause, restart, Results and input paths in each previously supported desktop browser; record results and anything not performed (Implements: FR-014) (code_ref: pending | knowledge_ref: pending)
- [ ] T046 Verify keyboard and gamepad navigation and remapping still work on the board and HUD (constitution III) (Implements: FR-003, FR-014) (code_ref: pending | knowledge_ref: pending)
- [ ] T047 Mobile-emulation smoke test, recorded as supplemental only (Implements: FR-015) (code_ref: pending | knowledge_ref: pending)
- [ ] T048 **Real-device verification** on every Frozen matrix row: load, orientation, tap, blocked selection, pan, pinch, Fit, Open Move, Back, completion, Results, Replay, Level Select, resize/orientation change, page scroll/zoom conflicts, audio, iframe behavior; record device model, OS, browser/version, landscape CSS viewport and devicePixelRatio; disclose anything not performed (Implements: FR-015) (code_ref: pending | knowledge_ref: pending)
- [ ] T049 Measure SC-003 using the documented working-zoom tap protocol (at least 20 taps on distinct removable arrows, zero premature selection or double-fire), report Fit-zoom tap usability separately, SC-004 (zero unintended page scroll/zoom/navigation in a full attempt), SC-007 (message within one second) and SC-008 (rotation preserves the attempt) and record results; move Verified rows of the Support Matrix to `Verified` (Implements: FR-011, FR-012, FR-015) (code_ref: pending | knowledge_ref: pending)
- [ ] T050 Amend constitution Principle V (supported mobile browsers/devices from the Verified matrix, not "desktop browsers" only) with a version bump and Sync Impact Report via `/devspark.evolve-constitution`, in .knowledge/governance/constitution.md (Implements: FR-016) (code_ref: pending | knowledge_ref: pending)
- [ ] T051 Replace the "Desktop-only boundary" and related touch/page-zoom/keyboard-focus text with the proven support boundary, deferrals and the Verified device list in .knowledge/architecture/web-showcase.md (Implements: FR-016, FR-018) (code_ref: pending | knowledge_ref: pending)
- [ ] T052 [P] Document touch input (tap, Pan-mode drag, pinch, cancel rules, capability-based input, 44 × 44 targets) in the board input section of .knowledge/architecture/arrow-puzzle.md, and the touch control-size/help rules in .knowledge/product/gameplay-contract.md only if player-visible behavior is described there (Implements: FR-016) (code_ref: pending | knowledge_ref: pending)
- [ ] T053 [P] Update CLAUDE.md and AGENTS.md "Recent Changes" and technology notes (touch landscape support, admission module) (Implements: FR-016) (code_ref: pending | knowledge_ref: pending)
- [ ] T054 Run `.devspark/scripts/powershell/check-planning-references.ps1` and confirm no durable code or `.knowledge/` file references spec 012 or any `.devspark.work/` artifact (code_ref: pending | knowledge_ref: pending)
- [ ] T055 Confirm every task's `code_ref`/`knowledge_ref` is populated, then leave the spec bundle in `.devspark.work/` for `/devspark.release` to archive (the spec states it remains until release archival; do not delete it here) (code_ref: pending | knowledge_ref: pending)

---

## Dependencies & Execution Order

- Phase 1 → Phase 2 (spike) → **T016 Matrix Freeze** → T017 task revision → Phases 3–8.
- Phase 3 blocks Phases 4–7. Phase 4 (US2) is the MVP implementation; US3 depends on US2; US4 depends only on the frozen matrix and can run in parallel with US2/US3 after Phase 3 (different files); US5 runs after US2, US3 and US4 because it shares files with all three.
- T050–T052 and T060 (governance, knowledge) only after T048–T049 mark rows `Verified`.
- **File serialization (analyze-001)**: `tests/run_puzzle_regressions.py`: T020 -> T022 -> T026. `scenes/puzzle/arrow_puzzle.gd/.tscn`: T025 -> T027 -> T030 -> T041. `web/game-shell/shell.html`: T037 -> T038 -> T040. `web/src/pages/play.astro` and `GameFrame.astro`: T035 -> T039 -> T040 -> T042. `tests/puzzle_touch_target_check.gd`: T026 -> T031. `scenes/puzzle/puzzle_board.gd`: T023 -> T059. `scripts/presentation/game_visual_style.gd`: T018 -> T019. Consequently US5 depends on US2, US3 and US4 for shared files, and US3 depends on US2.
- **Phase map**: plan Phase 0 = tasks Phases 1-2; plan Phase 1 = tasks Phases 3-4; plan Phase 2 = tasks Phases 3-5; plan Phase 3 = Phase 6; plan Phase 4 = Phase 7; plan Phase 5 = Phase 8.

## Parallel Opportunities

- Phase 1: T002 ∥ T003.
- Phase 2: T008–T014 and T056–T058 can proceed per device in parallel; T015 waits for all.
- After freeze (only where no file is shared): T028 ∥ T029; T033 ∥ T036; T052 ∥ T053.

## Implementation Strategy

1. **Spike first (US1)**; stop at the freeze if the evidence does not support usable landscape play.
2. **MVP** = US2 on the frozen phone classes (tablet rows may ship alongside but never alone), plus the minimum of US4 needed to expose it (T034–T035).
3. Then US3, remaining US4 messaging, US5, and Phase 8.
4. If only tablets or larger phones are Supported, implement for those only; record portrait and small phones as deferred.

## Coverage

FR-001 T002–T015 · FR-002 T018, T023, T025, T028–T029 · FR-003 T013, T030, T041–T042, T046 · FR-004 T010, T021, T023–T024 · FR-005 T009, T019, T032 · FR-006 T008, T021, T023 · FR-007 T011, T017, T020, T025–T026, T028–T029, T031 · FR-008 T025, T030 · FR-009 T041–T043 · FR-010 T016, T034–T036, T039–T040 · FR-011 T037, T049 · FR-012 T014, T027, T035, T049 · FR-013 T013, T037–T038 · FR-014 T001, T018–T019, T034, T044–T046 · FR-015 T004, T006, T015, T047–T049 · FR-016 T039, T050–T053 · FR-017 T021–T022, T026, T031, T033, T043–T044 · FR-018 T015–T016, T051. Remediation tasks T056–T061 extend FR-001, FR-006, FR-007, FR-014, FR-015, FR-016 coverage.

## Gate Remediation

**Source**: `gates/analyze.md` (analyze-001..005) and `gates/critic.md` (critic-001..004) plus the owner decision on critic-001 (release-time touch selection). Plan, spec, contracts, research, data model and quickstart were amended directly; the tasks below carry the remaining work. **All post-freeze remediation must be complete by T017.** The spike (Phases 1–2) may proceed now.

### Pre-freeze (run during the spike)

- [ ] T056 [US1] Record, per device, whether Godot emits both touch and mouse events for one tap, any premature (press-time) selection, and any double-fire, as counts, in the R1a-R1c rows of each Spike Record (resolves: critic-001) (Implements: FR-001, FR-006) (code_ref: pending | knowledge_ref: pending)
- [ ] T057 [US1] Record canvas-to-CSS scale and readable text sizes per HUD/menu role per device in each Spike Record, and note whether desktop scaling would be affected by any option tried (resolves: critic-002) (Implements: FR-001, FR-007, FR-014) (code_ref: pending | knowledge_ref: pending)
- [ ] T058 [US1] Document the working-zoom tap protocol used (how working zoom is reached, the on-device cell size in CSS px, number of distinct removable arrows) and report Fit-zoom tap usability separately; propose a working-zoom minimum cell size for freeze (resolves: critic-004) (Implements: FR-001, FR-015) (code_ref: pending | knowledge_ref: pending)

### By T017 (before post-freeze work)

- [ ] T061 Re-run `/devspark.analyze` and `/devspark.critic` as a recheck after the remediation edits and this task list change; confirm analyze-001..005 and critic-001..004 are resolved or reclassified, and update the gate artifacts (resolves: analyze-001, analyze-002, analyze-003, analyze-004, analyze-005, critic-001, critic-002, critic-003, critic-004) (code_ref: pending | knowledge_ref: pending)

### Post-freeze implementation additions

- [ ] T059 [US2] In scenes/puzzle/puzzle_board.gd, ignore emulated mouse events while a real touch sequence owns the board, using the smallest safe mechanism the spike supports, and keep real mouse press-time behavior unchanged; depends on T023 (same file) (resolves: critic-001) (Implements: FR-006, FR-014) (code_ref: pending | knowledge_ref: pending)
- [ ] T060 Update `.knowledge/architecture/game-visual-system.md` with touch control sizing (44 x 44 CSS px for required controls, not applied to puzzle cells), the capability-conditioned runtime scaling approach, the touch-capability helpers on GameVisualStyle, and the extended validation scope (touch devices in addition to desktop checks); only after T048-T049 (resolves: critic-003) (Implements: FR-016) (code_ref: pending | knowledge_ref: pending)

## Gate Acknowledgements

### 2026-10-03 — stale Analyze and Critic gates (explicit owner override)

- **Failing gate**: Gate freshness. `gates/analyze.md` and `gates/critic.md` were written before the remediation edits, so their `reviewed_artifacts` hashes no longer match `spec.md`, `plan.md` and `tasks.md`.
- **Unresolved finding**: critic-001 (touch selection semantics), the only open critical finding in the stale Critic report. It is resolved by owner decision and incorporated into the current artifacts: desktop mouse selection stays press-time; touch selection is release-time; a pending tap is cancelled by movement, a second finger, pan, pinch, focus loss, pause, visibility change or results; emulated mouse events do not trigger board selection while a real touch sequence owns the board; T056-T059 record and implement the evidence and behavior. The stale report does not reflect these edits.
- **Owner decision**: the owner acknowledges the stale gate state and authorizes Phase 1 and Phase 2 (real-device spike work) to proceed. No post-freeze implementation may begin until T061 re-runs Analyze and Critic against the remediated artifacts and passes the freeze gate. This acknowledgement does not waive T061 or any real-device evidence requirement.
- **Recorded**: 2026-10-03 (UTC date), not auto-selected.

## Implementation Notes

### Phase 1 progress (2026-10-03)

- **T002/T003/T004 done.** Spike mode: `?spike` on the Play page bypasses the desktop gate (CSS and load) and passes `?spike` to the game iframe, which shows the probe overlay from `web/game-shell/spike-probe.js` (inert without the flag; copied by `web/scripts/export-game.mjs`). The production CSP build still passes (one inline script, hash unchanged); `npm run check` and `npm run build` pass. T040 removes or confirms the flag inert before shipping.
- **T001 done (with disclosed limits).** Pinned engine used: Godot 4.4-stable (`4.4.stable.official.4c311cbee`, official win64 build, SHA-512 verified against the release's SHA512-SUMS), run from a copy of the project without `.godot/` as tests/README.md directs. `run_regressions.py`: exit 0, `REGRESSION_FAILURES=0`. `run_puzzle_regressions.py`: PUZZLE, ANALYZER, CATALOG, SCOREBOARD, ARROW_DEPARTURE_GEOMETRY and VIEWPORT checks all report 0 failures, but the launcher exits 1 at its layout step because its fresh `--import` on this Windows machine prints `SceneLoader not declared` parse noise from the Maaack opening script (the same first-import noise class CI tolerates). Run directly with the same 4.4 binary, `puzzle_layout_check`, `puzzle_canvas_check` and `puzzle_presentation_check` each pass with 0 failures and no script errors. Launcher steps after the layout step were therefore not run on this machine; CI on the PR is the authoritative run. Site baseline: `npm run check` (0 errors, 50 tests) and `npm run build` pass. No Godot or gameplay file changed, so this is a baseline, not a regression result.
- **T005 in progress.** The PR's Azure workflow builds the Web export in CI (no local export or export templates needed); push and PR authorized by the owner 2026-10-03.
- **Baseline finding for the spike**: `web/game-shell/shell.css` already sets `touch-action: none` on `body`, so the critic obligation's remark that no touch-action rule exists was wrong; the page-scroll/zoom leak risk in R4 still has to be observed on real devices.
