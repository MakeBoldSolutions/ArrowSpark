---
source: "BSW.DevSpark — © 2026 Baylor Scott & White Health. Source: https://bsw-devspark.bswhive.com"
classification: full-spec
risk_level: medium
target_workflow: specify-full
required_artifacts: spec, plan, tasks
recommended_next_step: plan
required_gates: checklist, analyze, critic, verify:end-to-end # end-to-end added: the puzzle must be proven through the real play/results/next-puzzle flow plus human playtest
route_intent: full-spec
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

# Feature Specification: The ArrowSpark Reference Puzzle and Level Groups

**Feature Branch**: `010-spec-reference-puzzle`
**Created**: 2026-09-29
**Status**: Draft <!-- Valid: Draft | In Progress | Complete -->
**Input**: User description: "Spec 010 — The ArrowSpark Reference Puzzle: craft one deliberately composed knot level that combines the best Spec 006/009 lessons, iterate it through human playtesting, and organize the puzzle catalog into purpose-based groups (Foundations, Puzzle Lab / Experiments, ArrowSpark Levels)."

> **Lifecycle note**: This spec is temporary working state under `.devspark.work/specs/`. It remains there until release archival and MUST NOT be referenced by durable code, tests, or `.knowledge/`.

## Product Owner TLDR

Specs 001–009 gave ArrowSpark a working game, a scoring/assist contract, a zoomable large canvas and a toolbox of knot ingredients, but no single level that shows what the game is *supposed* to feel like. This spec delivers exactly one hand-crafted, human-iterated **Reference Puzzle**: a readable knot with several distinct "aha" moments, partly-solvable regions that depend on each other, a few bridge arrows that visibly unwind, and a satisfying collapse instead of tedious cleanup. It also introduces lightweight **level groups** (Foundations, Puzzle Lab, ArrowSpark Levels) so the Reference Puzzle is not lost among 21 research puzzles. The spec is only finished when a human playtester genuinely wants to hand this level to someone else; green automated checks alone do not complete it.

## Clarifications

### Session 2026-09-29

- Q: Where should the large-canvas validation puzzle belong? → A: Puzzle Lab — treat it as an experimental validation board.
- Q: What should happen at the end of a group? → A: Advance within the group; at its end, offer Level Select instead of Next Puzzle.
- Q: Where should the main-menu Play button take players? → A: Start the Reference Puzzle in ArrowSpark Levels.
- Q: How should puzzles be numbered in menus and gameplay? → A: Restart numbering at 1 within each group; stable puzzle IDs remain unchanged.
- Q: How should the fifteen required playtest questions be defined? → A: Draft fifteen questions from this spec's existing experience goals and acceptance criteria.

## Rationale Summary

### Core Problem

The catalog holds 21 puzzles created for different reasons (mechanic validation, structural research, large-canvas validation, Gordian-knot ingredient experiments) presented as one flat, equal-weight sequence. None was designed against the mature ArrowSpark experience, and Spec 009 showed we have ingredients (long/bent arrows, regions, long-distance blockers, tail dependencies, releases) but have not shown we can *compose* them into one excellent level.

### Decision Summary

Hand-craft one level through an author → validate → measure → play → revise loop, using human play as primary evidence and analyzer metrics only as diagnostics. Add metadata-only grouping so mature levels are distinguishable from foundations and experiments, without changing any gameplay rule.

### Key Drivers

- Constitution Principle V: gameplay/menu changes require Godot validation, a smoke test, and recorded results or disclosed limitations.
- Spec 009 lesson: density should come from meaningful geometry, not object count; the spaghetti boundary is a warning, not a target.
- No new mechanics, no scripted solution, no generator/builder: sequencing must emerge from the existing blocking/removal rules.
- Grouping must be metadata, not gameplay state, and must not imply a quality ranking.

### Source Inputs

- Spec 006 (structural analysis), 007 (Open Move/scoring), 008 (large zoomable canvas), 009 (Gordian-knot experiments) and their durable knowledge in `.knowledge/`.
- Existing `PuzzleCatalog` (21 entries with stable ids), `PuzzleAnalyzer`, `PuzzleSolver`, `PuzzleScoreboard`, `PuzzleSession`, and the puzzle Level Select menu.
- The user's Spec 010 brief and its "Level Groups and Catalog Organization" addendum (this spec's scope authority).

### External Contracts

None. No cross-repo dependencies.

### Tradeoffs Considered

- Option A: several polished levels (a small pack). Not chosen: explicitly out of scope; one excellent level must be proven first.
- Option B: procedurally generate/search for a "good" level. Not chosen: we do not yet know enough to define "good"; craftsmanship comes before grammar.
- Option C: hide experiments from the game entirely. Not chosen: they remain valuable research and regression content.
- Selected: one hand-authored level plus metadata-only groups, because it proves the design rhythm and organizes content at minimal cost.

### Architectural Impact

- One new catalog entry with a stable id; no changes to blocking rules, solver, analyzer, scoring, Open Move or viewport behavior.
- Catalog gains a purpose-group classification per entry (metadata). Existing ids, titles and definitions are preserved and not duplicated.
- Level Select presents entries by group; no new persistence and no save-data change.
- Neighborhood, Discovery Beat, Insight Chain, Major Release are design/analysis vocabulary only and MUST NOT become gameplay state.

### Reviewer Guidance

Focus on (1) whether the playtest evidence honestly supports the "level I want someone else to play" claim, (2) that group membership was decided by original purpose and current role rather than puzzle number, (3) that no gameplay-contract regression slipped in, and (4) that the design report records observations unedited.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Play the Reference Puzzle and feel the rhythm (Priority: P1)

A player opens the ArrowSpark Levels group, starts the Reference Puzzle and sees an intriguing but readable knot. They pick a foothold, make local progress, get stuck on a stubborn arrow, trace its blocker to a distant region, discover the relationship, chain several removals, watch a long arrow unwind and the board visibly breathe, then have to stop and think again. This repeats a few times until the remaining structure is understood and collapses satisfyingly.

**Why this priority**: This is the whole point of the spec; without it nothing else has value.

**Independent Test**: A human plays the final candidate start to finish and answers the required playtest questions in the design report; automated checks confirm it loads, is solvable and completes through Results.

**Required playtest questionnaire**: The following fifteen questions are derived from this spec's experience goals and acceptance criteria and are the authoritative questionnaire for FR-013 and SC-006. They are not a reconstruction of the unavailable original brief. Record the session date, candidate version, tester, prior familiarity, input method, and any Open Move use alongside the tester's unedited answers. Ask after play so the questions do not reveal the intended discoveries. Missing or negative observations must be recorded honestly, not inferred from the intended design.

1. What was your first impression of the full board, and where did you see possible starting moves?
2. Could you trace individual arrows throughout play? Describe any ambiguous geometry and whether zoom, pan or Fit Puzzle helped.
3. Which distinct neighborhoods did you perceive, and what made them feel separate?
4. Which neighborhood, if any, could you substantially clear but not finish until you resolved something elsewhere? Describe that dependency.
5. Where did a distant arrow or its tail block your progress, and how did you discover the connection?
6. What distinct "aha" moments did you experience? Describe each and where it occurred, even if there were fewer than three.
7. Which discovery, if any, let you anticipate several upcoming removals, and did those consequences happen as expected?
8. After a chain of removals, where did you have to stop and rethink? Describe each such point, even if there were fewer than two.
9. Where did you feel free to choose among useful moves, and where did the order feel rigid or forced?
10. Which arrow, if any, seemed to connect or hold together separate areas? Describe what changed visually when it departed.
11. Did any stretch feel like following an obvious sequence for too long? Identify it and describe why.
12. Did any stretch require a full-board rescan after every move? Identify it and describe what made progress hard to follow.
13. How did the final portion feel: a satisfying collapse, tedious cleanup, or something else? Describe the remaining work.
14. Where did the experience become confusing, frustrating or less engaging, and what would you most want changed?
15. Is this a level you want someone else to play? Why or why not?

Questions 1–15 define the required observation categories for meaningful iterations. The final candidate requires an explicit written answer to every question. The separate first-time Level Select observation in SC-009 remains required and must not be inferred from this questionnaire.

**Acceptance Scenarios**:

1. **Given** the Reference Puzzle at 100% remaining, **When** the player views it, **Then** it reads as a knot with several understandable footholds, and the player can trace individual arrows (with zoom/pan/Fit Puzzle available) without being unable to tell which cells belong to which arrow.
2. **Given** a region the player has largely cleared, **When** two or more stubborn arrows remain, **Then** at least one is blocked by geometry (including a tail) originating in another region, so finishing the first region requires understanding the second.
3. **Given** the player discovers such a relationship, **When** they execute the resulting removals, **Then** they can anticipate several consequences in advance and see that understanding validated, after which the changed board poses a new question rather than an obvious remaining sequence.
4. **Given** a bridge arrow is finally removable, **When** the player removes it, **Then** its path-following departure unwinds from the knot and a substantial amount of visual mass leaves the board.
5. **Given** the final conceptual barrier is solved, **When** the player continues, **Then** the remainder collapses without a prolonged tail of trivial single-cell cleanup.

---

### User Story 2 - Find mature levels separately from foundations and experiments (Priority: P1)

A player or developer opens Level Select and sees puzzles organized by purpose: ArrowSpark Levels (mature, player-facing), Foundations (early mechanic/validation puzzles) and Puzzle Lab (research experiments). Every existing puzzle remains reachable and playable with its original id.

**Why this priority**: The Reference Puzzle would be buried in a flat list of 22 items; grouping is required for the level to serve as "the first ArrowSpark level".

**Independent Test**: Open Level Select; verify each group lists its members, each entry launches the correct puzzle, and existing puzzle ids resolve unchanged.

**Acceptance Scenarios**:

1. **Given** Level Select, **When** it opens, **Then** the three groups are distinguishable and the Reference Puzzle appears only under ArrowSpark Levels.
2. **Given** any pre-existing puzzle, **When** selected from its group, **Then** it launches the same definition it did before this spec, with the same stable id.
3. **Given** keyboard or gamepad navigation, **When** the player moves through groups and entries, **Then** every entry remains reachable and focus behaves consistently with the current menu.
4. **Given** the main menu, **When** the player chooses Play, **Then** the Reference Puzzle in ArrowSpark Levels starts directly.

---

### User Story 3 - Durable design report and honest playtest record (Priority: P2)

A future designer reads a durable Reference Puzzle design report describing intent (neighborhoods, cross-region dependencies, bridge arrows, discovery beats, insight chains, major releases, experience curve), the iteration history, unedited human playtest observations, where play diverged from intent, which Spec 006/009 concepts helped or disappointed, remaining weaknesses, and candidate design principles.

**Why this priority**: Captures the craft knowledge that a later "design grammar" spec will need; lower priority than the playable result.

**Independent Test**: Review the report against the 14 required documentation items and confirm playtest sections contain real, dated observations rather than reconstructed ones.

**Acceptance Scenarios**:

1. **Given** the final report, **When** reviewed, **Then** all required documentation items are present, playtest observations are attributed to actual sessions, and divergences between intent and actual play are stated rather than smoothed over.
2. **Given** the candidate design principles section, **When** read, **Then** each principle is framed as supported-by-this-level, not universal, and no generator or scoring formula is proposed.

---

### User Story 4 - Existing gameplay contracts are untouched (Priority: P2)

Everything that worked before still works, including for the new puzzle: Open Move, scoring, session bests, replay, Next Puzzle/Level Select navigation, zoom/pan/Fit Puzzle, transformed selection and path-following departures.

**Why this priority**: The level and grouping must be additive.

**Independent Test**: Run both required regression suites plus Godot 4.4 validation and a desktop smoke test of the new level and Level Select.

**Acceptance Scenarios**:

1. **Given** the new puzzle, **When** solved through normal play and via Open Move, **Then** it completes exactly once, reaches Results, scores correctly and updates session-best correctly.
2. **Given** Results for any puzzle, **When** Replay is chosen, **Then** the same puzzle restarts; when another puzzle remains in its group, Next Puzzle starts that entry; at the end of the group, Level Select is offered instead of Next Puzzle.

---

### Edge Cases

- A puzzle's group is changed later: ids, definitions and gameplay behavior must be unaffected because grouping is metadata only.
- At the end of any group, including a group containing only the Reference Puzzle, Results MUST offer Level Select instead of Next Puzzle; progression MUST NOT cross into another group or wrap to the group's first entry.
- The new level's board exceeds the window: zoom/pan/Fit Puzzle must make the geometry readable at a comfortable arrow size without being a workaround for illegible geometry.
- A candidate iteration validates and solves but fails the human bar: it must not be marked PASS; the spec records why the bar is not yet met and iterates again.
- Legacy content with no obvious single purpose must be classified by role and recorded; the large-canvas validation puzzle belongs to Puzzle Lab as an experimental validation board.
- Path-following departure of very long or multi-bend arrows in a dense board must still complete and leave the logical removal contract unchanged.
- A player takes an unintended order of legal moves: the level must remain solvable from every reachable state (existing monotonic contract).

## Requirements *(mandatory)*

### Functional Requirements

> Each `FR-###` is a stable traceability anchor for `tasks.md` (`Implements: FR-###`).

**Reference Puzzle — design**

- **FR-001**: The catalog MUST gain exactly one Reference Puzzle with a stable id and title; iteration versions (v1, v2, …) MUST NOT become permanent catalog entries.
- **FR-002**: The puzzle MUST be built from a meaningful mixture of long, medium, bent, multi-bend and simple arrows, using single-cell arrows only intentionally (punctuation, small blockers, transitions, breathing room, occasional cleanup) and not as filler.
- **FR-003**: The puzzle MUST contain multiple implicit neighborhoods emerging from geometry, whitespace, clustering and path direction, with no boundaries, labels, UI or gameplay state representing them.
- **FR-004**: At least some neighborhoods MUST be substantially progressable from the start but not initially completable.
- **FR-005**: Cross-neighborhood dependencies (including tail-based blocking) MUST matter to the solve, expressed as a partial ordering with real local freedom rather than one rigid region-by-region sequence.
- **FR-006**: The puzzle MUST include at least one Bridge Arrow whose geometry or blocking role connects multiple neighborhoods and whose removal produces a major visual release.
- **FR-007**: The puzzle MUST offer multiple distinct Discovery Beats separated by renewed uncertainty, and MUST NOT collapse into a single early aha followed by an obvious A-to-Z execution sequence, nor demand a full rescan after every removal.
- **FR-008**: Geometry MUST remain readable: individual arrows must be traceable at a zoom level the viewport supports, avoiding the Spec 009 spaghetti boundary.
- **FR-009**: The endgame MUST avoid a prolonged residue of trivial cleanup; the last portion should reward understanding with a satisfying collapse.
- **FR-010**: All sequencing MUST emerge from the existing blocking/removal rules; the spec MUST NOT introduce new mechanics (locks, keys, doors, colored regions, neighborhood markers, power-ups, lives, timers, forced restarts, new hint systems, combo multipliers, scripted unlocking) or encode an intended solution order in runtime behavior.

**Reference Puzzle — process and evidence**

- **FR-011**: The puzzle MUST be developed through repeated author → validate → measure → play → revise cycles, with important iteration decisions (what felt wrong, what changed, why, what happened) recorded in development documentation.
- **FR-012**: Each serious candidate MUST be run through the existing analyzer and structural reporting, capturing existing measurements (dimensions, arrow count, occupied cells, occupancy, dependency edges/depth, initial legal moves, forced moves, blocker distance, arrow length and bend characteristics) purely as diagnostics; no quality, fun, difficulty or entanglement score may be created.
- **FR-013**: Human playtesting MUST be performed and recorded for meaningful iterations using the observation categories defined by the required playtest questionnaire in User Story 1, with no fabricated observations; the final candidate MUST have explicit written answers to all fifteen questions, with session context and unedited answers preserved.
- **FR-014**: The solver witness MUST be used for correctness and diagnostics only; the level MUST NOT be tuned merely to make the witness look attractive.
- **FR-015**: A durable Reference Puzzle design report MUST document the fourteen required items (structural profile, intended neighborhoods, cross-neighborhood dependencies, bridge arrows, expected discovery beats, insight chains, major releases, intended experience curve, iteration history, human observations, intent-versus-actual differences, useful Spec 006/009 concepts, less useful concepts, remaining weaknesses) and MAY list candidate design principles labeled as level-specific evidence, not universal formulas.
- **FR-016**: The spec MUST NOT be marked complete unless the final human assessment supports "This is a level I want someone else to play"; if it does not, the report MUST state why and iteration continues.

**Reference Puzzle — correctness and contracts**

- **FR-017**: The final puzzle MUST pass definition validation, be solver-confirmed solvable, produce a valid witness that replays successfully, and remain solvable from every reachable state.
- **FR-018**: The puzzle MUST work through normal play and Open Move, complete exactly once, reach Results, preserve scoring and session-best behavior, and support Replay and Next Puzzle/Level Select.
- **FR-019**: The puzzle MUST work with zoom, pan, Fit Puzzle and transformed selection, and MUST preserve path-following departures without altering the logical-removal contract.
- **FR-020**: No persistent gameplay state, cross-session score, account, identity or telemetry MAY be introduced; existing saved progress and settings MUST be preserved.
- **FR-021**: All existing catalog puzzles MUST remain valid and both required regression suites MUST stay green.

**Level groups and catalog organization**

- **FR-022**: The catalog MUST assign every entry to exactly one purpose group, at minimum equivalent to Foundations, Puzzle Lab / Experiments and ArrowSpark Levels; final group names are to be settled during planning.
- **FR-023**: Group membership MUST be decided by reviewing each existing entry's original purpose and current gameplay role, not by puzzle number, and the resulting classification MUST be recorded in the design report. The large-canvas validation puzzle MUST belong to Puzzle Lab as an experimental validation board.
- **FR-024**: Stable puzzle ids MUST be preserved and no puzzle definition may be duplicated to place it in a group.
- **FR-025**: Level Select MUST make the three groups understandable using the simplest approach consistent with the existing menu (for example grouped sections), without a major UI redesign, and MUST remain keyboard/gamepad navigable.
- **FR-026**: The Reference Puzzle MUST be the first entry designed for and placed in ArrowSpark Levels.
- **FR-027**: Grouping MUST be metadata only and MUST NOT affect blocking rules, solvability, scoring, Open Move, puzzle state, solver, analyzer or viewport behavior; no separate gameplay engines per group.
- **FR-028**: Group presentation and documentation MUST NOT imply a quality ranking; Foundations and Puzzle Lab describe why content exists, and ArrowSpark Levels membership means "designed against the current player-experience standard," not a universal quality score.
- **FR-029**: The implementation MUST NOT include a content-management system or any generator, builder, difficulty formula or automatic quality scoring.
- **FR-031**: Next Puzzle MUST advance only within the current group. At the group's final entry, Results MUST offer Level Select instead of Next Puzzle, without crossing groups or wrapping; Replay MUST remain available.
- **FR-032**: The main-menu Play action MUST start the Reference Puzzle in ArrowSpark Levels directly. All other puzzles MUST remain accessible through Level Select.
- **FR-033**: Puzzle display numbering in menus and gameplay MUST restart at 1 within each group, following within-group progression order. The Reference Puzzle MUST display as level 1 in ArrowSpark Levels. Display numbering MUST NOT change stable puzzle IDs.

**Verification**

- **FR-030**: Verification MUST include Godot 4.4 project validation, both headless regression gates, extended catalog checks covering the new entry and group assignments, and a desktop smoke test of Level Select and the Reference Puzzle (including Open Move, zoom/pan/Fit Puzzle, Results, Replay and Next Puzzle); any check that cannot be run MUST be disclosed as an outstanding limitation.

### Key Entities *(include if feature involves data)*

- **Reference Puzzle**: The single authored knot level; has a stable id, title and the group ArrowSpark Levels.
- **Puzzle Group**: A purpose label (Foundations, Puzzle Lab / Experiments, ArrowSpark Levels) attached to a catalog entry as metadata; owns no gameplay behavior.
- **Design Report**: Durable document capturing structural profile, design intent, iteration history and honest playtest evidence.
- **Playtest Observation**: A dated, first-hand record of a human session against the required observation categories.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The final Reference Puzzle is validated, solver-confirmed solvable, and its witness replays to completion; 100% of both required regression suites pass and Godot 4.4 validation reports no errors.
- **SC-002**: In the final human playtest, the player reports at least three distinct "aha" moments, at least one of which let them anticipate several upcoming consequences, and identifies at least two points where they had to stop and rethink after a chain of removals.
- **SC-003**: In the final playtest, the player names at least one neighborhood that was substantially progressed yet not completable until a dependency from another neighborhood was resolved.
- **SC-004**: The player can identify and remove at least one bridge arrow and describe it as connecting or holding together separate areas; its removal is recorded as a visible simplification.
- **SC-005**: The final playtest records no section where the player felt they were following an obvious sequence for too long, no section requiring a full rescan after every move, and no tedious cleanup at the end.
- **SC-006**: The final playtest answers all fifteen required questions in writing, including the closing question, and the answer supports handing the level to someone else; if not, the spec status stays below Complete.
- **SC-007**: The design report contains all fourteen required items, with playtest observations for every serious iteration that was played, and contains zero invented scores or formulas.
- **SC-008**: 22 of 22 catalog entries (21 existing plus the Reference Puzzle) belong to exactly one group, all existing puzzle ids resolve unchanged, and every entry is reachable from Level Select by keyboard/gamepad and pointer.
- **SC-009**: A first-time viewer of Level Select can find the mature level's group without guidance, confirmed by at least one person other than the author.

## Assumptions

- The existing analyzer, solver, scoreboard, session and viewport transform provide all the structure and measurement needed; no new metrics are required unless a specific authoring question demands one and it can be clearly defined.
- The Reference Puzzle lives in the same catalog and authoring style as existing puzzles; the large-canvas viewport (Spec 008) is available for boards larger than the window.
- The author (Mark) is the primary human playtester; additional playtesters are welcome and SC-009 needs at least one other person.
- The initial group classification proposed for planning: the eight baseline puzzles → Foundations; the six Spec 006 experiments and the six Spec 009 knot experiments → Puzzle Lab; the Reference Puzzle → ArrowSpark Levels. This is a starting point subject to the review in FR-023.
- Puzzle display numbering restarts at 1 within each group without changing stable puzzle IDs. Main-menu Play starts the Reference Puzzle in ArrowSpark Levels. Within-group progression preserves the existing relative catalog order; at the group's end, Results offers Level Select instead of Next Puzzle.
