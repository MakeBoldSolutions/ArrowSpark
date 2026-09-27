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
status: Complete
---

# Feature Specification: Rich Arrow Model and Solvability Foundation

**Feature Branch**: `002-spec-multi-arrow-solvability`
**Created**: 2026-09-26
**Status**: Complete
**Input**: User description: "Rich Arrow Model and Solvability Foundation — extend the existing First Playable Arrow Puzzle to support multi-cell arrows (arrowhead plus a straight or right-angle-turning tail occupying one or more cells) and establish solvability as a formal, presentation-independent domain property with witness-solution generation, retaining basic structural counts as a foundation for future difficulty analysis, while preserving current scoring, HUD, Replay, Main Menu integration, and rule/presentation separation."

## Product Owner TLDR

Arrows can now be more than a single cell: each arrow has a head that sets its direction and a tail, which may run straight or bend at right angles, that occupies additional cells and can block other arrows just as a head does. The new handcrafted puzzle shows this off — straight tails, bent tails, tails that block other arrows until removed, and all four directions. Underneath, the game can now prove a puzzle is solvable by finding one complete valid order of removals, and it reports when a puzzle definition has no solution at all, so a puzzle we ship can never be silently broken. Everything players already rely on — scoring, mistakes, HUD, results, Replay, Main Menu — stays the same.

## Rationale Summary

### Core Problem

The current puzzle rule model only supports single-cell arrows, which cannot express tails that visually and mechanically block other arrows, and there is no domain-level way to know whether a hand-authored puzzle is actually solvable before it ships — today that assurance rests entirely on manual play.

### Decision Summary

Extend the arrow representation so each arrow owns a connected shape (head plus zero or more tail cells, straight or right-angle), keep the arrowhead as the sole source of travel direction, and extend blocking so any occupied cell of another active arrow — head or tail — counts. Add a presentation-independent solvability analysis that searches for one complete legal removal order (a witness) and reports failure when none exists, retaining cheap structural counts (choices encountered, forced states, branching states) so future difficulty work has a foundation without committing to a difficulty score now.

### Key Drivers

- Player-visible request: multi-cell arrows with straight and bent tails, and tails that participate in blocking.
- Correctness assurance: a puzzle shipped for play must be provably solvable, not just informally verified once by hand.
- Forward compatibility: the analysis result must be extensible for later difficulty metrics without a breaking change to its contract.
- Regression safety: the existing scoring model, HUD, Replay, Main Menu integration, and rule/presentation separation must not change.

### Source Inputs

- User's Rich Arrow Model and Solvability Foundation request and confirmed full-spec route.
- [Project constitution](../../../.knowledge/governance/constitution.md), version 2.0.0 — Principle I (simple, maintainable code and clear naming), Principle IV (responsive gameplay), Principle V (practical gameplay verification), Principle VI (preserve saved progress and settings).
- [Arrow Puzzle Rules, Presentation and Menu Integration](../../../.knowledge/architecture/arrow-puzzle.md): documents the current single-cell `PuzzleDefinition`/`PuzzleState` rule layer, the axis-scan blocking rule, the results/score/accuracy formulas, the Replay-via-scene-reload approach, and the no-reset menu guarantee — all of which this feature extends rather than replaces.
- Prior spec [001-spec-first-playable-arrow-puzzle](../001-spec-first-playable-arrow-puzzle/spec.md): establishes the scoring formulas, unlimited-mistakes behavior, HUD/results contract, and rule/presentation separation this feature must preserve.
- Context gathering found no other relevant prior specifications and skipped no context sources.

### Tradeoffs Considered

- Exhaustive enumeration of every solution for every puzzle would give the strongest possible solvability guarantee but is unnecessary for this iteration's stated goal (proving at least one solution exists) and is explicitly not required unless later analysis shows it is needed for verification itself.
- A full difficulty score or Easy/Medium/Hard classification was considered and rejected for this iteration; only inexpensive, naturally-available structural counts are retained so the result contract can grow later without redesign.
- Procedural or randomized puzzle generation was considered and rejected; the feature stays with a single handcrafted puzzle, consistent with prior scope decisions.
- Allowing tails to pass through cells already claimed by another arrow (shared cells) was rejected in favor of exclusive cell ownership, keeping blocking and removal unambiguous.

### Architectural Impact

- The rule layer's arrow representation changes from a single cell/direction pair to a shape (head cell, direction, and an ordered tail-cell path); this is a superset extension, so a single-cell arrow remains a valid degenerate case (empty tail).
- Blocking evaluation changes from a single-cell axis scan to a path-vs-occupied-cells check against every cell of every other active arrow, still confined to rule/state code independent of scenes, input, or animation.
- A new rule-core analysis capability is added alongside (not inside) the existing per-attempt state, since it evaluates puzzle definitions rather than tracking a live attempt; it does not alter `PuzzleState`'s existing counters or formulas.
- No changes are introduced to scoring/accuracy formulas, save/settings persistence, or menu wiring.

### Reviewer Guidance

Focus on: whether blocking correctly treats every tail cell the same as a head cell in all four directions; whether the arrowhead's direction is unaffected by tail shape; whether removal always clears every cell of the arrow's shape atomically; whether the solvability analysis is fully decoupled from scenes/input/animation and returns a usable witness sequence; whether the shipped puzzle's automated verification actually exercises the new analysis rather than only manual play; and whether existing scoring, HUD, Replay, and Main Menu behavior is unchanged.

## User Scenarios & Testing

### User Story 1 - Play Multi-Cell Arrows With Straight and Bent Tails (Priority: P1) ✅ Complete

As a player, I can see and select arrows that occupy more than one cell — some with a straight tail, some with a tail that bends once or more at right angles — and have them leave the board in the direction their head points.

**Why this priority**: Multi-cell arrows with straight and right-angle tails are the headline visible change requested and the foundation every other scenario depends on.

**Independent Test**: Load the puzzle, identify a multi-cell arrow with a straight tail and one with a bent tail, and successfully remove each when its path ahead is clear, confirming the entire shape leaves the board and the arrowhead's own direction (not the tail's shape) determines the exit direction.

**Acceptance Scenarios**:

1. **Given** an active arrow whose tail runs straight behind its head, **When** the path from the head to the board edge in the head's direction contains no other active arrow's cell, **Then** selecting the arrow removes every cell of its shape from the board at once.
2. **Given** an active arrow whose tail bends at one or more right angles before reaching its head, **When** its path ahead is clear, **Then** selecting it removes the entire bent shape, and the direction it exits in matches its arrowhead regardless of how the tail bends.
3. **Given** a puzzle containing arrows pointing up, down, left, and right, **When** each is selected with a clear forward path, **Then** each correctly exits toward the edge matching its own arrowhead direction.
4. **Given** an arrow occupying a single cell (no tail), **When** its path ahead is clear, **Then** it behaves exactly as in the prior single-cell puzzle.

### User Story 2 - Tails Block and Unblock Other Arrows (Priority: P1) ✅ Complete

As a player, I can see that an arrow's tail — not only its head — stops another arrow from moving, and that removing the blocking arrow opens up the path for the one it was blocking.

**Why this priority**: Tails participating in blocking, and arrows becoming removable only after another is cleared, is the mechanical core of the requested feature and must work before the puzzle can be considered representative.

**Independent Test**: Attempt to select an arrow whose forward path runs through another arrow's tail cell (not its head) and confirm it is blocked; then remove the blocking arrow and confirm the previously blocked arrow can now be removed.

**Acceptance Scenarios**:

1. **Given** an active arrow whose forward path toward the board edge passes through any occupied cell of another active arrow — whether that cell is the other arrow's head or any tail cell — **When** it is selected, **Then** the selection is blocked exactly as the existing blocked-selection behavior specifies: the arrow remains active and in place, visible feedback plays, the mistake counter increments once, and the player may immediately continue.
2. **Given** an arrow blocked only by another arrow's tail cell (its head is not in the path), **When** the blocking arrow is selected and successfully removed, **Then** the previously blocked arrow's path is re-evaluated as clear on its next selection, with no other change to its position or direction.
3. **Given** an arrow blocked by another arrow's head, **When** that blocking arrow is removed, **Then** the previously blocked arrow becomes selectable under the same rule as a tail-caused block.
4. **Given** two arrows whose shapes do not intersect the same forward path, **When** either is selected, **Then** the other's presence never affects the outcome, matching the existing off-axis/behind non-blocking guarantee.

### User Story 3 - Prove the Puzzle Is Solvable Before It Ships (Priority: P2) ✅ Complete

As the person responsible for the puzzle definition, I can run an automated, presentation-independent analysis that either produces one complete valid removal order clearing the whole board, or reports that no such order exists, so a broken puzzle can never reach players undetected.

**Why this priority**: This is the correctness backbone behind the visible puzzle, but it is a build-time/verification concern rather than something a player directly interacts with during a session, so it follows the player-facing mechanics in priority.

**Independent Test**: Run the solvability analysis against the shipped puzzle definition in isolation (no scene, input, or animation dependency) and confirm it returns a witness sequence; separately run it against a deliberately unsolvable puzzle definition and confirm it reports no complete solution.

**Acceptance Scenarios**:

1. **Given** a puzzle definition, **When** the solvability analysis runs, **Then** it determines, without depending on scenes, input, animation, or any other presentation concern, whether at least one sequence of legal arrow removals clears every arrow.
2. **Given** a solvable puzzle definition, **When** the analysis runs, **Then** it returns at least one complete sequence of legal removals (a witness solution) that, when executed in order against the rule layer, removes every arrow with no blocked step.
3. **Given** an unsolvable puzzle definition, **When** the analysis runs, **Then** it reports that no complete solution exists, without returning a partial or invalid sequence as if it were a witness.
4. **Given** the puzzle definition shipped for gameplay, **When** automated verification runs, **Then** it confirms that definition is solvable and that the produced witness sequence, executed against the rule layer, actually clears the board.

### User Story 4 - Retain Structural Counts for Future Difficulty Work (Priority: P3) ✅ Complete

As the person planning future puzzle-difficulty work, I want the solvability analysis to keep a record of basic structural facts it already encounters — how many legal choices came up, and which states were forced versus branching — so a later feature can build on this data without redesigning the analysis result.

**Why this priority**: This is a forward-looking foundation, not a requirement for the current puzzle to be playable or provably solvable, so it is the lowest priority story and can be validated independently of the others.

**Independent Test**: Run the solvability analysis against the shipped puzzle definition and confirm the returned result includes counts of active choices encountered, legal choices encountered, forced states, and branching states, with no difficulty score, level, or Easy/Medium/Hard label present anywhere in the result.

**Acceptance Scenarios**:

1. **Given** the solvability analysis has run to completion, **When** its result is inspected, **Then** it includes a count of active choices encountered, a count of legal choices encountered, a count of forced states (exactly one legal move available), and a count of branching states (more than one legal move available).
2. **Given** the same analysis result, **When** its structure is inspected, **Then** it contains no difficulty score, difficulty level, or Easy/Medium/Hard classification.
3. **Given** the analysis result's contract, **When** a future feature needs to add a new descriptive metric, **Then** the result is structured so that addition does not require changing or breaking its existing fields (solvability outcome, witness sequence, and the structural counts above).

### Edge Cases

- An arrow with no tail (a single occupied cell) must behave exactly as the original single-cell arrows did — no regression for the degenerate case.
- A tail may bend more than once; the representation must not assume at most one turn.
- Two arrows' shapes may never occupy the same cell; a puzzle definition that would create such an overlap is invalid and must be rejected by validation, not silently tolerated at runtime.
- An arrowhead facing directly at the board edge with no cells ahead (including no tail cells of its own in the way) is always immediately clear.
- An arrow's own head and tail cells never block that same arrow's own movement; valid geometry never requires resolving a conflict here, because no arrow's tail may legally occupy its own forward escape ray (FR-001) — a tail whose turns would place one of its own cells ahead of its head, along its direction of travel, makes the puzzle definition invalid rather than a self-blocking special case.
- A tail's first cell must be immediately behind the arrowhead, opposite its direction of travel, representing the body trailing the head; it may then run straight or turn at any number of right angles, but consecutive tail cells must be orthogonally adjacent with no diagonal links, gaps, branches, or disconnected segments.
- Every arrow's head and tail cells must fall within the puzzle's fixed board dimensions; any out-of-bounds cell makes the puzzle definition invalid.
- Different arrows' cells may be orthogonally adjacent to each other freely; adjacency alone carries no gameplay meaning — only cell overlap (FR-002) and forward-escape-ray occupancy (FR-004) are meaningful.
- A puzzle where every remaining arrow is mutually blocking (no legal move exists) mid-sequence must be distinguishable, during analysis, from a puzzle where a legal move exists but has not yet been tried — this is exactly the forced/branching/no-move distinction the analysis must make.
- A deliberately unsolvable test puzzle definition (used only for verifying the analysis itself, never shipped for play) must produce a clean "no complete solution" report rather than an error, timeout, or partial result presented as success.
- The shipped puzzle must have at least one arrow of each cardinal direction, at least one straight tail, at least one right-angle tail, at least one instance of a tail blocking another arrow, and at least one arrow that becomes removable only after another arrow is removed — all as literal edge-case content within its own layout.

## Requirements

For ArrowGame, include affected keyboard/gamepad navigation, remapping, and saved
progress/settings compatibility in requirements and acceptance scenarios where relevant.
Gameplay acceptance must cover Godot validation and affected-gameplay smoke tests;
automated tests remain selective but are required for solvability verification specifically.

### Functional Requirements

- **FR-001**: An arrow MUST be representable as a connected shape: exactly one arrowhead cell plus zero or more ordered tail cells. The tail's first cell, when present, MUST be the cell immediately behind the arrowhead, opposite the arrowhead's direction of travel — the tail represents the body trailing the head, not an extension in any other direction from it. Each subsequent tail cell MUST be orthogonally adjacent to (share an edge with) the immediately preceding cell in the path, so that the head plus its ordered tail cells form one continuous, non-branching path with no diagonal connections, gaps, or disconnected segments. Consecutive path segments run straight or turn at a right angle, and the representation MUST support more than one right-angle turn in a single tail. No cell of an arrow's own tail MAY lie on that same arrow's own forward escape ray (the cells strictly between its arrowhead and the board edge along its direction of travel); a puzzle definition whose geometry would place a tail cell there MUST be treated as invalid.
- **FR-002**: Every cell occupied by any arrow's head or tail MUST belong to exactly one arrow and MUST lie within the puzzle's fixed board dimensions. A puzzle definition in which two arrows' shapes would occupy the same cell, or in which any arrow cell falls outside the board, MUST be treated as invalid. Different arrows' cells MAY be orthogonally adjacent to one another without restriction; adjacency alone has no gameplay meaning.
- **FR-003**: An arrow's direction of travel MUST be determined solely by its arrowhead. Tail geometry (straight or any number of right-angle turns) MUST NOT alter the direction in which the arrow exits when removed.
- **FR-004**: An arrow MUST be legally removable if and only if every cell strictly between its arrowhead and the board edge, along its direction of travel (its forward escape ray), is free of any occupied cell belonging to another active arrow. Both head cells and tail cells of other arrows MUST count as occupied for this check. An arrow's own head cell and every one of its own tail cells MUST NOT count as blocking against itself; per FR-001, no arrow's own tail can legally occupy its own forward escape ray in a valid puzzle definition, so this exclusion is a self-ownership rule and never needs to resolve a self-blocking conflict at runtime.
- **FR-005**: A legal removal MUST remove every cell of that arrow's entire shape from the board in the same accepted selection; no partial removal of a shape (e.g., tail remaining after head departs) is permitted.
- **FR-006**: A blocked selection MUST preserve the existing blocked-selection contract unchanged: the arrow remains active and in its position, a visible non-blocking feedback cue plays, the mistake counter increments exactly once, and the player MAY continue selecting without restriction, including unlimited repeated blocked selections.
- **FR-007**: The system MUST define solvability as a property of a puzzle definition: a puzzle is solvable when at least one sequence of legal arrow removals, applied in order under FR-004/FR-005, results in every arrow being removed.
- **FR-008**: The system MUST provide a rule-core solvability analysis capability that determines whether a given puzzle definition is solvable, implemented without any dependency on scenes, rendering, input handling, or animation.
- **FR-009**: For a solvable puzzle definition, the analysis MUST return at least one complete sequence of legal removals (a witness solution) that clears every arrow when executed in order against the rule layer.
- **FR-010**: For an unsolvable puzzle definition, the analysis MUST report that no complete solution exists, and MUST NOT return a partial sequence, an error, or an ambiguous result in place of that report.
- **FR-011**: The puzzle definition shipped for gameplay MUST have automated verification confirming it is solvable via the analysis in FR-008/FR-009, and confirming the returned witness sequence actually clears the board when executed.
- **FR-012**: The solvability analysis result MUST be structured so that additional descriptive metrics can be added later without changing the meaning or presence of its existing fields (solvability outcome and, when solvable, the witness sequence).
- **FR-013**: The analysis result MUST retain a count of active choices encountered (the number of remaining arrows considered at each non-terminal state visited), a count of legal choices encountered (the number of legal moves available at each non-terminal state visited), a count of forced states (states with exactly one legal move), and a count of branching states (states with more than one legal move). These counts are produced during the same single traversal the solvability search already performs. The result MUST NOT include a difficulty score, difficulty level, or Easy/Medium/Hard classification.
- **FR-014**: The analysis MUST NOT be required to enumerate every possible complete solution; finding and returning one witness (or determining that none exists) satisfies solvability verification unless later analysis during planning demonstrates exhaustive enumeration is necessary for correctness.
- **FR-015**: The handcrafted puzzle definition shipped for gameplay MUST replace or adapt the prior puzzle and MUST demonstrate, within its own layout: multi-cell arrows, at least one straight tail, at least one right-angle tail, at least one case of a tail blocking another arrow, at least one arrow that becomes removable only after another arrow is removed, and all four arrowhead directions. This puzzle MUST have a verified witness solution per FR-011.
- **FR-016**: The existing scoring formula (`score = max(total arrows - mistakes, 0)`), accuracy formula, unlimited-mistakes behavior, live HUD counters, completion/results presentation, Replay behavior, Main Menu integration, rule/presentation separation, and existing regression-test philosophy MUST remain unchanged by this feature. "Total arrows" and "successful removals" MUST continue to count per arrow (one count per arrow removed), not per occupied cell, regardless of how many cells that arrow's shape spans.

### Key Entities

- **Arrow shape**: An arrowhead cell, a direction, and an ordered tail-cell path (possibly empty). When non-empty, the tail's first cell is immediately behind the head, opposite the direction of travel, and each subsequent cell is orthogonally adjacent to the previous one, forming one continuous, non-branching path with no diagonal connections, gaps, or branches; each path segment continues straight or turns at a right angle, and no tail cell ever lies on the head's own forward escape ray.
- **Puzzle definition**: A fixed board size and a set of arrow shapes such that every occupied cell belongs to exactly one arrow; extends the prior single-cell puzzle definition as a superset.
- **Puzzle attempt**: Unchanged from the prior specification — active arrows, successful removals, mistakes, accepted taps, and completion state — now operating over multi-cell arrow shapes instead of single cells.
- **Solvability analysis result**: A presentation-independent outcome for a puzzle definition: whether it is solvable, a witness removal sequence when solvable, and structural counts of active choices encountered, legal choices encountered, forced states, and branching states — structured to allow additional fields later without breaking existing ones.

### Assumptions

- Selecting any cell that belongs to a multi-cell arrow (head or any tail cell) selects that whole arrow, consistent with treating the arrow's shape as one indivisible unit for both blocking and selection.
- "Total arrows" and "successful removals" continue to be counted per arrow, not per cell, so the existing scoring and accuracy formulas need no change in meaning for multi-cell arrows.
- The solvability analysis is a build-time/verification-time capability exercised by automated tests against shipped puzzle definitions; it is not required to run interactively during play.
- A puzzle definition that is invalid under FR-002 (overlapping cells) is a defect to be caught by validation/verification, not a state the runtime needs to recover from during play.
- No context sources were skipped; no prior specification conflicts with this feature's direction.

### Out of Scope

- Procedural or randomized puzzle generation, and any additional puzzles or levels beyond the single shipped puzzle definition.
- Any difficulty score, difficulty level, or Easy/Medium/Hard classification.
- Progression, persistence, achievements, Android-specific functionality, and advertisements or monetization.
- Any change to the scoring model, accuracy formula, or unlimited-mistakes behavior.
- Exhaustive enumeration of every possible solution, unless planning-stage analysis demonstrates it is necessary for solvability verification itself.

### Required Verification

- Validate affected scripts/scenes in Godot and smoke-test the actual desktop launch/start/play/completion/replay journey using the new puzzle definition.
- Add automated rule-layer tests covering: multi-cell removal atomicity (entire shape leaves at once), tail-as-blocker and head-as-blocker equivalence in all four directions, straight and multi-turn tail geometry, an arrow's own tail never self-blocking, and the existing blocked-selection contract (feedback, mistake increment, continued play) under multi-cell arrows.
- Add an automated test that runs the solvability analysis against the shipped puzzle definition, asserts it reports solvable, and executes the returned witness sequence against the rule layer to confirm it fully clears the board.
- Add at least one automated test against a deliberately unsolvable puzzle definition confirming the analysis reports no complete solution, to guard against a false-positive solvability result.
- Add or extend automated tests confirming score/accuracy formulas, unlimited-mistakes behavior, HUD layout, Replay reset, and Main Menu no-reset integration are unchanged with multi-cell arrows in play.
- Record checks performed and their results; if a required check cannot be run, disclose that limitation explicitly rather than claim completion.

## Success Criteria

### Measurable Outcomes

- **SC-001**: A player can complete the shipped puzzle end to end using only legal removals, including at least one straight-tailed arrow, one right-angle-tailed arrow, and all four arrowhead directions.
- **SC-002**: In verification testing, every case in a blocking matrix that includes both head-caused and tail-caused blocks, across all four directions and both straight and bent tails, yields the correct blocked/clear result with no false clears or false blocks.
- **SC-003**: Automated verification produces a witness solution for the shipped puzzle and, executing that exact sequence against the rule layer, clears 100% of the board's arrows with zero blocked steps.
- **SC-004**: Automated verification against at least one deliberately unsolvable puzzle definition correctly reports no complete solution, with zero false-positive solvability determinations across the verification suite.
- **SC-005**: Existing scoring, accuracy, unlimited-mistakes, HUD, completion, Replay, and Main Menu behaviors produce identical results to the prior specification's verified formulas and flows when exercised against the new multi-cell puzzle.
- **SC-006**: The solvability analysis result for the shipped puzzle includes non-negative counts of active choices encountered, legal choices encountered, forced states, and branching states, and contains no difficulty score, level, or classification field.
