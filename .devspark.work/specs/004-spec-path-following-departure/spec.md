---
classification: full-spec
risk_level: medium
risk_profile: internal
change_type: brownfield
target_workflow: specify-full
required_artifacts: spec, plan, tasks
recommended_next_step: plan
required_gates: checklist, analyze, critic
route_intent: full-spec
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
status: Draft
---

# Feature Specification: Path-Following Arrow Departure

**Feature Branch**: `004-spec-path-following-departure`
**Created**: 2026-09-26
**Status**: Draft
**Input**: Pull legally removed continuous arrows through their stationary ordered route and clip them at the puzzle-board edge, preserving immediate logical removal and all puzzle rules.

## Product Owner TLDR

Bent arrows will visibly feed through their own bends and out of the board instead of sliding away as rigid shapes. Bends stay in place until the tail passes them, while the head continues forward at a consistent speed. Straight and single-cell arrows use the same behavior. Players can continue making legal moves immediately, and results appear only when all departing arrows have cleared the board.

## Rationale Summary

### Core Problem

Continuous arrows now communicate their full shape, but rigid departure does not convey that shape unwinding. Departing arrows also cease following board layout during resize. This change improves removal feedback without making animation part of the puzzle rules.

### Decision Summary

Move a constant-length arrow through its original stationary route and then along its forward escape ray. Clip departing geometry at the puzzle-board boundary, use distance-based timing, and preserve immediate atomic logical removal and the existing all-departures completion barrier.

### Key Drivers

- Readable, satisfying removal for single-cell, straight, one-bend, and multi-bend arrows.
- Unchanged domain behavior, whole-cell selection, and responsive successive moves.
- Correct clipping, resize, pause, cleanup, and concurrent-departure behavior.

### Source Inputs

- [User brief, preserved verbatim](source-brief.md), including explicit implementation preferences and verification coverage.
- Repository research and the user's accepted fixed-route, cell-distance speed, and board-clipping decisions in this conversation.
- Completed continuous-arrow presentation and the existing immediate-removal/departure barrier.
- Project constitution: simple project-level changes, preserved controls/settings, responsive gameplay, and honest automated/manual verification.
- User explicitly confirmed full-spec route, medium risk, and branch creation.

### Tradeoffs Considered

- Rigid translation retains the unwanted visual behavior; moving bends changes the accepted effect.
- Shrinking only the tail fails constant-length behavior; endpoint-only reconstruction can cut diagonally across bends.
- Fixed duration makes longer routes travel faster; consistent cell-distance speed is selected.
- Physics or chains of follower objects add unjustified complexity for a stationary ordered route.

### Architectural Impact

The individual-arrow presentation owns departure progress and appearance. Board presentation owns layout, clipping, and departing-view tracking. The controller coordinates lifecycle only. Puzzle structure, ownership, validation, legality, solver, counters, and logical completion remain unchanged. Preserve the user's detailed technical constraints in the source brief for planning; no new runtime dependency is required by this spec.

### Assumptions and Defaults

- Context gathering found all three prior specs and no skipped context; the full constitution was read separately because the gathered summary contains metadata only.
- The visual boundary means the occupied rectangular grid, centered within the board allocation, excluding any letterbox margin. This interpretation makes the exit edge follow the actual puzzle cells at every aspect ratio.
- Start at 10 cells per second, centrally configured and shared by all arrows. Tuning within the requested 8–12 range is permitted with recorded visual evidence; tests use the configured value. No duration cap is included initially, preserving consistent speed. A later cap requires documented rationale and deterministic acceptance updates rather than silent acceleration.
- Centerline length is measured before clipping, in cell units. Clipped onscreen length intentionally decreases; silhouette perimeter and pixel area need not remain constant.
- Resize preserves cell-distance progress. Pause freezes that progress; a layout change during pause may rescale/reposition the frozen shape without advancing it.

### Out of Scope

New mechanics, generation, difficulty analysis, levels, progression, persistence changes, achievements, audio, haptics, mobile deployment, broad menu/results redesign, scoring changes, curved authored routes, moving bends, physical ropes/snakes, departure collisions, per-arrow colors, and solver/domain changes.

### Retention

This temporary bundle remains under `.devspark.work/` until release archival. Production code, tests, and durable knowledge must not reference its identifiers or paths. Implementation updates current durable knowledge where behavior changes; this authoring step does not modify runtime code or knowledge.

## User Scenarios & Testing

### User Story 1 - See an arrow feed through its route (Priority: P1)

As a player, I want a removed arrow to unwind through its existing bends so its departure feels connected to its shape.

**Why this priority**: This is the requested visual change.

**Independent Test**: Depart single-cell, straight, one-bend, and multi-bend fixtures in all four directions; inspect positions at explicit departure distances and observe actual play.

**Acceptance Scenarios**:

1. **Given** a legal bent arrow, **When** selected, **Then** its head advances forward, the tail follows the ordered route, and each bend stays fixed until the tail passes it.
2. **Given** a partially departing arrow, **When** its geometry is evaluated, **Then** its unclipped centerline length is unchanged, intermediate corners remain connected, and no diagonal shortcut occurs.
3. **Given** a single-cell or straight arrow, **When** selected, **Then** it leaves naturally along a straight route with the same speed policy and no initial jump.
4. **Given** an arrow crossing the grid edge, **When** part of its head or body passes outside, **Then** that part is clipped and no departing geometry draws over surrounding UI.
5. **Given** two different required travel distances, **When** both depart, **Then** they advance at the same cells-per-second speed and the farther travel takes longer.

### User Story 2 - Continue play while departures drain (Priority: P1)

As a player, I want subsequent legal moves to work immediately and results to wait for every departing arrow.

**Why this priority**: Visual effects must not change correctness or responsiveness.

**Independent Test**: Remove a blocker, select its newly legal dependent before the first departure ends, then drain several departures in a different order from selection.

**Acceptance Scenarios**:

1. **Given** a legal arrow, **When** selected, **Then** every owned cell becomes logically inactive and counters/HUD update before visual motion advances.
2. **Given** a visibly departing former blocker, **When** its dependent is selected, **Then** legality reflects immediate removal; selecting the departing arrow's old cells adds no tap or mistake.
3. **Given** logical completion with multiple outstanding departures, **When** only some finish, **Then** results stay hidden; after the final full-tail clearance, results appear with unchanged score and accuracy.
4. **Given** different departure speeds used in verification, **When** the same selection sequence runs, **Then** logical outcomes and solver results are identical.

### User Story 3 - Preserve visual state and lifecycle (Priority: P2)

As a player, I want hover, blocked feedback, pause, resizing, and restarting to remain predictable during departure.

**Why this priority**: These transitions can corrupt geometry or leave completion waiting indefinitely.

**Independent Test**: Start departure during hover and several blocked-pulse phases, resize and pause it, then restart or leave the scene with multiple departures pending.

**Acceptance Scenarios**:

1. **Given** hover or blocked feedback, **When** departure starts, **Then** scale/color normalize synchronously and subsequent feedback or duplicate departure requests cannot interfere or duplicate completion.
2. **Given** a moving arrow, **When** paused and resumed, **Then** progress freezes and resumes at the same distance without skipping a bend.
3. **Given** an in-progress departure, **When** resized, **Then** its cell-relative progress is unchanged, pixel geometry and clipping follow the new layout, and input remains inactive.
4. **Given** pending departures, **When** restarting, reloading, replaying, or leaving, **Then** old effects are disposed without callbacks changing the next attempt.
5. **Given** existing controls, remaps, saved progress, and settings, **When** playing through pause/results/menu transitions, **Then** supported keyboard/gamepad navigation and stored values remain intact.

### Edge Cases

- Head already at the edge: head clipping can begin early; completion still waits for the tail cap.
- Multiple bends and neighboring nonconsecutive route cells: follow order without inventing connections.
- Very short residual segments or exact corner samples: no duplicated endpoint artifacts, division by zero, gaps, or discontinuities.
- Single-cell arrow: preserve its existing synthetic shaft rather than forming a zero-length path.
- Zero-size layout: remain safe and do not falsely complete; recover when a valid layout returns.
- Resize during pause: layout may change while departure distance remains frozen.
- Concurrent departures may visually overlap; that overlap never has collision or rule effects.
- Final logical removal may occur while earlier, longer arrows are still visible.

## Requirements

### Functional Requirements

- **FR-001**: A legal selection MUST remove the full arrow logically and atomically, updating existing counters and HUD before visual departure advances. Animation MUST NOT influence ownership, blocking, legality, solver behavior, scoring, mistakes, accuracy, unlimited attempts, or logical completion.
- **FR-002**: Departure MUST use the existing ordered shape as a stationary tail-to-head route followed by a straight forward ray. Bends MUST remain fixed in board coordinates and disappear only as the tail passes them.
- **FR-003**: The unclipped arrow MUST retain its original apparent centerline length throughout departure; interval geometry MUST retain all intervening corners without diagonal shortcuts, gaps, or disconnected head/body geometry.
- **FR-004**: Single-cell, straight, one-bend, and multi-bend arrows MUST use the same departure concept in all four directions. Single-cell arrows MUST retain their existing synthetic shaft. Head orientation and shape proportions MUST remain consistent with the continuous-arrow presentation, with no first-frame geometry jump.
- **FR-005**: Motion MUST advance at a centrally configured consistent cell-distance speed, initially 10 cells per second, independent of pixel size, arrow length, and frame rate. It MUST be monotonic and free of bounce or exaggerated easing; any speed tuning follows the stated defaults policy.
- **FR-006**: Departing geometry MUST be clipped progressively to the occupied grid rectangle, including during resize, without drawing over surrounding HUD or other UI. Logical removal MUST be independent of clipping.
- **FR-007**: A departure MUST finish only after all geometry has cleared the relevant grid edge, including body width, round tail cap, head shape, and a documented small clearance tolerance. Head exit alone MUST NOT finish departure.
- **FR-008**: Departure MUST synchronously clear hover/blocked state, cancel competing effect writers, normalize scale and color/modulation, and then begin motion. Departing views MUST ignore later hover/blocked requests and duplicate starts; each departure MUST complete exactly once.
- **FR-009**: Whole-cell hit testing and head/tail selection equivalence MUST remain unchanged for active arrows. Departing arrows MUST be excluded from active selection/hover immediately, while newly legal arrows remain selectable during ongoing effects.
- **FR-010**: Multiple departures MUST progress independently and may finish in any order. Results MUST wait for all outstanding departures after logical completion, then show unchanged outcome values.
- **FR-011**: Resizing MUST preserve cell-distance progress, rebuild and reposition departing geometry, update clipping/clearance, and neither restart animation nor reactivate input nor duplicate completion. Departing views MUST remain available to presentation layout and cleanup without rejoining active ownership.
- **FR-012**: Pause MUST freeze departure progress and prevent departure completion while paused. Resume MUST continue from the same distance. Restart, reload, replay, and scene exit MUST dispose old departures and prevent stale callbacks affecting another attempt.
- **FR-013**: Coincident presentation points, exact-vertex samples, short residual segments, and zero layout extent MUST be handled safely without geometry corruption, invalid arithmetic, or premature completion.
- **FR-014**: Puzzle definition, ordered ownership semantics, structural validation, state, solver, and existing gameplay rules MUST remain unchanged. Route calculations MUST be presentation-only; the individual view owns visuals, the board owns layout/clipping, and the controller coordinates lifecycle without path mathematics.
- **FR-015**: Existing keyboard/gamepad navigation, input remapping, saved progress/settings, replay, pause, and menu behavior MUST be preserved. No data migration/reset or persistence change is part of this feature.
- **FR-016**: Verification MUST include deterministic geometry and scene/lifecycle checks listed below, existing regression suites, engine validation, and actual desktop visual play. Required unavailable checks MUST remain explicitly outstanding rather than be reported as passed.
- **FR-017**: Implementation MUST update affected current presentation knowledge to explain ordered geometry, immediate logical removal, continued fixed-route departure, and the visual completion barrier without durable backlinks to this temporary bundle.

### Geometry Contract

In cell units, let P(s) sample the ordered route by distance, L be the original tail-endpoint-to-head-center distance, and d be departure distance. Tail position is P(d); head center is P(L+d). Beyond the original head, P continues analytically in the original forward direction. The body ends at the existing offset inside the head. Preserve every intermediate route vertex between the moving body endpoints. This describes required geometry, not a mandated API.

### User-Supplied Planning Constraints

Retain the existing `Line2D` body and `Polygon2D` head unless analysis identifies a concrete inability to meet these requirements. Prefer one scalar distance over an immutable presentation polyline, rebuilding its moving interval. A small pure presentation helper may calculate cumulative lengths, sampling, interval extraction, and clearance; it must not own Nodes or domain responsibilities. Do not introduce `Path2D`, `PathFollow2D`, `Curve2D`, physics, or segmented followers merely because they can animate paths. These explicit user constraints are retained here rather than discarded to satisfy a generic technology-agnostic drafting guideline; detailed implementation belongs in planning.

### Verification Scope

**Geometry/unit**: Route order, synthetic shaft, cumulative length, sampling within segments/at bends/at head/on forward ray, one/multiple bends, corner preservation, constant centerline length, continuity around bend consumption, head/body alignment and orientation, full tail clearance, coincident-point guards, zero extent, equivalent cell-relative geometry after resize, and initial appearance equivalence.

**Scene/integration**: Immediate removal/HUD, ignored departed-cell input/hover, synchronous normalization at different pulse phases, duplicate-start guards, independent concurrent departures with reversed finish order, pause/resume, resize, results barrier, cleanup/restart/reload, and domain independence from timing. Existing rule, solver, scoring, save/input, and presentation suites must remain green.

**Manual visual play**: All shape categories; readable feeding motion and speed (continuous frame-to-frame forward progress with no visible stutter, freeze, or backward step); fixed bends without diagonal cuts; acceptable tail-cap corner traversal (the tail cap follows the route through each bend with no visible skip or jump as it turns the corner); connected head/body without an initial jump; progressive grid clipping without UI spill; simultaneous departures; pause/resume; resize; final results transition. Exercise affected navigation/remapping and preservation of saved data, recording hardware limitations honestly.

## Success Criteria

### Measurable Outcomes

- **SC-001**: For single-cell, straight, one-bend, and multi-bend fixtures in every direction, all sampled departure states preserve the original route's corners and unclipped centerline length within a documented numerical tolerance; manual play confirms readable feeding motion in each shape category (US1).
- **SC-002**: Equal unpaused elapsed times produce equal cell-distance advancement at the configured speed across shape lengths and supported layouts, within numerical/frame scheduling tolerance; no direction reversal occurs (US1).
- **SC-003**: At every evaluated departure state, no rendered departing portion lies outside the grid clipping boundary; each departure signals once only after its entire tail and visual footprint clear (US1, US2).
- **SC-004**: Identical input sequences yield identical logical states, counters, scores, and accuracy across tested departure timings; all departed cells become unselectable before visual advancement (US2).
- **SC-005**: In simultaneous-departure scenarios with differing finish orders, results remain hidden while any departure is pending and appear once all have finished; no duplicate completion or negative pending count occurs (US2).
- **SC-006**: Pause and resize checks preserve departure distance, and repeated lifecycle transitions leave no old departures or callbacks affecting fresh attempts. Verification includes 960x540 and 1280x720 layouts and an aspect-ratio change (US3).
- **SC-007**: Required regression and validation checks pass, supported navigation/remapping and saved data remain intact, and all manual visual checks have recorded results before implementation is declared complete (US1–US3).
