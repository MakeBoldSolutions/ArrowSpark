---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
classification: full-spec
risk_level: medium
target_workflow: specify-full
required_artifacts: spec, plan, tasks
recommended_next_step: implement
required_gates: checklist, analyze, critic
depends_on: []
supersedes: []
participants:
  owner: human
  planner: ai
  implementer: ai
  reviewer: human
  critic: ai
  scribe: ai
---

# Feature Specification: ArrowSpark Progression Pack

**Feature Branch**: `013-spec-progression-pack`
**Created**: 2026-10-11
**Status**: In Progress <!-- Valid: Draft | In Progress | Complete -->
**Input**: User description: "Create a small curated progression of hand-authored, solver-proven ArrowSpark levels that bridge the gap between the small Foundations puzzles and the 115-arrow Reference Knot. Content only; not a generator."

> This spec is temporary working state under `.devspark.work/specs/`. It remains there until
> release archival and must not be referenced by durable code or `.knowledge/` content.

## Product Owner TLDR

ArrowSpark's player-facing content jumps from tutorial-sized puzzles straight to the 115-arrow Reference Knot. The goal is to get the showcase into a state the owner is comfortable sending people to: the API is working, so this is the last gameplay and content gap. The spec has two user stories. Story 1 is a short, targeted gameplay fix (camera and world, below). Story 2 adds roughly eight hand-authored levels (six to ten is acceptable; quality and progression matter more than the count) that step a player up in scale and in kinds of challenge. Each level is valid, proven solvable by the existing solver, plays under the existing rules on desktop and mobile web, and sits in the existing level catalog before the Reference Knot. Story 1's problem, found in play against similar games: the camera is clamped to the board, so a board corner can never be brought to the center of the screen. The board will sit inside a larger empty "world" so any board point can be centered when zoomed in. No rules, scoring, hints or interface change; the camera change is the only engine change in this spec. A further, quieter goal is to write down what these levels teach about what makes a level satisfying, so a future generator can be given real constraints instead of "make hard puzzles". The generator itself is explicitly not part of this spec.

## Rationale Summary

### Core Problem

The catalog has eight Foundations puzzles, thirteen Puzzle Lab experiments and one real level, the Reference Knot. A new player who finishes the introductory material has nothing between "a handful of arrows" and "a 46 × 32 board with 115 arrows and about ten simultaneously obvious moves in its middle". The showcase is live, the touch and feedback paths work, and content is now the main limiting factor on whether outside players stay.

A second problem, found by comparing with similar arrow games: ArrowSpark's camera is clamped so the viewport edge never passes the board edge, with only a 16 px margin at fit. When zoomed in, a corner or edge arrow can reach the screen's edge but never its center, which makes working a dense region near the boundary awkward, and pinch-zooming near an edge drifts away from the touch point. Games the owner likes put the board inside a much larger world canvas, so the viewport can center any board point. Larger, denser boards from this spec make the problem more visible.

### Decision Summary

Hand-author a short progression of real levels, each exploring a distinct kind of ArrowSpark challenge, and prove each with the tools that already exist. Treat analyzer numbers as descriptive instruments, not pass marks. Fix the camera by giving the board a surrounding world rather than adding navigation aids (a recenter control or minimap would leave the clamp in place). Record design learning as the by-product that informs later generator work, without building any of it.

### Key Drivers

- Content is the main gap between Foundations and the Reference Knot, and one small camera fix is the only engine gap standing between the showcase and a state the owner is comfortable sharing.
- Design principles already learned: hard is good and unsolvable is not; completion is expected and efficiency is scored; removing an arrow should make the board feel more untangled; density should come from geometry, not arrow count; long and bent arrows beat piles of isolated singles; structural complexity is not perceptual difficulty; roughly ten immediately obvious moves feels like clicking, and about four obvious moves after an insight feels good; the target rhythm is search → insight → short mastery → consequence → renewed search.
- Hand-authoring dense boards is slow. How slow, and what helped, is evidence for a later generator decision.
- The evidence base is still one designer. Authored levels must be judged by human play, not metrics alone.

### Source Inputs

- Spec 010 outcomes: the Reference Knot, the catalog purpose groups, and the finding that a hand-composed 115-arrow board is laborious to author by coordinates.
- Existing tooling: the puzzle solver, the structural analyzer (arrow count, board size, density, initial legal moves, dependency edges and depth, components, longest chain, bends, blocker distance), the catalog and its regression gates.
- Existing durable references on puzzle design and the Reference Knot.
- Existing durable description of the viewport transform and its bounds clamp in the architecture knowledge, and the existing viewport-transform and canvas headless checks, which assert the current clamp.
- Spec 012 closeout: desktop and landscape-touch play are working; only the camera bounds are reopened here (User Story 1).

### External Contracts

- None consumed from other repos. The existing completion hand-off from the game to the showcase page is unchanged; new puzzles use it exactly as current puzzles do.

### Tradeoffs Considered

- Procedural generation now: rejected. It would optimize metrics that human play has not yet validated, and the project has no stated constraints to give it.
- One more very large puzzle: rejected. The gap is in the middle, not at the top.
- Many small variations of Foundations: rejected. They would not add new kinds of challenge.
- Camera: a recenter button or minimap, or a smaller edge margin, were considered; none lets a corner reach the screen center. Selected: board inside a larger world.
- Selected: a small curated set with distinct intent per level, authored and checked with existing tools.

### Architectural Impact

- Catalog gains new entries in the existing level group. Stable ids of current puzzles are unchanged.
- Three layers become explicit: the viewport (the screen area), the board (the puzzle grid) and the world (the board plus whatever lies beyond its edges). The camera clamp in `PuzzleViewportTransform` moves from the board to the world. This is a presentation-layer change in `PuzzleViewportTransform` and `PuzzleBoard` only.
- No change to puzzle rules, scoring, the solver's meaning, board geometry or hit testing in logical coordinates, input mapping, persistence or the site.
- Group-relative numbering and group-scoped Next Puzzle shift as designed when entries are added; this is expected behavior, not a regression.

### Reviewer Guidance

Review the levels by playing them and reading the per-level notes, then check the evidence that each is valid and solvable. Do not review for conformance to metric targets; none are set.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Comfortable navigation: any part of the board can be centered (Priority: P1)

A short, targeted gameplay fix. A player zooms into a dense region and pans so that any point of the board, including corners and edges, sits at the center of the screen, on desktop and on a touch phone. The board lives inside a larger empty world, so there is room to do this, as in the similar arrow games the owner likes. This ships first and is independently valuable on the existing puzzles.

**Why this priority**: Navigation near the board boundary is the main play-feel gap found against similar games, and the denser levels in User Story 2 make it more visible. It is small, self-contained and testable on today's catalog.

**Independent Test**: On any existing puzzle at any zoom level, pan each of the four corners to the viewport center; wheel-zoom and pinch near an edge and confirm the point under the cursor or fingers stays put. No new levels are needed.

**Acceptance Scenarios**:

1. **Given** any puzzle zoomed in, **When** the player pans toward a board corner, **Then** the corner cell can be brought to the center of the viewport.
2. **Given** the puzzle at Fit Puzzle, **When** the view is shown, **Then** it frames the board as it does today; the extra world space is not visible until the player zooms in and pans out to it.
3. **Given** the camera near a board edge, **When** the player wheel-zooms or pinch-zooms there, **Then** the board point under the cursor or between the fingers stays under it.
4. **Given** the player has panned into the empty world, **When** they use Fit Puzzle or a reveal (hint, selection), **Then** the board is brought back into view as before.
5. **Given** the camera, **When** panned far from the board, **Then** it stops while some of the board remains reachable: the player cannot lose the board.
6. **Given** the player completes arrows while the board edge is on screen, **When** an arrow departs, **Then** it is not sliced at the board edge; it keeps moving past the edge and is removed only after travelling a fixed margin beyond it.

---

### User Story 2 - A hand-authored progression that fleshes out the demo (Priority: P1)

A player who has learned the basics moves through roughly eight hand-authored levels that grow in size and in the kinds of thinking required, and reaches the Reference Knot having already met long and bent arrows, neighborhoods, dependencies and board-wide rescans. Each level offers a different experience, is proven solvable, and plays correctly on desktop and mobile web. Together with User Story 1 this brings the showcase to a state the owner is comfortable sending people to.

**Why this priority**: Content is the gap between the Foundations puzzles and the Reference Knot, and a visitor needs more than a tutorial and one very large puzzle.

**Independent Test**: Play the new levels in order from the first to the Reference Knot: no jump feels like a cliff, every level completes via the normal Results flow, and the regression gates pass with the levels in the catalog. Each level has a design-intent note; a reviewer can name a different primary challenge for each.

**Acceptance Scenarios**:

1. **Given** the level catalog, **When** a player opens the level group that contains the Reference Knot, **Then** the new levels appear before it in an intended order, each with a distinct title, and Next Puzzle from the last new level opens the Reference Knot.
2. **Given** the main menu, **When** the player chooses Play, **Then** the first new progression level starts, and the Reference Knot remains reachable as the last level of its group.
3. **Given** any new level, **When** it is played to completion with the existing controls, **Then** Results, Replay and Next Puzzle behave as they do for existing puzzles.
4. **Given** the set of new levels, **When** the design-intent notes are read, **Then** each level names at least one primary challenge, no two share the same sole primary challenge, and long or bent arrows rather than isolated single-cell arrows carry the geometry.
5. **Given** each new level, **When** the existing solver runs on it, **Then** it reports the level valid and solvable with a witness order, and the existing headless regression gates report zero failures.
6. **Given** a new level on the live showcase build, **When** played on desktop and on a landscape touch phone, **Then** it loads, accepts taps and clicks, pans and zooms, and completes.
7. **Given** the finished set, **When** the design-learning record is read (secondary, lower priority), **Then** it lists per-level characteristics and designer notes, separates observed facts, judgments and open questions, and commits to building nothing.

---

### Edge Cases

- Board smaller than the viewport at Fit: the view stays locked and centered exactly as today; the buffer becomes reachable only after the player zooms in beyond Fit (decided with the owner).
- Window resize, rotation or orientation change while the camera is in the buffer: the camera stays within the new bounds and the board remains reachable.
- Keyboard and gamepad pan and the focused zoom actions obey the same world bounds as mouse and touch.
- Very small boards (for example the smallest Foundations puzzles) and the largest (Reference Knot) both satisfy the corner-centering behavior.
- The board is pannable out of view only partly; Fit Puzzle always restores a complete view.
- A level the analyzer rates structurally hard but that plays as a chore of obvious clicks: it is recorded as a learning and may be revised or dropped; it is not forced into the set.
- A level whose solver run is too slow for the headless launcher time limit: an existing sampled-check precedent applies; the limitation is recorded, not hidden.
- A candidate level that proves unsolvable or invalid: it is fixed or discarded before it enters the catalog; no unsolvable level ships.
- Fewer than six levels survive playtesting: the spec reports the shortfall honestly rather than padding with fixtures.
- Re-ordering or retitling a new level after release: ids remain stable once chosen.
- Catalog regression tests that assume the old group size or numbering: they are updated to the new, intended contents.

## Requirements *(mandatory)*

### Functional Requirements

> Each `FR-###` is a stable traceability anchor. Every functional requirement should be satisfied by at least one task in `tasks.md` (referenced there via `Implements: FR-###`).

#### Story 2 - Progression levels

- **FR-001**: The catalog MUST gain between six and ten new hand-authored, player-facing levels, targeting about eight, placed in the level group that currently holds only the Reference Knot and ordered before it.
- **FR-002**: Each new level MUST be valid and proven solvable by the existing solver, with the evidence recorded.
- **FR-003**: Each new level MUST use only existing gameplay rules, scoring, rendering and input; no rule, scoring, hint, persistence or UI change is part of this spec beyond the camera/world change in FR-018 to FR-022 and the departure presentation change in FR-023.
- **FR-004**: Each new level MUST have a stable id and a distinct, player-appropriate title, and MUST carry a short design-intent note naming its primary challenge or experience.
- **FR-005**: The set MUST present meaningfully different structures or experiences, drawn from ideas such as: tracing long or bent arrows; nearby arrow ownership; multiple local neighborhoods; dependencies between neighborhoods; bridge arrows; short follow-up chains; uncertainty followed by insight; major releases that open several moves; renewed whole-board rescans; rising visual density; longer tails and more bends. The ideas and the illustrative titles (First Knot, Two Neighborhoods, The Bridge, False Simplicity, The Rescan, Major Release, Dense Weave, Almost a Knot) are guidance, not a required list.
- **FR-006**: The set MUST rise in scale and demand in a way a reviewer can describe as a progression; the first new level MUST be a plausible next step after the Foundations material and the last a plausible lead-in to the Reference Knot.
- **FR-007**: New levels MUST be designed as real player content; they MUST NOT rely on many isolated single-cell arrows for density, and no level MUST be a diagnostic fixture.
- **FR-008**: For each new level the implementation MUST capture, where existing tooling reports them, the arrow count, board dimensions, density, initial legal move count, dependency depth and edges, connected components, longest chain, arrow length (average and maximum), bend count and single-cell arrow count or share, plus any notable unlock or release moments the designer observes.
- **FR-009**: Captured characteristics MUST be recorded as descriptive data. No numeric acceptance threshold is set on any of them unless existing durable evidence already supports that threshold.
- **FR-010**: The implementation MUST update the catalog regression coverage so the new levels are checked by the existing gates, and all existing failure markers MUST report zero.
- **FR-011**: Each new level MUST play correctly in the existing desktop and mobile-web experience, including the Results, Replay, Next Puzzle and Level Select flows and the completion hand-off to the showcase page.
- **FR-012**: The designer MUST play each level and record brief qualitative notes: where they searched, where an insight occurred, whether follow-up moves felt rewarding, whether the board felt tedious or satisfying, whether it produced a meaningful rescan, and which releases felt especially good. Formal user testing is not required.
- **FR-013**: A design-learning record MUST be produced, covering the per-level characteristics and notes, a short cross-level summary of what worked and what did not, and observations that could later inform a Puzzle Forge or generator specification. It MUST separate observed facts, designer judgments and open questions, and MUST NOT specify or begin a generator.
- **FR-014**: Findings discovered during verification MUST be classified as Blocking Defect, Accepted Limitation, Deferred Work or Learning / Changed Assumption. Only Blocking Defects prevent completion, and a finding MUST NOT create a new obligation for this spec merely because it suggests a future opportunity.
- **FR-015**: Existing puzzle ids, existing puzzle definitions and the Reference Knot's content MUST remain unchanged.
- **FR-016**: Durable project knowledge MUST be updated to reflect the new levels, any durable design learning and the new world-bounds camera behavior (replacing the description of the board-edge clamp), without referencing this spec's identifier.
- **FR-017**: The main-menu Play action MUST start the first new progression level instead of the Reference Knot, so a newcomer begins the ramp; the Reference Knot remains reachable as the last level of the group, and its content is unchanged.

#### Story 1 - Navigation and world buffer

- **FR-018**: The puzzle view MUST distinguish a board (the puzzle grid) from a world (the board plus whatever empty space the viewport shows beyond its edges), and MUST allow the camera center to reach any point of the board, including all four corners, at every zoom level beyond Fit (at Fit the whole board is already in view and the view stays centered).
- **FR-019**: The reachable world MUST allow a board corner to be centered in the viewport at any zoom beyond Fit (the camera center is limited to the board itself, so no separate buffer size exists), and MUST be bounded so that part of the board always remains inside the viewport.
- **FR-020**: Fit Puzzle, initial view, reveal-on-hint/selection and window resize MUST keep their current framing behavior; the buffer is only reachable by panning after zooming in beyond Fit, and MUST NOT change how a fitted board looks; at Fit scale the view stays centered and does not pan.
- **FR-021**: Wheel zoom, pinch zoom and the zoom buttons MUST keep the anchor point (cursor, pinch midpoint or viewport center) fixed in board space, including near and beyond board edges, with no drift introduced by clamping.
- **FR-022**: The camera change MUST be confined to the presentation layer; logical board geometry, hit testing in board coordinates, solver, state and scoring MUST be unchanged. Existing headless checks that assert the old board-edge clamp MUST be updated to the new behavior, and checks MUST be added for corner-centering, bounded pan and anchor stability.

- **FR-023**: Departing arrows MUST NOT be clipped at the board edge. A departing arrow MUST continue past the board edge and be removed only after travelling a fixed margin (in cells, independent of pixel size or zoom) beyond it, so that removal is not visible in the common zoomed-in view. The added time before Results MUST be measured and recorded; rules, state, scoring and the order of completion MUST be unchanged.

### Key Entities

- **Progression Level**: A hand-authored, player-facing puzzle in the level group, with a stable id, title, design-intent note, captured characteristics and designer notes.
- **Design-Learning Record**: The per-level and cross-level document of observations that may later inform generator constraints.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Between six and ten new levels are playable from Level Select, in an intended order, ahead of the Reference Knot.
- **SC-002**: 100% of new levels are shown valid and solvable by the existing solver, and every existing regression gate reports zero failures with the new levels included.
- **SC-003**: 100% of new levels complete through the normal Results flow on desktop, and on at least one real landscape touch phone each level is opened and a representative sample is played through, with anything not played recorded as not tested.
- **SC-004**: Every new level has a design-intent note, captured characteristics for each measure the existing tooling reports, and designer playtest notes; no level is accepted with an empty record.
- **SC-005**: A reviewer reading the intent notes can name a different primary challenge for every level, and none relies mainly on isolated single-cell arrows.
- **SC-006**: In the designer's judgment, the step from the previous level to each next level, including from the last new level to the Reference Knot, is not a cliff; any judged cliff is recorded as a finding with its classification.
- **SC-007**: A design-learning record exists that a future generator specification could cite, and no generator code, runtime generation or procedural content is added.
- **SC-008**: Zero changes to gameplay rules, scoring, hint behavior, persistence, controls layout or the showcase site's contracts. The only engine changes are the camera/world clamp and the departure presentation in FR-023.
- **SC-009**: A headless check shows each of the four board corners can be brought to the viewport center for every distinct board size in the catalog; on desktop this is hand-confirmed on a small and a large puzzle, and on the real Android phone on one new level and the Reference Knot. Fit Puzzle looks unchanged.
- **SC-010**: Pinch and wheel zoom near a board edge keep the board point under the anchor within one screen pixel of its pre-zoom position (headless check at the transform level; hand check on desktop and phone).
- **SC-012**: Completing the Reference Knot zoomed in with a board edge near the screen center shows no arrow sliced at the board edge, and the added time before Results is measured and recorded.
- **SC-011**: Choosing Play from the main menu starts the first new progression level.

## Assumptions

- The existing solver and analyzer are sufficient; extending them is not part of this spec. If a needed characteristic is not reported by existing tooling, it is recorded as unavailable rather than built.
- New levels fit the existing board model. Apart from the world-buffer camera change in User Story 1, the existing zoom, pan and Fit Puzzle support their size. The world needs no separate buffer size: the camera center is limited to the board itself, and the viewport shows whatever lies beyond the edge. Boards at or below the Reference Knot's size are expected.
- The existing puzzle content-version mechanism for the completion hand-off, if it derives from catalog content, updates by its existing means.
- The designer's own playtesting is acceptable evidence of feel for this spec, and its single-tester limitation is acknowledged in the record rather than treated as a defect.
- The reactions/feedback API is separate, already-working effort and is not part of this spec; this spec closes the remaining gameplay and content gaps before the owner shares the showcase.
- The level group's existing title ("ArrowSpark Levels") is kept.

## Out of Scope

- Procedural or random level generation, runtime generation, daily puzzles, endless mode, and any generator architecture.
- New scoring rules, hints or gameplay rules; persistence or player identity.
- Mobile redesign, broad UI redesign, and zoom/pan work beyond the world-buffer clamp and anchor stability in User Story 1 (no new gestures, minimap, inertia or zoom limits).
- Fresh-player validation protocol, feedback analysis and the 44 px touch-target work, which are separate follow-ups.
- Large manual test matrices; iPhone certification.
- Changing or rebalancing existing Foundations, Puzzle Lab or Reference Knot puzzles.
