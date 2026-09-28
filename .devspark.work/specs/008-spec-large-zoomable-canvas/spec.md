---
classification: full-spec
risk_level: high
status: Draft
target_workflow: specify-full
required_artifacts: spec, plan, tasks
recommended_next_step: plan
required_gates: checklist, analyze, critic, verify:end-to-end
route_intent: full-spec
---

# Feature Specification: Large Zoomable Puzzle Canvas

**Feature Branch**: `008-spec-large-zoomable-canvas`
**Created**: 2026-09-28
**Status**: Draft
**Input**: Spec 008 — the puzzle defines the world; the screen is only a window into it. Add large-board zoom, pan, and Fit Puzzle while preserving established gameplay.

## Product Owner TLDR

Players will inspect puzzles larger than their screen by zooming and moving around the board, then use Fit Puzzle to recover the overview. This enables future puzzles with long, bent, interwoven arrows without shrinking every arrow into an impractical selection target. Open Move assistance, departures, scoring, and replay will continue to work as the view changes. Existing small puzzles will remain comfortable without requiring navigation.

## Rationale Summary

### Core Problem

The current presentation fits the complete board into its available screen area. Larger authored puzzles therefore produce smaller arrows rather than a larger navigable world. Board size, geometric density, viewport, and zoom must be distinct: authored dimensions define the board; meaningful geometry defines density; the viewport defines the visible region; zoom defines its visual scale.

### Decision Summary

Introduce bounded zoom, pan, and Fit Puzzle as transient presentation capabilities, preserving the complete logical board and gameplay authorities regardless of visibility. Use minimal large validation content to prove the capability. Difficulty redesign and Gordian Knot content experiments remain future work.

### Key Drivers

- Enable the rhythm: inspect the whole knot, trace an arrow, find a loose thread, remove it, watch it unwind, and observe the simpler field.
- Support density through meaningful long, bent geometry rather than merely increasing arrow count.
- Preserve accessible, configurable keyboard/gamepad controls alongside mouse navigation.
- Preserve immediate logical removal, asynchronous departure, and session-only scoring.

### Source Inputs and Grounding

- User-supplied “Spec 008 — Large Zoomable Puzzle Canvas” brief and full-spec/high-risk approval.
- [Gameplay contract](../../../.knowledge/product/gameplay-contract.md), [puzzle architecture](../../../.knowledge/architecture/arrow-puzzle.md), [visual system](../../../.knowledge/architecture/game-visual-system.md), [save/settings contract](../../../.knowledge/architecture/save-progression.md), and [constitution](../../../.knowledge/governance/constitution.md).
- Prior working specs 004 (departure), 005 (catalog), 006 (analysis), and 007 (Open Move/scoring) establish scope context; current code and knowledge remain behavioral authorities.
- Initial inspection of [PuzzleBoard](../../../scenes/puzzle/puzzle_board.gd) found fit-to-area cell sizing, local-coordinate hit testing, and selection on left-button press. The [scene](../../../scenes/puzzle/arrow_puzzle.tscn) separates HUD and board area. The [controller](../../../scenes/puzzle/arrow_puzzle.gd) requests the deterministic legal move, highlights it, and waits for pending departures before results.
- Fit-only presentation is intentionally extended. No conflict with the constitution or gameplay contract was identified. Initial grounding does not replace planning research.

### Tradeoffs Considered

- Shrink-to-fit alone provides overview but cannot guarantee usable inspection and selection on large boards.
- Infinite canvas and advanced rendering machinery add unsupported scope and complexity.
- A bounded navigable board provides overview and working views while keeping authored geometry authoritative.

### Architectural Impact

| Authority | Responsibility preserved |
|---|---|
| PuzzleCatalog | Available puzzles |
| PuzzleDefinition | Complete logical dimensions and authored geometry |
| PuzzleState | Active arrows, blocking, legal moves, attempt state |
| PuzzleSolver | Solvability independent of presentation |
| PuzzleAnalyzer | Objective structure independent of presentation |
| PuzzleScoreboard | Session-best and overall-session scoring |
| PuzzleBoard / presentation | Rendering, interaction, transient viewport navigation |

Camera concepts must not enter definition, rule, solving, analysis, or scoring authorities. Planning must research the scene tree before choosing board-owned transforms, a wrapper, or another presentation component. This spec does not choose the implementation.

### Reviewer Guidance

High risk reflects input conversion, pan/selection arbitration, animation continuity, off-screen assistance, and multiple input methods. In addition to checklist, analyze, and critic, `verify:end-to-end` is required because geometry assertions and document review cannot establish rendered usability or real input behavior. Actual flow evidence is required during implementation acceptance; no implementation checks are claimed here.

### Working Artifact Lifecycle

This spec and related planning artifacts remain in `.devspark.work/` until release archival. Durable code, tests, and knowledge must not reference this spec or its planning identifiers. Implementation records affected code/test/knowledge linkage in the temporary task bundle and updates current knowledge.

## User Scenarios & Testing

### User Story 1 - Inspect the Large Board (Priority: P1)

As a player, I can understand the whole puzzle, zoom into an interesting region, and pan through its geometry so I can trace arrows larger than my current view.

**Why this priority**: Removes the screen-size constraint on authored puzzles.

**Independent Test**: Load the large fixture, inspect every corner at working scale, and return to the overview without selecting an arrow.

**Acceptance Scenarios**:

1. **Given** a large board, **When** it starts, **Then** the complete board is visible with surrounding margin.
2. **Given** an area of interest, **When** I zoom, **Then** scale changes around a predictable focal point within valid bounds, without changing gameplay state or score.
3. **Given** a board larger than the viewport, **When** I pan, **Then** every region is reachable without selecting arrows or changing attempt counters.
4. **Given** any navigated view, **When** I activate Fit Puzzle, **Then** the complete original logical bounds fit within the puzzle area with margin, regardless of remaining arrow count.
5. **Given** an existing small puzzle, **When** it starts, **Then** it is immediately playable without zoom or pan and retains readable feedback.

### User Story 2 - Inspect Without a Pointing Device (Priority: P1)

As a keyboard or gamepad user, I can zoom, move through the whole board, and recover the overview without needing a mouse.

**Why this priority**: Large-board inspection must preserve accessibility.

**Independent Test**: Using each supported input method, reach every region, zoom both ways, Fit Puzzle, and return focus to existing controls.

**Acceptance Scenarios**:

1. **Given** keyboard-only input, **When** I use canvas controls, **Then** zoom, pan, and Fit Puzzle are reachable and every region can be inspected.
2. **Given** gamepad-only input, **When** I perform that flow, **Then** it works without pointing-device input or a focus trap.
3. **Given** existing remaps, **When** navigation is used, **Then** mappings remain intact and affected controls respect the established configurable-input model and menu/pause navigation.

### User Story 3 - Select and Request Help Locally (Priority: P1)

As a player, I can select the intended arrow after navigation and perceive Open Move assistance even when its target begins off-screen.

**Why this priority**: Navigation is useful only if gameplay remains trustworthy.

**Independent Test**: Select known head/tail cells after navigation, attempt a blocked arrow, and request help with the deterministic legal target off-screen.

**Acceptance Scenarios**:

1. **Given** a zoomed/panned view, **When** I select a head or tail cell, **Then** its correct logical owner is selected; empty and departed cells remain ignored.
2. **Given** a pan gesture beginning over an arrow, **When** it ends or is cancelled, **Then** no selection, removal, mistake, or assist is recorded.
3. **Given** a blocked arrow, **When** I select it after navigation, **Then** it stays, the existing penalty applies once, and play continues immediately.
4. **Given** an off-screen assistance target, **When** I request Open Move, **Then** exactly that deterministic legal arrow and its highlight become perceivable, no arrow is removed, and the existing assist cost applies once.
5. **Given** an already perceivable target, **When** I request help, **Then** it remains perceivable without an unnecessary disruptive view change; repeated valid requests retain their existing cost.

### User Story 4 - Preserve Departures and Attempts (Priority: P1)

As a player, I can navigate and resize while a long arrow unwinds without corrupting the animation, attempt, or completion result.

**Why this priority**: Visible unwinding is central to the reward for long-arrow removal.

**Independent Test**: Remove a long bent arrow, zoom/pan/resize during departure, complete the puzzle, then replay.

**Acceptance Scenarios**:

1. **Given** a legal long arrow, **When** selected, **Then** logical removal is immediate and visible departure follows its authored route asynchronously.
2. **Given** active departures, **When** zoom/pan/resize occurs, **Then** each retains its route and progress and completes exactly once at its established full-board clearance condition.
3. **Given** a departing arrow outside the current view, **When** it crosses a viewport edge, **Then** clipping does not count as logical-board clearance or prematurely release the results barrier.
4. **Given** the last removal, **When** departures finish, **Then** results and session-best updates follow the established contract exactly once.
5. **Given** a navigated attempt, **When** resized, **Then** orientation adapts predictably without resetting counters, scoring, or departures.
6. **Given** a completed or interrupted attempt, **When** replay or another puzzle starts, **Then** the view is fresh and no old camera state is restored.

### Edge Cases

- Very wide/tall supported boards: fit includes every edge; pan reaches every region at working zoom.
- A suggested arrow longer than the viewport: reveal an identifiable selectable portion and highlight without requiring its entire length to fit at an unusably tiny scale.
- Repeated input beyond zoom limits: retain finite valid scale and a recoverable view.
- Fit after many removals: fit original authored bounds, not the remaining-arrow bounding box.
- Pan begins on an arrow, ends outside the board, or is interrupted by focus loss/pause: no latent selection follows.
- HUD, menus, and results overlays suppress covered canvas interaction; navigation invalidates stale hover.
- Minimized/zero-area view: avoid invalid transforms, accidental selection, or false completion; recover a valid view when space returns.
- Concurrent departures and assistance: use current logical state and never restart departures.
- Completed puzzle: assistance remains a no-op with zero cost; navigation cannot resubmit completion.
- Replay/puzzle replacement during departure: old presentation work cannot send stale completion into the new attempt.

## Requirements

### Functional Requirements

- **FR-001**: Authored puzzle dimensions MUST be independent of display dimensions. Supported large boards MUST retain complete geometry and rules even when only partly visible.
- **FR-002**: Presentation MUST distinguish board size, geometric density, viewport extent, and zoom. Navigation MUST NOT change cell ownership or authored geometry.
- **FR-003**: Players MUST have zoom-in/out through conventional desktop interaction and accessible keyboard/gamepad controls. Zoom MUST preserve a predictable area of interest and remain finite, positive, and bounded.
- **FR-004**: Players MUST be able to pan to every region of a supported board using desktop, keyboard, and gamepad controls. The whole pan gesture, including initiation/cancellation, MUST be distinguishable from selection and MUST NOT select arrows.
- **FR-005**: An explicit **Fit Puzzle** action MUST show complete authored bounds with positive surrounding margin inside the available puzzle area, for small/large boards and after navigation or removals.
- **FR-006**: Starting, replaying, or changing puzzles MUST establish a fresh complete-board overview. Existing small puzzles MUST remain naturally playable without navigation.
- **FR-007**: Working zoom levels MUST keep arrows traceable, selectable, and distinguishable from neighbors, with hover, blocked, and Open Move feedback perceivable. Large boards MUST have usable working scales beyond their overview.
- **FR-008**: Selection and hover MUST map viewport input to correct logical cells after zoom, pan, fit, and resize, preserving whole-cell head/tail selection and ignored empty/departed cells.
- **FR-009**: View changes MUST NOT alter active arrows, blocking, legal moves, attempt counters, mistakes, assists, score, or completion. Identical logical inputs MUST produce identical solver/analyzer results regardless of view.
- **FR-010**: Open Move MUST preserve the existing deterministic legal-move authority, identify exactly one arrow, reveal no sequence, and remove nothing. Every valid request MUST retain its existing five-mistake-equivalent penalty; automatic reveal MUST add no cost or gameplay mutation.
- **FR-011**: Open Move MUST make its target and highlight perceivable even when initially off-screen. Planning MUST research the smallest predictable reveal behavior; a long arrow need not fit entirely if its identity and selectable portion are clear.
- **FR-012**: Logical removal MUST remain immediate and presentation departure asynchronous. Zoom, pan, and resize MUST preserve the authored departure route, progress, geometry, and logical state.
- **FR-013**: Departure completion and results MUST preserve full-tail logical-board clearance and exactly-once behavior. Clipping/off-screen status MUST NOT complete departure. Pause, replacement/cancellation, and concurrent departures MUST remain correct.
- **FR-014**: Resize MUST adapt using an explicitly planned orientation invariant, such as logical focal point and working scale, without resetting the attempt or scoring. It MUST NOT unexpectedly return a navigated view to Fit Puzzle without a documented research-based reason.
- **FR-015**: Viewport state MUST remain transient: no zoom, pan, viewport location, or per-puzzle camera state may be persisted or restored across attempts/sessions. Existing saved progress, settings, and input remaps MUST be preserved.
- **FR-016**: Every existing catalog puzzle MUST retain loading, layout, selection, blocking feedback, departures, completion, results, scoring, and replay. Existing content MUST NOT be rewritten to demonstrate the canvas.
- **FR-017**: Navigation MUST coexist with configurable input, focus, pause, menus, and results. Canvas input MUST respect overlays and focus loss without accidental gameplay actions.
- **FR-018**: Implementation MUST create the smallest useful validation content, including one deliberately large authored fixture if needed, demonstrating both-axis overflow at working scale, long bent departure, off-screen assistance, and completion. It MUST NOT become difficulty tuning or a Gordian Knot content experiment.
- **FR-019**: Navigation MUST remain responsive for the declared supported authored-board envelope without whole-puzzle reconstruction on every pan/zoom event (threshold and scenario are declared in the plan's Performance Goals). Measurements MUST precede advanced rendering optimization.
- **FR-020**: Planning MUST explicitly document logical grid, board-local visual, and viewport/screen coordinate spaces, forward/inverse input mapping, and one clear presentation transform authority. Definition, rules, solving, analysis, and scoring MUST remain camera-independent.
- **FR-021**: Planning MUST inspect existing scenes, input, rendering, and assistance before fixing component placement, control bindings, zoom limits, pan bounds, reveal, and resize behavior. Interaction architecture MUST allow future pinch input without requiring mobile gestures now.
- **FR-022**: Implementation MUST supply the automated and desktop checks below, affected script/scene validation, and both isolated regression suites. Actual outcomes and unavailable checks MUST be recorded; unperformed checks remain outstanding.

### Planning Decisions and Acceptance Parameters

These are required planning outputs, not blocking product questions:

- Declare a finite large-board validation envelope: dimensions, representative long geometry, working scale, and window sizes. The fixture exceeds the working viewport in both axes and can still fit at valid overview zoom.
- Choose measurable zoom bounds, readable working cell/selection size, and fit margin from existing cell rendering. Distinguish overview from working readability; do not promise arbitrary board sizes.
- Choose pan/selection arbitration, mouse and non-mouse zoom anchoring, keyboard/gamepad mappings, and focus behavior. Inspect press-time selection before choosing any shared-button drag.
- Define off-screen and partially visible assistance reveal, including arrows longer than the viewport.
- Define resize orientation, bounds clamping, zero-area recovery, clipping, and departure projection without changing logical clearance.
- Establish a reproducible responsiveness measurement with machine/window conditions and an acceptance threshold before implementation acceptance. This spec invents no platform frame-rate guarantee.

### Key Entities

- **Logical board**: Complete authored dimensions and ordered arrow paths.
- **Viewport state**: Transient scale and location determining the visible region.
- **Navigation action**: Zoom, pan, or fit without gameplay selection.
- **Assistance target**: One existing legal arrow, highlighted and revealed by presentation.
- **Departure presentation**: A logically removed arrow retaining route/progress independent of visibility.

### Assumptions and Dependencies

- Existing catalog, monotonic rules, analysis, departure, Open Move, and session scoring remain authoritative.
- Fit Puzzle is the default initial view; planning validates its margin/scale against existing small-puzzle feel.
- Overview can be too small for comfortable selection on a large board; bounded working zoom supplies that capability.
- No durable camera preference is introduced; the existing configurable-input settings mechanism remains supported.
- Context gathering reported no skipped items. Its constitution summary contained header metadata only, so the constitution was read directly. The newly initialized 008 template is excluded from prior-feature evidence.
- Bindings, thresholds, component placement, and resize/reveal policy deliberately remain planning decisions, as requested. No blocking product clarification remains.

### Out of Scope

- Procedural generation; final Gordian Knot content/systems; broad difficulty redesign, ratings, adaptive difficulty; proving geometric-entanglement or satisfaction hypotheses.
- New arrow/blocking rules or changes to monotonic removal.
- Persistent camera state, new durable player preferences, profiles, accounts, authentication, cross-session scoring, leaderboards, achievements.
- Telemetry, feedback APIs, monetization, advertising.
- Web deployment, browser-specific optimization, mobile deployment, mobile UI redesign. Pinch gestures are not required; include only if trivial in existing architecture without scope expansion.
- Infinite canvas, arbitrary/unbounded board sizes, chunking, virtualization, spatial indexes, or level-of-detail systems without measured need.

## Success Criteria

### Measurable Outcomes

- **SC-001**: On the declared large fixture, players can inspect all four corners and every occupied region at working scale, then recover all authored bounds with margin using one Fit Puzzle action, with zero gameplay or scoring changes from navigation. Covers FR-001–006, FR-009.
- **SC-002**: Every tested head/tail selection maps to its intended owner after navigation/resize; every tested pan initiation, completion, and cancellation generates zero selections/counter changes. Covers FR-004, FR-008, FR-017, FR-020.
- **SC-003**: Mouse, keyboard-only, and available gamepad-only checks each complete zoom in/out, whole-board inspection, and Fit Puzzle without focus traps. Small puzzles require zero navigation actions before normal play. Covers FR-003–007, FR-016–017.
- **SC-004**: Each valid off-screen-help request reveals exactly the expected legal target/highlight, removes zero arrows, and increments assists once at the unchanged cost. Completed-state requests cost zero. Covers FR-010–011.
- **SC-005**: All long-arrow navigation/resize scenarios preserve route/progress and complete each departure exactly once; results wait for the existing barrier and score identical gameplay actions identically. Covers FR-012–014.
- **SC-006**: Every replay/new-puzzle case gets a fresh overview; storage checks find zero persisted viewport fields and no navigation-induced legacy save/settings changes. Identical logical inputs retain identical analysis results across views. Covers FR-006, FR-009, FR-015.
- **SC-007**: All catalog puzzles and the large fixture pass the specified automated checks. Desktop checks record actual outcomes; unavailable checks remain explicitly outstanding. Covers FR-016, FR-018, FR-022.
- **SC-008**: Large-fixture navigation meets the planning-declared responsiveness threshold under recorded conditions without unnecessary whole-puzzle reconstruction per event. Planning documents all coordinate/acceptance parameters before implementation. Covers FR-019–021.

### Automated Acceptance Coverage

| Check | Required evidence | Requirements |
|---|---|---|
| 1. Small layout | Existing small-board bounds and selection remain correct | FR-006, FR-016 |
| 2. Large board | Create/render a board larger than working viewport without rule changes | FR-001–002, FR-018 |
| 3. Zoom invariance | Scale changes, logical state and score do not | FR-003, FR-009 |
| 4. Pan invariance | Location changes, logical state and score do not | FR-004, FR-009 |
| 5. Fit | All original bounds and margin fit in puzzle area | FR-005 |
| 6. Limits | Repeated zoom input remains within finite valid bounds | FR-003 |
| 7. Coordinates | Head/tail/empty/departed mapping after transforms | FR-008, FR-020 |
| 8. Pan arbitration | Gestures over arrows, outside release and cancellation never select | FR-004, FR-017 |
| 9. Legal assistance | Same deterministic legal target after navigation | FR-010 |
| 10. Off-screen help | Target and highlight become perceivable | FR-011 |
| 11. Mistakes | Blocked selection retains feedback and penalty | FR-009, FR-016 |
| 12. Assist scoring | Valid/repeated/completed requests retain exact accounting | FR-010 |
| 13. Session score | Best and overall scores unaffected by navigation | FR-009, FR-016 |
| 14. Zoomed departure | Authored bends, route and progress remain correct | FR-012 |
| 15. Pan during departure | Route/progress and barrier preserved, including off-screen | FR-012–013 |
| 16. Resize | State unchanged, orientation policy respected during departure | FR-014 |
| 17. Replay | Fresh view; old departures cannot affect new attempt | FR-006, FR-013 |
| 18. Storage | No viewport writes; saved progress/settings preserved | FR-015 |
| 19. Analysis | Identical solver/analyzer results for identical logical inputs | FR-009, FR-020 |
| 20. Regression | Both existing isolated regression suites pass | FR-022 |

### Practical Desktop Verification

Record window sizes, fixture, devices, actions, and actual outcomes for mouse zoom; pan; Fit Puzzle; selection while zoomed and after panning; keyboard navigation; gamepad navigation where available; off-screen Open Move; departures zoomed in/out; zoom/pan during long-arrow departure; resizing while navigated and during departure; and existing small-puzzle feel. Include hover/blocked/assist readability, pause/resume, replay, puzzle transitions, menu focus, and results where affected.

Implementation must receive Godot validation of affected scripts/scenes and desktop smoke testing. Run `python tests/run_puzzle_regressions.py --godot <executable>` and `python tests/run_regressions.py --godot <executable>` with isolated test storage. Automated geometry checks do not replace rendered or physical-input checks. Record unavailable hardware/environment checks as outstanding rather than passed.
